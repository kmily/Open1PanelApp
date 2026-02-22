# 修复下载重试和分块下载问题 Spec

## Why
日志分析和源码审查发现三个关键问题：

1. **API 选择错误**：当前所有文件都使用 `GET /files/download`，但这个 API **不支持 Range 头**（源码 file.go 第546-562行使用 `http.ServeContent`，无 Range 处理）
2. **HTTP 416 错误**：当 flutter_downloader 尝试断点续传时，发送 Range 头，但 `/files/download` 不支持，返回 416
3. **旧时间戳问题**：`FlutterDownloader.retry()` 复用原始请求的 headers（旧时间戳），导致 1Panel API 认证失败

## 1Panel API 分析

| API | 方法 | Range 支持 | 用途 |
|-----|------|-----------|------|
| `/files/download` | GET | ❌ 不支持 | 小文件直接下载 |
| `/files/chunkdownload` | POST | ✅ 支持 | 大文件分块下载，支持断点续传 |

源码证据（file.go）：
- `GET /files/download` (第546-562行)：使用 `http.ServeContent`，无 Range 处理
- `POST /files/chunkdownload` (第573-639行)：处理 Range 请求，返回 206 Partial Content

## What Changes
- **BREAKING**: 根据文件大小选择正确的下载 API
  - 小文件（<50MB）：使用 `GET /files/download`，禁用断点续传
  - 大文件（≥50MB）：使用 `POST /files/chunkdownload`，支持断点续传
- 修改重试逻辑：不使用 `FlutterDownloader.retry()`，删除旧任务 + 创建新任务
- 每次下载请求都使用新的时间戳认证

## Impact
- Affected code:
  - `lib/features/files/files_provider.dart` (修改下载 API 选择逻辑)
  - `lib/core/services/transfer/transfer_manager.dart` (修改重试逻辑)
  - `lib/features/files/transfer_manager_page.dart` (UI 调用)

## ADDED Requirements

### Requirement: 根据文件大小选择下载 API
系统 SHALL 根据文件大小选择正确的下载 API。

#### Scenario: 小文件下载
- **WHEN** 文件大小 < 50MB
- **THEN** 系统应使用 `GET /files/download`
- **AND** 禁用断点续传（`resume: false`）

#### Scenario: 大文件下载
- **WHEN** 文件大小 ≥ 50MB
- **THEN** 系统应使用 `POST /files/chunkdownload`
- **AND** 支持断点续传

### Requirement: 重试下载时使用新时间戳
系统 SHALL 在重试下载时生成新的认证时间戳。

#### Scenario: 重试失败任务
- **WHEN** 用户点击重试按钮
- **THEN** 系统应删除旧任务并用新时间戳创建新任务

### Requirement: 处理已完成的下载
系统 SHALL 检测已完成的下载文件。

#### Scenario: 文件已完全下载
- **WHEN** 重试任务时发现文件已完全下载
- **THEN** 系统应删除任务记录并提示用户文件已存在

## REMOVED Requirements

### Requirement: 使用 FlutterDownloader.retry()
**Reason**: `retry()` 会使用旧的 headers（包含过期的时间戳），导致 1Panel API 认证失败
**Migration**: 使用 `remove()` + `enqueue()` 替代

### Requirement: 所有文件使用 /files/download
**Reason**: 该 API 不支持 Range 头，无法断点续传
**Migration**: 根据文件大小选择正确的 API

## Implementation Details

### 1. 修改 files_provider.dart 下载逻辑

```dart
/// 下载文件阈值：50MB
const int _chunkDownloadThreshold = 50 * 1024 * 1024;

Future<String?> downloadFile(FileInfo file) async {
  if (file.isDir) {
    throw Exception('cannot_download_directory');
  }

  final hasPermission = await _service.checkAndRequestStoragePermission();
  if (!hasPermission) {
    throw Exception('storage_permission_denied');
  }

  // 根据文件大小选择下载方式
  if (file.size >= _chunkDownloadThreshold) {
    // 大文件：使用分块下载 API（支持断点续传）
    return await _downloadWithChunkApi(file);
  } else {
    // 小文件：使用直接下载 API（不支持断点续传）
    return await _downloadWithDirectApi(file);
  }
}

/// 小文件直接下载（不支持断点续传）
Future<String?> _downloadWithDirectApi(FileInfo file) async {
  final config = await ApiConfigManager.getCurrentConfig();
  if (config == null) throw StateError('No server configured');

  final downloadDir = await getDownloadsDirectory();
  if (downloadDir == null) throw StateError('Cannot get download directory');

  final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
  final authToken = _generate1PanelAuthToken(config.apiKey, timestamp);

  // 使用 GET /files/download
  final downloadUrl = '${config.url}${ApiConstants.buildApiPath('/files/download')}?path=${Uri.encodeComponent(file.path)}';

  final taskId = await FlutterDownloader.enqueue(
    url: downloadUrl,
    savedDir: downloadDir.path,
    fileName: file.name,
    showNotification: true,
    openFileFromNotification: true,
    headers: {
      '1Panel-Token': authToken,
      '1Panel-Timestamp': timestamp,
    },
  );

  return taskId;
}

/// 大文件分块下载（支持断点续传）
Future<String?> _downloadWithChunkApi(FileInfo file) async {
  final config = await ApiConfigManager.getCurrentConfig();
  if (config == null) throw StateError('No server configured');

  final downloadDir = await getDownloadsDirectory();
  if (downloadDir == null) throw StateError('Cannot get download directory');

  final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
  final authToken = _generate1PanelAuthToken(config.apiKey, timestamp);

  // 使用 POST /files/chunkdownload
  // 注意：需要构造 POST 请求体
  final downloadUrl = '${config.url}${ApiConstants.buildApiPath('/files/chunkdownload')}';

  // flutter_downloader 不直接支持 POST 请求
  // 需要使用其他方式实现分块下载
  // TODO: 实现分块下载逻辑
}
```

### 2. 修改 TransferManager 重试逻辑

```dart
/// 重试下载任务（使用新时间戳）
Future<bool> retryDownloadTaskWithNewAuth(DownloadTask task) async {
  try {
    // 1. 检查文件是否已完全下载
    final file = File('${task.savedDir}/${task.filename}');
    if (await file.exists()) {
      final fileSize = await file.length();
      if (fileSize > 0) {
        // 文件已存在，删除任务
        await FlutterDownloader.remove(taskId: task.taskId);
        appLogger.iWithPackage('transfer', 'retryDownloadTaskWithNewAuth: 文件已存在，删除任务');
        return true;
      }
    }

    // 2. 删除旧任务
    await FlutterDownloader.remove(taskId: task.taskId);

    // 3. 从 URL 提取文件路径
    final uri = Uri.parse(task.url);
    final filePath = uri.queryParameters['path'];
    if (filePath == null) {
      appLogger.eWithPackage('transfer', 'retryDownloadTaskWithNewAuth: 无法从 URL 提取文件路径');
      return false;
    }

    // 4. 生成新的时间戳和认证
    final config = await ApiConfigManager.getCurrentConfig();
    if (config == null) return false;

    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
    final authToken = _generate1PanelAuthToken(config.apiKey, timestamp);

    // 5. 创建新任务
    final newTaskId = await FlutterDownloader.enqueue(
      url: task.url,
      savedDir: task.savedDir,
      fileName: task.filename,
      headers: {
        '1Panel-Token': authToken,
        '1Panel-Timestamp': timestamp,
      },
      showNotification: true,
      openFileFromNotification: true,
    );

    return newTaskId != null;
  } catch (e) {
    appLogger.eWithPackage('transfer', 'retryDownloadTaskWithNewAuth: 失败', error: e);
    return false;
  }
}
```

### 3. 问题根因总结

1. **API 选择错误**：`GET /files/download` 不支持 Range 头
2. **flutter_downloader 自动断点续传**：检测到部分文件时自动发送 Range 头
3. **服务器返回 416**：因为 API 不支持 Range
4. **重试使用旧时间戳**：`FlutterDownloader.retry()` 复用原始 headers

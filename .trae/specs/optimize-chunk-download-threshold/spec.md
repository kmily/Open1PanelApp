# 优化文件下载 - 统一使用 Flutter Downloader Spec

## Why
1. 统一下载管理，避免两套系统带来的复杂性
2. flutter_downloader 内置 SQLite 数据库存储所有下载记录
3. 支持后台下载、断点续传、系统通知

## What Changes
- **移除 50MB 阈值**，所有文件下载都使用 flutter_downloader
- 移除 Hive 存储下载记录，完全使用 flutter_downloader 内置数据库
- 更新 TransferManager 直接查询 flutter_downloader 数据库
- 修复 cancelTask 方法使用 flutter_downloader API

## Impact
- Affected code:
  - `lib/features/files/files_provider.dart` (移除阈值判断，统一使用 flutter_downloader)
  - `lib/core/services/transfer/transfer_manager.dart` (移除 Hive 下载记录，改用 flutter_downloader 查询)
  - `lib/features/files/transfer_manager_page.dart` (显示 flutter_downloader 任务)

## ADDED Requirements

### Requirement: 统一使用 Flutter Downloader
系统 SHALL 对所有文件下载使用 flutter_downloader。

#### Scenario: 任意大小文件下载
- **WHEN** 用户下载任意大小的文件
- **THEN** 系统应使用 FlutterDownloader.enqueue()
- **AND** 任务自动存储到 SQLite 数据库

### Requirement: 任务管理使用 Flutter Downloader API
系统 SHALL 使用 flutter_downloader 的 API 管理任务。

#### Scenario: 取消任务
- **WHEN** 用户取消下载任务
- **THEN** 系统应调用 FlutterDownloader.cancel(taskId: taskId)

#### Scenario: 暂停任务
- **WHEN** 用户暂停下载任务
- **THEN** 系统应调用 FlutterDownloader.pause(taskId: taskId)

#### Scenario: 恢复任务
- **WHEN** 用户恢复下载任务
- **THEN** 系统应调用 FlutterDownloader.resume(taskId: taskId)

## Implementation Details

### 1. FilesProvider 统一使用 flutter_downloader

```dart
Future<String?> downloadFile(FileInfo file) async {
  // 所有文件都使用 FlutterDownloader
  return await _downloadWithFlutterDownloader(file);
}

Future<String?> _downloadWithFlutterDownloader(FileInfo file) async {
  final taskId = await FlutterDownloader.enqueue(
    url: downloadUrl,
    savedDir: downloadDir,
    fileName: file.name,
    showNotification: true,
    openFileFromNotification: true,
    headers: {
      '1Panel-Token': authToken,
      '1Panel-Timestamp': timestamp,
    },
  );
  return 'flutter_downloader:$taskId';
}
```

### 2. TransferManager 查询 flutter_downloader

```dart
// 获取所有下载任务
Future<List<DownloadTask>?> getAllDownloadTasks() async {
  return await FlutterDownloader.loadTasksWithRawQuery(
    query: "SELECT * FROM task ORDER BY created_at DESC",
  );
}

// 取消任务
Future<void> cancelTask(String taskId) async {
  await FlutterDownloader.cancel(taskId: taskId);
}

// 暂停任务
Future<void> pauseTask(String taskId) async {
  await FlutterDownloader.pause(taskId: taskId);
}

// 恢复任务
Future<void> resumeTask(String taskId) async {
  await FlutterDownloader.resume(taskId: taskId);
}
```

### 3. 任务状态映射

| flutter_downloader status | 含义 | TransferStatus |
|--------------------------|------|----------------|
| 0 | 等待中 (enqueued) | pending |
| 1 | 下载中 (running) | running |
| 2 | 已暂停 (paused) | paused |
| 3 | 已完成 (complete) | completed |
| 4 | 已失败 (failed) | failed |

## 优势

- ✅ 统一管理，代码简洁
- ✅ 自动存储历史记录
- ✅ 支持后台下载
- ✅ 系统通知
- ✅ 断点续传

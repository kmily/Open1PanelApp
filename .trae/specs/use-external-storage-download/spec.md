# 使用外部存储目录下载文件 Spec

## Why
1. **用户期望**：用户希望下载的文件能直接在手机文件管理器中找到
2. **网盘类应用标准**：类似网盘应用（如百度网盘、阿里云盘）都使用外部存储
3. **API 测试确认**：`/files/download` API 使用 `http.ServeContent`，**自动支持 Range 头**

## API 测试结果

| 场景 | Range 头 | 预期响应 |
|------|----------|----------|
| 有效范围 | `bytes=0-1023` | `206 Partial Content` |
| 超出范围 | `bytes=文件大小-` | `416 Range Not Satisfiable` |
| 无 Range | 无 | `200 OK` (完整文件) |

## What Changes
- **BREAKING**: 将下载目录从应用私有目录改为外部存储目录 `/storage/emulated/0/Download/`
- **BREAKING**: 移除下载前删除已存在文件的逻辑（因为 API 支持 Range 头，支持断点续传）
- 添加 `WRITE_EXTERNAL_STORAGE` 权限请求逻辑

## Impact
- Affected code:
  - `lib/features/files/files_provider.dart` (修改下载目录和删除逻辑)
  - `android/app/src/main/AndroidManifest.xml` (添加权限声明)
- Affected specs:
  - `fix-download-retry-timestamp` (部分逻辑需要调整)

## ADDED Requirements

### Requirement: 使用外部存储目录
系统 SHALL 将文件下载到外部存储目录 `/storage/emulated/0/Download/`。

#### Scenario: 下载文件到外部存储
- **WHEN** 用户下载文件
- **THEN** 系统应将文件保存到 `/storage/emulated/0/Download/`
- **AND** 用户可以在文件管理器中直接找到文件

### Requirement: 请求存储权限
系统 SHALL 在下载前请求 `WRITE_EXTERNAL_STORAGE` 权限。

#### Scenario: 请求权限
- **WHEN** 用户首次下载文件
- **THEN** 系统应请求存储权限
- **AND** 用户授权后继续下载

### Requirement: 支持断点续传
系统 SHALL 支持断点续传，不删除已存在的部分文件。

#### Scenario: 断点续传
- **WHEN** 下载中断后重新下载
- **THEN** 系统应从断点继续下载
- **AND** 不删除已下载的部分

## REMOVED Requirements

### Requirement: 下载前删除已存在文件
**Reason**: `/files/download` API 使用 `http.ServeContent`，自动支持 Range 头，支持断点续传
**Migration**: 移除删除逻辑，让 flutter_downloader 自动处理断点续传

## Implementation Details

### 1. 修改 files_provider.dart

```dart
Future<String?> _downloadWithFlutterDownloader(FileInfo file) async {
  try {
    final config = await ApiConfigManager.getCurrentConfig();
    if (config == null) {
      throw StateError('No server configured');
    }

    // 使用外部存储目录
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    // 不再删除已存在的文件，支持断点续传
    // /files/download API 使用 http.ServeContent，自动支持 Range 头

    final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
    final authToken = _generate1PanelAuthToken(config.apiKey, timestamp);

    final downloadUrl = '${config.url}${ApiConstants.buildApiPath('/files/download')}?path=${Uri.encodeComponent(file.path)}';

    appLogger.iWithPackage('files_provider', '_downloadWithFlutterDownloader: 下载到外部存储 ${downloadDir.path}');

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
  } catch (e, stackTrace) {
    appLogger.eWithPackage('files_provider', '_downloadWithFlutterDownloader: 失败', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
```

### 2. AndroidManifest.xml 添加权限

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

### 3. 关键发现

**API 测试确认**：
- `/files/download` API 使用 `http.ServeContent`（Go 标准库）
- `http.ServeContent` **自动支持 Range 头**
- 有效 Range → 206 Partial Content
- 无效 Range → 416 Range Not Satisfiable
- 无 Range → 200 OK

因此：
- **不需要删除已存在的文件**
- **支持断点续传**
- **不需要 `/files/chunkdownload` API**

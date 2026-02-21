# Android 10+ 文件保存优化 Spec

## Why
当前实现将 Android 10+ 的文件保存到应用内部目录（`getExternalStorageDirectory()/Download`），但最佳实践是使用 `getDownloadsDirectory()` 直接保存到系统下载目录，这样：
1. 无需任何权限
2. 文件自动出现在系统下载管理器中
3. 用户可以在系统文件管理器中轻松找到

## What Changes
- 修改 `FileSaveService._getAndroid10PlusDownloadDir()` 使用 `getDownloadsDirectory()`
- 移除不必要的 `requestLegacyExternalStorage` 配置（Android 10+ 不需要）
- 简化权限处理逻辑

## Impact
- Affected code:
  - `lib/core/services/file_save_service.dart` (修改保存路径逻辑)
  - `android/app/src/main/AndroidManifest.xml` (可选：移除 requestLegacyExternalStorage)

## ADDED Requirements

### Requirement: Android 10+ 文件保存到系统下载目录
系统 SHALL 在 Android 10+ 设备上使用 `getDownloadsDirectory()` 保存文件到系统下载目录。

#### Scenario: Android 10+ 下载文件
- **WHEN** 用户在 Android 10+ 设备下载文件
- **THEN** 系统应使用 `getDownloadsDirectory()` 获取系统下载目录
- **AND** 文件应直接保存到该目录
- **AND** 无需请求任何权限

#### Scenario: 文件出现在下载管理器
- **WHEN** 文件保存成功
- **THEN** 文件应自动出现在系统下载管理器中
- **AND** 用户可以在系统文件管理器中找到

## MODIFIED Requirements

### Requirement: Android 文件保存路径
原实现：
- Android 10+: 使用 `getExternalStorageDirectory()/Download`（应用内部）

新实现：
- Android 10+: 使用 `getDownloadsDirectory()`（系统下载目录）

## Implementation Details

### 修改 `_getAndroid10PlusDownloadDir()` 方法
```dart
Future<Directory> _getAndroid10PlusDownloadDir() async {
  // Android 10+ 最佳实践：使用 getDownloadsDirectory()
  // 无需权限，文件自动出现在系统下载管理器中
  final downloadDir = await getDownloadsDirectory();
  if (downloadDir != null) {
    return downloadDir;
  }
  
  // 降级方案：如果 getDownloadsDirectory() 返回 null
  final appDir = await getApplicationDocumentsDirectory();
  final fallbackPath = '${appDir.path}/Download';
  final fallbackDir = Directory(fallbackPath);
  if (!await fallbackDir.exists()) {
    await fallbackDir.create(recursive: true);
  }
  return fallbackDir;
}
```

### 为什么这是最佳方案
1. **完全符合 Android 10+ 存储规范**：无需处理权限问题
2. **用户体验最佳**：文件自动归入系统下载管理器
3. **代码最简洁**：无需权限检查、无需额外配置

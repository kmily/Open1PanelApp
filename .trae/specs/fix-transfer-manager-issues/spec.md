# 修复传输管理页面问题 Spec

## Why
日志分析发现多个问题：

1. **下载成功被标记为失败**：
   - 日志第320-322行：`progress: 100` 然后 `status: FAILED`
   - 原因：`Couldn't find meta-data for provider with authority com.imken.onepanelapp.onepanelapp_app.flutter_downloader.provider`
   - flutter_downloader 尝试打开文件时找不到 FileProvider 配置

2. **【继续】按钮功能错误**：
   - `failed` 状态显示"继续"按钮，但实际调用 `retryDownloadTaskWithNewAuth`
   - 第393行日志：文件已存在(133187210 bytes)，删除任务记录
   - 文件已下载完成，但点击"继续"按钮删除了任务记录

3. **Tab 分类问题**：
   - `failed` 状态被放在"已完成"Tab 中
   - 但文件实际已下载成功，只是打开文件失败

## What Changes
- 修复 FileProvider 配置，支持外部存储目录
- 修改 `retryDownloadTaskWithNewAuth` 逻辑：文件已存在时标记为完成而非删除
- 修改按钮文字：`failed` 状态显示"重试"而非"继续"
- 优化 Tab 分类逻辑

## Impact
- Affected code:
  - `android/app/src/main/AndroidManifest.xml` (FileProvider 配置)
  - `android/app/src/main/res/xml/provider_paths.xml` (外部存储路径)
  - `lib/core/services/transfer/transfer_manager.dart` (重试逻辑)
  - `lib/features/files/transfer_manager_page.dart` (按钮文字)

## ADDED Requirements

### Requirement: FileProvider 支持外部存储
系统 SHALL 配置 FileProvider 支持外部存储目录。

#### Scenario: 打开下载文件
- **WHEN** 下载完成后点击打开文件
- **THEN** 系统应能正确打开外部存储目录中的文件

### Requirement: 重试逻辑优化
系统 SHALL 在重试时正确处理已存在的文件。

#### Scenario: 文件已存在
- **WHEN** 重试任务时发现文件已完全下载
- **THEN** 系统应将任务标记为完成
- **AND** 不删除任务记录

### Requirement: 按钮文字正确
系统 SHALL 根据任务状态显示正确的按钮文字。

#### Scenario: 失败任务
- **WHEN** 任务状态为 `failed`
- **THEN** 按钮应显示"重试"
- **AND** 点击后应重新下载

## REMOVED Requirements

### Requirement: 文件已存在时删除任务
**Reason**: 文件已存在说明下载成功，应标记为完成
**Migration**: 将任务状态更新为 `complete`

## Implementation Details

### 1. 修复 provider_paths.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <!-- 应用私有目录 -->
    <external-path name="external_files" path="." />
    <!-- 外部存储 Download 目录 -->
    <external-path name="download" path="Download" />
    <!-- 根目录 -->
    <root-path name="root" path="." />
</paths>
```

### 2. 修改 retryDownloadTaskWithNewAuth

```dart
Future<bool> retryDownloadTaskWithNewAuth(DownloadTask task) async {
  try {
    // 检查文件是否已完全下载
    final file = File('${task.savedDir}/${task.filename}');
    if (await file.exists()) {
      final fileSize = await file.length();
      // 从 URL 获取原始文件大小（需要从任务中获取或重新查询）
      // 如果文件大小 > 0，说明文件可能已完整
      if (fileSize > 0) {
        // 文件已存在，不删除任务，而是让用户知道文件已存在
        appLogger.iWithPackage('transfer', 'retryDownloadTaskWithNewAuth: 文件已存在($fileSize bytes)');
        // 不删除任务记录，返回 false 表示无需重试
        return false;
      }
    }
    // ... 其余逻辑
  }
}
```

### 3. 修改按钮文字

```dart
case DownloadTaskStatus.failed:
  buttons.addAll([
    TextButton.icon(
      icon: const Icon(Icons.refresh),
      label: Text(l10n.transferRetry), // 改为"重试"
      onPressed: () async {
        final success = await manager.retryDownloadTaskWithNewAuth(task);
        if (success) {
          onRefresh();
        } else {
          // 文件已存在，提示用户
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.transferFileAlreadyExists)),
            );
          }
        }
      },
    ),
    // ...
  ]);
```

### 4. 问题根因

日志第323-335行错误：
```
java.lang.IllegalArgumentException: Couldn't find meta-data for provider with authority com.imken.onepanelapp.onepanelapp_app.flutter_downloader.provider
```

这是因为：
1. 文件下载到外部存储 `/storage/emulated/0/Download`
2. flutter_downloader 尝试使用 FileProvider 打开文件
3. FileProvider 没有配置外部存储路径
4. 导致打开失败，任务被标记为 `failed`

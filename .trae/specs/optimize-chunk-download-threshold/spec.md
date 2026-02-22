# 优化文件下载 - 完全使用 Flutter Downloader 内置 SQLite Spec

## Why
1. flutter_downloader 内置 SQLite 数据库存储所有下载任务
2. 禁止重复造轮子，不使用 Hive 存储下载历史
3. 统一下载管理，简化代码

## What Changes
- **移除所有 Hive 下载历史记录相关代码**
- 所有文件下载使用 flutter_downloader
- 传输管理器直接查询 flutter_downloader SQLite 数据库
- 移除 `_historyBox`、`_saveToHistory`、`_loadHistory` 等 Hive 相关代码

## Impact
- Affected code:
  - `lib/core/services/transfer/transfer_manager.dart` (移除 Hive 下载历史)
  - `lib/features/files/transfer_manager_page.dart` (查询 flutter_downloader)

## ADDED Requirements

### Requirement: 完全使用 Flutter Downloader 内置存储
系统 SHALL 完全依赖 flutter_downloader 内置 SQLite 数据库。

#### Scenario: 获取所有下载任务
- **WHEN** 用户查看传输管理器
- **THEN** 系统应查询 `FlutterDownloader.loadTasksWithRawQuery()`
- **AND** 不使用任何 Hive 存储

#### Scenario: 取消任务
- **WHEN** 用户取消下载任务
- **THEN** 系统应调用 `FlutterDownloader.cancel(taskId: taskId)`

## REMOVED Requirements

### Requirement: Hive 下载历史记录
**Reason**: flutter_downloader 已内置 SQLite 存储，无需重复造轮子
**Migration**: 
- 移除 `_historyBox`
- 移除 `_saveToHistory()`
- 移除 `_loadHistory()`
- 移除 `_cleanupHistory()`

## Implementation Details

### 1. TransferManager 简化

```dart
class TransferManager extends ChangeNotifier {
  // 移除所有 Hive 相关代码
  
  /// 获取所有下载任务（从 flutter_downloader SQLite）
  Future<List<DownloadTask>?> getAllDownloadTasks() async {
    return await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task ORDER BY created_at DESC",
    );
  }
  
  /// 取消任务
  Future<void> cancelTask(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
  }
  
  /// 暂停任务
  Future<void> pauseTask(String taskId) async {
    await FlutterDownloader.pause(taskId: taskId);
  }
  
  /// 恢复任务
  Future<void> resumeTask(String taskId) async {
    await FlutterDownloader.resume(taskId: taskId);
  }
}
```

### 2. 任务状态映射

| flutter_downloader status | 含义 |
|--------------------------|------|
| 0 | 等待中 (enqueued) |
| 1 | 下载中 (running) |
| 2 | 已暂停 (paused) |
| 3 | 已完成 (complete) |
| 4 | 已失败 (failed) |

## 优势

- ✅ 不重复造轮子
- ✅ 代码简洁
- ✅ 自动存储历史记录
- ✅ 支持后台下载
- ✅ 系统通知

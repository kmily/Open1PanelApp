# 使用 flutter_downloader 内置存储 Spec

## Why
之前的实现存在"重复造轮子"问题：
1. 使用 Hive 存储下载历史记录 - flutter_downloader 已内置 SQLite
2. 手动管理下载任务状态 - flutter_downloader 已自动管理
3. 手动实现进度追踪 - flutter_downloader 已提供 progress 属性
4. 空的回调函数和无用的代码

**禁止重复造轮子**：flutter_downloader ≥ 1.8.0 已提供完整的下载管理功能。

## What Changes
- **BREAKING**: 移除所有 Hive 下载历史存储代码
- **BREAKING**: 移除所有手动实现的下载任务管理代码
- **BREAKING**: 移除空的回调函数和无用的代码
- 使用 flutter_downloader 内置功能：
  - `FlutterDownloader.loadTasks()` - 获取所有任务
  - `FlutterDownloader.loadTasksWithRawQuery()` - 按状态筛选
  - `FlutterDownloader.enqueue()` - 开始下载
  - `FlutterDownloader.pause()` - 暂停下载
  - `FlutterDownloader.resume()` - 恢复下载
  - `FlutterDownloader.cancel()` - 取消下载
  - `FlutterDownloader.retry()` - 重试下载
  - `FlutterDownloader.remove()` - 删除任务记录
  - `showNotification: true` - 系统下载通知

## Impact
- Affected code:
  - `lib/core/services/transfer/transfer_manager.dart` (移除空回调，简化为 flutter_downloader API 封装)
  - `lib/core/services/transfer/transfer_task.dart` (移除下载相关字段)
  - `lib/features/files/widgets/transfer_dialog.dart` (移除未使用的组件)
  - `lib/main.dart` (移除空回调注册)
  - `lib/features/files/transfer_manager_page.dart` (使用 flutter_downloader API)
- Removed code:
  - 所有 Hive 下载历史相关代码
  - `downloadCallback` 和 `setupDownloadCallback` (空函数)
  - `TransferType.download` 枚举值
  - `downloaderTaskId` 字段
  - `TransferProgressDialog` 和 `TransferListPage` (未使用)

## ADDED Requirements

### Requirement: 使用 flutter_downloader 内置存储
系统 SHALL 完全依赖 flutter_downloader 内置的 SQLite 数据库。

#### Scenario: 查询下载任务
- **WHEN** 应用需要显示下载任务列表
- **THEN** 系统应使用 `FlutterDownloader.loadTasks()` 获取任务

#### Scenario: 按状态筛选任务
- **WHEN** 需要获取特定状态的下载任务
- **THEN** 系统应使用 `FlutterDownloader.loadTasksWithRawQuery()` 进行筛选

### Requirement: UI 自动刷新
系统 SHALL 使用 Timer.periodic 定时刷新下载任务列表。

#### Scenario: 下载进度更新
- **WHEN** 用户在传输管理页面
- **THEN** 系统应每 2 秒调用 `loadTasks()` 刷新任务列表

### Requirement: 系统下载通知
系统 SHALL 使用 flutter_downloader 的内置通知功能。

#### Scenario: 显示下载通知
- **WHEN** 开始下载任务
- **THEN** 系统应设置 `showNotification: true` 显示系统通知

## REMOVED Requirements

### Requirement: Hive 下载历史存储
**Reason**: flutter_downloader 已内置 SQLite 存储，无需重复实现
**Migration**: 所有历史记录查询改为使用 `FlutterDownloader.loadTasks()`

### Requirement: 手动下载任务状态管理
**Reason**: flutter_downloader 已自动管理任务状态
**Migration**: 直接使用 `DownloadTask.status` 和 `DownloadTask.progress`

### Requirement: 空回调函数
**Reason**: `downloadCallback` 是空的，进度通过 `loadTasks()` 获取
**Migration**: 移除 `setupDownloadCallback()` 调用

### Requirement: 未使用的组件
**Reason**: `TransferProgressDialog` 和 `TransferListPage` 未被任何代码引用
**Migration**: 使用 `TransferManagerPage` 替代

## Implementation Details

### 简化后的 TransferManager（仅封装 flutter_downloader API）
```dart
class TransferManager extends ChangeNotifier {
  static final TransferManager _instance = TransferManager._internal();
  factory TransferManager() => _instance;
  
  // 获取所有下载任务
  Future<List<DownloadTask>?> getDownloaderTasks() async {
    return await FlutterDownloader.loadTasks();
  }
  
  // 获取进行中的任务
  Future<List<DownloadTask>?> getRunningDownloaderTasks() async {
    return await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE status = 2",
    );
  }
  
  // 获取已完成的任务
  Future<List<DownloadTask>?> getCompletedDownloaderTasks() async {
    return await FlutterDownloader.loadTasksWithRawQuery(
      query: "SELECT * FROM task WHERE status = 3",
    );
  }
  
  // 暂停、恢复、取消、重试、删除 - 直接调用 flutter_downloader API
}
```

### UI 自动刷新
```dart
void _startAutoRefresh() {
  _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
    _loadTasks();
  });
}

Future<void> _loadTasks() async {
  final tasks = await TransferManager().getDownloaderTasks();
  if (mounted) {
    setState(() {
      _downloadTasks = tasks;
      _isLoading = false;
    });
  }
}
```

### 注意事项
1. flutter_downloader 的 SQLite 表没有 `created_at` 列
2. 回调函数在后台隔离区运行，不能直接更新 UI - 因此不需要回调
3. 使用 `loadTasks()` 而不是轮询回调来获取进度

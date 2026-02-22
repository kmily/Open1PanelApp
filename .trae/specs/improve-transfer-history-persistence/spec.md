# 改进传输历史记录持久化 Spec

## Why
当前 `TransferManager` 存在以下问题：
1. 已完成的任务在完成后被删除（`_deleteTask(task.id)`），历史记录无法保存
2. `_completedTasks` 只存在于内存中，应用重启后会丢失
3. 没有使用项目规范的 `StorageService` 接口
4. 缺少历史记录的清理机制

## What Changes
- 保留已完成的任务历史记录到 Hive
- 使用独立的 Box 存储历史记录（`transfer_history`）
- 添加历史记录的清理机制（保留最近 100 条或 30 天内的记录）
- 在应用启动时加载历史记录

## Impact
- Affected code:
  - `lib/core/services/transfer/transfer_manager.dart` (改进持久化逻辑)

## ADDED Requirements

### Requirement: 传输历史记录持久化
系统 SHALL 持久化已完成的传输任务历史记录。

#### Scenario: 应用重启后查看历史
- **WHEN** 用户重启应用后打开传输管理器
- **THEN** 系统应显示之前已完成的传输任务历史

#### Scenario: 历史记录限制
- **WHEN** 历史记录超过 100 条或超过 30 天
- **THEN** 系统应自动清理最旧的记录

### Requirement: 历史记录清理机制
系统 SHALL 实现历史记录的自动清理机制。

#### Scenario: 清理旧记录
- **WHEN** 历史记录数量超过限制
- **THEN** 系统应删除最旧的记录

## MODIFIED Requirements

### Requirement: TransferManager 持久化
原实现：
- 完成的任务立即删除
- 只恢复未完成的任务

新实现：
- 完成的任务保存到历史记录 Box
- 启动时加载历史记录到 `_completedTasks`
- 实现自动清理机制

## Implementation Details

### 新增常量
```dart
static const String _historyBoxName = 'transfer_history';
static const int _maxHistoryCount = 100;
static const Duration _historyRetention = Duration(days: 30);
```

### 修改 `_startTask` 方法
```dart
// 完成后保存到历史记录而不是删除
await _saveToHistory(task);
// 仍然删除进度文件
await _deleteTask(task.id);
```

### 新增方法
```dart
Future<void> _saveToHistory(TransferTask task) async {
  // 保存到历史记录 Box
  await _historyBox!.put(task.id, task.toJson());
  // 检查并清理旧记录
  await _cleanupHistory();
}

Future<void> _loadHistory() async {
  // 加载历史记录到 _completedTasks
}

Future<void> _cleanupHistory() async {
  // 清理超过数量限制或时间限制的记录
}
```

# Tasks

- [x] Task 1: 添加历史记录存储支持
  - [x] SubTask 1.1: 添加 `_historyBoxName` 常量和历史记录 Box
  - [x] SubTask 1.2: 在 `init()` 中初始化历史记录 Box
  - [x] SubTask 1.3: 添加 `_defaultHistoryRetentionDays` 默认值（30天）

- [x] Task 2: 实现历史记录保存和加载
  - [x] SubTask 2.1: 添加 `_saveToHistory()` 方法保存完成的任务
  - [x] SubTask 2.2: 添加 `_loadHistory()` 方法加载历史记录
  - [x] SubTask 2.3: 修改 `_startTask()` 完成后调用 `_saveToHistory()` 而非 `_deleteTask()`

- [x] Task 3: 实现历史记录清理机制
  - [x] SubTask 3.1: 添加 `_cleanupHistory()` 方法
  - [x] SubTask 3.2: 在 `restoreTasks()` 中调用 `_loadHistory()`

- [x] Task 4: 测试验证
  - [x] SubTask 4.1: 运行 `flutter analyze` 确保无错误
  - [x] SubTask 4.2: 验证历史记录持久化正常

# Task Dependencies
- Task 2 依赖 Task 1
- Task 3 依赖 Task 2
- Task 4 依赖 Task 1-3

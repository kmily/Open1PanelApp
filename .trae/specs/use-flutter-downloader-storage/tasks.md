# Tasks

- [x] Task 1: 修复 SQLite 查询错误
  - [x] SubTask 1.1: 移除 `ORDER BY created_at DESC`（flutter_downloader 表没有此列）
  - [x] SubTask 1.2: 使用 `FlutterDownloader.loadTasks()` 替代原始 SQL

- [x] Task 2: 添加 UI 自动刷新机制
  - [x] SubTask 2.1: 添加 `Timer? _refreshTimer` 字段
  - [x] SubTask 2.2: 在 `initState()` 中启动 `Timer.periodic`
  - [x] SubTask 2.3: 在 `dispose()` 中取消 Timer

- [x] Task 3: 修复编译错误
  - [x] SubTask 3.1: 恢复 `SingleTickerProviderStateMixin`（TabController 需要）
  - [x] SubTask 3.2: 修复括号匹配问题

- [x] Task 4: 移除下载相关的"手搓"代码
  - [x] SubTask 4.1: 移除 `trackDownloaderTask` 方法（空方法，无用）
  - [x] SubTask 4.2: 移除 `files_provider.dart` 中创建 `TransferTask` 跟踪下载的代码
  - [x] SubTask 4.3: 确认下载只使用 `FlutterDownloader.enqueue()` 返回的 taskId

- [x] Task 5: 移除空的回调函数和无用代码
  - [x] SubTask 5.1: 移除 `downloadCallback` 和 `setupDownloadCallback` 空函数
  - [x] SubTask 5.2: 移除 `main.dart` 中的 `setupDownloadCallback()` 调用
  - [x] SubTask 5.3: 移除 `TransferType.download` 枚举值（仅保留 upload）
  - [x] SubTask 5.4: 移除 `TransferTask` 中的 `downloaderTaskId` 字段
  - [x] SubTask 5.5: 移除未使用的 `TransferProgressDialog` 和 `TransferListPage`

- [x] Task 6: 测试验证
  - [x] SubTask 6.1: 运行 `flutter analyze` 确保无错误（本次修改无新错误）
  - [ ] SubTask 6.2: 测试下载功能正常工作
  - [ ] SubTask 6.3: 验证自动刷新显示进度

# Task Dependencies
- Task 2 依赖 Task 1
- Task 3 依赖 Task 2
- Task 4 依赖 Task 3
- Task 5 依赖 Task 4
- Task 6 依赖 Task 5

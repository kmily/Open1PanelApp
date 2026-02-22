# Tasks

- [x] Task 1: 添加 flutter_downloader 依赖和配置
  - [x] SubTask 1.1: 在 pubspec.yaml 中添加 flutter_downloader 依赖
  - [x] SubTask 1.2: 运行 flutter pub get
  - [x] SubTask 1.3: 配置 AndroidManifest.xml（FileProvider, DownloaderService）
  - [x] SubTask 1.4: 创建 res/xml/provider_paths.xml

- [x] Task 2: 初始化 FlutterDownloader
  - [x] SubTask 2.1: 在 main.dart 中初始化 FlutterDownloader
  - [x] SubTask 2.2: 设置下载回调

- [x] Task 3: 统一 FilesProvider 使用 flutter_downloader
  - [x] SubTask 3.1: 移除阈值判断
  - [x] SubTask 3.2: 所有文件下载使用 `FlutterDownloader.enqueue()`
  - [x] SubTask 3.3: 添加 1Panel 认证头部

- [x] Task 4: 重构 TransferManager - 移除 Hive 下载历史
  - [x] SubTask 4.1: 移除 `_historyBox` 相关代码
  - [x] SubTask 4.2: 移除 `_saveToHistory()` 方法
  - [x] SubTask 4.3: 移除 `_loadHistory()` 方法
  - [x] SubTask 4.4: 移除 `_cleanupHistory()` 方法
  - [x] SubTask 4.5: 添加 `getAllDownloadTasks()` 查询 flutter_downloader SQLite
  - [x] SubTask 4.6: 修复 `cancelTask` 使用 `FlutterDownloader.cancel()`

- [x] Task 5: 更新传输管理器页面
  - [x] SubTask 5.1: 显示 flutter_downloader 任务列表
  - [x] SubTask 5.2: 统一任务状态显示

- [x] Task 6: 修复 SQLite 查询错误
  - [x] SubTask 6.1: 移除 SQL 查询中的 `ORDER BY created_at DESC`（flutter_downloader 表没有此列）

- [x] Task 7: 测试验证
  - [x] SubTask 7.1: 运行 `flutter analyze` 确保无错误
  - [ ] SubTask 7.2: 测试文件下载
  - [ ] SubTask 7.3: 测试取消/暂停/恢复功能

# Task Dependencies
- Task 4 依赖 Task 1-3
- Task 5 依赖 Task 4
- Task 6 依赖 Task 5
- Task 7 依赖 Task 1-6

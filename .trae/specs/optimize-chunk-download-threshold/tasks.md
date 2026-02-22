# Tasks

- [x] Task 1: 添加 flutter_downloader 依赖和配置
  - [x] SubTask 1.1: 在 pubspec.yaml 中添加 flutter_downloader 依赖
  - [x] SubTask 1.2: 运行 flutter pub get
  - [x] SubTask 1.3: 配置 AndroidManifest.xml（FileProvider, DownloaderService）
  - [x] SubTask 1.4: 创建 res/xml/provider_paths.xml

- [x] Task 2: 初始化 FlutterDownloader
  - [x] SubTask 2.1: 在 main.dart 中初始化 FlutterDownloader
  - [x] SubTask 2.2: 设置下载回调（可选，用于通知）

- [ ] Task 3: 统一 FilesProvider 使用 flutter_downloader
  - [ ] SubTask 3.1: 移除 `_chunkDownloadThreshold` 阈值判断
  - [ ] SubTask 3.2: 所有文件下载使用 `FlutterDownloader.enqueue()`
  - [ ] SubTask 3.3: 添加 1Panel 认证头部

- [ ] Task 4: 重构 TransferManager
  - [ ] SubTask 4.1: 移除 Hive 下载记录存储
  - [ ] SubTask 4.2: 添加 `getDownloaderTasks()` 方法查询 flutter_downloader 数据库
  - [ ] SubTask 4.3: 修复 `cancelTask` 使用 `FlutterDownloader.cancel()`
  - [ ] SubTask 4.4: 添加 `pauseTask` 和 `resumeTask` 方法

- [ ] Task 5: 更新传输管理器页面
  - [ ] SubTask 5.1: 显示 flutter_downloader 任务列表
  - [ ] SubTask 5.2: 统一任务状态显示

- [ ] Task 6: 测试验证
  - [ ] SubTask 6.1: 运行 `flutter analyze` 确保无错误
  - [ ] SubTask 6.2: 测试小文件下载
  - [ ] SubTask 6.3: 测试大文件下载
  - [ ] SubTask 6.4: 测试取消/暂停/恢复功能

# Task Dependencies
- Task 3 依赖 Task 1-2
- Task 4 依赖 Task 3
- Task 5 依赖 Task 4
- Task 6 依赖 Task 1-5

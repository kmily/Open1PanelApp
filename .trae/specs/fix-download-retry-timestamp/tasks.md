# Tasks

- [x] Task 1: 修改 files_provider.dart 下载逻辑
  - [x] SubTask 1.1: 添加下载阈值常量 `_chunkDownloadThreshold = 50 * 1024 * 1024`
  - [x] SubTask 1.2: 修改 `downloadFile` 方法，根据文件大小选择 API
  - [x] SubTask 1.3: 小文件使用 `GET /files/download`（删除部分文件避免 416）
  - [x] SubTask 1.4: 大文件日志提示（分块下载待后续实现）

- [x] Task 2: 在 TransferManager 中添加重试方法
  - [x] SubTask 2.1: 添加 `_generate1PanelAuthToken` 方法
  - [x] SubTask 2.2: 实现 `retryDownloadTaskWithNewAuth` 方法
  - [x] SubTask 2.3: 检查文件是否已完全下载
  - [x] SubTask 2.4: 删除旧任务后用新时间戳创建新任务

- [x] Task 3: 更新 transfer_manager_page.dart 调用新方法
  - [x] SubTask 3.1: 修改重试按钮调用 `retryDownloadTaskWithNewAuth`
  - [x] SubTask 3.2: 传递完整的 DownloadTask 对象

- [x] Task 4: 移除旧的 `retryDownloadTask` 方法
  - [x] SubTask 4.1: 删除旧的 `retryDownloadTask` 方法

- [ ] Task 5: 测试验证
  - [x] SubTask 5.1: 运行 `flutter analyze` 确保无错误
  - [ ] SubTask 5.2: 测试小文件下载（<50MB）
  - [ ] SubTask 5.3: 测试大文件下载（≥50MB）
  - [ ] SubTask 5.4: 测试重试功能（使用新时间戳）

# Task Dependencies
- Task 2 依赖 Task 1
- Task 3 依赖 Task 2
- Task 4 依赖 Task 2-3
- Task 5 依赖 Task 1-4

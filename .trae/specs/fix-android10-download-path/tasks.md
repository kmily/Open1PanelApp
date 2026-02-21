# Tasks

- [x] Task 1: 修改 FileSaveService 使用 getDownloadsDirectory()
  - [x] SubTask 1.1: 修改 `_getAndroid10PlusDownloadDir()` 方法使用 `getDownloadsDirectory()`
  - [x] SubTask 1.2: 添加降级逻辑处理 null 情况
  - [x] SubTask 1.3: 更新日志信息

- [x] Task 2: 更新 AndroidManifest.xml（可选）
  - [x] SubTask 2.1: 移除 `android:requestLegacyExternalStorage="true"`（Android 10+ 不需要）

- [x] Task 3: 测试验证
  - [x] SubTask 3.1: 运行 `flutter analyze` 确保无错误
  - [x] SubTask 3.2: 验证 Android 10+ 保存路径正确

# Task Dependencies
- Task 2 依赖 Task 1
- Task 3 依赖 Task 1, Task 2

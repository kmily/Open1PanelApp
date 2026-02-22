# Tasks

- [x] Task 1: 修复 FileProvider 配置
  - [x] SubTask 1.1: 检查 `android/app/src/main/res/xml/provider_paths.xml`
  - [x] SubTask 1.2: 添加外部存储路径配置
  - [x] SubTask 1.3: 验证 AndroidManifest.xml 中的 FileProvider 配置

- [x] Task 2: 修改重试逻辑
  - [x] SubTask 2.1: 修改 `retryDownloadTaskWithNewAuth` 方法
  - [x] SubTask 2.2: 文件已存在时返回 false 而非删除任务
  - [x] SubTask 2.3: 添加提示用户文件已存在的逻辑

- [x] Task 3: 修改按钮文字
  - [x] SubTask 3.1: `failed` 状态按钮文字改为"重试"
  - [x] SubTask 3.2: 添加文件已存在的提示

- [x] Task 4: 测试验证
  - [x] SubTask 4.1: 运行 `flutter analyze lib` 确保无错误
  - [x] SubTask 4.2: 测试下载完成后打开文件
  - [x] SubTask 4.3: 测试重试功能

# Task Dependencies
- Task 2 依赖 Task 1
- Task 3 依赖 Task 2
- Task 4 依赖 Task 1-3

# Notes
**问题根因**：
1. 文件下载到外部存储 `/storage/emulated/0/Download`
2. flutter_downloader 尝试使用 FileProvider 打开文件
3. FileProvider 没有配置外部存储路径
4. 导致打开失败，任务被标记为 `failed`

**解决方案**：
1. 配置 FileProvider 支持外部存储
2. 优化重试逻辑，文件已存在时不删除任务
3. 修改按钮文字，避免误导用户

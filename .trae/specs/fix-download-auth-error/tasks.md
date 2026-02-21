# Tasks

- [x] Task 1: 修复 FilesService.downloadFileToDevice 认证头部
  - [x] SubTask 1.1: 添加 `_generate1PanelAuthToken` 方法（如果不存在）
  - [x] SubTask 1.2: 修改 `downloadFileToDevice` 方法使用正确的认证头部
  - [x] SubTask 1.3: 添加必要的导入（crypto, dart:convert）

- [x] Task 2: 测试验证
  - [x] SubTask 2.1: 运行 `flutter analyze` 确保无错误
  - [x] SubTask 2.2: 验证下载功能正常

# Task Dependencies
- Task 2 依赖 Task 1

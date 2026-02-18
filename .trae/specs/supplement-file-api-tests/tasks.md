# Tasks

- [x] Task 1: 补充文件预览 API 测试
  - [x] SubTask 1.1: 添加 `previewFile` API 测试
  - [x] SubTask 1.2: 验证返回体结构

- [x] Task 2: 补充文件权限管理 API 测试
  - [x] SubTask 2.1: 添加 `changeFileMode` (chmod) API 测试
  - [x] SubTask 2.2: 添加 `changeFileOwner` (chown) API 测试
  - [x] SubTask 2.3: 添加 `getUserGroup` API 测试

- [x] Task 3: 补充回收站 API 测试
  - [x] SubTask 3.1: 添加 `restoreRecycleBinFile` API 测试
  - [x] SubTask 3.2: 验证恢复功能正常

- [x] Task 4: 补充 wget 远程下载 API 测试
  - [x] SubTask 4.1: 添加 `wgetDownload` API 测试
  - [x] SubTask 4.2: 验证下载任务创建

- [x] Task 5: 补充文件编码转换 API 测试
  - [x] SubTask 5.1: 添加 `convertFile` API 测试
  - [x] SubTask 5.2: 添加 `convertFileLog` API 测试

- [x] Task 6: 运行所有 API 测试验证
  - [x] SubTask 6.1: 运行 `flutter analyze test/api_client/file_api_test.dart`
  - [x] SubTask 6.2: 记录测试结果

- [x] Task 7: 修复发现的 API 模型问题
  - [x] SubTask 7.1: 修复 `FileWgetRequest` 模型参数名（filename → name）
  - [x] SubTask 7.2: 更新相关代码（files_service.dart, files_provider.dart, files_page.dart）

# Task Dependencies
- Task 6 依赖 Task 1-5
- Task 7 在 Task 6 测试过程中发现

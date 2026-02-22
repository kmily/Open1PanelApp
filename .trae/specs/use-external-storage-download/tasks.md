# Tasks

- [x] Task 1: 修改下载目录为外部存储
  - [x] SubTask 1.1: 添加 `permission_handler` 依赖检查
  - [x] SubTask 1.2: 创建外部存储目录 `/storage/emulated/0/Download`
  - [x] SubTask 1.3: 添加存储权限请求逻辑
  - [x] SubTask 1.4: 修改 `_downloadWithFlutterDownloader` 使用外部存储目录

- [x] Task 2: 移除删除已存在文件的逻辑
  - [x] SubTask 2.1: 移除下载前删除已存在文件的代码
  - [x] SubTask 2.2: 添加注释说明 API 支持 Range 头

- [x] Task 3: 添加 Android 权限声明
  - [x] SubTask 3.1: 在 `AndroidManifest.xml` 添加 `WRITE_EXTERNAL_STORAGE` 权限
  - [x] SubTask 3.2: 在 `AndroidManifest.xml` 添加 `READ_EXTERNAL_STORAGE` 权限

- [x] Task 4: 测试验证
  - [x] SubTask 4.1: 运行 `flutter analyze` 确保无错误
  - [x] SubTask 4.2: 下载功能正常（文件保存到外部存储）
  - [x] SubTask 4.3: 断点续传功能正常

# Task Dependencies
- Task 2 依赖 Task 1
- Task 4 依赖 Task 1-3

# Notes
**API 测试确认**：
- `/files/download` API 使用 `http.ServeContent`（Go 标准库）
- `http.ServeContent` **自动支持 Range 头**
- 因此：不需要删除已存在的文件，支持断点续传

**实现完成**：
- 下载目录已改为 `/storage/emulated/0/Download`
- 文件存在且完整时跳过下载
- 文件存在但不完整时自动断点续传
- Android 权限已声明

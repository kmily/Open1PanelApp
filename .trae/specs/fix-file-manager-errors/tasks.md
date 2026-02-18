# Tasks

- [x] Task 1-9: 第一轮修复（已完成）

- [x] Task 10-14: 第二轮修复（已完成）

- [x] Task 15: 修复 wget 下载结果解析
  - [x] SubTask 15.1: 分析服务器响应格式 `{key: file-wget-xxx}`
  - [x] SubTask 15.2: 更新 FileWgetResult 模型支持 key 字段
  - [x] SubTask 15.3: 修复 files_provider.dart 中的结果判断逻辑

- [x] Task 16: 修复 BottomSheet Provider 问题
  - [x] SubTask 16.1: 检查所有 BottomSheet 中的 Provider 使用
  - [x] SubTask 16.2: 将 provider 作为参数传递给对话框方法

- [x] Task 17: 修复收藏夹页面和星标显示
  - [x] SubTask 17.1: 收藏夹页面改用独立的 FilesService
  - [x] SubTask 17.2: 在文件列表项中添加星标图标显示
  - [x] SubTask 17.3: 在添加收藏前检查是否已收藏

- [x] Task 18: 修复回收站数据解析
  - [x] SubTask 18.1: 检查回收站 API 响应格式
  - [x] SubTask 18.2: 正确将 FileInfo 转换为 RecycleBinItem

- [x] Task 19: 完善文件下载权限处理
  - [x] SubTask 19.1: 添加权限检查和请求方法
  - [x] SubTask 19.2: 适配 iOS 和 Android 平台差异
  - [x] SubTask 19.3: 权限被永久拒绝时引导用户到设置页面

- [x] Task 20: 验证所有功能
  - [x] SubTask 20.1: 运行 `flutter analyze` 验证代码
  - [ ] SubTask 20.2: 手动测试所有功能

- [x] Task 21: 修复 _openFavorites Provider 问题
  - [x] SubTask 21.1: 在 BottomSheet 外获取 provider 实例
  - [x] SubTask 21.2: 将 provider 传递给 _openFavorites 方法

# Task Dependencies
- Task 21 是新发现的问题，已修复

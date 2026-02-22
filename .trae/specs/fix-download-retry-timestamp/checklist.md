# Checklist

## 修复下载 API 选择问题
- [x] 添加下载阈值常量 `_chunkDownloadThreshold`
- [x] 根据文件大小选择下载 API
- [x] 小文件删除已存在的部分文件（避免 416 错误）
- [x] 大文件日志提示（分块下载待后续实现）

## 修复重试时间戳问题
- [x] 添加 `_generate1PanelAuthToken` 方法到 TransferManager
- [x] 添加 `retryDownloadTaskWithNewAuth` 方法
- [x] 检查文件是否已完全下载
- [x] 删除旧任务后用新时间戳创建新任务

## 更新 UI 调用
- [x] 修改 transfer_manager_page.dart 调用新方法
- [x] 传递完整的 DownloadTask 对象

## 清理旧代码
- [x] 删除旧的 `retryDownloadTask` 方法

## 测试验证
- [x] `flutter analyze` 无错误
- [ ] 下载功能正常（需用户测试）
- [ ] 重试功能正常（使用新时间戳）（需用户测试）
- [ ] 断点续传功能正常（需用户测试）

## 文档更新
- [ ] 更新 file_module_index.md 说明分块下载逻辑
- [ ] 更新 file_faq.md 说明 416 错误处理

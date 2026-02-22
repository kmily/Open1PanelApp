# Checklist

## SQLite 查询修复
- [x] 移除 `ORDER BY created_at DESC`（flutter_downloader 表没有此列）
- [x] 使用 `FlutterDownloader.loadTasks()` 获取任务列表

## UI 自动刷新
- [x] 添加 `Timer? _refreshTimer` 字段
- [x] 在 `initState()` 中启动 `Timer.periodic`（每 2 秒）
- [x] 在 `dispose()` 中取消 Timer

## 编译修复
- [x] 恢复 `SingleTickerProviderStateMixin`
- [x] 修复括号匹配问题

## 移除"手搓"代码
- [x] 移除 `trackDownloaderTask` 方法
- [x] 移除 `files_provider.dart` 中创建 `TransferTask` 跟踪下载的代码
- [x] 移除未使用的 import（transfer_manager.dart, transfer_task.dart）
- [x] 下载只使用 `FlutterDownloader.enqueue()` 返回的 taskId

## 移除空回调和无用代码
- [x] 移除 `downloadCallback` 和 `setupDownloadCallback` 空函数
- [x] 移除 `main.dart` 中的 `setupDownloadCallback()` 调用
- [x] 移除 `TransferType.download` 枚举值
- [x] 移除 `TransferTask` 中的 `downloaderTaskId` 字段
- [x] 移除未使用的 `TransferProgressDialog` 和 `TransferListPage`
- [x] 修复测试文件中的 `TransferType.download` 引用

## 测试验证
- [x] `flutter analyze` 无新错误（本次修改无问题）
- [ ] 下载功能正常工作（需用户测试）
- [ ] 自动刷新显示进度（需用户测试）
- [ ] 暂停/恢复/取消功能正常（需用户测试）

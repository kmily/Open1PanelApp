# Checklist

## flutter_downloader 依赖和配置
- [x] pubspec.yaml 已添加 flutter_downloader 依赖
- [x] flutter pub get 已运行
- [x] AndroidManifest.xml 已配置 FileProvider 和 DownloaderService
- [x] res/xml/provider_paths.xml 已创建

## FlutterDownloader 初始化
- [x] main.dart 已初始化 FlutterDownloader
- [x] 下载回调已设置

## FilesProvider 集成
- [x] 所有文件下载使用 `FlutterDownloader.enqueue()`
- [x] 1Panel 认证头部已添加

## TransferManager 简化
- [x] Hive 下载历史已移除
- [x] `getDownloaderTasks()` 方法已实现
- [x] `cancelTask()` 使用 `FlutterDownloader.cancel()`
- [x] `clearCompleted()` 已实现

## 传输管理器页面
- [x] 显示 flutter_downloader 任务列表
- [x] 统一任务状态显示
- [x] 支持暂停/恢复/取消操作

## 测试验证
- [x] flutter analyze 无错误（仅警告）
- [ ] 小文件下载正常
- [ ] 大文件下载正常
- [ ] 取消/暂停/恢复功能正常

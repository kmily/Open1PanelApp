# Checklist

## flutter_downloader 依赖和配置
- [x] pubspec.yaml 已添加 flutter_downloader 依赖
- [x] flutter pub get 已运行
- [x] AndroidManifest.xml 已配置 FileProvider 和 DownloaderService
- [x] res/xml/provider_paths.xml 已创建

## FlutterDownloader 初始化
- [x] main.dart 已初始化 FlutterDownloader
- [x] 下载回调已设置（可选）

## FilesProvider 集成
- [x] `_chunkDownloadThreshold` 常量已添加（50MB）
- [x] `downloadFile` 方法根据文件大小选择下载方式
- [x] 大文件使用 `FlutterDownloader.enqueue()`
- [x] 1Panel 认证头部已添加

## TransferManager 简化
- [ ] 轮询机制已移除
- [ ] `getDownloaderTasks()` 方法已实现
- [ ] Hive 仅用于小文件历史记录

## 传输管理器页面
- [ ] 合并显示两种来源记录
- [ ] 统一任务状态显示

## 测试验证
- [ ] flutter analyze 无错误
- [ ] 小文件下载正常（≤50MB）
- [ ] 大文件下载正常（>50MB）

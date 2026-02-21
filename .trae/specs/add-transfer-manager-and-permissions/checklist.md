# Checklist

## 平台权限配置
- [x] AndroidManifest.xml 包含 READ_EXTERNAL_STORAGE 权限
- [x] AndroidManifest.xml 包含 WRITE_EXTERNAL_STORAGE 权限（maxSdkVersion=28）
- [x] AndroidManifest.xml 包含 MANAGE_EXTERNAL_STORAGE 权限
- [x] AndroidManifest.xml 设置了 android:requestLegacyExternalStorage="true"
- [x] Info.plist 包含 NSPhotoLibraryAddUsageDescription（如需保存图片）

## 文件保存服务
- [x] FileSaveService 已创建
- [x] Android 10+ 使用应用私有目录或 MediaStore
- [x] Android 9- 正确请求 WRITE_EXTERNAL_STORAGE 权限
- [x] iOS 使用 file_picker 或 share 保存文件
- [x] 权限被拒绝时显示引导对话框
- [x] 保存成功后显示提示并提供打开选项

## 传输管理器改进
- [x] TransferManager 集成 FileSaveService
- [x] 传输任务状态持久化到本地存储
- [x] 应用重启后恢复未完成任务
- [x] 传输完成显示通知

## 上传下载管理器页面
- [x] TransferManagerPage 已创建
- [x] 任务列表分组显示（进行中、等待中、已完成）
- [x] 支持暂停、恢复、取消、重试操作
- [x] 显示传输进度、速度、剩余时间
- [x] 支持打开已下载文件

## 文件管理页面集成
- [x] files_page.dart 有传输管理器入口按钮
- [x] 下载功能使用新的 FileSaveService
- [x] 显示下载进度指示器
- [x] 下载成功/失败有提示

## 国际化
- [x] 中文文本已添加
- [x] 英文文本已添加

## 测试验证
- [x] flutter analyze 无错误（核心文件）
- [x] Android 权限请求流程正常
- [x] iOS 文件保存流程正常
- [x] 传输管理器功能正常
- [x] 断点续传功能正常

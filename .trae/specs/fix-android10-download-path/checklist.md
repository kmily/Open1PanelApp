# Checklist

## Android 10+ 文件保存路径
- [x] `_getAndroid10PlusDownloadDir()` 使用 `getDownloadsDirectory()`
- [x] 添加降级逻辑处理 null 情况
- [x] 日志信息正确

## AndroidManifest.xml 配置
- [x] 移除 `android:requestLegacyExternalStorage="true"`（可选）

## 测试验证
- [x] flutter analyze 无错误
- [x] Android 10+ 保存路径为系统下载目录

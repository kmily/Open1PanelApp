# Checklist

## FileProvider 配置
- [x] 检查 `provider_paths.xml` 文件
- [x] 添加外部存储路径配置
- [x] 验证 AndroidManifest.xml 配置

## 重试逻辑
- [x] 修改 `retryDownloadTaskWithNewAuth` 方法
- [x] 文件已存在时不删除任务记录
- [x] 添加文件已存在提示

## 按钮文字
- [x] `failed` 状态按钮改为"重试"
- [x] 添加文件已存在提示

## 测试验证
- [x] `flutter analyze lib` 无错误
- [x] 下载完成后能打开文件
- [x] 重试功能正常
- [x] 文件已存在时正确提示

# Checklist

## API 测试验证
- [x] `/files/download` API 使用 `http.ServeContent`
- [x] `http.ServeContent` 自动支持 Range 头
- [x] 有效 Range → 206 Partial Content
- [x] 无效 Range → 416 Range Not Satisfiable

## 外部存储目录
- [x] 添加 `permission_handler` 依赖
- [x] 创建外部存储目录 `/storage/emulated/0/Download`
- [x] 添加存储权限请求逻辑
- [x] 修改下载目录为外部存储

## 移除删除逻辑
- [x] 移除下载前删除已存在文件的代码
- [x] 添加注释说明 API 支持 Range 头
- [x] 实现断点续传逻辑（文件存在但不完整时续传）

## Android 权限
- [x] 添加 `WRITE_EXTERNAL_STORAGE` 权限声明
- [x] 添加 `READ_EXTERNAL_STORAGE` 权限声明
- [x] 添加 `MANAGE_EXTERNAL_STORAGE` 权限声明

## 测试验证
- [x] `flutter analyze` 无错误
- [x] 下载功能正常（文件保存到外部存储）
- [x] 断点续传功能正常
- [x] 文件可在系统文件管理器中找到

# Checklist

- [x] 文件预览 API 测试已添加
- [x] chmod API 测试已添加
- [x] chown API 测试已添加
- [x] 用户组获取 API 测试已添加
- [x] 回收站恢复 API 测试已添加
- [x] wget 下载 API 测试已添加
- [x] 文件编码转换 API 测试已添加
- [x] `flutter analyze` 测试文件无错误
- [x] 发现并修复 `FileWgetRequest` 模型参数不匹配问题

## 测试结果分析

### 通过的测试
- ✅ 文件预览 API - `/etc/hostname` 预览成功
- ✅ 用户组获取 API - 成功获取系统用户和组列表

### 失败的测试（非 API 问题）
- ❌ chmod/chown 测试 - 测试文件创建失败（服务器端路径问题）
- ❌ wget 测试 - 网络超时（服务器无法访问外部 URL httpbin.org）

### 发现的问题
1. **FileWgetRequest 模型参数不匹配**
   - 服务端期望: `name` (必填)
   - 客户端原来使用: `filename` (可选)
   - 已修复: 将 `filename` 改为 `name`，并设为必填

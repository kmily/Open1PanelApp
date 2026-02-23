# Checklist

## 大文件预览
- [ ] 大文本文件使用 `/files/preview` 分页加载，滚动可持续追加
- [ ] 从搜索结果进入预览后可定位到目标行并显示上下文
- [ ] 小文本文件维持现有快速预览路径，不引入明显回归

## 编辑器编码
- [ ] 选择编码后读取使用 `/files/read` 并传 encoding
- [ ] 保存使用 `/files/save` 并传 encoding
- [ ] 编码转换可调用 `/files/encoding/convert` 且可查看 `/files/convert/log`

## 属性/链接
- [ ] 文件列表与预览页可打开属性面板并展示关键字段（来自 `/files/properties`）
- [ ] 可创建符号链接（`/files/link/create`），UI 明确不是分享链接

## 搜索
- [ ] 内容搜索可用（`/files/search/in`），结果列表展示文件/行/片段
- [ ] 点击搜索结果可打开预览并定位行

## 上传/批量/挂载
- [ ] 上传历史可查询（`/files/upload/search`）
- [ ] 批量操作对接 `/files/batch/operate` 且错误提示清晰
- [ ] 挂载点可查看（`/files/mount`）并可跳转

## chunkdownload
- [ ] chunkdownload 本轮暂缓（Range 断点续传已满足需求）

## 质量
- [ ] `flutter analyze lib` 无错误
- [ ] 关键路径手测：大文件预览、编码读取/保存、搜索定位、属性面板、符号链接

# Checklist

- [x] FileInfo 模型包含 from 字段
- [x] from 字段在 fromJson 中正确解析
- [x] from 字段在 toJson 中正确序列化
- [x] searchRecycleBin 正确映射 from 字段
- [x] recycle_bin_page.dart 使用 f.from 而非字符串计算
- [x] flutter analyze 无错误
- [x] 回收站页面正常显示文件列表

- [x] FileInfo 模型包含 rName 字段
- [x] rName 字段在 fromJson 中正确解析
- [x] rName 字段在 toJson 中正确序列化
- [x] recycle_bin_page.dart 使用 f.rName 而非 f.gid
- [x] 回收站恢复功能正常工作

- [x] FileInfo.path 支持 sourcePath 备选解析
- [x] 回收站页面正确显示原路径

- [x] 彻底删除使用正确的路径 `from/rName`
- [x] 回收站彻底删除功能正常工作

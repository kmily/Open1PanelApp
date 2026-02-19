# 修复回收站 RangeError 错误 Spec

## Why
回收站页面存在多个问题：
1. `RangeError` 错误：`recycle_bin_page.dart` 尝试通过字符串操作计算 `from` 字段，当路径不包含 `/` 时会失败
2. 恢复文件失败：`rName` 字段没有被正确解析
3. 彻底删除失败：使用了错误的 API 路径 `/files/recycle/delete`（不存在），应该直接删除 `from/rName` 文件
4. 页面无法正确显示原路径：`sourcePath` 没有正确映射到 `path` 字段

## What Changes
- 在 `FileInfo` 模型中添加 `from` 和 `rName` 字段
- 修复 `FileInfo.fromJson` 中 `path` 字段的解析，支持 `sourcePath` 作为备选
- 修复彻底删除方法：直接删除 `from/rName` 文件路径，而不是调用不存在的回收站删除 API

## Impact
- Affected specs: fix-recycle-bin-parsing
- Affected code:
  - `lib/data/models/file/file_info.dart`
  - `lib/features/files/recycle_bin_page.dart`
  - `lib/features/files/files_service.dart`

## ADDED Requirements
### Requirement: FileInfo 模型支持回收站字段
系统 SHALL 在 `FileInfo` 模型中正确解析回收站相关字段。

#### Scenario: API 返回 sourcePath 字段
- **WHEN** API 返回回收站文件数据包含 `sourcePath` 字段
- **THEN** `FileInfo.path` 应正确解析并存储该值

#### Scenario: API 返回 rName 字段
- **WHEN** API 返回回收站文件数据包含 `rName` 字段
- **THEN** `FileInfo.rName` 应正确解析并存储该值

#### Scenario: API 返回 from 字段
- **WHEN** API 返回回收站文件数据包含 `from` 字段
- **THEN** `FileInfo.from` 应正确解析并存储该值

### Requirement: 回收站彻底删除使用正确的路径
系统 SHALL 使用普通文件删除 API 来彻底删除回收站文件，路径为 `from/rName`。

#### Scenario: 彻底删除回收站文件
- **WHEN** 用户点击彻底删除按钮
- **THEN** 应调用 `/files/delete` API，传递路径为 `from/rName`

#### Scenario: 彻底删除成功
- **WHEN** API 返回成功
- **THEN** 文件应从回收站中移除，页面应刷新

# 文件管理 API 数据模型修复 Spec

## Why
文件管理模块无法正确获取服务器数据，原因是数据模型字段名与 1Panel API 返回的字段名不匹配。

## What Changes
- 修复 `FileInfo` 模型字段名映射
- 添加缺失的 API 响应字段
- 修复 `FileSearch` 请求参数

## Impact
- Affected code: `lib/data/models/file_models.dart`, `lib/api/v2/file_v2.dart`

## ADDED Requirements

### Requirement: 字段名映射正确
系统 SHALL 正确映射 1Panel API 返回的字段名。

#### Scenario: modTime 字段映射
- **WHEN** API 返回 `modTime` 字段
- **THEN** 模型正确解析为 `modifiedAt`

#### Scenario: mode 字段映射
- **WHEN** API 返回 `mode` 字段
- **THEN** 模型正确解析为 `permission`

#### Scenario: linkPath 字段映射
- **WHEN** API 返回 `linkPath` 字段
- **THEN** 模型正确解析为 `linkTarget`

### Requirement: 响应结构正确解析
系统 SHALL 正确解析 1Panel API 的嵌套响应结构。

#### Scenario: 文件列表响应
- **WHEN** API 返回 `{ data: { items: [...], itemTotal: N } }`
- **THEN** 正确提取 items 数组作为文件列表

## MODIFIED Requirements

### Requirement: FileInfo 模型字段
模型 SHALL 包含以下字段（括号内为 API 字段名）：
- `name` (name)
- `path` (path)
- `type` (type)
- `size` (size)
- `permission` (mode)
- `user` (user)
- `group` (group)
- `modifiedAt` (modTime)
- `mimeType` (mimeType)
- `isDir` (isDir)
- `isSymlink` (isSymlink)
- `linkTarget` (linkPath)
- `extension` (extension) - 新增
- `isHidden` (isHidden) - 新增
- `itemTotal` (itemTotal) - 新增
- `children` (items) - 子文件列表

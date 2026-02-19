# 修复文件权限管理功能 Spec

## Why
1. `getFilePermission` 方法错误地调用 `/files/mode` API（这是修改权限的 API，不是获取权限）
2. 文件权限信息应该从文件详情中获取（`response.FileInfo` 包含 `mode`, `user`, `group`）
3. 权限修改 API 请求格式可能不正确

## What Changes
- 修复 `getFilePermission` 方法，从文件详情获取权限信息
- 修复 `updateFileMode` 方法的请求格式
- 修复 `updateFileOwner` 方法的请求格式
- 更新 `FilePermission` 模型以匹配 API 响应

## Impact
- Affected code:
  - `lib/api/v2/file_v2.dart`
  - `lib/data/models/file/file_permission.dart`
  - `lib/features/files/files_service.dart`
  - `lib/features/files/widgets/dialogs/permission_dialog.dart`

## ADDED Requirements
### Requirement: 正确获取文件权限
系统 SHALL 从文件详情 API 获取权限信息。

#### Scenario: 获取文件权限
- **WHEN** 用户打开权限管理对话框
- **THEN** 系统应从文件详情中提取 `mode`, `user`, `group` 信息

## MODIFIED Requirements
### Requirement: 修改文件权限模式
系统 SHALL 使用正确的 API 格式修改文件权限。

#### Scenario: 修改权限模式
- **WHEN** 用户修改文件权限
- **THEN** 系统应调用 `/files/mode` API，请求体包含 `path` 和 `mode`

### Requirement: 修改文件所有者
系统 SHALL 使用正确的 API 格式修改文件所有者。

#### Scenario: 修改所有者
- **WHEN** 用户修改文件所有者
- **THEN** 系统应调用 `/files/owner` API，请求体包含 `path`, `user`, `group`

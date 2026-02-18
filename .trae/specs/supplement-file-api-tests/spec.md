# 补充文件管理 API 测试 Spec

## Why
根据模块适配专属工作流规范，所有新增功能必须有对应的 API 测试验证。当前新增的文件预览、权限管理、回收站恢复、wget 下载等功能缺少 API 测试，需要补充测试以确保请求正确性和返回体结构验证。

## What Changes
- 补充文件预览 API 测试
- 补充文件权限管理 API 测试（chmod/chown）
- 补充回收站恢复 API 测试
- 补充 wget 远程下载 API 测试
- 补充文件编码转换 API 测试
- 补充用户组获取 API 测试

## Impact
- Affected code: `test/api_client/file_api_test.dart`
- 确保所有 API 请求格式正确
- 验证返回体结构与模型定义一致

## ADDED Requirements

### Requirement: API 测试覆盖
所有新增功能的 API 必须有对应的测试用例。

#### Scenario: 文件预览 API 测试
- **WHEN** 调用 `/files/preview` 接口
- **THEN** 返回正确的文件内容

#### Scenario: 权限管理 API 测试
- **WHEN** 调用 `/files/mode` 和 `/files/owner` 接口
- **THEN** 权限修改成功

#### Scenario: wget 下载 API 测试
- **WHEN** 调用 `/files/wget` 接口
- **THEN** 下载任务创建成功

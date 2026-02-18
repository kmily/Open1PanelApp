# 修复测试问题并更新文档 Spec

## Why
chmod/chown 测试失败是因为测试文件创建路径问题，wget 测试失败是因为网络超时。需要修复测试用例并更新文件管理模块文档以反映已实现的功能。

## What Changes
- 修复 chmod/chown 测试用例（使用已存在的文件路径）
- 修复 wget 测试用例（使用更可靠的测试 URL 或跳过网络测试）
- 更新 file_module_index.md 文档
- 更新 file_module_architecture.md 文档

## Impact
- Affected code: 
  - `test/api_client/file_api_test.dart` - 测试用例
  - `docs/development/modules/文件管理/file_module_index.md` - 模块索引
  - `docs/development/modules/文件管理/file_module_architecture.md` - 架构文档

## ADDED Requirements

### Requirement: 测试用例修复
测试用例应使用可靠的方式验证 API 功能。

#### Scenario: chmod/chown 测试使用已存在文件
- **WHEN** 运行权限管理测试
- **THEN** 使用服务器已存在的文件路径（如 /etc/hostname）

#### Scenario: wget 测试使用可靠 URL 或跳过
- **WHEN** 运行 wget 测试
- **THEN** 使用可靠的测试 URL 或标记为跳过

### Requirement: 文档更新
文档应反映已实现的功能。

#### Scenario: 更新模块索引
- **WHEN** 查看模块索引
- **THEN** 显示所有已实现的功能状态

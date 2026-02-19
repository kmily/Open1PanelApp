# 文件管理 API 测试完善 Spec

## Why
文件管理模块无法正确加载数据，需要创建全面的 API 测试来验证请求和响应解析是否正确。

## What Changes
- 创建完整的文件 API 测试文件，覆盖 `file_api_analysis.json` 中所有 File 标签端点
- 验证请求格式和响应解析
- 添加详细的日志输出便于调试

## Impact
- Affected code: `test/api_client/file_api_test.dart`

## ADDED Requirements

### Requirement: 文件 API 测试覆盖
系统 SHALL 提供完整的文件 API 测试，覆盖所有 File 标签端点。

#### Scenario: 文件搜索测试
- **WHEN** 执行 `POST /files/search` 请求
- **THEN** 正确解析响应数据并显示文件列表

#### Scenario: 文件检查测试
- **WHEN** 执行 `POST /files/check` 请求
- **THEN** 正确返回文件是否存在的结果

#### Scenario: 文件树测试
- **WHEN** 执行 `POST /files/tree` 请求
- **THEN** 正确解析文件树结构

#### Scenario: 回收站测试
- **WHEN** 执行回收站相关 API 请求
- **THEN** 正确解析回收站状态和内容

### Requirement: 测试输出详细日志
测试 SHALL 输出详细的请求和响应日志，便于调试问题。

#### Scenario: 请求日志
- **WHEN** 发送 API 请求
- **THEN** 输出请求路径、参数和请求体

#### Scenario: 响应日志
- **WHEN** 收到 API 响应
- **THEN** 输出响应状态码、原始数据和解析后的模型

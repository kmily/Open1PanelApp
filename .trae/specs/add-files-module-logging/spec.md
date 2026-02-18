# 文件管理模块日志增强 Spec

## Why
文件管理模块的删除、移动、重命名、压缩等操作在UI层无法正常工作，但API测试全部通过。需要添加详细的日志记录来定位问题根源。

## What Changes
- 在 `files_provider.dart` 中添加操作前后的日志记录
- 在 `files_service.dart` 中添加API调用日志记录
- 在 `files_page.dart` 中添加UI事件日志记录
- 记录请求参数、响应结果、错误信息

## Impact
- Affected code: 
  - `lib/features/files/files_provider.dart`
  - `lib/features/files/files_service.dart`
  - `lib/features/files/files_page.dart`

## ADDED Requirements

### Requirement: Provider层日志记录
系统 SHALL 在Provider层记录所有文件操作的日志。

#### Scenario: 操作开始日志
- **WHEN** 执行文件操作时
- **THEN** 记录操作名称和参数

#### Scenario: 操作成功日志
- **WHEN** 文件操作成功时
- **THEN** 记录操作成功信息

#### Scenario: 操作失败日志
- **WHEN** 文件操作失败时
- **THEN** 记录错误信息和堆栈

### Requirement: Service层日志记录
系统 SHALL 在Service层记录API调用详情。

#### Scenario: API请求日志
- **WHEN** 调用API时
- **THEN** 记录请求端点和参数

#### Scenario: API响应日志
- **WHEN** 收到API响应时
- **THEN** 记录响应状态和数据

### Requirement: UI层日志记录
系统 SHALL 在UI层记录用户交互事件。

#### Scenario: 按钮点击日志
- **WHEN** 用户点击操作按钮时
- **THEN** 记录点击事件

#### Scenario: 对话框操作日志
- **WHEN** 用户在对话框中操作时
- **THEN** 记录操作详情

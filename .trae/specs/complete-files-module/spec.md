# 文件管理模块完善 Spec

## Why
文件管理模块的 UI 层存在占位符文案，服务器选择器未显示服务器列表，需要完善整个架构使其完全可用。

## What Changes
- 更新 i18n 字符串，移除占位符文案
- 完善服务器选择器，显示可用服务器列表
- 确保所有文件操作功能正常工作

## Impact
- Affected code: `lib/l10n/app_*.arb`, `lib/features/files/files_page.dart`

## ADDED Requirements

### Requirement: 空状态文案更新
系统 SHALL 显示正确的空状态文案，而非占位符文案。

#### Scenario: 空目录显示
- **WHEN** 用户打开一个空目录
- **THEN** 显示 "此文件夹为空" 而非 "文件页占位已完成"

### Requirement: 服务器选择器功能
系统 SHALL 在文件页面提供服务器切换功能。

#### Scenario: 服务器切换
- **WHEN** 用户点击服务器选择器
- **THEN** 显示所有已配置的服务器列表
- **AND** 当前服务器有选中标记

#### Scenario: 切换服务器
- **WHEN** 用户选择另一个服务器
- **THEN** 文件列表刷新为新服务器的文件

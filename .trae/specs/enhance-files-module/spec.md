# 文件管理模块完整功能实现 Spec

## Why
文件管理模块目前只能列出文件，缺少基本的文件操作功能和导航功能，无法进行有效的文件管理。

## What Changes
- 添加面包屑导航和返回上级功能
- 实现文件/文件夹操作：删除、重命名、移动、复制、新建
- 添加文件详情查看功能
- 完善所有 File API 端点测试

## Impact
- Affected code: `lib/features/files/files_page.dart`, `lib/features/files/files_provider.dart`, `lib/features/files/files_service.dart`, `test/api_client/file_api_test.dart`

## ADDED Requirements

### Requirement: 文件夹导航功能
系统 SHALL 提供便捷的文件夹导航功能。

#### Scenario: 进入文件夹
- **WHEN** 用户点击文件夹
- **THEN** 进入该文件夹并显示其内容

#### Scenario: 返回上级文件夹
- **WHEN** 用户点击返回按钮或面包屑导航
- **THEN** 返回上一级目录并显示内容

#### Scenario: 面包屑导航
- **WHEN** 用户查看当前路径
- **THEN** 显示面包屑导航条，可点击任意层级直接跳转

### Requirement: 文件操作功能
系统 SHALL 提供完整的文件操作功能。

#### Scenario: 删除文件
- **WHEN** 用户选择文件并点击删除
- **THEN** 显示确认对话框，确认后删除文件

#### Scenario: 重命名文件
- **WHEN** 用户选择文件并点击重命名
- **THEN** 显示重命名对话框，输入新名称后重命名

#### Scenario: 新建文件夹
- **WHEN** 用户点击新建文件夹按钮
- **THEN** 显示对话框，输入名称后创建文件夹

#### Scenario: 移动文件
- **WHEN** 用户选择文件并点击移动
- **THEN** 显示目录选择器，选择目标目录后移动文件

#### Scenario: 复制文件
- **WHEN** 用户选择文件并点击复制
- **THEN** 显示目录选择器，选择目标目录后复制文件

### Requirement: 文件详情查看
系统 SHALL 提供文件详情查看功能。

#### Scenario: 查看文件详情
- **WHEN** 用户长按或点击详情
- **THEN** 显示文件详细信息（大小、权限、修改时间等）

#### Scenario: 查看文本文件内容
- **WHEN** 用户点击文本文件
- **THEN** 显示文件内容预览

### Requirement: API 测试覆盖
系统 SHALL 完整测试所有 File API 端点。

#### Scenario: 删除文件测试
- **WHEN** 执行 `POST /files/del` 请求
- **THEN** 正确删除指定文件

#### Scenario: 重命名文件测试
- **WHEN** 执行 `POST /files/rename` 请求
- **THEN** 正确重命名文件

#### Scenario: 移动文件测试
- **WHEN** 执行 `POST /files/move` 请求
- **THEN** 正确移动文件到目标位置

#### Scenario: 复制文件测试
- **WHEN** 执行 `POST /files/copy` 请求
- **THEN** 正确复制文件到目标位置

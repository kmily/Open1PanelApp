# 完善文件管理功能 Spec

## Why
根据 1Panel API 分析，已有大量文件操作 API 实现，但 UI 功能尚未完全覆盖。需要实现文件预览、文件编辑器、文件下载、权限管理、回收站、收藏夹、远程下载等常规文件管理器功能。

## What Changes
- 实现文件预览功能（文本、图片、代码高亮）
- 完善文件编辑器（支持保存、编码选择）
- 实现文件下载功能（保存到本地）
- 实现文件权限管理 UI
- 实现回收站管理页面
- 实现收藏夹功能
- 实现 wget 远程下载功能
- 实现文件编码转换功能

## Impact
- Affected code: 
  - `lib/features/files/files_page.dart` - 添加新功能入口
  - `lib/features/files/files_provider.dart` - 添加状态管理
  - 新增文件预览页面、编辑器页面、权限管理页面等

## ADDED Requirements

### Requirement: 文件预览功能
系统应支持预览常见文件类型。

#### Scenario: 预览文本文件
- **WHEN** 用户点击文本文件
- **THEN** 显示文件内容，支持代码高亮

#### Scenario: 预览图片文件
- **WHEN** 用户点击图片文件（jpg, png, gif, webp）
- **THEN** 显示图片预览

### Requirement: 文件编辑器
系统应支持编辑文本文件。

#### Scenario: 编辑文本文件
- **WHEN** 用户选择编辑文件
- **THEN** 显示编辑器，支持修改和保存

### Requirement: 文件下载
系统应支持下载文件到本地设备。

#### Scenario: 下载文件
- **WHEN** 用户选择下载文件
- **THEN** 文件保存到设备下载目录

### Requirement: 文件权限管理
系统应支持修改文件权限和所有者。

#### Scenario: 修改权限
- **WHEN** 用户选择权限管理
- **THEN** 显示权限编辑对话框，支持修改 mode 和 owner

### Requirement: 回收站管理
系统应支持查看和恢复回收站文件。

#### Scenario: 查看回收站
- **WHEN** 用户进入回收站
- **THEN** 显示已删除文件列表，支持恢复或彻底删除

### Requirement: 收藏夹功能
系统应支持收藏常用文件/文件夹。

#### Scenario: 收藏文件
- **WHEN** 用户选择收藏文件
- **THEN** 文件添加到收藏夹

### Requirement: 远程下载
系统应支持 wget 远程下载。

#### Scenario: wget 下载
- **WHEN** 用户输入 URL
- **THEN** 服务器下载文件到指定目录

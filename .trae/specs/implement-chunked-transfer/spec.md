# 大文件分块传输优化 Spec

## Why
1. 大文件上传下载时容易超时或失败，需要断点续传功能
2. 网络不稳定时需要支持并发传输提高效率
3. 用户体验需要实时进度显示和传输状态管理

## What Changes
- 实现分块上传管理器（支持断点续传）
- 实现分块下载管理器（支持断点续传）
- 添加传输进度跟踪和状态管理
- 添加并发传输控制
- 添加传输队列管理

## Impact
- Affected code:
  - `lib/core/services/transfer/` (新建)
  - `lib/features/files/files_service.dart`
  - `lib/features/files/files_provider.dart`
  - `lib/features/files/widgets/transfer_dialog.dart` (新建)
  - `lib/l10n/app_zh.arb`
  - `lib/l10n/app_en.arb`

## API Support
1Panel V2 API 已支持：
- `POST /files/chunkupload` - 分块上传
- `POST /files/chunkdownload` - 分块下载

## ADDED Requirements
### Requirement: 分块上传
系统 SHALL 支持大文件分块上传。

#### Scenario: 分块上传文件
- **WHEN** 用户上传大文件（>10MB）
- **THEN** 系统应自动分块上传，显示进度

#### Scenario: 断点续传
- **WHEN** 上传中断后重新上传
- **THEN** 系统应从断点继续上传，而非重新开始

### Requirement: 分块下载
系统 SHALL 支持大文件分块下载。

#### Scenario: 分块下载文件
- **WHEN** 用户下载大文件（>10MB）
- **THEN** 系统应自动分块下载，显示进度

#### Scenario: 断点续传下载
- **WHEN** 下载中断后重新下载
- **THEN** 系统应从断点继续下载

### Requirement: 传输状态管理
系统 SHALL 提供传输状态管理。

#### Scenario: 查看传输状态
- **WHEN** 用户查看传输列表
- **THEN** 系统应显示所有传输任务的状态、进度、速度

#### Scenario: 暂停/恢复传输
- **WHEN** 用户暂停或恢复传输任务
- **THEN** 系统应正确处理暂停/恢复操作

### Requirement: 并发传输
系统 SHALL 支持并发传输。

#### Scenario: 并发上传
- **WHEN** 多个分块同时上传
- **THEN** 系统应控制并发数量，避免资源耗尽

## Not Implemented
### 文件分享功能
**原因**: 1Panel V2 API 不支持文件分享功能（无生成分享链接的 API 端点）

需要后端支持的功能：
- 生成临时分享链接
- 设置过期时间
- 访问权限控制

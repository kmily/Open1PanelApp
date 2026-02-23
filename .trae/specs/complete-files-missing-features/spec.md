# 文件管理缺口功能补齐（大文件预览/编码/属性/搜索等）Spec

## Why
文件管理模块的 File API 已较完整，但多项端点与能力尚未在 UI/业务层落地，导致大文件预览卡顿、编辑器编码设置无效、缺少属性面板/内容搜索等问题。

## What Changes
- 大文件预览与按行读取：
  - 基于 `POST /files/preview`（按行）与 `POST /files/read`（offset/length）实现大文本文件的分页/增量加载
  - 小文件继续使用现有内容获取方式，避免过度复杂
- 文件编辑器编码链路打通：
  - 读取时使用 `FileRead.encoding`（`POST /files/read`）
  - 保存时使用 `FileSave.encoding`（`POST /files/save`）而不是仅固定走默认写入
  - 提供“编码转换”入口：`POST /files/encoding/convert` + 查看日志 `POST /files/convert/log`
- 文件属性面板（properties）：
  - 落地 `POST /files/properties` 并提供可复用的“属性/详情”展示组件
- 文件链接（link/create）：
  - 落地 `POST /files/link/create`（创建符号链接能力），并在 UI 明确该功能为“符号链接”而非分享链接
- 内容搜索（search/in）：
  - 落地 `POST /files/search/in`，提供结果列表与定位到预览行的能力
- 上传列表查询（upload/search）：
  - 落地 `POST /files/upload/search`（上传历史/记录查询入口），并与现有上传任务列表做整合展示
- 批量能力增强：
  - 在现有多选基础上系统化对接 `POST /files/batch/operate`、`POST /files/batch/check`、`POST /files/batch/change/role` 等
- 挂载信息（mount）轻量接入：
  - 使用 `POST /files/mount` 提供“挂载点信息/快捷跳转”入口（不做复杂磁盘可视化）
- 分块下载（chunkdownload）策略：本轮暂缓
  - 当前下载链路已支持 Range 断点续传，可满足大文件下载需求
  - `POST /files/chunkdownload` 保留接口与模型，待后续确认收益后再落地

## Impact
- Affected specs:
  - `enhance-file-preview`（文件类型扩展仍可并行）
  - `implement-chunked-transfer`（需修订“文件分享不支持”的过时结论；link/create 为符号链接）
- Affected code:
  - `lib/api/v2/file_v2.dart`（已存在，主要是调用链补齐）
  - `lib/features/files/file_preview_page.dart`
  - `lib/features/files/file_editor_page.dart`
  - `lib/features/files/files_provider.dart`
  - `lib/features/files/files_service.dart`
  - `lib/l10n/app_zh.arb` / `lib/l10n/app_en.arb`
  - 可能新增：`lib/features/files/widgets/` 下的属性面板/搜索页等组件

## ADDED Requirements

### Requirement: 大文件预览与按行加载
系统 SHALL 在预览大文本文件时使用 `preview/read` 进行分页/增量加载，避免一次性拉取全文导致卡顿或内存峰值。

#### Scenario: 预览大文件（按行）
- **WHEN** 用户打开一个文本文件且 `FileInfo.size` 超过阈值（例如 ≥ 1MB）
- **THEN** 系统应调用 `POST /files/preview` 拉取首屏（默认 line=1, limit=200）
- **AND** 用户继续向下滚动时应增量加载后续行（例如每次追加 200 行）

#### Scenario: 跳转到指定行
- **WHEN** 用户从“内容搜索结果”点击某条匹配项
- **THEN** 系统应以匹配行号为中心调用 `POST /files/preview` 获取相邻若干行并滚动定位

### Requirement: 编辑器编码设置生效
系统 SHALL 让编辑器的编码选择影响读取与保存行为。

#### Scenario: 以指定编码读取文件
- **WHEN** 用户在编辑器中选择某种编码（例如 GBK）
- **THEN** 系统应调用 `POST /files/read` 并携带 `encoding`
- **AND** 编辑器应刷新内容显示

#### Scenario: 以指定编码保存文件
- **WHEN** 用户在编辑器中保存文件
- **THEN** 系统应调用 `POST /files/save` 并携带 `encoding`

### Requirement: 文件编码转换与日志
系统 SHALL 提供文件编码转换入口与可追踪日志。

#### Scenario: 转换文件编码
- **WHEN** 用户在编辑器/文件菜单中选择“转换编码”
- **THEN** 系统应调用 `POST /files/encoding/convert`
- **AND** 成功后提示转换结果（含备份路径若开启 backup）

#### Scenario: 查看转换日志
- **WHEN** 用户在转换完成后选择“查看日志”
- **THEN** 系统应调用 `POST /files/convert/log` 并展示日志内容

### Requirement: 文件属性面板
系统 SHALL 提供可从文件列表与预览页进入的属性面板。

#### Scenario: 查看文件属性
- **WHEN** 用户在文件条目菜单中点击“属性”
- **THEN** 系统应调用 `POST /files/properties`
- **AND** 展示常用字段（大小、权限、所有者、组、时间、链接目标等）

### Requirement: 内容搜索（search/in）
系统 SHALL 支持在指定目录内进行内容搜索并展示可定位结果。

#### Scenario: 搜索并打开命中位置
- **WHEN** 用户输入 pattern 并提交搜索
- **THEN** 系统应调用 `POST /files/search/in`
- **AND** 显示命中列表（文件路径、行号、命中片段）
- **AND** 点击结果可打开预览并定位到命中行

### Requirement: 文件链接（符号链接）
系统 SHALL 提供创建符号链接能力，并在 UI 上明确这是“符号链接”。

#### Scenario: 创建符号链接
- **WHEN** 用户选择文件并创建链接（输入目标路径）
- **THEN** 系统应调用 `POST /files/link/create` 完成创建

### Requirement: 分块下载（chunkdownload）暂缓
系统 SHALL 在本轮不落地 chunkdownload 下载任务系统，继续使用现有 Range 断点续传下载链路。

## MODIFIED Requirements

### Requirement: 文件预览数据源选择
系统 SHALL 根据文件大小与类型选择数据源：小文本用现有方式，大文本用 preview/read 分页。

## REMOVED Requirements

### Requirement: “文件分享不支持”结论
**Reason**: 现有 `POST /files/link/create` 提供的是“符号链接”能力，但不等价于“分享链接”。此前结论混淆了概念。
**Migration**: UI 文案统一为“符号链接”，分享链接功能若需要需后端新增独立端点。

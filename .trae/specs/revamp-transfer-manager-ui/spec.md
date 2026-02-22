# 传输管理页面改版与“打开位置”修复 Spec

## Why
当前“传输管理”存在可用性与一致性问题：Android 上点击“打开位置”会抛出 UnsupportedError，且 Toast/SnackBar 展示不够符合 MDUI3；同时页面信息架构为“三个 Tab（进行中/等待中/已完成）”导致用户难以按“上传/下载”快速定位任务。

## What Changes
- 修复 Android 上“打开位置/打开文件”能力：
  - **BREAKING**: 将下载任务完成态的主操作从“打开位置”调整为“打开文件”（更符合移动端预期）
  - 提供“更多”操作：打开下载目录（尽力而为）/ 复制文件路径
- 优化提示反馈（SnackBar/Toast）：
  - 使用 Material 3 风格的浮动 SnackBar（圆角、边距、可关闭/带 action）
  - 避免抛出原始异常信息给用户（保持可读、可行动）
- 重构传输管理信息架构：
  - 将“进行中 + 等待中”合并为同一页面的分组展示
  - 按“下载 / 上传”作为一级分组（移动端用切换控件；大屏支持双栏）
  - “进行中/等待中/已完成”等状态用分组标题 + 状态 Chip 标记，不再依赖三 Tab
- 统一按钮文字与行为一致性：重试/暂停/继续/删除/打开 等动作与状态严格匹配

## Impact
- Affected specs:
  - `fix-transfer-manager-issues`（已完成的修复保持不回退）
- Affected code:
  - `lib/core/services/file_save_service.dart`（补齐打开文件/目录能力与平台降级）
  - `lib/features/files/transfer_manager_page.dart`（UI 信息架构与交互重构）
  - `lib/l10n/app_zh.arb` / `lib/l10n/app_en.arb`（新增文案）
  - Android 侧可能需要新增依赖（如 open_filex / android_intent_plus）并做相应配置

## ADDED Requirements

### Requirement: Android 可用的“打开”能力
系统 SHALL 在 Android 上提供可用的“打开文件”能力，并对“打开目录”提供合理降级。

#### Scenario: 下载完成后打开文件
- **WHEN** 用户在传输管理中点击已完成下载任务的主操作按钮
- **THEN** 系统应尝试打开该文件
- **AND** 若无法打开，应提示原因并提供“复制路径”等替代动作

#### Scenario: 打开下载目录（尽力而为）
- **WHEN** 用户选择“打开下载目录”
- **THEN** 系统应尝试唤起系统文件管理器并定位到 Download 目录
- **AND** 若系统不支持定位目录，则应提示并提供“复制目录路径”

### Requirement: 提示反馈遵循 MDUI3
系统 SHALL 使用 Material 3 推荐的提示组件与样式（SnackBar/BottomSheet），避免系统 Toast 风格的不一致体验。

#### Scenario: 打开失败提示
- **WHEN** 打开文件或打开目录失败
- **THEN** 系统应展示浮动 SnackBar（带 action，例如“复制路径”）
- **AND** 文案应来自 l10n，不允许硬编码

### Requirement: 传输页面信息架构调整
系统 SHALL 将“进行中/等待中”合并，并按“下载/上传”作为一级分组。

#### Scenario: 手机窄屏
- **WHEN** 屏幕宽度较小（手机）
- **THEN** 页面应提供“下载/上传”切换（TabBar 或 SegmentedButton）
- **AND** 每个分组内部以 Section（进行中/已完成）分组展示

#### Scenario: 平板/横屏宽屏
- **WHEN** 屏幕宽度达到阈值（例如 ≥ 840dp）
- **THEN** 页面应使用双栏并排展示“下载”和“上传”
- **AND** 每栏内部使用 Section 分组展示

## MODIFIED Requirements

### Requirement: 下载任务“已完成”的定义
系统 SHALL 将 `failed && progress==100` 视为“已完成但打开失败/收尾失败”，在 UI 上按完成态展示（允许提供修复/打开操作），且不误导为真实下载失败。

## REMOVED Requirements

### Requirement: 已完成任务主操作为“打开位置”
**Reason**: Android 平台无法直接“打开文件所在目录”且当前实现抛出 UnsupportedError，用户操作必失败。
**Migration**: 主操作改为“打开文件”，目录定位作为“更多操作”并提供降级路径（复制路径）。 


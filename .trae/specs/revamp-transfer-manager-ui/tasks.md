# Tasks

- [x] Task 1: 设计并落地“打开文件/打开目录”跨平台策略
  - [x] SubTask 1.1: 审计现有 `FileSaveService.openFile/openFileLocation` 的平台支持与缺口
  - [x] SubTask 1.2: 选择并引入必要依赖（如 open_filex、android_intent_plus），补齐 Android 打开文件能力
  - [x] SubTask 1.3: 为 Android 实现“打开下载目录”的尽力而为方案与降级（复制路径）
  - [x] SubTask 1.4: 为桌面平台保持现有打开目录能力不回退

- [x] Task 2: 传输管理页面信息架构改版（下载/上传为一级分组）
  - [x] SubTask 2.1: 窄屏使用切换控件（TabBar/SegmentedButton）在“下载/上传”间切换
  - [x] SubTask 2.2: 宽屏（≥840dp）使用双栏布局并排展示“下载/上传”
  - [x] SubTask 2.3: 每个分组内部以 Section 分组（进行中/已完成），状态用 Chip 标记

- [x] Task 3: 优化任务卡片与操作区（MDUI3）
  - [x] SubTask 3.1: 卡片使用 MD3 的间距、圆角与按钮层级（Filled/Outlined/Text）
  - [x] SubTask 3.2: “failed + progress==100” 显示为完成态，并提供修复/打开入口
  - [x] SubTask 3.3: 按钮文案与行为严格匹配（重试/暂停/继续/删除/打开）

- [x] Task 4: 统一提示反馈为 Material 3 浮动 SnackBar
  - [x] SubTask 4.1: 设计统一的提示方法（可选：封装 helper），默认 floating + close + action
  - [x] SubTask 4.2: 打开失败提示提供可行动作（复制路径/重试）

- [ ] Task 5: 国际化与验证
  - [x] SubTask 5.1: 补齐新增文案到 `app_zh.arb`/`app_en.arb` 并生成 l10n
  - [x] SubTask 5.2: `flutter analyze lib` 通过
  - [ ] SubTask 5.3: 真机/模拟器验证：打开文件、打开目录降级、任务分组与按钮行为正确

# Task Dependencies
- Task 3 depends on Task 2
- Task 4 depends on Task 2
- Task 5 depends on Task 1-4

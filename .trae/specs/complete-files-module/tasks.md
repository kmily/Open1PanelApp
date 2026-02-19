# Tasks

- [x] Task 1: 更新 i18n 空状态文案
  - [x] SubTask 1.1: 更新 `app_zh.arb` 中的 `filesEmptyTitle` 和 `filesEmptyDesc`
  - [x] SubTask 1.2: 更新 `app_en.arb` 中的 `filesEmptyTitle` 和 `filesEmptyDesc`
  - [x] SubTask 1.3: 重新生成 l10n 代码

- [x] Task 2: 完善服务器选择器功能
  - [x] SubTask 2.1: 在 `_buildServerSelector` 中加载服务器列表
  - [x] SubTask 2.2: 显示服务器列表项，标记当前选中服务器
  - [x] SubTask 2.3: 实现服务器切换逻辑

- [x] Task 3: 验证构建通过
  - [x] SubTask 3.1: 运行 `flutter build apk --debug` 验证

# Task Dependencies
- Task 2 依赖 Task 1（i18n 字符串需要先更新）
- Task 3 依赖 Task 1 和 Task 2

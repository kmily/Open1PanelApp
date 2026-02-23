# Tasks

- [ ] Task 1: 落地大文件预览按行加载（preview/read）
  - [ ] SubTask 1.1: 为预览页引入“按大小分流”策略（阈值可配置）
  - [ ] SubTask 1.2: 实现 `/files/preview` 分页加载与滚动追加
  - [ ] SubTask 1.3: 实现“跳转到行”能力（供内容搜索定位复用）

- [ ] Task 2: 修复编辑器编码链路并补齐编码转换/日志
  - [ ] SubTask 2.1: 编辑器读取走 `/files/read` 并传递 encoding
  - [ ] SubTask 2.2: 编辑器保存走 `/files/save` 并传递 encoding
  - [ ] SubTask 2.3: 增加“转换编码”入口（`/files/encoding/convert`）
  - [ ] SubTask 2.4: 增加“查看转换日志”入口（`/files/convert/log`）

- [ ] Task 3: 增加文件属性面板（properties）与符号链接创建（link/create）
  - [ ] SubTask 3.1: 从文件列表与预览页接入属性面板（bottom sheet/page）
  - [ ] SubTask 3.2: 接入 `/files/properties` 并展示关键字段
  - [ ] SubTask 3.3: 接入 `/files/link/create` 并将 UI 文案明确为“符号链接”

- [ ] Task 4: 增加内容搜索页（search/in）并联动预览定位
  - [ ] SubTask 4.1: 增加搜索入口（文件页 AppBar 或更多菜单）
  - [ ] SubTask 4.2: 接入 `/files/search/in` 并展示结果列表（文件/行/片段）
  - [ ] SubTask 4.3: 点击结果打开预览并定位行（复用 Task 1.3）

- [ ] Task 5: 上传历史（upload/search）与批量能力增强（batch/*）
  - [ ] SubTask 5.1: 增加上传历史入口并接入 `/files/upload/search`
  - [ ] SubTask 5.2: 批量操作对接 `/files/batch/operate`
  - [ ] SubTask 5.3: 批量检查/权限对接 `/files/batch/check`、`/files/batch/change/role`

- [ ] Task 6: 挂载信息（mount）轻量接入
  - [ ] SubTask 6.1: 增加挂载点列表入口并接入 `/files/mount`
  - [ ] SubTask 6.2: 提供“跳转到挂载点路径”的导航能力

- [ ] Task 7: chunkdownload 暂缓（Range 断点续传已满足需求）
  - [ ] SubTask 7.1: 保留接口与模型，不在本轮落地 UI/任务系统
  - [ ] SubTask 7.2: 后续如需接入，优先评估与现有 Range 下载策略的收益对比

- [ ] Task 8: 国际化与验证
  - [ ] SubTask 8.1: 补齐新增文案到 `app_zh.arb`/`app_en.arb` 并生成 l10n
  - [ ] SubTask 8.2: 补齐/更新相关测试（优先：预览分页、编码保存调用、search/in 解析）
  - [ ] SubTask 8.3: `flutter analyze lib` 通过，关键路径手测通过

# Task Dependencies
- Task 4 depends on Task 1
- Task 8 depends on Task 1-6

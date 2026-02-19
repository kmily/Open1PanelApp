# Tasks

- [x] Task 1: 分析 API 文档确认正确的权限 API
  - [x] SubTask 1.1: 确认 `/files/mode` 是修改权限 API
  - [x] SubTask 1.2: 确认权限信息从文件详情获取
  - [x] SubTask 1.3: 确认请求/响应格式

- [x] Task 2: 修复 `getFilePermission` 方法
  - [x] SubTask 2.1: 移除错误的 `/files/mode` 调用
  - [x] SubTask 2.2: 从文件详情中提取权限信息
  - [x] SubTask 2.3: 更新 `FilePermission` 模型

- [x] Task 3: 修复权限修改 API
  - [x] SubTask 3.1: 修复 `updateFileMode` 请求格式
  - [x] SubTask 3.2: 修复 `updateFileOwner` 请求格式

- [x] Task 4: 更新权限对话框
  - [x] SubTask 4.1: 适配新的权限模型
  - [x] SubTask 4.2: 修复权限保存逻辑

- [x] Task 5: 验证修复
  - [x] SubTask 5.1: 运行 flutter analyze
  - [x] SubTask 5.2: 测试权限加载
  - [x] SubTask 5.3: 测试权限修改

# Task Dependencies
- Task 2 依赖 Task 1
- Task 3 依赖 Task 1
- Task 4 依赖 Task 2 和 Task 3
- Task 5 依赖 Task 1-4

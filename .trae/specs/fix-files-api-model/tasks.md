# Tasks

- [x] Task 1: 修复 FileInfo 模型字段映射
  - [x] SubTask 1.1: 添加 `modTime` → `modifiedAt` 字段映射
  - [x] SubTask 1.2: 添加 `mode` → `permission` 字段映射
  - [x] SubTask 1.3: 添加 `linkPath` → `linkTarget` 字段映射
  - [x] SubTask 1.4: 添加缺失字段：`extension`, `isHidden`, `itemTotal`, `favoriteID`, `gid`, `isDetail`
  - [x] SubTask 1.5: 修复 `children` 字段映射为 `items`

- [x] Task 2: 修复 FileSearch 请求参数
  - [x] SubTask 2.1: 添加缺失参数：`containSub`, `dir`, `showHidden`, `isDetail`

- [x] Task 3: 修复 API 响应解析
  - [x] SubTask 3.1: 修复 `searchFiles` 响应解析，正确处理 `response.FileInfo` 结构

- [x] Task 4: 验证构建通过
  - [x] SubTask 4.1: 运行 `flutter build apk --debug` 验证

# Task Dependencies
- Task 3 依赖 Task 1 和 Task 2
- Task 4 依赖 Task 1, 2, 3

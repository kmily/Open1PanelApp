# Tasks

- [x] Task 1: 实现文件预览功能
  - [x] SubTask 1.1: 创建 `FilePreviewPage` 页面，支持文本文件预览
  - [x] SubTask 1.2: 添加代码高亮支持（使用 flutter_highlight 库）
  - [x] SubTask 1.3: 支持图片预览（jpg, png, gif, webp）
  - [x] SubTask 1.4: 在文件列表中添加点击预览入口

- [x] Task 2: 实现文件编辑器
  - [x] SubTask 2.1: 创建 `FileEditorPage` 页面
  - [x] SubTask 2.2: 支持文本编辑和保存
  - [x] SubTask 2.3: 添加编码选择功能
  - [x] SubTask 2.4: 添加编辑入口（长按菜单）

- [x] Task 3: 实现文件下载功能
  - [x] SubTask 3.1: 添加 `path_provider` 依赖
  - [x] SubTask 3.2: 实现 `downloadFile` 方法，保存到设备下载目录
  - [x] SubTask 3.3: 添加下载进度显示
  - [x] SubTask 3.4: 添加下载入口（长按菜单）

- [x] Task 4: 实现文件权限管理
  - [x] SubTask 4.1: 创建权限编辑对话框
  - [x] SubTask 4.2: 支持 chmod 操作（修改 mode）
  - [x] SubTask 4.3: 支持 chown 操作（修改 owner/group）
  - [x] SubTask 4.4: 添加权限管理入口

- [x] Task 5: 实现回收站管理
  - [x] SubTask 5.1: 创建 `RecycleBinPage` 页面
  - [x] SubTask 5.2: 显示回收站文件列表
  - [x] SubTask 5.3: 支持恢复文件
  - [x] SubTask 5.4: 支持彻底删除
  - [x] SubTask 5.5: 添加回收站入口（AppBar 菜单）

- [x] Task 6: 实现收藏夹功能
  - [x] SubTask 6.1: 添加收藏/取消收藏入口
  - [x] SubTask 6.2: 创建收藏夹页面显示收藏列表
  - [x] SubTask 6.3: 添加收藏夹入口（AppBar 菜单）

- [x] Task 7: 实现 wget 远程下载
  - [x] SubTask 7.1: 创建 wget 下载对话框
  - [x] SubTask 7.2: 输入 URL 和目标路径
  - [x] SubTask 7.3: 添加 wget 入口（创建菜单）

- [x] Task 8: 验证功能
  - [x] SubTask 8.1: 运行 `flutter analyze` 验证代码
  - [ ] SubTask 8.2: 手动测试所有新功能

# Task Dependencies
- Task 1, 2, 3, 4, 5, 6, 7 可以并行执行
- Task 8 依赖所有其他任务

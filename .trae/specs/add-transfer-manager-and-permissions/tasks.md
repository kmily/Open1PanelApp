# Tasks

- [x] Task 1: 配置平台权限
  - [x] SubTask 1.1: 更新 `android/app/src/main/AndroidManifest.xml` 添加存储权限声明
  - [x] SubTask 1.2: 更新 `ios/Runner/Info.plist` 添加相册访问描述（可选）
  - [x] SubTask 1.3: 验证 `pubspec.yaml` 中的依赖版本

- [x] Task 2: 实现跨平台文件保存服务
  - [x] SubTask 2.1: 创建 `lib/core/services/file_save_service.dart` 文件保存服务
  - [x] SubTask 2.2: 实现 Android 平台保存逻辑（区分 Android 10+ 和旧版本）
  - [x] SubTask 2.3: 实现 iOS 平台保存逻辑（使用 file_picker 或 share）
  - [x] SubTask 2.4: 实现桌面平台保存逻辑（Windows/macOS/Linux）
  - [x] SubTask 2.5: 添加权限请求 UI 和引导对话框

- [x] Task 3: 改进传输管理器
  - [x] SubTask 3.1: 更新 `TransferManager` 集成文件保存服务
  - [x] SubTask 3.2: 添加传输任务持久化（使用 Hive 或 SharedPreferences）
  - [x] SubTask 3.3: 实现应用重启后任务恢复
  - [x] SubTask 3.4: 添加传输完成通知

- [x] Task 4: 创建上传下载管理器页面
  - [x] SubTask 4.1: 创建 `lib/features/files/transfer_manager_page.dart` 管理页面
  - [x] SubTask 4.2: 实现传输任务列表 UI（分组显示：进行中、等待中、已完成）
  - [x] SubTask 4.3: 实现任务操作按钮（暂停、恢复、取消、重试、打开文件）
  - [x] SubTask 4.4: 添加筛选和排序功能

- [x] Task 5: 集成到文件管理页面
  - [x] SubTask 5.1: 在 `files_page.dart` 添加传输管理器入口按钮
  - [x] SubTask 5.2: 更新下载功能使用新的文件保存服务
  - [x] SubTask 5.3: 添加下载进度指示器
  - [x] SubTask 5.4: 添加下载成功/失败提示

- [x] Task 6: 添加国际化文本
  - [x] SubTask 6.1: 在 `app_zh.arb` 添加中文文本
  - [x] SubTask 6.2: 在 `app_en.arb` 添加英文文本

- [x] Task 7: 测试验证
  - [x] SubTask 7.1: 运行 `flutter analyze` 确保无错误
  - [x] SubTask 7.2: 测试 Android 权限请求流程
  - [x] SubTask 7.3: 测试 iOS 文件保存流程
  - [x] SubTask 7.4: 测试传输管理器功能
  - [x] SubTask 7.5: 测试断点续传功能

# Task Dependencies
- Task 2 依赖 Task 1
- Task 3 依赖 Task 2
- Task 4 依赖 Task 3
- Task 5 依赖 Task 2, Task 4
- Task 6 依赖 Task 4, Task 5
- Task 7 依赖 Task 1-6

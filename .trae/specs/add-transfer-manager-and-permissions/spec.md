# 上传下载管理器与文件保存权限处理 Spec

## Why
1. 当前分块传输功能已实现，但缺少独立的上传下载管理页面入口
2. 文件下载保存时权限处理不完善，Android 缺少必要的权限声明，iOS 需要使用文件选择器保存
3. 用户需要能够查看、暂停、恢复、取消传输任务

## What Changes
- 添加上传下载管理器页面（独立入口）
- 完善 Android 平台存储权限声明
- 实现 iOS 文件保存选择器（使用 file_picker 或 share_plus）
- 统一跨平台文件保存流程
- 添加传输任务通知和状态持久化

## Impact
- Affected code:
  - `android/app/src/main/AndroidManifest.xml` (添加权限声明)
  - `ios/Runner/Info.plist` (添加使用描述)
  - `lib/features/files/files_service.dart` (改进权限处理)
  - `lib/features/files/files_page.dart` (添加管理器入口)
  - `lib/core/services/transfer/transfer_manager.dart` (改进下载保存)
  - `lib/features/files/widgets/transfer_dialog.dart` (增强UI)
  - `pubspec.yaml` (可能添加 share_plus 或 file_saver)

## ADDED Requirements

### Requirement: 上传下载管理器页面
系统 SHALL 提供独立的上传下载管理器页面。

#### Scenario: 查看传输任务列表
- **WHEN** 用户打开上传下载管理器
- **THEN** 系统应显示所有传输任务（进行中、等待中、已完成）

#### Scenario: 管理传输任务
- **WHEN** 用户对传输任务进行操作
- **THEN** 系统应支持暂停、恢复、取消、重试操作

#### Scenario: 查看传输详情
- **WHEN** 用户点击传输任务
- **THEN** 系统应显示传输进度、速度、剩余时间等详细信息

### Requirement: Android 存储权限处理
系统 SHALL 正确处理 Android 平台存储权限。

#### Scenario: Android 10+ 下载文件
- **WHEN** 用户在 Android 10+ 设备下载文件
- **THEN** 系统应使用 MediaStore API 或应用私有目录，无需请求存储权限

#### Scenario: Android 9- 下载文件
- **WHEN** 用户在 Android 9- 设备下载文件到公共目录
- **THEN** 系统应请求 WRITE_EXTERNAL_STORAGE 权限

#### Scenario: 权限被永久拒绝
- **WHEN** 用户永久拒绝了存储权限
- **THEN** 系统应显示引导对话框，引导用户到设置页面开启权限

### Requirement: iOS 文件保存
系统 SHALL 正确处理 iOS 平台文件保存。

#### Scenario: iOS 保存文件
- **WHEN** 用户在 iOS 设备下载文件
- **THEN** 系统应使用文件选择器让用户选择保存位置，或使用分享菜单

#### Scenario: iOS 保存到相册（图片）
- **WHEN** 用户保存图片到相册
- **THEN** 系统应请求相册写入权限并保存

### Requirement: 跨平台文件保存流程
系统 SHALL 提供统一的跨平台文件保存流程。

#### Scenario: 保存小文件
- **WHEN** 用户下载小文件（<10MB）
- **THEN** 系统应直接下载并保存到目标位置

#### Scenario: 保存大文件
- **WHEN** 用户下载大文件（>=10MB）
- **THEN** 系统应使用分块下载，显示进度，完成后保存

#### Scenario: 保存成功提示
- **WHEN** 文件保存成功
- **THEN** 系统应显示成功提示，并提供打开文件或打开所在目录的选项

### Requirement: 传输任务持久化
系统 SHALL 持久化传输任务状态。

#### Scenario: 应用重启后恢复任务
- **WHEN** 应用重启后用户打开传输管理器
- **THEN** 系统应恢复未完成的传输任务状态

#### Scenario: 断点续传
- **WHEN** 传输中断后重新开始
- **THEN** 系统应从断点继续传输

## MODIFIED Requirements

### Requirement: 文件下载功能
系统 SHALL 改进文件下载功能以支持跨平台保存。

原实现：
- 下载到临时目录或固定位置
- 权限处理不完善

新实现：
- Android: 优先使用应用私有目录，Android 10+ 使用 MediaStore
- iOS: 使用文件选择器或分享菜单
- 提供保存位置选择

## Platform-Specific Configuration

### Android 配置
需要在 `AndroidManifest.xml` 添加：
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<application
    android:requestLegacyExternalStorage="true"
    ...>
```

### iOS 配置
需要在 `Info.plist` 添加（如需保存图片到相册）：
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要访问相册以保存下载的图片</string>
```

## Dependencies
- `permission_handler: ^11.0.0` (已有)
- `path_provider: ^2.1.0` (已有)
- `file_picker: ^8.0.0` (已有)
- 可选: `share_plus` 或 `file_saver` 用于 iOS 分享

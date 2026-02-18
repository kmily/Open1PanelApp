# GitHub Actions 构建与下载指南

## 📱 1Panel Open Mobile App - CI/CD 自动化

本指南介绍如何使用 GitHub Actions 自动构建 APK 包和下载构建产物。

## 🚀 自动构建

### 构建触发条件

构建工作流 `build-apk.yml` 会在以下情况自动触发：

- **推送代码**: 推送到 `main` 或 `develop` 分支
- **创建 PR**: 对 `main` 或 `develop` 分支的 Pull Request
- **发布 Release**: 创建新的 Release 版本
- **手动触发**: 在 Actions 页面手动运行

### 构建产物

每次构建会生成以下文件：

- **`app-release.apk`**: Android 应用安装包
- **`app-release.aab`**: Android App Bundle（用于 Google Play 发布）

### 构建流程

1. **环境准备**: 检查代码、设置 Java 17 和 Flutter 3.16.0
2. **依赖安装**: `flutter pub get`
3. **代码生成**: `flutter packages pub run build_runner build`
4. **代码分析**: `flutter analyze`
5. **运行测试**: `flutter test --coverage`
6. **构建 APK**: `flutter build apk --release --tree-shake-icons`
7. **构建 AAB**: `flutter build appbundle --release`
8. **上传产物**: 保存构建结果到 Artifacts（保留30天）

## 📥 下载构建产物

### 方法一：手动下载（推荐）

1. 访问项目的 **Actions** 页面
2. 选择相应的构建工作流运行
3. 在构建完成的页面底部找到 **Artifacts** 部分
4. 点击下载 `app-release-apk` 获取构建产物

### 方法二：使用下载工作流

使用 `download.yml` 工作流可以快速下载最新的构建产物：

1. 进入项目的 **Actions** 页面
2. 选择 **Download Latest Build** 工作流
3. 点击 **Run workflow**
4. 选择下载类型：
   - `apk`: 只下载 APK 文件
   - `aab`: 只下载 AAB 文件
   - `both`: 下载两种格式
5. 点击绿色的 **Run workflow** 按钮

### 方法三：Release 下载

当创建新的 Release 时，构建产物会自动附加到 Release 页面：

1. 进入项目的 **Releases** 页面
2. 点击相应的 Release 版本
3. 在发布说明底部找到构建产物
4. 点击文件名即可下载

## 🛠️ 工作流配置详情

### build-apk.yml

```yaml
name: Build APK

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]
  release:
    types: [ published ]
  workflow_dispatch:
```

**主要特性**:
- 支持多触发条件
- 自动代码生成和测试
- 生成 APK 和 AAB 两种格式
- 自动上传到 GitHub Releases（仅 Release 事件）
- 详细构建日志和状态报告

### download.yml

```yaml
name: Download Latest Build

on:
  workflow_dispatch:
    inputs:
      build_type:
        description: 'Build type to download'
        required: true
        default: 'apk'
        type: choice
        options:
          - apk
          - aab
          - both
```

**主要特性**:
- 支持手动触发下载
- 可选择下载类型
- 自动检测最新构建
- 生成详细的下载说明

## 📋 使用说明

### 获取构建产物

构建完成后，你可以通过以下方式获取 APK 文件：

1. **GitHub Actions 页面**: 下载 Artifacts
2. **Release 页面**: 如果是 Release 构建
3. **下载工作流**: 使用自动下载功能

### 安装 APK

在 Android 设备上安装 APK：

1. 下载 APK 文件到设备
2. 进入设备 **设置** → **安全**
3. 启用 **未知来源** 或 **安装未知应用**
4. 使用文件管理器找到 APK 文件
5. 点击 APK 文件进行安装

### 版本信息

版本信息从 `pubspec.yaml` 文件中读取：

```yaml
version: 1.0.0+1
```

- `1.0.0`: 版本号 (versionName)
- `1`: 构建号 (versionCode)

## 🔧 高级配置

### 自定义构建

如果需要自定义构建参数，可以修改工作流文件：

```bash
# 自定义构建命令
flutter build apk --release --tree-shake-icons --target-platform android-arm64
```

### 添加签名

对于生产发布，需要配置应用签名：

1. 生成签名密钥
2. 在 GitHub Secrets 中存储签名信息
3. 修改构建配置使用正式签名

### 环境变量

可以在 GitHub Secrets 中设置以下变量：

- `KEYSTORE_PASSWORD`: 密钥库密码
- `KEY_PASSWORD`: 密钥密码
- `KEY_ALIAS`: 密钥别名

## 🚨 注意事项

1. **构建时间**: 完整构建约需 5-10 分钟
2. **文件大小**: APK 通常 20-50MB，AAB 约 15-30MB
3. **存储期限**: Artifacts 保留30天，Release 永久保存
4. **网络要求**: 构建需要稳定的网络连接下载依赖
5. **权限要求**: 需要 GitHub Actions 权限上传 Release

## 📞 问题排查

### 常见问题

**构建失败**:
- 检查 Flutter 版本兼容性
- 确认所有依赖都已正确声明
- 查看构建日志中的具体错误信息

**下载失败**:
- 确认构建已成功完成
- 检查 Artifacts 是否存在
- 验证工作流运行状态

**安装失败**:
- 确认 Android 设备已启用未知来源安装
- 检查 APK 文件是否完整下载
- 验证设备 Android 版本兼容性

## 📈 监控和统计

- 构建历史可在 Actions 页面查看
- 构建成功率、耗时等统计信息
- 支持查看详细的构建日志
- 可设置通知接收构建状态更新

---

通过这套完整的 CI/CD 流程，你可以轻松实现自动化构建、测试和分发，大幅提升开发效率和版本管理质量。
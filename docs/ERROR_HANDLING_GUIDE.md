# 错误处理系统使用指南

## 概述

本项目实现了一个统一的错误处理系统，旨在为用户提供友好、详细的错误信息，帮助新手用户快速理解问题原因并采取相应的解决措施。

## 核心组件

### 1. ErrorHandlerService

位置: `lib/core/services/error_handler_service.dart`

提供核心的错误处理功能：

- `getErrorMessage()`: 将异常转换为用户友好的错误消息
- `showErrorDialog()`: 显示友好的错误对话框
- `showNetworkErrorDialog()`: 显示网络错误对话框
- `showErrorWithLogs()`: 显示带完整日志的错误对话框（开发者模式）

**使用示例:**

```dart
try {
  await someAsyncOperation();
} catch (e) {
  final errorMessage = ErrorHandlerService.getErrorMessage(context, e);
  await ErrorHandlerService.showErrorDialog(
    context: context,
    title: '操作失败',
    message: errorMessage,
    onRetry: () => someAsyncOperation(),
  );
}
```

### 2. ErrorHelper

位置: `lib/core/services/error_helper.dart`

提供常用的错误处理UI组件：

- `buildErrorView()`: 显示加载失败的视图
- `buildEmptyView()`: 显示空数据视图
- `buildLoadingView()`: 显示加载状态视图
- `showErrorSnackBar()`: 显示错误SnackBar
- `showSuccessSnackBar()`: 显示成功SnackBar
- `handleAsyncOperation()`: 处理异步操作的通用方法

**使用示例:**

```dart
// 显示错误视图
ErrorHelper.buildErrorView(
  context: context,
  error: '加载失败',
  onRetry: () => loadData(),
  originalError: e,
);

// 显示空数据视图
ErrorHelper.buildEmptyView(
  context: context,
  title: '暂无数据',
  description: '点击下方按钮添加新项目',
  action: FilledButton(
    onPressed: () => _addItem(),
    child: Text('添加'),
  ),
);

// 显示错误SnackBar
ErrorHelper.showErrorSnackBar(
  context: context,
  message: '操作失败，请重试',
  action: () => retry(),
);

// 处理异步操作
final result = await ErrorHelper.handleAsyncOperation(
  context: context,
  operation: () => api.getData(),
  loadingMessage: '正在加载...',
  showErrorDialog: true,
);
```

### 3. 国际化错误消息

位置: `lib/l10n/app_zh.arb` 和 `lib/l10n/app_en.arb`

所有错误消息都支持中英文，包括：

**网络错误:**
- `errorNetworkTitle`: 网络错误
- `errorConnectionTimeout`: 连接超时
- `errorSendTimeout`: 发送超时
- `errorReceiveTimeout`: 接收超时
- `errorConnectionRefused`: 连接被拒绝
- `errorHostNotFound`: 无法找到服务器
- `errorNetworkUnreachable`: 网络不可达
- `errorCannotConnectServer`: 无法连接到服务器
- `errorSslError`: SSL证书验证失败
- `errorNoInternet`: 没有网络连接
- `errorServerUnreachable`: 服务器无法访问

**连接测试错误:**
- `errorConnectionTestFailed`: 连接测试失败
- `errorConnectionTestTimeout`: 连接测试超时（包含详细检查列表）
- `errorConnectionTestInvalidUrl`: 服务器地址格式不正确
- `errorConnectionTestInvalidKey`: API密钥无效（包含详细检查列表）
- `errorConnectionTestServerDown`: 服务器无响应（包含详细检查列表）

**HTTP错误:**
- `errorBadRequest`: 请求错误
- `errorUnauthorized`: 认证失败
- `errorForbidden`: 权限不足
- `errorNotFound`: 请求的资源不存在
- `errorInternalServerError`: 服务器内部错误
- `errorServiceUnavailable`: 服务暂时不可用
- `errorServerError`: 服务器错误
- `errorUnexpectedStatus`: 意外的响应状态码

**错误提示:**
- `errorTipCheckNetwork`: 💡 提示: 请检查您的网络连接是否正常
- `errorTipCheckServer`: 💡 提示: 请确认服务器地址和API密钥是否正确
- `errorTipCheckServerStatus`: 💡 提示: 请确认服务器正在运行且面板服务已启动
- `errorTipContactSupport`: 💡 提示: 如果问题仍然存在，请联系技术支持
- `errorTipRetryLater`: 💡 提示: 请稍后重试，如果问题持续存在请检查网络设置

## 在不同模块中的应用

### 1. 服务器管理模块

**文件:**
- `lib/features/server/server_connection_service.dart`
- `lib/features/server/server_form_page.dart`

**改进:**
- 添加了详细的连接错误类型枚举
- 提供了针对每种错误的具体解决方案
- 错误对话框中包含重试按钮和提示信息

**错误类型:**
```dart
enum ServerConnectionErrorType {
  timeout,              // 超时
  connectionError,      // 连接错误
  invalidUrl,          // 无效的URL
  authenticationFailed, // 认证失败
  serverError,         // 服务器错误
  unknown,             // 未知错误
}
```

### 2. 仪表盘模块

**文件:**
- `lib/features/dashboard/dashboard_page.dart`
- `lib/features/dashboard/dashboard_provider.dart`
- `lib/features/dashboard/widgets/dashboard_error_view.dart`

**改进:**
- 添加了 `originalError` 字段保存原始错误对象
- 错误视图中显示友好的错误消息和提示
- 提供查看错误详情的功能
- 支持重试操作

## 最佳实践

### 1. 错误处理模式

```dart
Future<void> loadData() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final result = await api.getData();
    setState(() {
      _data = result;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
      _originalError = e;
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
```

### 2. Provider中保存原始错误

```dart
class MyProvider extends ChangeNotifier {
  dynamic _originalError;
  String _errorMessage = '';

  dynamic get originalError => _originalError;
  String get errorMessage => _errorMessage;

  Future<void> doSomething() async {
    try {
      // ... 执行操作
    } catch (e) {
      _errorMessage = e.toString();
      _originalError = e; // 保存原始错误对象
      notifyListeners();
    }
  }
}
```

### 3. UI中显示错误

```dart
// 方式1: 使用 ErrorHelper
if (provider.errorMessage != null) {
  return ErrorHelper.buildErrorView(
    context: context,
    error: provider.errorMessage,
    onRetry: () => provider.loadData(),
    originalError: provider.originalError,
  );
}

// 方式2: 使用自定义错误视图
if (provider.errorMessage != null) {
  return DashboardErrorView(
    error: provider.errorMessage,
    onRetry: () => provider.loadData(),
    originalError: provider.originalError,
  );
}
```

### 4. 表单验证错误

```dart
Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  try {
    await _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('保存成功')),
    );
  } catch (e) {
    await ErrorHandlerService.showErrorDialog(
      context: context,
      title: '保存失败',
      message: ErrorHandlerService.getErrorMessage(context, e),
    );
  }
}
```

## 添加新的错误消息

### 1. 在ARB文件中添加

**app_zh.arb:**
```json
{
  "errorCustomError": "自定义错误消息",
  "@errorCustomError": {
    "description": "自定义错误的描述"
  }
}
```

**app_en.arb:**
```json
{
  "errorCustomError": "Custom error message"
}
```

### 2. 生成国际化文件

```bash
flutter gen-l10n
```

### 3. 在代码中使用

```dart
final l10n = context.l10n;
Text(l10n.errorCustomError)
```

## 日志记录

所有错误都应该记录到日志中，使用统一的日志系统：

```dart
import 'package:onepanelapp_app/core/services/logger_service.dart';

try {
  await someOperation();
} catch (e, stackTrace) {
  appLogger.eWithPackage(
    'my.module',
    '操作失败',
    error: e,
    stackTrace: stackTrace,
  );
}
```

## 错误分类

根据错误的严重程度和性质，我们应该：

1. **用户可恢复的错误**: 提供重试选项和明确的解决步骤
2. **配置错误**: 提供详细的配置指南和示例
3. **权限错误**: 明确说明需要什么权限以及如何获取
4. **网络错误**: 提供网络诊断步骤
5. **服务器错误**: 建议稍后重试或联系技术支持

## 注意事项

1. **永远不要向用户显示原始错误堆栈**，除非是在开发者模式下
2. **所有错误消息必须国际化**，支持中英文
3. **为每种错误类型提供明确的解决步骤**
4. **在适当的时候提供重试选项**
5. **记录所有错误到日志系统**，便于调试和分析
6. **使用一致的错误UI组件**，保持用户体验的一致性

## 常见问题

### Q: 如何添加自定义错误类型？

A: 在对应的service中创建自定义异常类，并在ErrorHandlerService中添加处理逻辑。

### Q: 如何处理网络超时？

A: ErrorHandlerService已经内置了超时处理，会自动识别并显示相应的友好消息。

### Q: 如何在测试中模拟错误？

A: 可以使用mockito模拟API调用抛出异常，然后测试错误处理逻辑。

### Q: 错误提示信息太长怎么办？

A: 使用错误对话框的可展开详情功能，将详细信息放在折叠区域。

## 相关文件

- `lib/core/services/error_handler_service.dart`: 核心错误处理服务
- `lib/core/services/error_helper.dart`: 错误处理辅助类
- `lib/core/services/logger_service.dart`: 日志服务
- `lib/l10n/app_zh.arb`: 中文错误消息
- `lib/l10n/app_en.arb`: 英文错误消息
- `lib/features/server/server_connection_service.dart`: 服务器连接服务示例
- `lib/features/dashboard/widgets/dashboard_error_view.dart`: 错误视图示例

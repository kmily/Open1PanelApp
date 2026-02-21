# 修复 TransferManager ProviderNotFoundException Spec

## Why
`TransferManager` 没有在 `main.dart` 的 `MultiProvider` 中注册，导致 `files_page.dart` 中调用 `context.read<TransferManager>()` 时抛出 `ProviderNotFoundException`。

## What Changes
- 在 `main.dart` 的 `MultiProvider` 中添加 `TransferManager` 的 Provider

## Impact
- Affected code:
  - `lib/main.dart` (添加 TransferManager Provider)

## ADDED Requirements

### Requirement: TransferManager Provider 注册
系统 SHALL 在应用启动时注册 TransferManager Provider。

#### Scenario: 打开传输管理器
- **WHEN** 用户点击右上角三个点菜单中的"传输管理"
- **THEN** 系统应能正确获取 TransferManager 实例
- **AND** 不应抛出 ProviderNotFoundException

## Root Cause Analysis
日志显示：
```
ProviderNotFoundException: Could not find the correct Provider<TransferManager> above this FilesView Widget
```

原因：
1. `TransferManager` 是单例模式
2. `files_page.dart` 使用 `context.read<TransferManager>()` 获取实例
3. 但 `main.dart` 的 `MultiProvider` 中没有注册 `TransferManager`

## Implementation Details

### 修改 `main.dart`
```dart
import 'package:onepanelapp_app/core/services/transfer/transfer_manager.dart';

// 在 MultiProvider 的 providers 列表中添加：
ChangeNotifierProvider(
  create: (_) => TransferManager(),
),
```

由于 `TransferManager` 是单例模式，也可以使用：
```dart
ChangeNotifierProvider.value(
  value: TransferManager(),
),
```

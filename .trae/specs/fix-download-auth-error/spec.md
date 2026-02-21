# 修复下载文件 401 认证错误 Spec

## Why
`FilesService.downloadFileToDevice` 方法创建了一个新的 `Dio` 实例，使用了错误的认证头部格式 `Authorization: Bearer xxx`，但 1Panel API 需要的是 `1Panel-Token` 和 `1Panel-Timestamp` 头部，导致下载请求返回 401 错误。

## What Changes
- 修改 `FilesService.downloadFileToDevice` 方法使用正确的 1Panel 认证头部
- 或者使用已配置好的 `DioClient` 实例进行下载

## Impact
- Affected code:
  - `lib/features/files/files_service.dart` (修改下载方法)

## ADDED Requirements

### Requirement: 下载文件使用正确的认证头部
系统 SHALL 在下载文件时使用正确的 1Panel API 认证头部。

#### Scenario: 下载文件认证
- **WHEN** 用户下载文件
- **THEN** 系统应使用 `1Panel-Token` 和 `1Panel-Timestamp` 头部
- **AND** 认证 token 应为 MD5("1panel" + apiKey + timestamp)

## MODIFIED Requirements

### Requirement: FilesService.downloadFileToDevice 方法
原实现：
```dart
final dio = Dio();
dio.options.headers['Authorization'] = 'Bearer ${config.apiKey}';
```

新实现：
```dart
// 方案1：使用 AuthInterceptor 生成正确的头部
final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
final authToken = _generate1PanelAuthToken(config.apiKey, timestamp);
dio.options.headers['1Panel-Token'] = authToken;
dio.options.headers['1Panel-Timestamp'] = timestamp;

// 或方案2：使用已有的 DioClient 实例
```

## Root Cause Analysis
日志显示：
```
DioException [bad response]: status code of 401
```

原因：
1. `FilesService.downloadFileToDevice` 创建了新的 `Dio` 实例
2. 使用了 `Authorization: Bearer xxx` 头部格式
3. 1Panel API 不识别 Bearer 认证，需要 `1Panel-Token` 和 `1Panel-Timestamp`

## Implementation Details

### 修改 `_generate1PanelAuthToken` 方法（如果不存在则添加）
```dart
String _generate1PanelAuthToken(String apiKey, String timestamp) {
  final authString = '1panel$apiKey$timestamp';
  final bytes = utf8.encode(authString);
  final digest = md5.convert(bytes);
  return digest.toString();
}
```

### 修改 `downloadFileToDevice` 方法
```dart
final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
final authToken = _generate1PanelAuthToken(config.apiKey, timestamp);

final dio = Dio();
dio.options.headers['1Panel-Token'] = authToken;
dio.options.headers['1Panel-Timestamp'] = timestamp;
```

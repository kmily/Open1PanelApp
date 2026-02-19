import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/services/logger_service.dart';

/// 统一错误处理服务
/// 
/// 提供友好的错误信息转换和显示功能，帮助新手用户理解问题原因
class ErrorHandlerService {
  static const String _defaultPackage = 'core.services.error_handler';

  /// 将异常转换为用户友好的错误消息
  static String getErrorMessage(BuildContext context, dynamic error) {
    if (error is DioException) {
      return _getDioErrorMessage(context, error);
    } else if (error is NetworkException) {
      return _getNetworkErrorMessage(context, error);
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is ApiException) {
      return error.message;
    }
    
    // 未知错误
    final l10n = context.l10n;
    appLogger.wWithPackage(_defaultPackage, '未处理的错误类型: ${error.runtimeType}', error: error);
    return l10n.unknownError(error.toString());
  }

  /// 处理 DioException 并返回友好的错误消息
  static String _getDioErrorMessage(BuildContext context, DioException error) {
    final l10n = context.l10n;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        appLogger.wWithPackage(_defaultPackage, '连接超时', error: error);
        return l10n.errorConnectionTimeout;
      
      case DioExceptionType.sendTimeout:
        appLogger.wWithPackage(_defaultPackage, '发送超时', error: error);
        return l10n.errorSendTimeout;
      
      case DioExceptionType.receiveTimeout:
        appLogger.wWithPackage(_defaultPackage, '接收超时', error: error);
        return l10n.errorReceiveTimeout;
      
      case DioExceptionType.connectionError:
        appLogger.wWithPackage(_defaultPackage, '连接失败', error: error);
        return _getConnectionErrorDetails(context, error);
      
      case DioExceptionType.badResponse:
        appLogger.wWithPackage(_defaultPackage, '服务器返回错误: ${error.response?.statusCode}', error: error);
        return _getBadResponseMessage(context, error);
      
      case DioExceptionType.cancel:
        appLogger.iWithPackage(_defaultPackage, '请求已取消');
        return l10n.errorRequestCancelled;
      
      case DioExceptionType.badCertificate:
        appLogger.wWithPackage(_defaultPackage, '证书验证失败', error: error);
        return l10n.errorBadCertificate;
      
      case DioExceptionType.unknown:
        appLogger.eWithPackage(_defaultPackage, '未知网络错误', error: error);
        return l10n.errorUnknown(error.message ?? l10n.unknownError(''));
    }
  }

  /// 处理连接错误并返回详细信息
  static String _getConnectionErrorDetails(BuildContext context, DioException error) {
    final l10n = context.l10n;
    
    // 检查是否有特定的错误信息
    final message = error.message?.toLowerCase() ?? '';
    
    if (message.contains('connection refused')) {
      return l10n.errorConnectionRefused;
    } else if (message.contains('host') && message.contains('not found')) {
      return l10n.errorHostNotFound;
    } else if (message.contains('network') && message.contains('unreachable')) {
      return l10n.errorNetworkUnreachable;
    } else if (message.contains('timeout')) {
      return l10n.errorConnectionTimeout;
    } else if (message.contains('ssl') || message.contains('certificate')) {
      return l10n.errorSslError;
    }
    
    return l10n.errorCannotConnectServer;
  }

  /// 处理服务器响应错误
  static String _getBadResponseMessage(BuildContext context, DioException error) {
    final l10n = context.l10n;
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    
    // 尝试从响应中提取错误信息
    String serverMessage = '';
    if (data is Map<String, dynamic>) {
      serverMessage = data['message']?.toString() ?? 
                      data['error']?.toString() ?? 
                      data['msg']?.toString() ?? '';
    } else if (data is String) {
      serverMessage = data;
    }
    
    switch (statusCode) {
      case 400:
        return serverMessage.isNotEmpty 
            ? l10n.errorBadRequest(serverMessage)
            : l10n.errorBadRequest('');
      case 401:
        return l10n.errorUnauthorized;
      case 403:
        return l10n.errorForbidden;
      case 404:
        return l10n.errorNotFound;
      case 500:
        return l10n.errorInternalServerError;
      case 502:
      case 503:
      case 504:
        return l10n.errorServiceUnavailable;
      default:
        if (serverMessage.isNotEmpty) {
          return l10n.errorServerError(statusCode?.toString() ?? 'Unknown', serverMessage);
        }
        return l10n.errorUnexpectedStatus(statusCode?.toString() ?? 'Unknown');
    }
  }

  /// 处理网络异常
  static String _getNetworkErrorMessage(BuildContext context, NetworkException error) {
    final l10n = context.l10n;
    switch (error.type) {
      case NetworkErrorType.noInternet:
        return l10n.errorNoInternet;
      case NetworkErrorType.timeout:
        return l10n.errorConnectionTimeout;
      case NetworkErrorType.serverUnreachable:
        return l10n.errorServerUnreachable;
      default:
        return error.message;
    }
  }

  /// 显示友好的错误对话框
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    List<Widget>? actions,
    String? details,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        actions: actions,
        details: details,
      ),
    );
  }

  /// 显示网络错误对话框
  static Future<void> showNetworkErrorDialog({
    required BuildContext context,
    dynamic error,
    VoidCallback? onRetry,
  }) async {
    final l10n = context.l10n;
    final message = getErrorMessage(context, error);
    final details = error is DioException ? error.message : error?.toString();
    
    await showErrorDialog(
      context: context,
      title: l10n.errorNetworkTitle,
      message: message,
      details: details,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        if (onRetry != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: Text(l10n.retry),
          ),
      ],
    );
  }

  /// 显示带日志的错误对话框（开发者模式）
  static Future<void> showErrorWithLogs({
    required BuildContext context,
    required String title,
    required String message,
    String? stackTrace,
    VoidCallback? onRetry,
  }) async {
    await showErrorDialog(
      context: context,
      title: title,
      message: message,
      details: stackTrace,
      actions: [
        if (stackTrace != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFullLogs(context, message, stackTrace);
            },
            child: const Text('查看完整日志'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        if (onRetry != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: Text(context.l10n.retry),
          ),
      ],
    );
  }

  /// 显示完整日志
  static void _showFullLogs(BuildContext context, String message, String stackTrace) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('错误日志'),
        content: SingleChildScrollView(
          child: SelectableText(
            '错误信息:\n$message\n\n堆栈跟踪:\n$stackTrace',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 网络异常类型
enum NetworkErrorType {
  noInternet,
  timeout,
  serverUnreachable,
  unknown,
}

/// 网络异常
class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;
  
  NetworkException({
    required this.message,
    this.type = NetworkErrorType.unknown,
  });
}

/// API 异常
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
}

/// 验证异常
class ValidationException implements Exception {
  final String message;
  
  ValidationException(this.message);
}

/// 错误对话框组件
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final List<Widget>? actions;
  final String? details;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text(
                  '详细信息',
                  style: TextStyle(fontSize: 14),
                ),
                tilePadding: EdgeInsets.zero,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      details!,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: actions ??
          [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.cancel),
            ),
          ],
    );
  }
}

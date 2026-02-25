import 'package:onepanelapp_app/core/network/dio_client.dart';
import 'package:onepanelapp_app/core/network/network_exceptions.dart';
import 'package:onepanelapp_app/core/services/logger/logger_service.dart';

class ServerConnectionResult {
  const ServerConnectionResult({
    required this.success,
    this.errorMessage,
    this.errorType,
    this.osInfo,
    this.responseTime,
  });

  final bool success;
  final String? errorMessage;
  final ServerConnectionErrorType? errorType;
  final Map<String, dynamic>? osInfo;
  final Duration? responseTime;
}

enum ServerConnectionErrorType {
  timeout,
  connectionError,
  invalidUrl,
  authenticationFailed,
  serverError,
  unknown,
}

class ServerConnectionService {
  static const String _package = 'server.connection_service';

  Future<ServerConnectionResult> testConnection({
    required String serverUrl,
    required String apiKey,
  }) async {
    final stopwatch = Stopwatch()..start();

    // 清理并验证 URL 格式
    final cleanUrl = _normalizeUrl(serverUrl);
    if (!_isValidUrl(cleanUrl)) {
      stopwatch.stop();
      return ServerConnectionResult(
        success: false,
        errorMessage: 'serverConnectionTestInvalidUrl',
        errorType: ServerConnectionErrorType.invalidUrl,
        responseTime: stopwatch.elapsed,
      );
    }

    try {
      // 使用统一的 DioClient，包含认证拦截器
      final dioClient = DioClient(
        baseUrl: cleanUrl,
        apiKey: apiKey,
      );

      appLogger.dWithPackage(_package, '开始连接测试: $cleanUrl');

      final response = await dioClient.get(
        '/api/v2/dashboard/base/os',
      );

      stopwatch.stop();

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['data'] != null) {
          appLogger.iWithPackage(_package, '连接测试成功, 耗时: ${stopwatch.elapsedMilliseconds}ms');
          return ServerConnectionResult(
            success: true,
            osInfo: data['data'] as Map<String, dynamic>?,
            responseTime: stopwatch.elapsed,
          );
        }
      }

      appLogger.wWithPackage(_package, '服务器返回无效响应');
      return ServerConnectionResult(
        success: false,
        errorMessage: 'serverConnectionTestServerDown',
        errorType: ServerConnectionErrorType.serverError,
        responseTime: stopwatch.elapsed,
      );
    } on NetworkConnectionException catch (e) {
      stopwatch.stop();
      appLogger.wWithPackage(_package, '连接测试失败: 网络连接错误', error: e);

      final errorMessage = _getDetailedConnectionErrorFromMessage(e.message);
      final errorType = errorMessage == 'serverConnectionTestTimeout'
          ? ServerConnectionErrorType.timeout
          : ServerConnectionErrorType.connectionError;

      return ServerConnectionResult(
        success: false,
        errorMessage: errorMessage,
        errorType: errorType,
        responseTime: stopwatch.elapsed,
      );
    } on AuthException catch (e) {
      stopwatch.stop();
      appLogger.wWithPackage(_package, '连接测试失败: 认证失败', error: e);

      return ServerConnectionResult(
        success: false,
        errorMessage: 'serverConnectionTestInvalidKey',
        errorType: ServerConnectionErrorType.authenticationFailed,
        responseTime: stopwatch.elapsed,
      );
    } on ServerException catch (e) {
      stopwatch.stop();
      appLogger.wWithPackage(_package, '连接测试失败: 服务器错误', error: e);

      return ServerConnectionResult(
        success: false,
        errorMessage: 'serverConnectionTestServerDown',
        errorType: ServerConnectionErrorType.serverError,
        responseTime: stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      appLogger.eWithPackage(_package, '连接测试出现未知错误', error: e);
      return ServerConnectionResult(
        success: false,
        errorMessage: 'serverConnectionTestServerDown',
        errorType: ServerConnectionErrorType.unknown,
        responseTime: stopwatch.elapsed,
      );
    }
  }

  /// 标准化 URL（移除末尾斜杠，避免双斜杠问题）
  String _normalizeUrl(String url) {
    String normalized = url.trim();
    // 移除 URL 末尾的斜杠
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  /// 验证 URL 格式
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 获取详细的连接错误信息（从异常消息中）
  String _getDetailedConnectionErrorFromMessage(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('connection refused')) {
      return 'serverConnectionTestServerDown';
    } else if (lowerMessage.contains('host') && lowerMessage.contains('not found')) {
      return 'serverConnectionTestInvalidUrl';
    } else if (lowerMessage.contains('network') && lowerMessage.contains('unreachable')) {
      return 'serverConnectionTestTimeout';
    } else if (lowerMessage.contains('timeout')) {
      return 'serverConnectionTestTimeout';
    } else if (lowerMessage.contains('ssl') || lowerMessage.contains('certificate')) {
      return 'errorSslError';
    }

    return 'serverConnectionTestServerDown';
  }
}

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:onepanelapp_app/core/services/logger_service.dart';

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

    // 验证 URL 格式
    if (!_isValidUrl(serverUrl)) {
      stopwatch.stop();
      return ServerConnectionResult(
        success: false,
        errorMessage: 'serverConnectionTestInvalidUrl',
        errorType: ServerConnectionErrorType.invalidUrl,
        responseTime: stopwatch.elapsed,
      );
    }

    try {
      final dio = Dio(BaseOptions(
        baseUrl: serverUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final authString = '1panel$apiKey$timestamp';
      final bytes = utf8.encode(authString);
      final digest = md5.convert(bytes);
      final token = digest.toString();

      appLogger.dWithPackage(_package, '开始连接测试: $serverUrl');

      final response = await dio.get(
        '/api/v2/dashboard/base/os',
        options: Options(headers: {
          '1Panel-Token': token,
          '1Panel-Timestamp': timestamp,
        }),
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
    } on DioException catch (e) {
      stopwatch.stop();
      appLogger.wWithPackage(_package, '连接测试失败: ${e.type}', error: e);

      String errorMessage;
      ServerConnectionErrorType errorType;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'serverConnectionTestTimeout';
          errorType = ServerConnectionErrorType.timeout;
          break;
        case DioExceptionType.connectionError:
          errorMessage = _getDetailedConnectionError(e);
          errorType = ServerConnectionErrorType.connectionError;
          break;
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            errorMessage = 'serverConnectionTestInvalidKey';
            errorType = ServerConnectionErrorType.authenticationFailed;
          } else {
            errorMessage = 'serverConnectionTestServerDown';
            errorType = ServerConnectionErrorType.serverError;
          }
          break;
        default:
          errorMessage = 'serverConnectionTestServerDown';
          errorType = ServerConnectionErrorType.unknown;
      }

      return ServerConnectionResult(
        success: false,
        errorMessage: errorMessage,
        errorType: errorType,
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

  /// 验证 URL 格式
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url.trim());
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 获取详细的连接错误信息
  String _getDetailedConnectionError(DioException error) {
    final message = error.message?.toLowerCase() ?? '';

    if (message.contains('connection refused')) {
      return 'serverConnectionTestServerDown';
    } else if (message.contains('host') && message.contains('not found')) {
      return 'serverConnectionTestInvalidUrl';
    } else if (message.contains('network') && message.contains('unreachable')) {
      return 'errorConnectionTestTimeout';
    } else if (message.contains('timeout')) {
      return 'serverConnectionTestTimeout';
    } else if (message.contains('ssl') || message.contains('certificate')) {
      return 'errorSslError';
    }

    return 'serverConnectionTestServerDown';
  }
}

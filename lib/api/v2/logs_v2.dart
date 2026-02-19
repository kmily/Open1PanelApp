import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/logs_models.dart';
import '../../data/models/common_models.dart';

class LogsV2Api {
  final DioClient _client;

  LogsV2Api(this._client);

  Future<Response> getSystemLogs(LogSearch request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/logs/system'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => LogInfo.fromJson(json as Map<String, dynamic>),
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  Future<Response<List<LogFileInfo>>> getSystemLogFiles() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/logs/system/files'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => LogFileInfo.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  Future<Response<String>> getSystemLogFileContent(LogFileContent request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/logs/system/file'),
      data: request.toJson(),
    );
    return Response(
      data: response.data?.toString() ?? '',
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  Future<Response> cleanLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/core/logs/clean'),
      data: data,
    );
  }

  Future<Response> searchLoginLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/core/logs/login'),
      data: data,
    );
  }

  Future<Response> searchOperationLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/core/logs/operation'),
      data: data,
    );
  }

  Future<Response> getAppLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/logs/app'),
      data: data,
    );
  }

  Future<Response> getSecurityLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/logs/security'),
      data: data,
    );
  }

  Future<Response> getAccessLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/logs/access'),
      data: data,
    );
  }

  Future<Response> getErrorLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/logs/error'),
      data: data,
    );
  }

  Future<Response> getLogStats(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/logs/stats'),
      data: data,
    );
  }

  Future<Response> exportLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/logs/export'),
      data: data,
    );
  }
}

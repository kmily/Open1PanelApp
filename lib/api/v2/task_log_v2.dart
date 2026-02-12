/// 1Panel V2 API - TaskLog 相关接口
///
/// 此文件包含与任务日志管理相关的所有API接口，
/// 包括任务日志的查询、统计、清理等操作。

import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/task_log_models.dart';
import '../../data/models/common_models.dart';

class TaskLogV2Api {
  final DioClient _client;

  TaskLogV2Api(this._client);

  /// 获取正在执行的任务数量
  Future<Response<int>> getExecutingTaskCount() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/logs/tasks/executing/count'),
    );
    return Response(
      data: response.data?['data'] as int? ?? 0,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 搜索任务日志
  Future<Response<PageResult<TaskLogInfo>>> searchTaskLogs(TaskLogSearch request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/logs/tasks/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data?['data'] as Map<String, dynamic>? ?? {},
        (dynamic item) => TaskLogInfo.fromJson(item as Map<String, dynamic>),
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }
}

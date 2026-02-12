/// 1Panel V2 API - Snapshot 相关接口
///
/// 此文件包含与系统快照相关的所有API接口，
/// 包括快照的创建、恢复、管理等操作。

import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/snapshot_models.dart';

class SnapshotV2Api {
  final DioClient _client;

  SnapshotV2Api(this._client);

  /// 创建快照
  Future<Response<void>> createSnapshot(SnapshotCreate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/settings/snapshot'),
      data: request.toJson(),
    );
  }

  /// 删除快照
  Future<Response<void>> deleteSnapshot(SnapshotDelete request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/settings/snapshot/del'),
      data: request.toJson(),
    );
  }

  /// 更新快照描述
  Future<Response<void>> updateSnapshotDescription(SnapshotDescriptionUpdate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/settings/snapshot/description/update'),
      data: request.toJson(),
    );
  }

  /// 导入快照
  Future<Response<void>> importSnapshot(SnapshotImport request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/settings/snapshot/import'),
      data: request.toJson(),
    );
  }

  /// 加载快照
  Future<Response<Map<String, dynamic>>> loadSnapshot() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/settings/snapshot/load'),
    );
    return Response(
      data: response.data?['data'] as Map<String, dynamic>? ?? {},
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 恢复快照
  Future<Response<void>> recoverSnapshot(SnapshotRecover request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/settings/snapshot/recover'),
      data: request.toJson(),
    );
  }

  /// 重建快照
  Future<Response<void>> recreateSnapshot() async {
    return await _client.post(
      ApiConstants.buildApiPath('/settings/snapshot/recreate'),
    );
  }

  /// 回滚快照
  Future<Response<void>> rollbackSnapshot(SnapshotRollback request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/settings/snapshot/rollback'),
      data: request.toJson(),
    );
  }

  /// 搜索快照
  Future<Response<PageResult<SnapshotInfo>>> searchSnapshots(SearchWithPage request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/settings/snapshot/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data?['data'] as Map<String, dynamic>? ?? {},
        (dynamic item) => SnapshotInfo.fromJson(item as Map<String, dynamic>),
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }
}

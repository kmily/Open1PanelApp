/// 1Panel V2 API - SystemGroup 相关接口
///
/// 此文件包含与系统分组管理相关的所有API接口，
/// 包括分组的创建、删除、更新、查询等操作。

import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/system_group_models.dart';
import '../../data/models/common_models.dart';

class SystemGroupV2Api {
  final DioClient _client;

  SystemGroupV2Api(this._client);

  /// 获取分组列表
  Future<Response<List<SystemGroupInfo>>> getGroups() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/core/groups'),
    );
    final data = response.data?['data'] as List?;
    return Response(
      data: data?.map((e) => SystemGroupInfo.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 删除分组
  Future<Response<void>> deleteGroup(GroupDelete request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/core/groups/del'),
      data: request.toJson(),
    );
  }

  /// 搜索分组
  Future<Response<PageResult<SystemGroupInfo>>> searchGroups(SearchWithPage request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/core/groups/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data?['data'] as Map<String, dynamic>? ?? {},
        (dynamic item) => SystemGroupInfo.fromJson(item as Map<String, dynamic>),
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 更新分组
  Future<Response<void>> updateGroup(GroupUpdate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/core/groups/update'),
      data: request.toJson(),
    );
  }
}

/// 1Panel V2 API - Container 相关接口
///
/// 此文件包含与容器管理相关的所有API接口，
/// 包括容器的创建、删除、启动、停止、查询等操作。

import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/container_models.dart';
import '../../data/models/common_models.dart';

/// API响应解析帮助类
class _Parser {
  /// 从1Panel API响应中提取data字段
  static T extractData<T>(Response<Map<String, dynamic>> response, T Function(Map<String, dynamic>) fromJson) {
    final body = response.data!;
    if (body.containsKey('data') && body['data'] != null) {
      return fromJson(body['data'] as Map<String, dynamic>);
    }
    throw Exception('API响应格式错误: 缺少data字段');
  }

  /// 从1Panel API响应中提取data字段（Map类型）
  static Map<String, dynamic> extractMapData(Response<Map<String, dynamic>> response) {
    final body = response.data!;
    if (body.containsKey('data') && body['data'] != null) {
      return body['data'] as Map<String, dynamic>;
    }
    return {};
  }

  /// 从1Panel API响应中提取data字段（List类型）
  static List<T> extractListData<T>(Response<List<dynamic>> response, T Function(Map<String, dynamic>) fromJson) {
    final body = response.data!;
    return body.map((item) => fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 从1Panel API响应中提取data字段（原始List）
  static List<Map<String, dynamic>> extractRawListData(Response<List<dynamic>> response) {
    return response.data?.map((item) => item as Map<String, dynamic>).toList() ?? [];
  }

  /// 从1Panel API响应中提取data字段（PageResult类型）
  static PageResult<T> extractPageData<T>(Response<Map<String, dynamic>> response, T Function(Map<String, dynamic>) fromJson) {
    final body = response.data!;
    if (body.containsKey('data') && body['data'] != null) {
      return PageResult.fromJson(
        body['data'] as Map<String, dynamic>,
        (dynamic item) => fromJson(item as Map<String, dynamic>),
      );
    }
    return PageResult(items: [], total: 0);
  }
}

class ContainerV2Api {
  final DioClient _client;

  ContainerV2Api(this._client);

  /// 创建容器
  Future<Response> createContainer(ContainerOperate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers'),
      data: request.toJson(),
    );
  }

  /// 操作容器（启动/停止/重启等）
  Future<Response> operateContainer(ContainerOperation request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/operate'),
      data: request.toJson(),
    );
  }

  /// 启动容器
  Future<Response> startContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.start.value,
    ));
  }

  /// 停止容器
  Future<Response> stopContainer(List<String> names, {bool force = false}) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: force ? ContainerOperationType.kill.value : ContainerOperationType.stop.value,
    ));
  }

  /// 重启容器
  Future<Response> restartContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.restart.value,
    ));
  }

  /// 暂停容器
  Future<Response> pauseContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.pause.value,
    ));
  }

  /// 恢复容器
  Future<Response> unpauseContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.unpause.value,
    ));
  }

  /// 删除容器
  Future<Response> deleteContainer(List<String> names, {bool force = false}) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.remove.value,
    ));
  }

  /// 搜索容器
  Future<Response<PageResult<ContainerInfo>>> searchContainers(PageContainer request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/search'),
      data: request.toJson(),
    );
    return Response(
      data: _Parser.extractPageData(response, ContainerInfo.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器列表
  Future<Response<List<ContainerInfo>>> listContainers() async {
    final response = await _client.post<List<dynamic>>(
      ApiConstants.buildApiPath('/containers/list'),
    );
    return Response(
      data: _Parser.extractListData(response, ContainerInfo.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器详情
  Future<Response<ContainerInfo>> getContainerDetail(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/$id'),
    );
    return Response(
      data: _Parser.extractData(response, ContainerInfo.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器统计信息
  Future<Response<ContainerStats>> getContainerStats(String id) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/stats/$id'),
    );
    return Response(
      data: _Parser.extractData(response, ContainerStats.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器列表统计信息
  Future<Response<List<ContainerListStats>>> listContainerStats() async {
    final response = await _client.get<List<dynamic>>(
      ApiConstants.buildApiPath('/containers/list/stats'),
    );
    return Response(
      data: _Parser.extractListData(response, ContainerListStats.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器状态统计
  Future<Response<ContainerStatus>> getContainerStatus() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/status'),
    );
    return Response(
      data: _Parser.extractData(response, ContainerStatus.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 升级容器
  Future<Response> upgradeContainer(ContainerUpgrade request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/upgrade'),
      data: request.toJson(),
    );
  }

  /// 重命名容器
  Future<Response> renameContainer(ContainerRename request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/rename'),
      data: request.toJson(),
    );
  }

  /// 提交容器为镜像
  Future<Response> commitContainer(ContainerCommit request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/commit'),
      data: request.toJson(),
    );
  }

  /// 清理容器资源
  Future<Response> pruneContainers(ContainerPrune request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/prune'),
      data: request.toJson(),
    );
  }

  /// 清理容器日志
  Future<Response> cleanContainerLog(OperationWithName request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/clean/log'),
      data: request.toJson(),
    );
  }

  /// 通过命令创建容器
  Future<Response> createContainerByCommand(ContainerCreateByCommand request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/command'),
      data: request.toJson(),
    );
  }

  /// 获取容器信息
  Future<Response<ContainerOperate>> getContainerInfo(OperationWithName request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/info'),
      data: request.toJson(),
    );
    return Response(
      data: _Parser.extractData(response, ContainerOperate.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 检查容器
  Future<Response<String>> inspectContainer(InspectReq request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/inspect'),
      data: request.toJson(),
    );
    return Response(
      data: response.data?['data']?.toString() ?? '',
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器日志
  Future<Response<Map<String, dynamic>>> getContainerLogs({
    required String container,
    String? since,
    bool? follow,
    String? tail,
  }) async {
    final queryParams = <String, dynamic>{};
    if (since != null) queryParams['since'] = since;
    if (follow != null) queryParams['follow'] = follow.toString();
    if (tail != null) queryParams['tail'] = tail;

    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/search/log'),
      queryParameters: queryParams,
    );
    return Response(
      data: _Parser.extractMapData(response),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 更新容器
  Future<Response> updateContainer(ContainerOperate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/update'),
      data: request.toJson(),
    );
  }

  /// 下载容器日志
  Future<Response<String>> downloadContainerLog(String container) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/download/log'),
      queryParameters: {'container': container},
    );
    return Response(
      data: response.data?['data']?.toString() ?? '',
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器资源限制
  Future<Response<Map<String, dynamic>>> getContainerLimits() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/limit'),
    );
    return Response(
      data: _Parser.extractMapData(response),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  // 镜像管理相关方法
  /// 获取镜像选项
  Future<Response<List<Map<String, dynamic>>>> getImageOptions() async {
    final response = await _client.get<List<dynamic>>(
      ApiConstants.buildApiPath('/containers/image'),
    );
    return Response(
      data: _Parser.extractRawListData(response),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取所有镜像
  Future<Response<List<Map<String, dynamic>>>> getAllImages() async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/image/all'),
    );
    final data = response.data!;
    final list = data['data'] as List?;
    return Response(
      data: list?.map((item) => item as Map<String, dynamic>).toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 构建镜像
  Future<Response<String>> buildImage(ImageBuild request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/image/build'),
      data: request.toJson(),
    );
    return Response(
      data: response.data?['data']?.toString() ?? '',
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 加载镜像
  Future<Response> loadImage(ImageLoad request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/load'),
      data: request.toJson(),
    );
  }

  /// 拉取镜像
  Future<Response> pullImage(ImagePull request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/pull'),
      data: request.toJson(),
    );
  }

  /// 推送镜像
  Future<Response> pushImage(ImagePush request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/push'),
      data: request.toJson(),
    );
  }

  /// 删除镜像
  Future<Response<ContainerPruneReport>> removeImage(BatchDelete request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/image/remove'),
      data: request.toJson(),
    );
    return Response(
      data: _Parser.extractData(response, ContainerPruneReport.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 保存镜像
  Future<Response> saveImage(ImageSave request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/save'),
      data: request.toJson(),
    );
  }

  /// 搜索镜像
  Future<Response<PageResult<Map<String, dynamic>>>> searchImages(SearchWithPage request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/image/search'),
      data: request.toJson(),
    );
    return Response(
      data: _Parser.extractPageData(response, (json) => json as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 标记镜像
  Future<Response> tagImage(ImageTag request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/tag'),
      data: request.toJson(),
    );
  }

  // 网络管理相关方法
  /// 获取网络选项
  Future<Response<List<Map<String, dynamic>>>> getNetworkOptions() async {
    final response = await _client.get<List<dynamic>>(
      ApiConstants.buildApiPath('/containers/network'),
    );
    return Response(
      data: _Parser.extractRawListData(response),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 创建网络
  Future<Response> createNetwork(NetworkCreate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network'),
      data: request.toJson(),
    );
  }

  /// 删除网络
  Future<Response> deleteNetwork(BatchDelete request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network/del'),
      data: request.toJson(),
    );
  }

  /// 搜索网络
  Future<Response<PageResult<Map<String, dynamic>>>> searchNetworks(SearchWithPage request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/network/search'),
      data: request.toJson(),
    );
    return Response(
      data: _Parser.extractPageData(response, (json) => json as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  // 卷管理相关方法
  /// 获取卷选项
  Future<Response<List<Map<String, dynamic>>>> getVolumeOptions() async {
    final response = await _client.get<List<dynamic>>(
      ApiConstants.buildApiPath('/containers/volume'),
    );
    return Response(
      data: _Parser.extractRawListData(response),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 创建卷
  Future<Response> createVolume(VolumeCreate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume'),
      data: request.toJson(),
    );
  }

  /// 删除卷
  Future<Response> deleteVolume(BatchDelete request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume/del'),
      data: request.toJson(),
    );
  }

  /// 搜索卷
  Future<Response<PageResult<Map<String, dynamic>>>> searchVolumes(SearchWithPage request) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.buildApiPath('/containers/volume/search'),
      data: request.toJson(),
    );
    return Response(
      data: _Parser.extractPageData(response, (json) => json as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }
}

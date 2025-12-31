/// 1Panel V2 API - Container 相关接口
///
/// 此文件包含与容器管理相关的所有API接口，
/// 包括容器的创建、删除、启动、停止、查询等操作。

import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/container_models.dart';
import '../../data/models/common_models.dart';

class ContainerV2Api {
  final DioClient _client;

  ContainerV2Api(this._client);

  /// 创建容器
  ///
  /// 创建一个新的容器
  /// @param request 容器操作请求
  /// @return 创建结果
  Future<Response> createContainer(ContainerOperate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers'),
      data: request.toJson(),
    );
  }

  /// 操作容器（启动/停止/重启等）
  ///
  /// 对指定容器执行操作
  /// @param request 容器操作请求
  /// @return 操作结果
  Future<Response> operateContainer(ContainerOperation request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/operate'),
      data: request.toJson(),
    );
  }

  /// 启动容器
  ///
  /// 启动指定的容器
  /// @param names 容器名称列表
  /// @return 启动结果
  Future<Response> startContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.start.value,
    ));
  }

  /// 停止容器
  ///
  /// 停止指定的容器
  /// @param names 容器名称列表
  /// @param force 是否强制停止
  /// @return 停止结果
  Future<Response> stopContainer(List<String> names, {bool force = false}) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: force ? ContainerOperationType.kill.value : ContainerOperationType.stop.value,
    ));
  }

  /// 重启容器
  ///
  /// 重启指定的容器
  /// @param names 容器名称列表
  /// @return 重启结果
  Future<Response> restartContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.restart.value,
    ));
  }

  /// 暂停容器
  ///
  /// 暂停指定的容器
  /// @param names 容器名称列表
  /// @return 暂停结果
  Future<Response> pauseContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.pause.value,
    ));
  }

  /// 恢复容器
  ///
  /// 恢复指定的容器
  /// @param names 容器名称列表
  /// @return 恢复结果
  Future<Response> unpauseContainer(List<String> names) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.unpause.value,
    ));
  }

  /// 删除容器
  ///
  /// 删除指定的容器
  /// @param names 容器名称列表
  /// @param force 是否强制删除
  /// @return 删除结果
  Future<Response> deleteContainer(List<String> names, {bool force = false}) async {
    return await operateContainer(ContainerOperation(
      names: names,
      operation: ContainerOperationType.remove.value,
    ));
  }

  /// 搜索容器
  ///
  /// 分页搜索容器列表
  /// @param request 分页搜索请求
  /// @return 容器列表
  Future<Response<PageResult<ContainerInfo>>> searchContainers(PageContainer request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ContainerInfo.fromJson(json as Map<String, dynamic>),
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器列表
  ///
  /// 获取所有容器列表
  /// @return 容器列表
  Future<Response<List<ContainerInfo>>> listContainers() async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/list'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => ContainerInfo.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器详情
  ///
  /// 获取指定容器的详细信息
  /// @param id 容器ID
  /// @return 容器详情
  Future<Response<ContainerInfo>> getContainerDetail(String id) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/$id'),
    );
    return Response(
      data: ContainerInfo.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器统计信息
  ///
  /// 获取指定容器的资源使用统计信息
  /// @param id 容器ID
  /// @return 容器统计信息
  Future<Response<ContainerStats>> getContainerStats(String id) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/stats/$id'),
    );
    return Response(
      data: ContainerStats.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器列表统计信息
  ///
  /// 批量获取容器统计信息
  /// @return 容器列表统计
  Future<Response<List<ContainerListStats>>> listContainerStats() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/list/stats'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => ContainerListStats.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器状态统计
  ///
  /// 获取容器状态统计信息
  /// @return 容器状态统计
  Future<Response<ContainerStatus>> getContainerStatus() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/status'),
    );
    return Response(
      data: ContainerStatus.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 升级容器
  ///
  /// 升级指定容器到新镜像
  /// @param request 容器升级请求
  /// @return 升级结果
  Future<Response> upgradeContainer(ContainerUpgrade request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/upgrade'),
      data: request.toJson(),
    );
  }

  /// 重命名容器
  ///
  /// 重命名指定容器
  /// @param request 容器重命名请求
  /// @return 重命名结果
  Future<Response> renameContainer(ContainerRename request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/rename'),
      data: request.toJson(),
    );
  }

  /// 提交容器为镜像
  ///
  /// 将指定容器提交为镜像
  /// @param request 容器提交请求
  /// @return 提交结果
  Future<Response> commitContainer(ContainerCommit request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/commit'),
      data: request.toJson(),
    );
  }

  /// 清理容器资源
  ///
  /// 清理容器、镜像、卷等资源
  /// @param request 清理请求
  /// @return 清理结果
  Future<Response> pruneContainers(ContainerPrune request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/prune'),
      data: request.toJson(),
    );
  }

  /// 清理容器日志
  ///
  /// 清理指定容器的日志文件
  /// @param request 清理日志请求
  /// @return 清理结果
  Future<Response> cleanContainerLog(OperationWithName request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/clean/log'),
      data: request.toJson(),
    );
  }

  /// 通过命令创建容器
  ///
  /// 使用命令行方式创建容器
  /// @param request 创建请求
  /// @return 创建结果
  Future<Response> createContainerByCommand(ContainerCreateByCommand request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/command'),
      data: request.toJson(),
    );
  }

  /// 获取容器信息
  ///
  /// 获取指定容器的详细信息
  /// @param request 容器信息请求
  /// @return 容器信息
  Future<Response<ContainerOperate>> getContainerInfo(OperationWithName request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/info'),
      data: request.toJson(),
    );
    return Response(
      data: ContainerOperate.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 检查容器
  ///
  /// 检查容器的详细配置信息
  /// @param request 检查请求
  /// @return 容器配置
  Future<Response<String>> inspectContainer(InspectReq request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/inspect'),
      data: request.toJson(),
    );
    return Response(
      data: response.data.toString(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器日志
  ///
  /// 获取指定容器的日志信息
  /// @param container 容器名称
  /// @param since 时间筛选（可选）
  /// @param follow 是否追踪日志（可选）
  /// @param tail 显示行数（可选）
  /// @return 容器日志
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

    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/search/log'),
      queryParameters: queryParams,
    );
    return Response(
      data: response.data as Map<String, dynamic>,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 更新容器
  ///
  /// 更新指定容器的配置
  /// @param request 容器操作请求
  /// @return 更新结果
  Future<Response> updateContainer(ContainerOperate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/update'),
      data: request.toJson(),
    );
  }

  /// 下载容器日志
  ///
  /// 下载指定容器的日志文件
  /// @param container 容器名称
  /// @return 日志文件下载链接
  Future<Response<String>> downloadContainerLog(String container) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/download/log'),
      queryParameters: {'container': container},
    );
    return Response(
      data: response.data.toString(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取容器资源限制
  ///
  /// 获取容器的资源使用限制
  /// @return 资源限制信息
  Future<Response<Map<String, dynamic>>> getContainerLimits() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/limit'),
    );
    return Response(
      data: response.data as Map<String, dynamic>,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  // 镜像管理相关方法
  /// 获取镜像选项
  ///
  /// 获取可用的镜像操作选项
  /// @return 镜像选项列表
  Future<Response<List<Map<String, dynamic>>>> getImageOptions() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/image'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取所有镜像
  ///
  /// 获取系统中所有的Docker镜像
  /// @return 镜像列表
  Future<Response<List<Map<String, dynamic>>>> getAllImages() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/image/all'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 构建镜像
  ///
  /// 使用Dockerfile构建新的镜像
  /// @param request 构建请求
  /// @return 构建结果
  Future<Response<String>> buildImage(ImageBuild request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/image/build'),
      data: request.toJson(),
    );
    return Response(
      data: response.data.toString(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 加载镜像
  ///
  /// 从文件加载Docker镜像
  /// @param request 加载请求
  /// @return 加载结果
  Future<Response> loadImage(ImageLoad request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/load'),
      data: request.toJson(),
    );
  }

  /// 拉取镜像
  ///
  /// 从仓库拉取Docker镜像
  /// @param request 拉取请求
  /// @return 拉取结果
  Future<Response> pullImage(ImagePull request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/pull'),
      data: request.toJson(),
    );
  }

  /// 推送镜像
  ///
  /// 将镜像推送到仓库
  /// @param request 推送请求
  /// @return 推送结果
  Future<Response> pushImage(ImagePush request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/push'),
      data: request.toJson(),
    );
  }

  /// 删除镜像
  ///
  /// 删除指定的Docker镜像
  /// @param request 删除请求
  /// @return 删除结果
  Future<Response<ContainerPruneReport>> removeImage(BatchDelete request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/image/remove'),
      data: request.toJson(),
    );
    return Response(
      data: ContainerPruneReport.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 保存镜像
  ///
  /// 将镜像保存到文件
  /// @param request 保存请求
  /// @return 保存结果
  Future<Response> saveImage(ImageSave request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/save'),
      data: request.toJson(),
    );
  }

  /// 搜索镜像
  ///
  /// 分页搜索Docker镜像
  /// @param request 搜索请求
  /// @return 镜像列表
  Future<Response<PageResult<Map<String, dynamic>>>> searchImages(SearchWithPage request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/image/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 标记镜像
  ///
  /// 为镜像添加新的标签
  /// @param request 标记请求
  /// @return 标记结果
  Future<Response> tagImage(ImageTag request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/tag'),
      data: request.toJson(),
    );
  }

  // 网络管理相关方法
  /// 获取网络选项
  ///
  /// 获取可用的网络操作选项
  /// @return 网络选项列表
  Future<Response<List<Map<String, dynamic>>>> getNetworkOptions() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/network'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 创建网络
  ///
  /// 创建新的Docker网络
  /// @param request 网络创建请求
  /// @return 创建结果
  Future<Response> createNetwork(NetworkCreate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network'),
      data: request.toJson(),
    );
  }

  /// 删除网络
  ///
  /// 删除指定的Docker网络
  /// @param request 删除请求
  /// @return 删除结果
  Future<Response> deleteNetwork(BatchDelete request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network/del'),
      data: request.toJson(),
    );
  }

  /// 搜索网络
  ///
  /// 分页搜索Docker网络
  /// @param request 搜索请求
  /// @return 网络列表
  Future<Response<PageResult<Map<String, dynamic>>>> searchNetworks(SearchWithPage request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/network/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  // 卷管理相关方法
  /// 获取卷选项
  ///
  /// 获取可用的卷操作选项
  /// @return 卷选项列表
  Future<Response<List<Map<String, dynamic>>>> getVolumeOptions() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/volume'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 创建卷
  ///
  /// 创建新的Docker卷
  /// @param request 卷创建请求
  /// @return 创建结果
  Future<Response> createVolume(VolumeCreate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume'),
      data: request.toJson(),
    );
  }

  /// 删除卷
  ///
  /// 删除指定的Docker卷
  /// @param request 删除请求
  /// @return 删除结果
  Future<Response> deleteVolume(BatchDelete request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume/del'),
      data: request.toJson(),
    );
  }

  /// 搜索卷
  ///
  /// 分页搜索Docker卷
  /// @param request 搜索请求
  /// @return 卷列表
  Future<Response<PageResult<Map<String, dynamic>>>> searchVolumes(SearchWithPage request) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/containers/volume/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }
}
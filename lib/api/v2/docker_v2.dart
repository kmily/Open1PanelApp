import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';

class DockerV2Api {
  final DioClient _client;

  DockerV2Api(this._client);

  Future<Response> dockerOperate(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/docker/operate'),
      data: data,
    );
  }

  Future<Response> getDockerStatus() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/docker/status'),
    );
  }

  Future<Response> getContainerInfo() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/info'),
    );
  }

  Future<Response> searchContainers(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/search'),
      data: data,
    );
  }

  Future<Response> listContainers(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/list'),
      data: data,
    );
  }

  Future<Response> listContainersByImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/list/byimage'),
      data: data,
    );
  }

  Future<Response> listContainerStats() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/list/stats'),
    );
  }

  Future<Response> getContainerStats(String id) async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/stats/$id'),
    );
  }

  Future<Response> getItemStats(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/item/stats'),
      data: data,
    );
  }

  Future<Response> inspectContainer(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/inspect'),
      data: data,
    );
  }

  Future<Response> operateContainer(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/operate'),
      data: data,
    );
  }

  Future<Response> updateContainer(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/update'),
      data: data,
    );
  }

  Future<Response> upgradeContainer(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/upgrade'),
      data: data,
    );
  }

  Future<Response> renameContainer(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/rename'),
      data: data,
    );
  }

  Future<Response> pruneContainers(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/prune'),
      data: data,
    );
  }

  Future<Response> cleanContainerLog(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/clean/log'),
      data: data,
    );
  }

  Future<Response> searchContainerLogs(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/search/log'),
      data: data,
    );
  }

  Future<Response> commitContainer(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/commit'),
      data: data,
    );
  }

  Future<Response> getContainerLimit() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/limit'),
    );
  }

  Future<Response> getContainerUsers() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/users'),
    );
  }

  Future<Response> getContainerStatus() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/status'),
    );
  }

  Future<Response> searchImages(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/search'),
      data: data,
    );
  }

  Future<Response> getAllImages() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/image/all'),
    );
  }

  Future<Response> getImage() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/image'),
    );
  }

  Future<Response> pullImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/pull'),
      data: data,
    );
  }

  Future<Response> pushImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/push'),
      data: data,
    );
  }

  Future<Response> removeImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/remove'),
      data: data,
    );
  }

  Future<Response> saveImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/save'),
      data: data,
    );
  }

  Future<Response> loadImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/load'),
      data: data,
    );
  }

  Future<Response> buildImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/build'),
      data: data,
    );
  }

  Future<Response> tagImage(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/tag'),
      data: data,
    );
  }

  Future<Response> searchNetworks(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network/search'),
      data: data,
    );
  }

  Future<Response> createNetwork(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network'),
      data: data,
    );
  }

  Future<Response> deleteNetwork(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network/del'),
      data: data,
    );
  }

  Future<Response> searchVolumes(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume/search'),
      data: data,
    );
  }

  Future<Response> createVolume(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume'),
      data: data,
    );
  }

  Future<Response> deleteVolume(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume/del'),
      data: data,
    );
  }

  Future<Response> searchRepos(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/repo/search'),
      data: data,
    );
  }

  Future<Response> getRepoStatus() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/repo/status'),
    );
  }

  Future<Response> createRepo(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/repo'),
      data: data,
    );
  }

  Future<Response> updateRepo(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/repo/update'),
      data: data,
    );
  }

  Future<Response> deleteRepo(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/repo/del'),
      data: data,
    );
  }

  Future<Response> getDaemonJson() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/daemonjson'),
    );
  }

  Future<Response> getDaemonJsonFile() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/daemonjson/file'),
    );
  }

  Future<Response> updateDaemonJson(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/daemonjson/update'),
      data: data,
    );
  }

  Future<Response> updateDaemonJsonByFile(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/daemonjson/update/byfile'),
      data: data,
    );
  }

  Future<Response> updateIpv6Option(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/ipv6option/update'),
      data: data,
    );
  }

  Future<Response> updateLogOption(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/logoption/update'),
      data: data,
    );
  }

  Future<Response> getTemplates() async {
    return await _client.get(
      ApiConstants.buildApiPath('/containers/template'),
    );
  }

  Future<Response> searchTemplates(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/template/search'),
      data: data,
    );
  }

  Future<Response> updateTemplate(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/template/update'),
      data: data,
    );
  }

  Future<Response> deleteTemplate(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/template/del'),
      data: data,
    );
  }

  Future<Response> batchTemplates(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/template/batch'),
      data: data,
    );
  }

  Future<Response> createCompose(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/compose'),
      data: data,
    );
  }

  Future<Response> operateCompose(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/compose/operate'),
      data: data,
    );
  }

  Future<Response> searchComposes(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/compose/search'),
      data: data,
    );
  }

  Future<Response> testCompose(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/compose/test'),
      data: data,
    );
  }

  Future<Response> updateCompose(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/compose/update'),
      data: data,
    );
  }

  Future<Response> cleanComposeLog(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/compose/clean/log'),
      data: data,
    );
  }

  Future<Response> containerCommand(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/command'),
      data: data,
    );
  }
}

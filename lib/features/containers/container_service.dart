import '../../api/v2/container_v2.dart';
import '../../core/services/base_component.dart';
import '../../data/models/common_models.dart';
import '../../data/models/container_extension_models.dart';
import '../../data/models/container_models.dart';

class ContainerService extends BaseComponent {
  ContainerService({
    ContainerV2Api? api,
    super.clientManager,
    super.permissionResolver,
  }) : _api = api;

  ContainerV2Api? _api;

  Future<ContainerV2Api> _ensureApi() async {
    if (_api != null) {
      return _api!;
    }
    _api = await clientManager.getContainerApi();
    return _api!;
  }

  Future<List<ContainerInfo>> listContainers() {
    return runGuarded(() async {
      final api = await _ensureApi();
      final response = await api.searchContainers(PageContainer(
        page: 1,
        pageSize: 100,
        state: 'all',
      ));
      return response.data?.items ?? [];
    });
  }

  Future<List<ContainerImage>> listImages() {
    return runGuarded(() async {
      final api = await _ensureApi();
      final response = await api.getAllImages();
      return response.data
              ?.map((item) => ContainerImage.fromJson(item))
              .toList() ??
          [];
    });
  }

  Future<void> startContainer(String containerId) {
    return runGuarded(() async {
      final api = await _ensureApi();
      await api.startContainer([containerId]);
    });
  }

  Future<void> stopContainer(String containerId, {bool force = false}) {
    return runGuarded(() async {
      final api = await _ensureApi();
      await api.stopContainer([containerId], force: force);
    });
  }

  Future<void> killContainer(String containerId) {
    return runGuarded(() async {
      final api = await _ensureApi();
      await api.killContainer([containerId]);
    });
  }

  Future<void> restartContainer(String containerId) {
    return runGuarded(() async {
      final api = await _ensureApi();
      await api.restartContainer([containerId]);
    });
  }

  Future<void> removeContainer(String containerId) {
    return runGuarded(() async {
      final api = await _ensureApi();
      await api.deleteContainer([containerId]);
    });
  }

  Future<void> removeImage(int imageId) {
    return runGuarded(() async {
      final api = await _ensureApi();
      await api.removeImage(BatchDelete(ids: [imageId]));
    });
  }

  Future<ContainerStats> getContainerStats(String containerId) {
    return runGuarded(() async {
      final api = await _ensureApi();
      final response = await api.getContainerStats(containerId);
      return response.data!;
    });
  }

  Future<String> getContainerLogs(String containerId, {String? since, String? tail}) {
    return runGuarded(() async {
      final api = await _ensureApi();
      // Using downloadContainerLog for now as it returns string content
      // Or we can use getContainerLogs if we want structured logs
      final response = await api.downloadContainerLog(containerId);
      return response.data ?? '';
    });
  }

  Future<String> inspectContainer(String containerName) {
    return runGuarded(() async {
      final api = await _ensureApi();
      final response = await api.inspectContainer(InspectReq(name: containerName));
      return response.data ?? '';
    });
  }
}

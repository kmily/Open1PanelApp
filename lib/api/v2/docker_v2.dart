import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/docker_models.dart';
import '../../data/models/container_models.dart';

class DockerV2Api {
  final DioClient _client;

  DockerV2Api(this._client);

  // --- Images ---

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromJson) {
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map<String, dynamic>) {
      if (data['data'] is List) {
        return (data['data'] as List)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data['items'] is List) {
        return (data['items'] as List)
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// List all images
  Future<Response<List<DockerImage>>> listImages() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/image/all'),
    );
    return Response(
      data: _parseList(response.data, DockerImage.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// Pull image
  Future<Response> pullImage(ImagePull request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/pull'),
      data: request.toJson(),
    );
  }

  /// Remove image
  Future<Response> removeImage(String imageId, {bool force = false}) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/image/remove'),
      data: {'names': [imageId], 'force': force},
    );
  }

  // --- Networks ---

  /// List networks
  Future<Response<List<DockerNetwork>>> listNetworks() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/network'),
    );
    return Response(
      data: _parseList(response.data, DockerNetwork.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// Create network
  Future<Response> createNetwork(NetworkCreate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network'),
      data: request.toJson(),
    );
  }

  /// Remove network
  Future<Response> removeNetwork(String networkId) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/network/del'),
      data: {'names': [networkId]},
    );
  }

  // --- Volumes ---

  /// List volumes
  Future<Response<List<DockerVolume>>> listVolumes() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/containers/volume'),
    );
    return Response(
      data: _parseList(response.data, DockerVolume.fromJson),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// Create volume
  Future<Response> createVolume(VolumeCreate request) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume'),
      data: request.toJson(),
    );
  }

  /// Remove volume
  Future<Response> removeVolume(String volumeName) async {
    return await _client.post(
      ApiConstants.buildApiPath('/containers/volume/del'),
      data: {'names': [volumeName]},
    );
  }
}

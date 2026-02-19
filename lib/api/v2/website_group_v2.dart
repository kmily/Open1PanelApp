import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';

class WebsiteGroupV2Api {
  final DioClient _client;

  WebsiteGroupV2Api(this._client);

  Future<Response> getGroups() async {
    return await _client.get(
      ApiConstants.buildApiPath('/groups'),
    );
  }

  Future<Response> searchGroups(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/groups/search'),
      data: data,
    );
  }

  Future<Response> updateGroup(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/groups/update'),
      data: data,
    );
  }

  Future<Response> deleteGroup(Map<String, dynamic> data) async {
    return await _client.post(
      ApiConstants.buildApiPath('/groups/del'),
      data: data,
    );
  }
}

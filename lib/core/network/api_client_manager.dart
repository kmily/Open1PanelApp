import 'dio_client.dart';

/// API客户端管理器
/// 用于管理多个服务器配置的API客户端实例
class ApiClientManager {
  static final ApiClientManager _instance = ApiClientManager._internal();
  final Map<String, DioClient> _clients = {};
  final Map<String, _ClientConfigMeta> _clientMeta = {};

  factory ApiClientManager() {
    return _instance;
  }

  ApiClientManager._internal();

  /// 获取指定服务器的API客户端
  DioClient getClient(String serverId, String serverUrl, String apiKey) {
    final nextMeta = _ClientConfigMeta(url: serverUrl, apiKey: apiKey);
    final currentMeta = _clientMeta[serverId];

    if (currentMeta == nextMeta && _clients.containsKey(serverId)) {
      return _clients[serverId]!;
    }

    final client = DioClient(
      baseUrl: serverUrl,
      apiKey: apiKey,
    );
    _clients[serverId] = client;
    _clientMeta[serverId] = nextMeta;
    return client;
  }

  /// 移除指定服务器的API客户端
  void removeClient(String serverId) {
    _clients.remove(serverId);
    _clientMeta.remove(serverId);
  }

  /// 清除所有API客户端
  void clearAllClients() {
    _clients.clear();
    _clientMeta.clear();
  }
}

class _ClientConfigMeta {
  const _ClientConfigMeta({
    required this.url,
    required this.apiKey,
  });

  final String url;
  final String apiKey;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is _ClientConfigMeta &&
        other.url == url &&
        other.apiKey == apiKey;
  }

  @override
  int get hashCode => Object.hash(url, apiKey);
}

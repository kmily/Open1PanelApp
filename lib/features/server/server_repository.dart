import 'package:onepanelapp_app/core/config/api_config.dart';
import 'server_models.dart';

class ServerRepository {
  const ServerRepository();

  Future<List<ServerCardViewModel>> loadServerCards() async {
    final configs = await ApiConfigManager.getConfigs();
    final current = await ApiConfigManager.getCurrentConfig();

    return configs
        .map(
          (config) => ServerCardViewModel(
            config: config,
            isCurrent: current?.id == config.id,
            metrics: const ServerMetricsSnapshot(),
          ),
        )
        .toList();
  }

  Future<void> setCurrent(String id) async {
    await ApiConfigManager.setCurrentConfig(id);
  }

  Future<void> removeConfig(String id) async {
    await ApiConfigManager.deleteConfig(id);
  }

  Future<void> saveConfig(ApiConfig config) async {
    await ApiConfigManager.saveConfig(config);
    await ApiConfigManager.setCurrentConfig(config.id);
  }
}

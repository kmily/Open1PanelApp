import 'package:flutter/foundation.dart';
import 'package:onepanelapp_app/core/config/api_config.dart';
import 'server_models.dart';
import 'server_repository.dart';

class ServerProvider extends ChangeNotifier {
  ServerProvider({ServerRepository? repository})
      : _repository = repository ?? const ServerRepository();

  final ServerRepository _repository;
  bool _isLoading = false;
  List<ServerCardViewModel> _servers = const [];

  bool get isLoading => _isLoading;
  List<ServerCardViewModel> get servers => _servers;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _servers = await _repository.loadServerCards();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrent(String id) async {
    await _repository.setCurrent(id);
    await load();
  }

  Future<void> delete(String id) async {
    await _repository.removeConfig(id);
    await load();
  }

  Future<void> save(ApiConfig config) async {
    await _repository.saveConfig(config);
    await load();
  }
}

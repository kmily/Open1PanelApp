import 'package:flutter/foundation.dart';
import '../../../data/models/app_models.dart';
import '../app_service.dart';

class AppStoreProvider extends ChangeNotifier {
  final AppService _appService;

  AppStoreProvider({AppService? appService})
      : _appService = appService ?? AppService();

  List<AppItem> _apps = [];
  bool _isLoading = false;
  String? _error;

  List<AppItem> get apps => _apps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadApps({
    int page = 1,
    int pageSize = 20,
    String? name,
    String? type,
    String? resource,
    bool? recommend,
    List<String>? tags,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = AppSearchRequest(
        page: page,
        pageSize: pageSize,
        name: name,
        type: type,
        resource: resource,
        recommend: recommend,
        tags: tags,
      );
      _apps = await _appService.searchApps(request);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> installApp(AppInstallCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appService.installApp(request);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncApps() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appService.syncRemoteApps();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

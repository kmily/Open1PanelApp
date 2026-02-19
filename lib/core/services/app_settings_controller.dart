import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/services/app_preferences_service.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({AppPreferencesService? preferencesService})
      : _preferencesService = preferencesService ?? AppPreferencesService();

  final AppPreferencesService _preferencesService;

  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;
  bool get loaded => _loaded;

  Future<void> load() async {
    _themeMode = await _preferencesService.loadThemeMode();
    _locale = await _preferencesService.loadLocale();
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _preferencesService.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> updateLocale(Locale? locale) async {
    _locale = locale;
    await _preferencesService.saveLocale(locale);
    notifyListeners();
  }
}

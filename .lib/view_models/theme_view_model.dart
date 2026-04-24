import 'package:flutter/material.dart';
import '../models/theme.dart';
import '../repositories/settings_repository.dart';

class ThemeViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  AppTheme _appTheme = AppTheme.system;
  bool _useAdaptiveColor = false;
  Color? _customSeedColor;

  ThemeViewModel(this._repository) {
    _loadSettings();
  }

  AppTheme get appTheme => _appTheme;
  bool get useAdaptiveColor => _useAdaptiveColor;
  Color? get customSeedColor => _customSeedColor;

  bool get isDarkMode {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    if (_appTheme == AppTheme.system) {
      return brightness == Brightness.dark;
    }
    return _appTheme == AppTheme.dark;
  }

  ThemeMode get themeMode {
    switch (_appTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  void _loadSettings() {
    _appTheme = _repository.getAppTheme();
    _useAdaptiveColor = _repository.getUseAdaptiveColor();
    _customSeedColor = _repository.getCustomSeedColor();
    notifyListeners();
  }

  void setTheme(AppTheme theme) async {
    _appTheme = theme;
    await _repository.setAppTheme(theme);
    notifyListeners();
  }

  void setAdaptiveColor(bool value) async {
    _useAdaptiveColor = value;
    await _repository.setUseAdaptiveColor(value);
    notifyListeners();
  }

  void setCustomSeedColor(Color? color) async {
    _customSeedColor = color;
    await _repository.setCustomSeedColor(color);
    notifyListeners();
  }
}

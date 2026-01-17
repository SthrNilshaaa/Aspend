import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/theme.dart';

class SettingsRepository {
  static const String _settingsBoxName = 'settings';
  static const String _themeKey = 'theme';
  static const String _adaptiveColorKey = 'adaptiveColor';
  static const String _customColorKey = 'customSeedColor';
  static const String _introCompletedKey = 'introCompleted';

  Box get _settingsBox => Hive.box(_settingsBoxName);

  AppTheme getAppTheme() {
    final index =
        _settingsBox.get(_themeKey, defaultValue: AppTheme.system.index);
    return AppTheme.values[index];
  }

  Future<void> setAppTheme(AppTheme theme) async {
    await _settingsBox.put(_themeKey, theme.index);
  }

  bool getUseAdaptiveColor() {
    return _settingsBox.get(_adaptiveColorKey, defaultValue: false);
  }

  Future<void> setUseAdaptiveColor(bool value) async {
    await _settingsBox.put(_adaptiveColorKey, value);
  }

  Color? getCustomSeedColor() {
    final colorValue = _settingsBox.get(_customColorKey);
    return colorValue != null ? Color(colorValue) : null;
  }

  Future<void> setCustomSeedColor(Color? color) async {
    if (color != null) {
      await _settingsBox.put(_customColorKey, color.toARGB32());
    } else {
      await _settingsBox.delete(_customColorKey);
    }
  }

  bool isIntroCompleted() {
    return _settingsBox.get(_introCompletedKey, defaultValue: false);
  }

  Future<void> setIntroCompleted(bool completed) async {
    await _settingsBox.put(_introCompletedKey, completed);
  }

  Stream<BoxEvent> watchSettings() {
    return _settingsBox.watch();
  }
}

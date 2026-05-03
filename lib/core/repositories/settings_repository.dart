import 'package:aspends_tracker/core/const/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  static const String _settingsBoxName = AppConstants.settingsBox;
  static const String _themeKey = AppConstants.themeKey;
  static const String _adaptiveColorKey = AppConstants.adaptiveColorKey;
  static const String _customColorKey = AppConstants.customColorKey;
  static const String _introCompletedKey = AppConstants.introCompletedKey;
  static const String _monthlyBudgetKey = AppConstants.monthlyBudgetKey;
  static const String _joinPreviousMonthBalanceKey =
      AppConstants.joinPreviousMonthBalanceKey;
  static const String _autoDeleteUndetectedKey =
      AppConstants.autoDeleteUndetectedKey;
  static const String _customCategoriesKey = 'customCategories'; // Legacy
  static const String _customAccountsKey = 'customAccounts'; // Legacy
  static const String _incomeCategoriesKey = AppConstants.incomeCategoriesKey;
  static const String _expenseCategoriesKey = AppConstants.expenseCategoriesKey;
  static const String _accountsKey = AppConstants.accountsKey;
  static const String _ignoredPatternsKey = AppConstants.ignoredPatternsKey;
  static const String _autoDetectionKey = 'autoDetectionEnabled';
  static const String _autoSelectionFirstTimeKey = 'isFirstTimeAutoSelection';

  Box get _settingsBox => Hive.box(_settingsBoxName);

  ThemeMode getThemeMode() {
    final index =
        _settingsBox.get(_themeKey, defaultValue: ThemeMode.system.index);
    return ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsBox.put(_themeKey, mode.index);
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

  double getMonthlyBudget() {
    return _settingsBox.get(_monthlyBudgetKey, defaultValue: 0.0);
  }

  Future<void> setMonthlyBudget(double amount) async {
    await _settingsBox.put(_monthlyBudgetKey, amount);
  }

  bool getJoinPreviousMonthBalance() {
    return _settingsBox.get(_joinPreviousMonthBalanceKey, defaultValue: true);
  }

  Future<void> setJoinPreviousMonthBalance(bool value) async {
    await _settingsBox.put(_joinPreviousMonthBalanceKey, value);
  }

  bool getAutoDeleteUndetected() {
    return _settingsBox.get(_autoDeleteUndetectedKey, defaultValue: false);
  }

  Future<void> setAutoDeleteUndetected(bool value) async {
    await _settingsBox.put(_autoDeleteUndetectedKey, value);
  }

  List<String> getIncomeCategories() {
    final def = [
      'Salary',
      'Freelance',
      'Bonus',
      'Investment',
      'Interest',
      'Rent Received',
      'Gift',
      'Cashback',
      'Business',
      'Refund',
      'Other'
    ];
    return List<String>.from(
        _settingsBox.get(_incomeCategoriesKey, defaultValue: def));
  }

  Future<void> setIncomeCategories(List<String> list) async =>
      await _settingsBox.put(_incomeCategoriesKey, list);

  List<String> getExpenseCategories() {
    final def = [
      'Food',
      'Groceries',
      'Transport',
      'Fuel',
      'Shopping',
      'Bills',
      'Rent',
      'Entertainment',
      'Health',
      'Education',
      'Travel',
      'Maintenance',
      'Insurance',
      'Subscription',
      'Personal Care',
      'Tax',
      'Gifts',
      'Charity',
      'Loan Repayment',
      'Other'
    ];
    return List<String>.from(
        _settingsBox.get(_expenseCategoriesKey, defaultValue: def));
  }

  Future<void> setExpenseCategories(List<String> list) async =>
      await _settingsBox.put(_expenseCategoriesKey, list);

  List<String> getAccounts() {
    final def = [
      'Cash',
      'Bank',
      'Savings',
      'Wallet',
      'UPI',
      'Credit Card',
      'Debit Card',
      'Online'
    ];
    return List<String>.from(_settingsBox.get(_accountsKey, defaultValue: def));
  }

  Future<void> setAccounts(List<String> list) async =>
      await _settingsBox.put(_accountsKey, list);

  List<String> getCustomCategories() => List<String>.from(
      _settingsBox.get(_customCategoriesKey, defaultValue: <String>[]));
  Future<void> setCustomCategories(List<String> categories) async =>
      await _settingsBox.put(_customCategoriesKey, categories);
  List<String> getCustomAccounts() => List<String>.from(
      _settingsBox.get(_customAccountsKey, defaultValue: <String>[]));
  Future<void> setCustomAccounts(List<String> accounts) async =>
      await _settingsBox.put(_customAccountsKey, accounts);

  List<String> getIgnoredPatterns() {
    return List<String>.from(
        _settingsBox.get(_ignoredPatternsKey, defaultValue: <String>[]));
  }

  Future<void> setIgnoredPatterns(List<String> list) async =>
      await _settingsBox.put(_ignoredPatternsKey, list);

  Future<void> addIgnoredPattern(String pattern) async {
    final list = getIgnoredPatterns();
    if (!list.contains(pattern)) {
      list.add(pattern);
      await setIgnoredPatterns(list);
    }
  }

  Stream<BoxEvent> watchSettings() {
    return _settingsBox.watch();
  }

  bool getUseAutoDetection() {
    return _settingsBox.get(_autoDetectionKey, defaultValue: false);
  }

  Future<void> setUseAutoDetection(bool value) async {
    await _settingsBox.put(_autoDetectionKey, value);
  }

  bool isFirstTimeAutoSelection() {
    return _settingsBox.get(_autoSelectionFirstTimeKey, defaultValue: true);
  }

  Future<void> setFirstTimeAutoSelection(bool value) async {
    await _settingsBox.put(_autoSelectionFirstTimeKey, value);
  }
  
  String? getUpiId() {
    return _settingsBox.get(AppConstants.upiIdKey);
  }

  Future<void> setUpiId(String? upiId) async {
    if (upiId == null || upiId.isEmpty) {
      await _settingsBox.delete(AppConstants.upiIdKey);
    } else {
      await _settingsBox.put(AppConstants.upiIdKey, upiId);
    }
  }

  String? getUpiName() {
    return _settingsBox.get(AppConstants.upiNameKey);
  }

  Future<void> setUpiName(String? upiName) async {
    if (upiName == null || upiName.isEmpty) {
      await _settingsBox.delete(AppConstants.upiNameKey);
    } else {
      await _settingsBox.put(AppConstants.upiNameKey, upiName);
    }
  }

  String? getLocale() {
    return _settingsBox.get(AppConstants.localeKey);
  }

  Future<void> setLocale(String? localeCode) async {
    if (localeCode == null) {
      await _settingsBox.delete(AppConstants.localeKey);
    } else {
      await _settingsBox.put(AppConstants.localeKey, localeCode);
    }
  }
}

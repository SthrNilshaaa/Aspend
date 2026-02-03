import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  static const String _settingsBoxName = 'settings';
  static const String _themeKey = 'theme';
  static const String _adaptiveColorKey = 'adaptiveColor';
  static const String _customColorKey = 'customSeedColor';
  static const String _introCompletedKey = 'introCompleted';
  static const String _monthlyBudgetKey = 'monthlyBudget';
  static const String _joinPreviousMonthBalanceKey = 'joinPreviousMonthBalance';
  static const String _customCategoriesKey = 'customCategories'; // Legacy
  static const String _customAccountsKey = 'customAccounts'; // Legacy
  static const String _incomeCategoriesKey = 'incomeCategories';
  static const String _expenseCategoriesKey = 'expenseCategories';
  static const String _accountsKey = 'accounts_list';

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

  Stream<BoxEvent> watchSettings() {
    return _settingsBox.watch();
  }
}

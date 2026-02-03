import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

class ThemeViewModel with ChangeNotifier {
  final SettingsRepository _repository;
  ThemeMode _themeMode = ThemeMode.system;
  bool _useAdaptiveColor = true;
  Color? _customSeedColor;
  double _monthlyBudget = 0;
  bool _joinPreviousMonthBalance = true;
  List<String> _incomeCategories = [];
  List<String> _expenseCategories = [];
  List<String> _accounts = [];

  ThemeViewModel(this._repository) {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get useAdaptiveColor => _useAdaptiveColor;
  Color? get customSeedColor => _customSeedColor;
  double get monthlyBudget => _monthlyBudget;
  bool get joinPreviousMonthBalance => _joinPreviousMonthBalance;
  List<String> get incomeCategories => _incomeCategories;
  List<String> get expenseCategories => _expenseCategories;
  List<String> get accounts => _accounts;

  bool get isDarkMode {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system && brightness == Brightness.dark);
  }

  void _loadSettings() {
    _themeMode = _repository.getThemeMode();
    _useAdaptiveColor = _repository.getUseAdaptiveColor();
    _customSeedColor = _repository.getCustomSeedColor();
    _monthlyBudget = _repository.getMonthlyBudget();
    _joinPreviousMonthBalance = _repository.getJoinPreviousMonthBalance();
    _incomeCategories = _repository.getIncomeCategories();
    _expenseCategories = _repository.getExpenseCategories();
    _accounts = _repository.getAccounts();
    
    // Migration logic
    final legacyCats = _repository.getCustomCategories();
    final legacyAccs = _repository.getCustomAccounts();
    if (legacyCats.isNotEmpty) {
      for (var c in legacyCats) {
        if (!_expenseCategories.contains(c)) {
          _expenseCategories.add(c);
        }
      }
      _repository.setExpenseCategories(_expenseCategories);
      _repository.setCustomCategories([]);
    }
    if (legacyAccs.isNotEmpty) {
      for (var a in legacyAccs) {
        if (!_accounts.contains(a)) {
          _accounts.add(a);
        }
      }
      _repository.setAccounts(_accounts);
      _repository.setCustomAccounts([]);
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _repository.setThemeMode(mode);
    notifyListeners();
  }

  void setUseAdaptiveColor(bool use) async {
    _useAdaptiveColor = use;
    await _repository.setUseAdaptiveColor(use);
    notifyListeners();
  }

  void setCustomSeedColor(Color? color) async {
    _customSeedColor = color;
    await _repository.setCustomSeedColor(color);
    notifyListeners();
  }

  void setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await _repository.setMonthlyBudget(budget);
    notifyListeners();
  }

  void setJoinPreviousMonthBalance(bool value) async {
    _joinPreviousMonthBalance = value;
    await _repository.setJoinPreviousMonthBalance(value);
    notifyListeners();
  }

  void addItem(String item, String type) async {
    if (type == 'Income') {
      if (!_incomeCategories.contains(item)) {
        _incomeCategories.add(item);
        await _repository.setIncomeCategories(_incomeCategories);
      }
    } else if (type == 'Expense') {
      if (!_expenseCategories.contains(item)) {
        _expenseCategories.add(item);
        await _repository.setExpenseCategories(_expenseCategories);
      }
    } else {
      if (!_accounts.contains(item)) {
        _accounts.add(item);
        await _repository.setAccounts(_accounts);
      }
    }
    notifyListeners();
  }

  void updateItem(String old, String next, String type) async {
    if (type == 'Income') {
      final i = _incomeCategories.indexOf(old);
      if (i != -1) {
        _incomeCategories[i] = next;
        await _repository.setIncomeCategories(_incomeCategories);
      }
    } else if (type == 'Expense') {
      final i = _expenseCategories.indexOf(old);
      if (i != -1) {
        _expenseCategories[i] = next;
        await _repository.setExpenseCategories(_expenseCategories);
      }
    } else {
      final i = _accounts.indexOf(old);
      if (i != -1) {
        _accounts[i] = next;
        await _repository.setAccounts(_accounts);
      }
    }
    notifyListeners();
  }

  void removeItem(String item, String type) async {
    if (type == 'Income') {
      if (_incomeCategories.remove(item)) {
        await _repository.setIncomeCategories(_incomeCategories);
      }
    } else if (type == 'Expense') {
      if (_expenseCategories.remove(item)) {
        await _repository.setExpenseCategories(_expenseCategories);
      }
    } else {
      if (_accounts.remove(item)) {
        await _repository.setAccounts(_accounts);
      }
    }
    notifyListeners();
  }
}

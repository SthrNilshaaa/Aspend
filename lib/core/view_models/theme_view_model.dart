import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:aspends_tracker/core/repositories/settings_repository.dart';

class ThemeViewModel with ChangeNotifier {
  final SettingsRepository _repository;
  ThemeMode _themeMode = ThemeMode.system;
  bool _useAdaptiveColor = true;
  Color? _customSeedColor;
  double _monthlyBudget = 0;
  bool _joinPreviousMonthBalance = true;
  bool _autoDeleteUndetected = false;
  List<String> _incomeCategories = [];
  List<String> _expenseCategories = [];
  List<String> _accounts = [];
  String? _upiId;
  String? _upiName;
  Locale? _locale;

  ThemeViewModel(this._repository) {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  bool get useAdaptiveColor => _useAdaptiveColor;
  Color? get customSeedColor => _customSeedColor;
  double get monthlyBudget => _monthlyBudget;
  bool get joinPreviousMonthBalance => _joinPreviousMonthBalance;
  bool get autoDeleteUndetected => _autoDeleteUndetected;
  List<String> get incomeCategories => _incomeCategories;
  List<String> get expenseCategories => _expenseCategories;
  List<String> get accounts => _accounts;
  String? get upiId => _upiId;
  String? get upiName => _upiName;
  Locale? get locale => _locale;

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
    _autoDeleteUndetected = _repository.getAutoDeleteUndetected();
    _incomeCategories = _repository.getIncomeCategories();
    _expenseCategories = _repository.getExpenseCategories();
    _accounts = _repository.getAccounts();
    _upiId = _repository.getUpiId();
    _upiName = _repository.getUpiName();
    final localeCode = _repository.getLocale();
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }

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
    applySystemUI();
    notifyListeners();
  }

  void applySystemUI() {
    final brightness = isDarkMode ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDarkMode ? const Color(0xFF0D0D0D) : const Color(0xFFFDFFFD),
        systemNavigationBarIconBrightness: brightness,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _repository.setThemeMode(mode);
    applySystemUI();
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

  void setAutoDeleteUndetected(bool value) async {
    _autoDeleteUndetected = value;
    await _repository.setAutoDeleteUndetected(value);
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

  void setUpiId(String? id) async {
    _upiId = id;
    await _repository.setUpiId(id);
    notifyListeners();
  }

  void setUpiName(String? name) async {
    _upiName = name;
    await _repository.setUpiName(name);
    notifyListeners();
  }

  void setLocale(Locale? locale) async {
    _locale = locale;
    await _repository.setLocale(locale?.languageCode);
    notifyListeners();
  }
}

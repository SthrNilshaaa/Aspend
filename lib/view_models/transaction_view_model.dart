import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/settings_repository.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
  category
}

class TransactionViewModel with ChangeNotifier {
  final TransactionRepository _repository;
  final SettingsRepository _settings;
  List<Transaction> _txs = [];
  double _bal = 0;
  SortOption _sort = SortOption.dateNewest;
  bool _joinPrev = true;
  StreamSubscription? _sub, _balSub, _setSub;

  TransactionViewModel(this._repository, this._settings) {
    _load();
    _sub = _repository.watchTransactions().listen((e) {
      _load();
      if (!e.deleted &&
          e.value is Transaction &&
          (e.value as Transaction).source != null) {
        _showToast(e.value as Transaction);
      }
    });
    _balSub = _repository.watchBalance().listen((e) {
      _bal = e.value ?? 0;
      notifyListeners();
      _updateHW();
    });
    _setSub = _settings.watchSettings().listen((_) => _loadSettings());
    _loadSettings();
  }

  void _load() {
    _txs = _repository.getAllTransactions();
    _bal = _repository.getCurrentBalance();
    notifyListeners();
    _updateHW();
  }

  void _loadSettings() {
    _joinPrev = _settings.getJoinPreviousMonthBalance();
    notifyListeners();
    _updateHW();
  }

  double get totalBalance {
    if (_joinPrev) return _bal;
    final now = DateTime.now(), start = DateTime(now.year, now.month, 1);
    return _txs
        .where(
            (t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))))
        .fold(0.0, (s, t) => s + (t.isIncome ? t.amount : -t.amount));
  }

  List<Transaction> get transactions => _txs;
  SortOption get currentSortOption => _sort;

  void setSortOption(SortOption o) {
    _sort = o;
    notifyListeners();
  }

  void toggleSortOrder() {
    _sort = (_sort == SortOption.dateNewest)
        ? SortOption.dateOldest
        : SortOption.dateNewest;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction t) async {
    await _repository.addTransaction(t);
    await _updateBal(t.amount, t.isIncome);
  }

  Future<void> deleteTransaction(Transaction t) async {
    await _updateBal(-t.amount, t.isIncome);
    await _repository.deleteTransaction(t.key);
  }

  Future<void> updateTransaction(Transaction old, Transaction next) async {
    final d = (next.isIncome ? next.amount : -next.amount) -
        (old.isIncome ? old.amount : -old.amount);
    await updateBalance(_bal + d);
    await _repository.updateTransaction(old.key, next);
  }

  Future<void> updateBalance(double nb) async {
    await _repository.updateBalance(nb);
    _bal = nb;
    notifyListeners();
    _updateHW();
  }

  Future<void> _updateBal(double a, bool inc) async {
    final nb = _bal + (inc ? a : -a);
    await updateBalance(nb);
  }

  Future<void> deleteAllData() async {
    await _repository.clearAllData();
    _txs.clear();
    _bal = 0;
    notifyListeners();
    _updateHW();
  }

  List<Transaction> get sortedTransactions {
    final l = List<Transaction>.from(_txs);
    switch (_sort) {
      case SortOption.dateNewest:
        l.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateOldest:
        l.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountHighest:
        l.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountLowest:
        l.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.category:
        l.sort((a, b) => a.category.compareTo(b.category));
        break;
    }
    return l;
  }

  List<Transaction> getTransactionsInRange(DateTime start, DateTime end) =>
      sortedTransactions
          .where((t) =>
              t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))))
          .toList();

  double get totalSpend =>
      _txs.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
  double get totalIncome =>
      _txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);

  void _showToast(Transaction t) => Fluttertoast.showToast(
        msg: "Detected ${t.isIncome ? 'Income' : 'Expense'}: ₹${t.amount}",
        backgroundColor: t.isIncome ? Colors.green : Colors.red,
        textColor: Colors.white,
      );

  void _updateHW() async {
    await HomeWidget.saveWidgetData(
        'balance', '₹${totalBalance.toStringAsFixed(2)}');
    await HomeWidget.saveWidgetData(
        'transaction_count', _txs.length.toString());
    await HomeWidget.updateWidget(
        androidName: 'HomeWidgetProvider', iOSName: 'HomeWidget');
  }

  @override
  void dispose() {
    _sub?.cancel();
    _balSub?.cancel();
    _setSub?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'package:aspends_tracker/core/models/transaction.dart';
import 'package:aspends_tracker/core/repositories/transaction_repository.dart';
import 'package:aspends_tracker/core/repositories/settings_repository.dart';

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
  bool _isSyncing = false;

  // Filtering state
  String? _searchQuery;
  String _selectedRange = 'All';

  // Memoization
  List<Transaction>? _cachedFilteredTransactions;
  Map<DateTime, List<Transaction>>? _cachedGroupedTransactions;

  StreamSubscription? _sub, _balSub, _setSub;

  TransactionViewModel(this._repository, this._settings) {
    _loadSync(); // faster initial load
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
      _updateHW();
      notifyListeners();
    });
    _setSub = _settings.watchSettings().listen((_) => _loadSettings());
    _loadSettings();
  }

  void _loadSync() {
    _txs = _repository.getAllTransactions();
    _bal = _repository.getCurrentBalance();
    _markDirty();
    // No notify here as it's during construction
    _updateHW();
  }

  void _load() {
    final txs = _repository.getAllTransactions();
    final bal = _repository.getCurrentBalance();

    _txs = txs;
    _bal = bal;
    _markDirty();
    _updateHW();
    notifyListeners();
  }

  void _loadSettings() {
    _joinPrev = _settings.getJoinPreviousMonthBalance();
    notifyListeners();
    _updateHW();
  }

  // Filtering Getters & Setters
  String? get searchQuery => _searchQuery;
  String get selectedRange => _selectedRange;
  bool get isSyncing => _isSyncing;

  void setSyncing(bool val) {
    if (_isSyncing == val) return;
    _isSyncing = val;
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    final newQuery = query?.toLowerCase().trim();
    if (_searchQuery == newQuery) return;
    _searchQuery = newQuery?.isEmpty == true ? null : newQuery;
    _markDirty();
    notifyListeners();
  }

  void setSelectedRange(String range) {
    if (_selectedRange == range) return;
    _selectedRange = range;
    _markDirty();
    notifyListeners();
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
    if (_sort == o) return;
    _sort = o;
    _markDirty();
    notifyListeners();
  }

  void toggleSortOrder() {
    _sort = (_sort == SortOption.dateNewest)
        ? SortOption.dateOldest
        : SortOption.dateNewest;
    _markDirty();
    notifyListeners();
  }

  Future<void> addTransaction(Transaction t) async {
    await _repository.addTransaction(t);
    await _updateBal(t.amount, t.isIncome);
    _load();
  }

  Future<void> deleteTransaction(Transaction t) async {
    await _updateBal(-t.amount, t.isIncome);
    await _repository.deleteTransaction(t.key);
    _load();
  }

  Future<void> deleteMultipleTransactions(List<Transaction> ts) async {
    if (ts.isEmpty) return;
    double delta = 0;
    for (var t in ts) {
      delta += t.isIncome ? -t.amount : t.amount;
      await _repository.deleteTransaction(t.key);
    }
    await updateBalance(_bal + delta);
    _load();
  }

  Future<void> updateTransaction(Transaction old, Transaction next) async {
    final d = (next.isIncome ? next.amount : -next.amount) -
        (old.isIncome ? old.amount : -old.amount);
    await updateBalance(_bal + d);
    await _repository.updateTransaction(old.key, next);
    _load();
  }

  Future<void> updateBalance(double nb) async {
    await _repository.updateBalance(nb);
    _bal = nb;
    _updateHW();
    notifyListeners();
  }

  Future<void> _updateBal(double a, bool inc) async {
    final nb = _bal + (inc ? a : -a);
    await updateBalance(nb);
  }

  Future<void> deleteAllData() async {
    await _repository.clearAllData();
    _txs.clear();
    _bal = 0;
    _markDirty();
    notifyListeners();
    _updateHW();
  }

  List<Transaction> get filteredTransactions {
    if (_cachedFilteredTransactions != null) {
      return _cachedFilteredTransactions!;
    }

    final allSorted = sortedTransactions;
    DateTime? startDate;
    final now = DateTime.now();

    switch (_selectedRange) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'All':
      default:
        startDate = null;
    }

    _cachedFilteredTransactions = allSorted.where((t) {
      final matchesRange = startDate == null ||
          t.date.isAfter(startDate.subtract(const Duration(seconds: 1)));
      final matchesSearch = _searchQuery == null ||
          t.note.toLowerCase().contains(_searchQuery!) ||
          t.category.toLowerCase().contains(_searchQuery!);
      return matchesRange && matchesSearch;
    }).toList();

    return _cachedFilteredTransactions!;
  }

  Map<DateTime, List<Transaction>> get groupedFilteredTransactions {
    if (_cachedGroupedTransactions != null) return _cachedGroupedTransactions!;

    final txs = filteredTransactions;
    final grouped = <DateTime, List<Transaction>>{};
    for (var tx in txs) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(tx);
    }
    _cachedGroupedTransactions = grouped;
    return _cachedGroupedTransactions!;
  }

  List<Transaction>? _cachedSortedTransactions;

  List<Transaction> get sortedTransactions {
    if (_cachedSortedTransactions != null) return _cachedSortedTransactions!;

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
    _cachedSortedTransactions = l;
    return _cachedSortedTransactions!;
  }

  List<Transaction> getTransactionsInRange(DateTime start, DateTime end) =>
      sortedTransactions
          .where((t) =>
              t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(end.add(const Duration(days: 1))))
          .toList();

  double get totalSpend => filteredTransactions
      .where((t) => !t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);
  double get totalIncome => filteredTransactions
      .where((t) => t.isIncome)
      .fold(0.0, (s, t) => s + t.amount);

  void _showToast(Transaction t) => Fluttertoast.showToast(
        msg: "Detected ${t.isIncome ? 'Income' : 'Expense'}: ₹${t.amount}",
        backgroundColor: t.isIncome ? Colors.green : Colors.red,
        textColor: Colors.white,
      );

  void _updateHW() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    final monthTxs = _txs.where((t) => t.date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))));
    final monthIncome = monthTxs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final monthExpense = monthTxs.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);
    
    String lastTxText = "";
    if (_txs.isNotEmpty) {
      final last = sortedTransactions.first;
      lastTxText = "${last.isIncome ? '+' : '-'}${last.amount.toStringAsFixed(0)} ${last.note}";
      if (lastTxText.length > 25) lastTxText = "${lastTxText.substring(0, 22)}...";
    }

    await HomeWidget.saveWidgetData('balance', '₹${totalBalance.toStringAsFixed(2)}');
    await HomeWidget.saveWidgetData('total_income', monthIncome.toString());
    await HomeWidget.saveWidgetData('total_expenses', monthExpense.toString());
    await HomeWidget.saveWidgetData('last_transaction', lastTxText);
    
    await HomeWidget.updateWidget(
        androidName: 'HomeWidgetProvider',
        iOSName: 'HomeWidget');
  }

  void _markDirty() {
    _cachedSortedTransactions = null;
    _cachedFilteredTransactions = null;
    _cachedGroupedTransactions = null;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _balSub?.cancel();
    _setSub?.cancel();
    super.dispose();
  }
}

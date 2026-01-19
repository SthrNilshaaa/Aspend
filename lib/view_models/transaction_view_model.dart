import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
  category
}

class TransactionViewModel with ChangeNotifier {
  final TransactionRepository _repository;

  List<Transaction> _transactions = [];
  double _currentBalance = 0;
  SortOption _currentSortOption = SortOption.dateNewest;

  // Memoization
  List<Transaction>? _cachedSpends;
  List<Transaction>? _cachedIncomes;
  Map<String, List<Transaction>>? _cachedGroupedTransactions;
  double? _cachedTotalSpend;
  double? _cachedTotalIncome;
  bool _isDirty = true;

  StreamSubscription? _txSubscription;
  StreamSubscription? _balanceSubscription;

  TransactionViewModel(this._repository) {
    _loadData();
    _subscribeToChanges();
  }

  SortOption get currentSortOption => _currentSortOption;
  bool get sortByNewestFirst => _currentSortOption == SortOption.dateNewest;
  List<Transaction> get transactions => _transactions;
  double get totalBalance => _currentBalance;

  void setSortOption(SortOption option) {
    _currentSortOption = option;
    _markDirty();
    notifyListeners();
  }

  void toggleSortOrder() {
    if (_currentSortOption == SortOption.dateNewest) {
      _currentSortOption = SortOption.dateOldest;
    } else {
      _currentSortOption = SortOption.dateNewest;
    }
    _markDirty();
    notifyListeners();
  }

  void _subscribeToChanges() {
    _txSubscription = _repository.watchTransactions().listen((event) {
      _loadData();
      if (!event.deleted && event.value is Transaction) {
        final tx = event.value as Transaction;
        if (tx.source != null) {
          _showDetectionToast(tx);
        }
      }
    });

    _balanceSubscription = _repository.watchBalance().listen((event) {
      _currentBalance = event.value ?? 0.0;
      notifyListeners();
      _updateHomeWidget();
    });
  }

  void _showDetectionToast(Transaction tx) {
    Fluttertoast.showToast(
      msg: "Detected ${tx.isIncome ? 'Income' : 'Expense'}: ₹${tx.amount}",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: tx.isIncome ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _loadData() {
    _transactions = _repository.getAllTransactions();
    _currentBalance = _repository.getCurrentBalance();
    _markDirty();
    _updateHomeWidget();
    notifyListeners();
  }

  void addTransaction(Transaction tx) async {
    await _repository.addTransaction(tx);
    await addOrMinusBalance(tx.amount, tx.isIncome);
  }

  void deleteTransaction(Transaction transaction) async {
    await addOrMinusBalance(-transaction.amount, transaction.isIncome);
    await _repository.deleteTransaction(transaction.key);
  }

  void updateTransaction(Transaction oldTx, Transaction newTx) async {
    // Revert old effect and apply new effect
    final double oldEffect = oldTx.isIncome ? oldTx.amount : -oldTx.amount;
    final double newEffect = newTx.isIncome ? newTx.amount : -newTx.amount;
    final double delta = newEffect - oldEffect;

    await updateBalance(_currentBalance + delta);
    await _repository.updateTransaction(oldTx.key, newTx);
  }

  Future<void> updateBalance(double newBalance) async {
    await _repository.updateBalance(newBalance);
    _currentBalance = newBalance;
    notifyListeners();
  }

  Future<void> addOrMinusBalance(double amount, bool isIncome) async {
    final double newBalance = _currentBalance + (isIncome ? amount : -amount);
    await _repository.updateBalance(newBalance);
    _currentBalance = newBalance;
    notifyListeners();
  }

  Future<void> deleteAllData() async {
    await _repository.clearAllData();
    _transactions.clear();
    _currentBalance = 0.0;
    _markDirty();
    _updateHomeWidget();
    notifyListeners();
  }

  // Getters for filtered/grouped data
  List<Transaction> get spends {
    if (_cachedSpends == null || _isDirty) {
      _cachedSpends = _transactions.where((t) => !t.isIncome).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    _isDirty = false;
    return _cachedSpends!;
  }

  List<Transaction> get incomes {
    if (_cachedIncomes == null || _isDirty) {
      _cachedIncomes = _transactions.where((t) => t.isIncome).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
    _isDirty = false;
    return _cachedIncomes!;
  }

  List<Transaction> getTransactionsInRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Transaction> get sortedTransactions {
    if (_isDirty) {
      switch (_currentSortOption) {
        case SortOption.dateNewest:
          _transactions.sort((a, b) => b.date.compareTo(a.date));
          break;
        case SortOption.dateOldest:
          _transactions.sort((a, b) => a.date.compareTo(b.date));
          break;
        case SortOption.amountHighest:
          _transactions.sort((a, b) => b.amount.compareTo(a.amount));
          break;
        case SortOption.amountLowest:
          _transactions.sort((a, b) => a.amount.compareTo(b.amount));
          break;
        case SortOption.category:
          _transactions.sort((a, b) => a.category.compareTo(b.category));
          break;
      }
      _isDirty = false;
    }
    return _transactions;
  }

  double get totalSpend {
    if (_cachedTotalSpend == null || _isDirty) {
      final spendList =
          _cachedSpends ?? _transactions.where((t) => !t.isIncome).toList();
      _cachedTotalSpend =
          spendList.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    }
    return _cachedTotalSpend ?? 0.0;
  }

  double get totalIncome {
    if (_cachedTotalIncome == null || _isDirty) {
      final incomeList =
          _cachedIncomes ?? _transactions.where((t) => t.isIncome).toList();
      _cachedTotalIncome =
          incomeList.fold<double>(0.0, (sum, tx) => sum + tx.amount);
    }
    return _cachedTotalIncome ?? 0.0;
  }

  Map<String, List<Transaction>> get groupedTransactions {
    if (_cachedGroupedTransactions == null || _isDirty) {
      _cachedGroupedTransactions = _groupTransactionsByDate(_transactions);
      _cachedGroupedTransactions!.forEach((key, transactions) {
        transactions.sort((a, b) => b.date.compareTo(a.date));
      });
    }
    return _cachedGroupedTransactions!;
  }

  void _markDirty() {
    _isDirty = true;
    _cachedSpends = null;
    _cachedIncomes = null;
    _cachedGroupedTransactions = null;
    _cachedTotalSpend = null;
    _cachedTotalIncome = null;
  }

  void _updateHomeWidget() async {
    final formattedBalance = '₹${_currentBalance.toStringAsFixed(2)}';
    await HomeWidget.saveWidgetData('balance', formattedBalance);
    await HomeWidget.saveWidgetData(
        'transaction_count', _transactions.length.toString());

    final totalIncome = _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = _transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    await HomeWidget.saveWidgetData('total_income', totalIncome.toString());
    await HomeWidget.saveWidgetData('total_expenses', totalExpenses.toString());
    await HomeWidget.saveWidgetData('has_data', _transactions.isNotEmpty);

    await HomeWidget.updateWidget(
      androidName: 'HomeWidgetProvider',
      iOSName: 'HomeWidget',
    );
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(
      List<Transaction> transactions) {
    if (transactions.isEmpty) return {};

    final Map<String, List<Transaction>> grouped = {};
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    for (var tx in transactions) {
      final DateTime txDate =
          DateTime(tx.date.year, tx.date.month, tx.date.day);
      String formattedDate;

      if (txDate == today) {
        formattedDate = 'Today';
      } else if (txDate == yesterday) {
        formattedDate = 'Yesterday';
      } else {
        formattedDate = _formatDate(tx.date);
      }

      grouped.putIfAbsent(formattedDate, () => []).add(tx);
    }
    return grouped;
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  void dispose() {
    _txSubscription?.cancel();
    _balanceSubscription?.cancel();
    super.dispose();
  }
}

import 'package:aspends_tracker/core/const/app_constants.dart';
import 'package:aspends_tracker/core/models/transaction.dart';
import 'package:aspends_tracker/core/models/detection_history.dart';
import 'package:hive/hive.dart'; 

class TransactionRepository {
  static const String _txBoxName = AppConstants.transactionsBox;
  static const String _balanceBoxName = AppConstants.balanceBox;
  static const String _historyBoxName = AppConstants.detectionHistoryBox;
  static const String _currentBalanceKey = 'currentBalance';

  Box<Transaction> get _txBox => Hive.box<Transaction>(_txBoxName);
  Box<double> get _balanceBox => Hive.box<double>(_balanceBoxName);
  Box<DetectionHistory> get _historyBox => Hive.box<DetectionHistory>(_historyBoxName);

  List<Transaction> getAllTransactions() {
    return _txBox.values.toList();
  }

  double getCurrentBalance() {
    return _balanceBox.get(_currentBalanceKey, defaultValue: 0.0) ?? 0.0;
  }

  Future<void> addTransaction(Transaction tx) async {
    await _txBox.add(tx);
  }

  Future<void> deleteTransaction(dynamic key) async {
    await _txBox.delete(key);
  }

  Future<void> updateTransaction(dynamic key, Transaction tx) async {
    await _txBox.put(key, tx);
  }

  Future<void> updateBalance(double balance) async {
    await _balanceBox.put(_currentBalanceKey, balance);
  }

  Future<void> clearAllData() async {
    await _txBox.clear();
    await _balanceBox.put(_currentBalanceKey, 0.0);
  }

  Stream<BoxEvent> watchTransactions() {
    return _txBox.watch();
  }

  Stream<BoxEvent> watchBalance() {
    return _balanceBox.watch(key: _currentBalanceKey);
  }

  // Detection History Methods
  List<DetectionHistory> getDetectionHistory() {
    return _historyBox.values.toList();
  }

  Future<void> addDetectionHistory(DetectionHistory entry) async {
    await _historyBox.add(entry);
  }

  Future<void> updateDetectionHistory(List<DetectionHistory> history) async {
    await _historyBox.clear();
    await _historyBox.addAll(history);
  }

  Future<void> clearOldDetectionHistory(Duration threshold) async {
    final now = DateTime.now();
    final keysToDelete = <dynamic>[];

    for (var key in _historyBox.keys) {
      final entry = _historyBox.get(key);
      if (entry != null && (entry.status == 'skipped' || entry.status == 'failed')) {
        if (now.difference(entry.timestamp) >= threshold) {
          keysToDelete.add(key);
        }
      }
    }

    if (keysToDelete.isNotEmpty) {
      await _historyBox.deleteAll(keysToDelete);
    }
  }
}

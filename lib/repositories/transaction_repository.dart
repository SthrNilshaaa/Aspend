import 'package:hive/hive.dart';
import '../models/transaction.dart';

class TransactionRepository {
  static const String _txBoxName = 'transactions';
  static const String _balanceBoxName = 'balanceBox';
  static const String _currentBalanceKey = 'currentBalance';

  Box<Transaction> get _txBox => Hive.box<Transaction>(_txBoxName);
  Box<double> get _balanceBox => Hive.box<double>(_balanceBoxName);

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
}

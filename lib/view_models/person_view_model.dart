import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../repositories/person_repository.dart';

class PersonViewModel with ChangeNotifier {
  final PersonRepository _repository;

  List<Person> _people = [];
  List<PersonTransaction> _transactions = [];

  // Memoization
  Map<String, List<PersonTransaction>>? _cachedGroupedByPerson;
  Map<String, double>? _cachedTotals;
  bool _isDirty = true;

  PersonViewModel(this._repository) {
    _loadData();
    _subscribeToChanges();
  }

  List<Person> get people => _people;

  List<PersonTransaction> get allTransactions {
    if (_isDirty) {
      _transactions = _repository.getAllPersonTransactions();
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _isDirty = false;
    }
    return _transactions;
  }

  void _loadData() {
    _people = _repository.getAllPeople();
    _transactions = _repository.getAllPersonTransactions();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _markDirty();
    notifyListeners();
  }

  void _subscribeToChanges() {
    _repository.watchPeople().listen((_) => _loadData());
    _repository.watchPersonTransactions().listen((_) => _loadData());
  }

  void addPerson(Person person) async {
    await _repository.addPerson(person);
  }

  void deletePerson(Person person) async {
    await _repository.deletePerson(person.key);
  }

  void addPersonTransaction(PersonTransaction tx, String personName) async {
    await _repository.addPersonTransaction(tx);
  }

  void deleteTransaction(PersonTransaction tx) async {
    await _repository.deletePersonTransaction(tx.key);
  }

  List<PersonTransaction> transactionsFor(String personName) {
    return allTransactions.where((tx) => tx.personName == personName).toList();
  }

  double getTotalForPerson(String name) {
    if (_cachedTotals == null || _isDirty) {
      _calculateTotals();
    }
    return _cachedTotals![name] ?? 0.0;
  }

  void _calculateTotals() {
    _cachedTotals = {};
    for (var tx in allTransactions) {
      _cachedTotals![tx.personName] = (_cachedTotals![tx.personName] ?? 0.0) +
          (tx.isIncome ? tx.amount : -tx.amount);
    }
  }

  Map<String, List<PersonTransaction>> get groupedByPerson {
    if (_cachedGroupedByPerson == null || _isDirty) {
      final Map<String, List<PersonTransaction>> grouped = {};
      for (var tx in allTransactions) {
        grouped.putIfAbsent(tx.personName, () => []).add(tx);
      }
      _cachedGroupedByPerson = grouped;
    }
    return _cachedGroupedByPerson!;
  }

  double get overallTotalRent {
    double total = 0;
    for (var person in _people) {
      double personTotal = getTotalForPerson(person.name);
      if (personTotal > 0) total += personTotal;
    }
    return total;
  }

  double get overallTotalGiven {
    double total = 0;
    for (var person in _people) {
      double personTotal = getTotalForPerson(person.name);
      if (personTotal < 0) total += personTotal.abs();
    }
    return total;
  }

  Future<void> deleteAllData() async {
    await _repository.clearAllPeopleData();
    await _repository.clearAllPersonTransactionsData();
    _loadData();
  }

  void _markDirty() {
    _isDirty = true;
    _cachedGroupedByPerson = null;
    _cachedTotals = null;
  }
}

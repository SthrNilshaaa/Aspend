import 'package:flutter/foundation.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../repositories/person_repository.dart';

enum PersonSortOption {
  nameAZ,
  nameZA,
  balanceHighest,
  balanceLowest,
}

enum PersonTransactionSortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
}

class PersonViewModel with ChangeNotifier {
  final PersonRepository _repository;

  List<Person> _people = [];
  List<PersonTransaction> _transactions = [];
  PersonSortOption _sortOption = PersonSortOption.nameAZ;

  // Memoization
  Map<String, List<PersonTransaction>>? _cachedGroupedByPerson;
  Map<String, double>? _cachedTotals;
  List<Person>? _cachedSortedPeople;
  bool _isDirty = true;

  PersonViewModel(this._repository) {
    _loadData();
    _subscribeToChanges();
  }

  List<Person> get people => _people;

  PersonSortOption get currentSortOption => _sortOption;

  void setSortOption(PersonSortOption option) {
    if (_sortOption == option) return;
    _sortOption = option;
    _cachedSortedPeople = null;
    notifyListeners();
  }

  List<Person> get sortedPeople {
    if (_cachedSortedPeople != null) return _cachedSortedPeople!;

    final list = List<Person>.from(_people);
    switch (_sortOption) {
      case PersonSortOption.nameAZ:
        list.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case PersonSortOption.nameZA:
        list.sort(
            (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case PersonSortOption.balanceHighest:
        list.sort((a, b) =>
            getTotalForPerson(b.name).compareTo(getTotalForPerson(a.name)));
        break;
      case PersonSortOption.balanceLowest:
        list.sort((a, b) =>
            getTotalForPerson(a.name).compareTo(getTotalForPerson(b.name)));
        break;
    }
    _cachedSortedPeople = list;
    return list;
  }

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
    _loadData();
  }

  void deletePerson(Person person) async {
    await _repository.deletePerson(person.key);
    _loadData();
  }

  void updatePerson(Person oldPerson, Person newPerson) async {
    await _repository.updatePerson(oldPerson.key, newPerson);

    // If name changed, update all transactions associated with this person
    if (oldPerson.name != newPerson.name) {
      final transactions = _repository.getAllPersonTransactions();
      for (final tx in transactions) {
        if (tx.personName == oldPerson.name) {
          final updatedTx = PersonTransaction(
            personName: newPerson.name,
            amount: tx.amount,
            note: tx.note,
            date: tx.date,
            isIncome: tx.isIncome,
          );
          await _repository.updatePersonTransaction(tx.key, updatedTx);
        }
      }
    }
    _loadData();
  }

  void addPersonTransaction(PersonTransaction tx, String personName) async {
    await _repository.addPersonTransaction(tx);
    _loadData();
  }

  void updatePersonTransaction(
      PersonTransaction oldTx, PersonTransaction newTx) async {
    await _repository.updatePersonTransaction(oldTx.key, newTx);
    _loadData();
  }

  void deleteTransaction(PersonTransaction tx) async {
    await _repository.deletePersonTransaction(tx.key);
    _loadData();
  }

  List<PersonTransaction> transactionsFor(String personName) {
    return allTransactions.where((tx) => tx.personName == personName).toList();
  }

  // Moved from UI for performance
  Map<String, List<PersonTransaction>> getGroupedTransactionsFor(
      String personName, PersonTransactionSortOption sortOption) {
    final txs = transactionsFor(personName);
    final sortedTxs = List<PersonTransaction>.from(txs);

    switch (sortOption) {
      case PersonTransactionSortOption.dateNewest:
        sortedTxs.sort((a, b) => b.date.compareTo(a.date));
        break;
      case PersonTransactionSortOption.dateOldest:
        sortedTxs.sort((a, b) => a.date.compareTo(b.date));
        break;
      case PersonTransactionSortOption.amountHighest:
        sortedTxs.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case PersonTransactionSortOption.amountLowest:
        sortedTxs.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    final groups = <String, List<PersonTransaction>>{};
    for (var tx in sortedTxs) {
      final dateStr = _getGroupHeader(tx.date);
      if (!groups.containsKey(dateStr)) {
        groups[dateStr] = [];
      }
      groups[dateStr]!.add(tx);
    }
    return groups;
  }

  String _getGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      // We don't have access to DateFormat here unless we import intl
      // But we can return a consistently formatted string
      return "${date.day} ${_getMonthName(date.month)}, ${date.year}";
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
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
    _cachedSortedPeople = null;
  }
}

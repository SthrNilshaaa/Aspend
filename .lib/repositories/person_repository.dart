import 'package:hive/hive.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';

class PersonRepository {
  static const String _peopleBoxName = 'people';
  static const String _txBoxName = 'personTransactions';

  Box<Person> get _peopleBox => Hive.box<Person>(_peopleBoxName);
  Box<PersonTransaction> get _txBox => Hive.box<PersonTransaction>(_txBoxName);

  List<Person> getAllPeople() {
    return _peopleBox.values.toList();
  }

  Future<void> addPerson(Person person) async {
    await _peopleBox.add(person);
  }

  Future<void> deletePerson(dynamic key) async {
    await _peopleBox.delete(key);
  }

  List<PersonTransaction> getAllPersonTransactions() {
    return _txBox.values.toList();
  }

  List<PersonTransaction> getTransactionsForPerson(String personName) {
    return _txBox.values.where((tx) => tx.personName == personName).toList();
  }

  Future<void> addPersonTransaction(PersonTransaction tx) async {
    await _txBox.add(tx);
  }

  Future<void> deletePersonTransaction(dynamic key) async {
    await _txBox.delete(key);
  }

  Future<void> clearAllPeopleData() async {
    await _peopleBox.clear();
  }

  Future<void> clearAllPersonTransactionsData() async {
    await _txBox.clear();
  }

  Stream<BoxEvent> watchPeople() {
    return _peopleBox.watch();
  }

  Stream<BoxEvent> watchPersonTransactions() {
    return _txBox.watch();
  }
}

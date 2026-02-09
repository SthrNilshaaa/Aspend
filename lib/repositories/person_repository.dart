import 'package:hive/hive.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../const/app_constants.dart';

class PersonRepository {
  static const String _peopleBoxName = AppConstants.peopleBox;
  static const String _txBoxName = AppConstants.personTransactionsBox;

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

  Future<void> updatePerson(dynamic key, Person person) async {
    await _peopleBox.put(key, person);
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

  Future<void> updatePersonTransaction(
      dynamic key, PersonTransaction tx) async {
    await _txBox.put(key, tx);
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

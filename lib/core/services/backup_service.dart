import 'dart:convert';
import 'dart:io';
import 'package:aspends_tracker/core/const/app_constants.dart';
import 'package:aspends_tracker/core/models/person.dart';
import 'package:aspends_tracker/core/models/person_transaction.dart';
import 'package:aspends_tracker/core/models/transaction.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; 

class BackupService {
  static Future<void> exportToCsvAndShare() async {
    final box = Hive.box<Transaction>(AppConstants.transactionsBox);
    final txs = box.values.toList();

    List<List<dynamic>> rows = [];
    rows.add(["Date", "Note", "Amount", "Category", "Account", "Type"]);

    for (var tx in txs) {
      List<dynamic> row = [];
      row.add(tx.date.toString());
      row.add(tx.note);
      row.add(tx.amount);
      row.add(tx.category);
      row.add(tx.account);
      row.add(tx.isIncome ? "Income" : "Expense");
      rows.add(row);
    }
    String csvData = Csv().encode(rows);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/aspends_transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Aspends Transactions Export (CSV)',
      ),
    );
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)],
        text: 'Aspends Transactions Export (CSV)'));
  }

  static Future<void> exportAllDataJsonAndShare() async {
    final txBox = Hive.box<Transaction>(AppConstants.transactionsBox);
    final peopleBox = Hive.box<Person>('people');
    final personTxBox = Hive.box<PersonTransaction>('personTransactions');
    final settingsBox = Hive.box(AppConstants.settingsBox);

    final data = {
      'transactions': txBox.values.map((t) => t.toJson()).toList(),
      'people': peopleBox.values.map((p) => p.toJson()).toList(),
      'personTransactions':
          personTxBox.values.map((pt) => pt.toJson()).toList(),
      'settings': Map<String, dynamic>.from(settingsBox.toMap()),
      'balance': Hive.box<double>(AppConstants.balanceBox)
          .get('currentBalance', defaultValue: 0.0),
      'exportDate': DateTime.now().toIso8601String(),
    };

    final jsonStr = jsonEncode(data);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/aspends_full_backup_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(jsonStr);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Aspends Full Backup (JSON)',
      ),
    );
  }

  static Future<bool> importDataFromJson(BuildContext context, {String conflictResolutionStrategy = 'merge'}) async {
    final txBox = Hive.box<Transaction>(AppConstants.transactionsBox);
    final peopleBox = Hive.box<Person>('people');
    final personTxBox = Hive.box<PersonTransaction>('personTransactions');
    final settingsBox = Hive.box(AppConstants.settingsBox);
    final balanceBox = Hive.box<double>(AppConstants.balanceBox);

    // Create safe pre-import database state snapshots
    final txSnapshot = txBox.values.toList();
    final peopleSnapshot = peopleBox.values.toList();
    final personTxSnapshot = personTxBox.values.toList();
    final settingsSnapshot = Map<String, dynamic>.from(settingsBox.toMap());
    final balanceSnapshot = balanceBox.get('currentBalance');

    Future<void> rollback() async {
      debugPrint('Restoring safe pre-import snapshot due to error...');
      try {
        await txBox.clear();
        for (var tx in txSnapshot) {
          await txBox.add(tx);
        }
        await peopleBox.clear();
        for (var p in peopleSnapshot) {
          await peopleBox.add(p);
        }
        await personTxBox.clear();
        for (var pt in personTxSnapshot) {
          await personTxBox.add(pt);
        }
        await settingsBox.clear();
        for (var entry in settingsSnapshot.entries) {
          await settingsBox.put(entry.key, entry.value);
        }
        if (balanceSnapshot != null) {
          await balanceBox.put('currentBalance', balanceSnapshot);
        } else {
          await balanceBox.clear();
        }
      } catch (rollbackError) {
        debugPrint('Rollback failed catastrophically: $rollbackError');
      }
    }

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      // Import Transactions
      if (data.containsKey('transactions')) {
        final existingTxs = txBox.values.toList();
        for (var item in data['transactions']) {
          final double amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
          final String note = item['note'] ?? '';
          final String category = item['category'] ?? '';
          final String account = item['account'] ?? '';
          final DateTime date = DateTime.parse(item['date']);
          final bool isIncome = item['isIncome'] ?? false;
          final List<String>? imagePaths = (item['imagePaths'] as List?)
              ?.map((e) => e.toString())
              .toList();

          Transaction? conflictTx;
          for (var tx in existingTxs) {
            if ((tx.amount - amount).abs() < 0.01 &&
                tx.date.millisecondsSinceEpoch == date.millisecondsSinceEpoch &&
                tx.note == note &&
                tx.category == category &&
                tx.account == account &&
                tx.isIncome == isIncome) {
              conflictTx = tx;
              break;
            }
          }

          if (conflictTx != null) {
            if (conflictResolutionStrategy == 'overwrite') {
              conflictTx.amount = amount;
              conflictTx.note = note;
              conflictTx.category = category;
              conflictTx.account = account;
              conflictTx.date = date;
              conflictTx.isIncome = isIncome;
              conflictTx.imagePaths = imagePaths;
              await conflictTx.save();
            }
          } else {
            await txBox.add(Transaction(
              amount: amount,
              note: note,
              category: category,
              account: account,
              date: date,
              isIncome: isIncome,
              imagePaths: imagePaths,
            ));
          }
        }
      }

      // Import People
      if (data.containsKey('people')) {
        final existingPeople = peopleBox.values.toList();
        for (var item in data['people']) {
          final backupPerson = Person.fromJson(item);
          Person? conflictPerson;
          for (var p in existingPeople) {
            if (p.name.trim().toLowerCase() == backupPerson.name.trim().toLowerCase()) {
              conflictPerson = p;
              break;
            }
          }

          if (conflictPerson != null) {
            if (conflictResolutionStrategy == 'overwrite') {
              conflictPerson.photoPath = backupPerson.photoPath;
              conflictPerson.upiId = backupPerson.upiId;
              await conflictPerson.save();
            }
          } else {
            await peopleBox.add(backupPerson);
          }
        }
      }

      // Import Person Transactions
      if (data.containsKey('personTransactions')) {
        final existingPersonTxs = personTxBox.values.toList();
        for (var item in data['personTransactions']) {
          final backupPersonTx = PersonTransaction.fromJson(item);
          PersonTransaction? conflictPersonTx;
          for (var pt in existingPersonTxs) {
            if (pt.personName == backupPersonTx.personName &&
                (pt.amount - backupPersonTx.amount).abs() < 0.01 &&
                pt.date.millisecondsSinceEpoch == backupPersonTx.date.millisecondsSinceEpoch &&
                pt.note == backupPersonTx.note &&
                pt.isIncome == backupPersonTx.isIncome) {
              conflictPersonTx = pt;
              break;
            }
          }

          if (conflictPersonTx != null) {
            if (conflictResolutionStrategy == 'overwrite') {
              conflictPersonTx.amount = backupPersonTx.amount;
              conflictPersonTx.note = backupPersonTx.note;
              conflictPersonTx.date = backupPersonTx.date;
              conflictPersonTx.isIncome = backupPersonTx.isIncome;
              await conflictPersonTx.save();
            }
          } else {
            await personTxBox.add(backupPersonTx);
          }
        }
      }

      // Import Settings
      if (data.containsKey('settings')) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (var entry in settings.entries) {
          await settingsBox.put(entry.key, entry.value);
        }
      }

      // Import Balance
      if (data.containsKey('balance')) {
        await balanceBox.put('currentBalance', data['balance']);
      }

      return true;
    } catch (e) {
      debugPrint('Import Error occurred. Commencing safe snapshot rollback: $e');
      await rollback();
      rethrow;
    }
  }
}

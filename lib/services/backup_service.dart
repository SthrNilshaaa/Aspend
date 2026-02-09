import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction.dart';
import '../models/person.dart';
import '../models/person_transaction.dart';
import '../const/app_constants.dart';

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

    String csvData = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/aspends_transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(file.path)],
        text: 'Aspends Transactions Export (CSV)');
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

    await Share.shareXFiles([XFile(file.path)],
        text: 'Aspends Full Backup (JSON)');
  }

  static Future<bool> importDataFromJson(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);

      // Import Transactions
      if (data.containsKey('transactions')) {
        final box = Hive.box<Transaction>(AppConstants.transactionsBox);
        await box.clear();
        for (var item in data['transactions']) {
          await box.add(Transaction(
            amount: item['amount'],
            note: item['note'],
            category: item['category'],
            account: item['account'],
            date: DateTime.parse(item['date']),
            isIncome: item['isIncome'],
            imagePaths: (item['imagePaths'] as List?)
                ?.map((e) => e.toString())
                .toList(),
          ));
        }
      }

      // Import People
      if (data.containsKey('people')) {
        final box = Hive.box<Person>('people');
        await box.clear();
        for (var item in data['people']) {
          await box.add(Person.fromJson(item));
        }
      }

      // Import Person Transactions
      if (data.containsKey('personTransactions')) {
        final box = Hive.box<PersonTransaction>('personTransactions');
        await box.clear();
        for (var item in data['personTransactions']) {
          await box.add(PersonTransaction.fromJson(item));
        }
      }

      // Import Settings
      if (data.containsKey('settings')) {
        final box = Hive.box(AppConstants.settingsBox);
        final settings = data['settings'] as Map<String, dynamic>;
        for (var entry in settings.entries) {
          await box.put(entry.key, entry.value);
        }
      }

      // Import Balance
      if (data.containsKey('balance')) {
        await Hive.box<double>(AppConstants.balanceBox)
            .put('currentBalance', data['balance']);
      }

      return true;
    } catch (e) {
      debugPrint('Import Error: $e');
      return false;
    }
  }
}

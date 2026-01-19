import 'dart:async';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/transaction.dart';
import 'native_bridge.dart';
import '../utils/transaction_parser.dart';
import '../models/detection_history.dart';

class TransactionDetectionService {
  static const String _settingsBoxName = 'settings';
  static const String _autoDetectionKey = 'autoDetectionEnabled';
  static Timer? _recheckTimer;

  static Future<void> initialize() async {
    // Check if auto-detection is enabled
    final settingsBox = await Hive.openBox(_settingsBoxName);
    final isEnabled = settingsBox.get(_autoDetectionKey, defaultValue: false);

    if (isEnabled) {
      await startMonitoring();

      // Process any notifications that were queued while app was closed
      await _processPendingNotifications();
    }
  }

  static Future<void> _processPendingNotifications() async {
    final pending = await NativeBridge.getPendingNotifications();
    if (pending.isEmpty) return;

    print(
        'Processing ${pending.length} pending notifications from offline queue');
    for (final entry in pending) {
      final parts = entry.split('|');
      if (parts.length < 3) continue;

      if (parts[0] == 'SMS') {
        final body = parts[1];
        final sender = parts[2];
        await processSmsMessage(body, sender: sender);
      } else {
        final title = parts[0];
        final text = parts[1];
        final packageName = parts[2];
        await processNotification(title, text, packageName: packageName);
      }
    }
  }

  static Future<void> startMonitoring() async {
    try {
      // Request permissions
      await _requestPermissions();

      // Start notification monitoring
      await _startNotificationMonitoring();

      // Start keep alive service
      await NativeBridge.startKeepAliveService();

      // Start periodic recheck
      _startRecheckTimer();

      // Run first recheck immediately
      recheckSkippedTransactions();

      print('Transaction detection monitoring started successfully');
    } catch (e) {
      print('Error starting transaction detection: $e');
    }
  }

  static Future<void> stopMonitoring() async {
    try {
      _recheckTimer?.cancel();
      await NativeBridge.stopKeepAliveService();
      print('Transaction detection monitoring stopped');
    } catch (e) {
      print('Error stopping transaction detection: $e');
    }
  }

  static Future<void> _requestPermissions() async {
    // Request notification permission
    await Permission.notification.request();

    // Request SMS permission
    await Permission.sms.request();

    // Requesting ignore battery optimization is also important for background services
    await NativeBridge.requestBatteryOptimization();
  }

  static Future<void> _startNotificationMonitoring() async {
    // Check if notification access is enabled
    final hasAccess = await NativeBridge.checkNotificationPermission();
    if (!hasAccess) {
      await NativeBridge.requestNotificationPermission();
    }
  }

  static Future<void> processNotification(String title, String body,
      {String? packageName}) async {
    if (!(await isEnabled())) {
      print('Auto-detection disabled, skipping notification processing.');
      return;
    }
    try {
      // Skip notifications from our own app
      if (packageName == 'org.x.aspend.ns') return;

      final fullText = '$title $body';
      final detectedTransaction =
          _extractTransactionFromText(fullText, packageName: packageName);

      if (detectedTransaction != null) {
        await _addDetectedTransaction(detectedTransaction, 'Notification');
        await _recordDetection(
          text: fullText,
          status: 'detected',
          packageName: packageName,
        );
      } else {
        await _recordDetection(
          text: fullText,
          status: 'skipped',
          reason: 'Pattern not matched or filtered out',
          packageName: packageName,
        );
      }
    } catch (e) {
      print('Error processing notification: $e');
    }
  }

  static Future<void> processSmsMessage(String body, {String? sender}) async {
    if (!(await isEnabled())) {
      print('Auto-detection disabled, skipping SMS processing.');
      return;
    }
    try {
      // Ignore OTP messages
      final lowerBody = body.toLowerCase();
      if (lowerBody.contains('otp') ||
          lowerBody.contains('verification code')) {
        return;
      }

      final detectedTransaction =
          _extractTransactionFromText(body, packageName: sender);
      if (detectedTransaction != null) {
        await _addDetectedTransaction(detectedTransaction, 'SMS');
        await _recordDetection(
          text: body,
          status: 'detected',
        );
      } else {
        await _recordDetection(
          text: body,
          status: 'skipped',
          reason: 'Pattern not matched or filtered out',
        );
      }
    } catch (e) {
      print('Error processing SMS message: $e');
    }
  }

  static Transaction? _extractTransactionFromText(String text,
      {String? packageName}) {
    final parsed = TransactionParser.parse(text, packageName: packageName);
    return parsed?.toTransaction();
  }

  static Future<void> _addDetectedTransaction(
      Transaction transaction, String source) async {
    try {
      // Open boxes
      final transactionBox = await Hive.openBox<Transaction>('transactions');
      final balanceBox = await Hive.openBox<double>('balanceBox');

      // Check for duplicates (within last 5 minutes)
      final now = DateTime.now();
      final isDuplicate = transactionBox.values.any((t) =>
          t.amount == transaction.amount &&
          t.isIncome == transaction.isIncome &&
          now.difference(t.date).inMinutes.abs() < 5);

      if (isDuplicate) {
        print('Duplicate transaction detected from $source, skipping...');
        return;
      }

      // Add the transaction
      transaction.source = source;
      await transactionBox.add(transaction);

      // Update balance - fixed key to currentBalance for consistency
      final currentBalance =
          balanceBox.get('currentBalance', defaultValue: 0.0) ?? 0.0;
      final newBalance = transaction.isIncome
          ? currentBalance + transaction.amount
          : currentBalance - transaction.amount;
      await balanceBox.put('currentBalance', newBalance);

      print(
          'Auto-detected transaction added: ${transaction.amount} from $source');

      // Notify UI
      NativeBridge.notifyTransactionDetected();

      // Show notification to user
      await _showTransactionNotification(transaction, source);
    } catch (e) {
      print('Error adding detected transaction: $e');
    }
  }

  static Future<void> _showTransactionNotification(
      Transaction transaction, String source) async {
    // For now, we'll just print to console
    // In a future update, we can implement a custom notification system
    print('New transaction detected from $source: ₹${transaction.amount}');
  }

  static Future<bool> isEnabled() async {
    final settingsBox = await Hive.openBox(_settingsBoxName);
    return settingsBox.get(_autoDetectionKey, defaultValue: false);
  }

  static Future<void> setEnabled(bool enabled) async {
    final settingsBox = await Hive.openBox(_settingsBoxName);
    await settingsBox.put(_autoDetectionKey, enabled);

    if (enabled) {
      await startMonitoring();
    } else {
      await stopMonitoring();
    }
  }

  static Future<void> _recordDetection({
    required String text,
    required String status,
    String? reason,
    String? packageName,
  }) async {
    try {
      final historyBox =
          await Hive.openBox<DetectionHistory>('detection_history');
      final entry = DetectionHistory(
        text: text,
        timestamp: DateTime.now(),
        status: status,
        reason: reason,
        packageName: packageName,
      );
      await historyBox.add(entry);
    } catch (e) {
      print('Error recording detection history: $e');
    }
  }

  static void _startRecheckTimer() {
    _recheckTimer?.cancel();
    // Recheck every hour
    _recheckTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      recheckSkippedTransactions();
    });
  }

  static Future<void> recheckSkippedTransactions() async {
    try {
      final historyBox =
          await Hive.openBox<DetectionHistory>('detection_history');
      final skipped =
          historyBox.values.where((e) => e.status == 'skipped').toList();

      intCount = 0;
      for (final entry in skipped) {
        final tx = _extractTransactionFromText(entry.text,
            packageName: entry.packageName);
        if (tx != null) {
          await _addDetectedTransaction(tx, 'Recheck History');

          // Update status to detected
          final index = historyBox.values.toList().indexOf(entry);
          if (index != -1) {
            final updatedEntry = DetectionHistory(
              text: entry.text,
              timestamp: entry.timestamp,
              status: 'detected',
              reason: 'Successful recheck',
              packageName: entry.packageName,
            );
            await historyBox.putAt(index, updatedEntry);
            intCount++;
          }
        }
      }
      if (intCount > 0) {
        print('Successfully re-detected $intCount transactions from history');
      }
    } catch (e) {
      print('Error rechecking skipped transactions: $e');
    }
  }

  static int intCount = 0;

  // Method to manually process recent notifications
  static Future<void> processRecentSms() async {
    try {
      // This will be handled through native bridge
      print('Processing recent notifications through native bridge');
    } catch (e) {
      print('Error processing recent notifications: $e');
    }
  }
}

// Background message handler for notifications
@pragma('vm:entry-point')
void backgroundMessageHandler(String messageBody) {
  TransactionDetectionService.processSmsMessage(messageBody);
}

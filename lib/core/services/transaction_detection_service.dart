import 'dart:async';
import 'dart:convert';
import 'package:aspends_tracker/core/models/detection_history.dart';
import 'package:aspends_tracker/core/models/transaction.dart';
import 'package:aspends_tracker/core/utils/transaction_parser.dart';
import 'package:aspends_tracker/core/repositories/transaction_repository.dart';
import 'package:aspends_tracker/core/repositories/settings_repository.dart';
import 'package:flutter/foundation.dart';

import 'native_bridge.dart';
import 'package:aspends_tracker/core/const/app_constants.dart';

class TransactionDetectionService {
  static final TransactionRepository _transactionRepo = TransactionRepository();
  static final SettingsRepository _settingsRepo = SettingsRepository();
  
  static Timer? _recheckTimer;

  static Future<void> initialize() async {
    try {
      // Check if auto-detection is enabled
      final isEnabled = await _settingsRepo.getUseAutoDetection();

      if (isEnabled) {
        await startMonitoring();
        await _processPendingNotifications();
      }

      // Load ignored patterns into parser
      final ignored = await _settingsRepo.getIgnoredPatterns();
      TransactionParser.dynamicIgnoredPatterns = List<String>.from(ignored);

      // Run auto-delete if enabled
      await deleteOldUndetectedHistory();
    } catch (e) {
      debugPrint('Error during TransactionDetectionService initialization: $e');
    }
  }

  static Future<void> updateIgnoredPatterns(List<String> patterns) async {
    TransactionParser.dynamicIgnoredPatterns = patterns;
    await _settingsRepo.setIgnoredPatterns(patterns);
  }

  static Future<void> _processPendingNotifications() async {
    final pending = await NativeBridge.getPendingNotifications();
    if (pending.isEmpty) return;

    debugPrint('Processing ${pending.length} pending items from offline queue');
    NativeBridge.notifySyncStatus(true);
    for (final entry in pending) {
      try {
        if (entry.startsWith('{')) {
          final Map<String, dynamic> data = json.decode(entry);
          final type = data['type'] as String?;
          final text = data['text'] as String? ?? '';
          final packageName = data['packageName'] as String?;
          final title = data['title'] as String? ?? '';

          if (type == 'SMS') {
            await processSmsMessage(text, sender: packageName);
          } else if (type == 'ACCESSIBILITY') {
            await processAccessibilityEvent(text, packageName: packageName);
          } else {
            await processNotification(title, text, packageName: packageName);
          }
        } else {
          final parts = entry.split('|');
          if (parts.length < 3) continue;

          if (parts[0] == 'SMS') {
            await processSmsMessage(parts[1], sender: parts[2]);
          } else if (parts[0] == 'ACCESSIBILITY' ||
              (parts.length > 2 && parts[2] == 'ACCESSIBILITY')) {
            await processAccessibilityEvent(parts[1], packageName: parts[0]);
          } else {
            await processNotification(parts[0], parts[1], packageName: parts[2]);
          }
        }
      } catch (e) {
        debugPrint('Error processing pending queue item: $e');
      }
    }
    NativeBridge.notifySyncStatus(false);
  }

  static Future<void> startMonitoring() async {
    try {
      await _startNotificationMonitoring();
      await NativeBridge.startKeepAliveService();
      _startRecheckTimer();
      recheckSkippedTransactions();
      debugPrint('Transaction detection monitoring started successfully');
    } catch (e) {
      debugPrint('Error starting transaction detection: $e');
    }
  }

  static Future<void> stopMonitoring() async {
    try {
      _recheckTimer?.cancel();
      await NativeBridge.stopKeepAliveService();
      debugPrint('Transaction detection monitoring stopped');
    } catch (e) {
      debugPrint('Error stopping transaction detection: $e');
    }
  }

  static Future<void> _startNotificationMonitoring() async {
    final hasAccess = await NativeBridge.checkNotificationPermission();
    if (!hasAccess) {
      // Handled by UI
    }
  }

  static Future<void> processNotification(String title, String body,
      {String? packageName}) async {
    if (!(await isEnabled())) return;
    
    try {
      // Skip notifications from our own app
      if (packageName == 'org.x.aspend.ns') return;

      if (packageName != null) {
        final monitoredApps = await NativeBridge.getMonitoredApps();
        if (monitoredApps.isNotEmpty && !monitoredApps.contains(packageName)) {
          return;
        }
      }

      final fullText = '$title $body';
      final parsed = TransactionParser.parse(fullText, packageName: packageName);

      if (parsed != null) {
        final tx = parsed.toTransaction();
        await _addDetectedTransaction(tx, 'Notification');
        await _recordDetection(
          text: fullText,
          status: 'detected',
          packageName: packageName,
          confidence: parsed.confidence,
        );
      } else if (parsed?.isBalanceUpdate == true) {
        await _handleBalanceUpdate(parsed!.balance!, 'Notification', packageName);
        await _recordDetection(
          text: fullText,
          status: 'detected',
          reason: 'Balance Sync',
          packageName: packageName,
          confidence: parsed.confidence,
        );
      } else {
        await _recordDetection(
          text: fullText,
          status: 'skipped',
          reason: 'Pattern not matched',
          packageName: packageName,
        );
      }
    } catch (e) {
      debugPrint('Error processing notification: $e');
    }
  }

  static Future<void> processSmsMessage(String body, {String? sender}) async {
    if (!(await isEnabled())) return;
    
    try {
      final lowerBody = body.toLowerCase();
      if (lowerBody.contains('otp') || lowerBody.contains('verification code')) return;

      final parsed = TransactionParser.parse(body, packageName: sender);
      if (parsed != null) {
        final tx = parsed.toTransaction();
        await _addDetectedTransaction(tx, 'SMS');
        await _recordDetection(
          text: body,
          status: 'detected',
          confidence: parsed.confidence,
        );
      } else if (parsed?.isBalanceUpdate == true) {
        await _handleBalanceUpdate(parsed!.balance!, 'SMS', sender);
        await _recordDetection(
          text: body,
          status: 'detected',
          reason: 'Balance Sync',
          confidence: parsed.confidence,
        );
      } else {
        await _recordDetection(
          text: body,
          status: 'skipped',
          reason: 'Pattern not matched',
        );
      }
    } catch (e) {
      debugPrint('Error processing SMS: $e');
    }
  }

  static Future<bool> _isDuplicateHash(String text) async {
    try {
      final hash = text.trim().hashCode.toString();
      final history = await _transactionRepo.getDetectionHistory();
      
      // Check if this exact text hash exists in recent history (last 100 items)
      final recent = history.length > 100 
          ? history.sublist(history.length - 100) 
          : history;
      
      return recent.any((e) => e.text.trim().hashCode.toString() == hash && 
          DateTime.now().difference(e.timestamp).inHours < 24);
    } catch (e) {
      return false;
    }
  }

  static Future<void> _handleBalanceUpdate(double balance, String source, String? packageName) async {
    try {
      final currentBal = await _transactionRepo.getCurrentBalance();
      if ((currentBal - balance).abs() < 0.01) return; // No change

      await _transactionRepo.updateBalance(balance);
      debugPrint('Auto-synced balance from $source: ₹$balance');
      NativeBridge.notifyTransactionDetected();
    } catch (e) {
      debugPrint('Error syncing balance: $e');
    }
  }

  static Future<void> processAccessibilityEvent(String text, {String? packageName}) async {
    try {
      if (packageName != null) {
        final monitoredApps = await NativeBridge.getMonitoredApps();
        if (monitoredApps.isNotEmpty && !monitoredApps.contains(packageName)) return;
      }

      final parsed = TransactionParser.parse(text, packageName: packageName);
      if (parsed != null && parsed.confidence > 0.5) {
        final tx = parsed.toTransaction();
        await _addDetectedTransaction(tx, 'Screen Activity');
        await _recordDetection(
          text: text,
          status: 'detected',
          reason: 'Screen activity',
          packageName: packageName,
          confidence: parsed.confidence,
        );
      }
    } catch (e) {
      debugPrint('Error processing accessibility event: $e');
    }
  }

  static Future<void> _addDetectedTransaction(Transaction transaction, String source) async {
    try {
      final transactions = await _transactionRepo.getAllTransactions();
      final now = DateTime.now();

      bool isDuplicate = false;
      // Check last 50 transactions or last 12 hours for duplicates
      final recentTxs = transactions.length > 50 
          ? transactions.sublist(transactions.length - 50) 
          : transactions;

      for (final t in recentTxs.reversed) {
        if (now.difference(t.date).inHours.abs() > 12) break;

        final sameAmount = (t.amount - transaction.amount).abs() < 0.01;
        final sameIncome = t.isIncome == transaction.isIncome;
        
        if (transaction.reference != null && t.reference != null && 
            transaction.reference!.isNotEmpty && t.reference == transaction.reference) {
          isDuplicate = true;
          break;
        }

        final timeDiff = now.difference(t.date).inMinutes.abs();
        final sameMerchant = t.note.toLowerCase() == transaction.note.toLowerCase();

        if (sameAmount && sameIncome && sameMerchant && timeDiff < 10) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate || await _isDuplicateHash(transaction.originalText ?? '')) {
        debugPrint('Duplicate transaction detected from $source, skipping...');
        return;
      }

      transaction.source = source;
      await _transactionRepo.addTransaction(transaction);

      final currentBal = await _transactionRepo.getCurrentBalance();
      final newBal = transaction.isIncome ? currentBal + transaction.amount : currentBal - transaction.amount;
      await _transactionRepo.updateBalance(newBal);

      debugPrint('Auto-detected transaction added: ₹${transaction.amount} from $source');
      NativeBridge.notifyTransactionDetected();
      await _showTransactionNotification(transaction, source);
    } catch (e) {
      debugPrint('Error adding detected transaction: $e');
    }
  }

  static Future<void> _showTransactionNotification(Transaction transaction, String source) async {
    // Platform specific notification implementation could go here
    debugPrint('New transaction: ₹${transaction.amount} via $source');
  }

  static Future<bool> isEnabled() async {
    return _settingsRepo.getUseAutoDetection();
  }

  static Future<void> setEnabled(bool enabled) async {
    await _settingsRepo.setUseAutoDetection(enabled);
    if (enabled) {
      await _autoSelectPaymentApps();
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
    double? confidence,
  }) async {
    try {
      final entry = DetectionHistory(
        text: text,
        timestamp: DateTime.now(),
        status: status,
        reason: reason,
        packageName: packageName,
        confidence: confidence,
      );
      await _transactionRepo.addDetectionHistory(entry);
    } catch (e) {
      debugPrint('Error recording detection history: $e');
    }
  }

  static void _startRecheckTimer() {
    _recheckTimer?.cancel();
    _recheckTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      recheckSkippedTransactions();
      deleteOldUndetectedHistory();
    });
  }

  static Future<void> recheckSkippedTransactions() async {
    try {
      NativeBridge.notifySyncStatus(true);
      final history = await _transactionRepo.getDetectionHistory();
      final now = DateTime.now();
      int count = 0;

      // Create a mutable list to allow updates
      final List<DetectionHistory> updatedHistory = [];
      for (var entry in history) {
        if (entry.status == 'skipped' && now.difference(entry.timestamp).inHours < 24) {
          final parsed = TransactionParser.parse(entry.text, packageName: entry.packageName);
          if (parsed != null) {
            await _addDetectedTransaction(parsed.toTransaction(), 'Recheck History');
            // Update status to detected
            updatedHistory.add(DetectionHistory(
              text: entry.text,
              timestamp: entry.timestamp,
              status: 'detected',
              reason: 'Successful recheck',
              packageName: entry.packageName,
              confidence: parsed.confidence,
            ));
            count++;
          } else {
            updatedHistory.add(entry); // Keep unchanged if not re-detected
          }
        } else {
          updatedHistory.add(entry); // Keep unchanged if not skipped or too old
        }
      }
      // Save the updated history back
      if (count > 0) {
        await _transactionRepo.updateDetectionHistory(updatedHistory);
        debugPrint('Successfully re-detected $count transactions from history');
      }
      NativeBridge.notifySyncStatus(false);
    } catch (e) {
      NativeBridge.notifySyncStatus(false);
      debugPrint('Error rechecking transactions: $e');
    }
  }

  static Future<void> deleteOldUndetectedHistory() async {
    try {
      if (!(await _settingsRepo.getAutoDeleteUndetected())) return;
      await _transactionRepo.clearOldDetectionHistory(const Duration(hours: 2));
    } catch (e) {
      debugPrint('Error clearing old history: $e');
    }
  }

  // Method to manually process recent notifications
  static Future<void> processRecentSms() async {
    try {
      // This will be handled through native bridge
      debugPrint('Processing recent notifications through native bridge');
    } catch (e) {
      debugPrint('Error processing recent notifications: $e');
    }
  }

  static Future<void> _autoSelectPaymentApps() async {
    try {
      if (!(await _settingsRepo.isFirstTimeAutoSelection())) return;

      debugPrint('First time auto-detection enabled, auto-selecting payment apps...');

      final installedApps = await NativeBridge.getInstalledApps();
      final currentMonitored = await NativeBridge.getMonitoredApps();
      final List<String> toMonitor = List<String>.from(currentMonitored);
      bool changed = false;

      const monitoredPackages = AppConstants.defaultMonitoredPackages;

      for (final app in installedApps) {
        final pkg = app['packageName'];
        if (pkg != null && monitoredPackages.contains(pkg) && !toMonitor.contains(pkg)) {
          toMonitor.add(pkg);
          changed = true;
          debugPrint('Auto-selected $pkg for monitoring');
        }
      }

      if (changed) await NativeBridge.saveMonitoredApps(toMonitor);
      await _settingsRepo.setFirstTimeAutoSelection(false);
    } catch (e) {
      debugPrint('Error auto-selecting apps: $e');
    }
  }
}

@pragma('vm:entry-point')
void backgroundMessageHandler(String messageBody) {
  TransactionDetectionService.processSmsMessage(messageBody);
}

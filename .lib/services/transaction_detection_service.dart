import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/transaction.dart';
import 'native_bridge.dart';

class TransactionDetectionService {
  static const String _settingsBoxName = 'settings';
  static const String _autoDetectionKey = 'autoDetectionEnabled';

  // Transaction patterns for different banks and services
  static final List<RegExp> _transactionPatterns = [
    // Pattern for "Rs. 100 credited/debited"
    RegExp(
        r'(?:Rs\.?|INR|₹)\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)\s*(?:credited|debited|paid|sent|received|spent|withdrawal|withdrawn)',
        caseSensitive: false),
    // Pattern for "credited/debited ... Rs. 100"
    RegExp(
        r'(?:credited|debited|paid|sent|received|spent|withdrawal|withdrawn).*?(?:Rs\.?|INR|₹)\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
        caseSensitive: false),
    // Pattern for UPI transactions
    RegExp(
        r'spent\s*(?:Rs\.?|INR|₹)\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)\s*on\s*UPI',
        caseSensitive: false),
    // Simple amount pattern as fallback
    RegExp(r'(?:Rs\.?|INR|₹)\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
        caseSensitive: false),
  ];

  // Bank keywords for categorization
  static final Map<String, String> _bankKeywords = {
    'hdfc': 'HDFC Bank',
    'sbi': 'State Bank of India',
    'icici': 'ICICI Bank',
    'axis': 'Axis Bank',
    'kotak': 'Kotak Bank',
    'yes': 'Yes Bank',
    'paytm': 'Paytm',
    'phonepe': 'PhonePe',
    'googlepay': 'Google Pay',
    'gpay': 'Google Pay',
    'amazonpay': 'Amazon Pay',
    'bhim': 'BHIM UPI',
    'pnb': 'Punjab National Bank',
    'bob': 'Bank of Baroda',
    'canara': 'Canara Bank',
    'idbi': 'IDBI Bank',
    'indusind': 'IndusInd Bank',
    'federal': 'Federal Bank',
    'rbl': 'RBL Bank',
    'hsbc': 'HSBC Bank',
    'citi': 'Citi Bank',
    'standard chartered': 'Standard Chartered',
    'cred': 'CRED',
    'zomato': 'Zomato',
    'swiggy': 'Swiggy',
    'uber': 'Uber',
    'ola': 'Ola',
    'amazon': 'Amazon',
    'flipkart': 'Flipkart',
    'slice': 'Slice',
    'uni': 'Uni Card',
    'onecard': 'OneCard',
    'mobikwik': 'MobiKwik',
    'freecharge': 'Freecharge',
    'jio': 'JioPay',
    'airtel': 'Airtel Payments Bank',
  };

  static Future<void> initialize() async {
    // Check if auto-detection is enabled
    final settingsBox = await Hive.openBox(_settingsBoxName);
    final isEnabled = settingsBox.get(_autoDetectionKey, defaultValue: false);

    if (isEnabled) {
      await startMonitoring();
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

      print('Transaction detection monitoring started successfully');
    } catch (e) {
      print('Error starting transaction detection: $e');
    }
  }

  static Future<void> stopMonitoring() async {
    try {
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
    try {
      // Skip notifications from our own app
      if (packageName == 'org.x.aspend.ns') return;

      final fullText = '$title $body';
      final detectedTransaction = _extractTransactionFromText(fullText);
      if (detectedTransaction != null) {
        await _addDetectedTransaction(detectedTransaction, 'Notification');
      }
    } catch (e) {
      print('Error processing notification: $e');
    }
  }

  static Future<void> processSmsMessage(String body) async {
    try {
      // Ignore OTP messages
      final lowerBody = body.toLowerCase();
      if (lowerBody.contains('otp') ||
          lowerBody.contains('verification code')) {
        return;
      }

      final detectedTransaction = _extractTransactionFromText(body);
      if (detectedTransaction != null) {
        await _addDetectedTransaction(detectedTransaction, 'SMS');
      }
    } catch (e) {
      print('Error processing SMS message: $e');
    }
  }

  static Transaction? _extractTransactionFromText(String text) {
    try {
      final lowerText = text.toLowerCase();

      // Look for amount
      for (final pattern in _transactionPatterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          final amountStr = match.group(1)?.replaceAll(',', '');
          if (amountStr != null) {
            final amount = double.tryParse(amountStr);
            if (amount != null && amount > 0) {
              // Determine if it's income or expense based on keywords
              bool isIncome = lowerText.contains('credited') ||
                  lowerText.contains('received') ||
                  lowerText.contains('depository') ||
                  lowerText.contains('refund');

              // If it contains both 'debited' and 'credited', we need to be careful
              // Usually the last one is the actual action or we look for "to" or "from"
              if (lowerText.contains('debited') ||
                  lowerText.contains('paid') ||
                  lowerText.contains('sent') ||
                  lowerText.contains('spent')) {
                isIncome = false;
              }

              // Extract category
              String category = 'Bank Transaction';
              for (final entry in _bankKeywords.entries) {
                if (lowerText.contains(entry.key)) {
                  category = entry.value;
                  break;
                }
              }

              // Extract account info
              String account = 'Auto Detected';
              if (lowerText.contains('upi')) {
                account = 'UPI';
              } else if (lowerText.contains('atm')) {
                account = 'ATM';
              } else if (lowerText.contains('card')) {
                account = 'Card';
              } else if (lowerText.contains('bank')) {
                account = 'Bank';
              }

              return Transaction(
                amount: amount,
                note: 'Auto-detected: ${isIncome ? "In" : "Out"}',
                category: category,
                account: account,
                date: DateTime.now(),
                isIncome: isIncome,
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting transaction from text: $e');
    }
    return null;
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

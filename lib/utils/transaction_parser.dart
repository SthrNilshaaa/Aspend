import '../models/transaction.dart';

class ParsedTransaction {
  final double amount;
  final bool isIncome;
  final String? bank;
  final String? account;
  final String? category;
  final String? merchant;
  final String? reference;
  final double? balance;
  final DateTime? date;
  final String? rawText;

  ParsedTransaction({
    required this.amount,
    required this.isIncome,
    this.bank,
    this.account,
    this.category,
    this.merchant,
    this.reference,
    this.balance,
    this.date,
    this.rawText,
  });

  Transaction toTransaction() {
    String note = '';
    if (merchant != null) {
      note = merchant!;
    } else {
      note = isIncome ? 'Received' : 'Paid';
    }

    if (reference != null) {
      note += ' (Ref: $reference)';
    }

    return Transaction(
      amount: amount,
      note: note,
      category: category ?? bank ?? 'Auto Detected',
      account: account ?? (bank ?? 'Auto Detected'),
      date: date ?? DateTime.now(),
      isIncome: isIncome,
      bankName: bank,
      reference: reference,
      balanceAfter: balance,
      originalText: rawText,
    );
  }
}

class TransactionParser {
  static final List<RegExp> _amountPatterns = [
    // Handle ₹, Rs., INR, Rs
    RegExp(r'(?:Rs\.?|INR|₹|\$)\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
        caseSensitive: false),
    // Handle cases where amount comes after "of" or "for"
    RegExp(r'(?:of|for)\s*(?:Rs\.?|INR|₹|\$)\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
        caseSensitive: false),
  ];

  static final List<String> _incomeKeywords = [
    'credited',
    'received',
    'added',
    'refund',
    'cashback',
    'deposited',
    'dividend',
    'salary',
    'cr to',
    'credited to',
    'received from',
  ];

  static final List<String> _expenseKeywords = [
    'debited',
    'paid',
    'sent',
    'spent',
    'withdrawal',
    'withdrawn',
    'transferred to',
    'txn of',
    'dr from',
    'debited from',
    'payment to',
  ];

  static final Map<String, String> _bankLogos = {
    'icici': 'ICICI Bank',
    'hdfc': 'HDFC Bank',
    'sbi': 'SBI',
    'axis': 'Axis Bank',
    'kotak': 'Kotak Bank',
    'paytm': 'Paytm',
    'phonepe': 'PhonePe',
    'gpay': 'Google Pay',
    'google pay': 'Google Pay',
    'amazon': 'Amazon Pay',
    'zomato': 'Zomato',
    'swiggy': 'Swiggy',
    'airtel': 'Airtel',
    'jio': 'JioPay',
    'ybl': 'PhonePe',
    'oksbi': 'Google Pay',
    'okaxis': 'Google Pay',
    'okhdfcbank': 'Google Pay',
    'okicici': 'Google Pay',
    'whatsapp': 'WhatsApp Pay',
    'bharatpe': 'BharatPe',
    'bhim': 'BHIM UPI',
    'cred': 'CRED',
    'slice': 'Slice',
    'uni': 'Uni Card',
    'onecard': 'OneCard',
    'mobikwik': 'MobiKwik',
    'freecharge': 'Freecharge',
    'netflix': 'Netflix',
    'spotify': 'Spotify',
    'youtube': 'YouTube',
    'uber': 'Uber',
    'ola': 'Ola',
    'flipkart': 'Flipkart',
    'zerodha': 'Zerodha',
    'upstox': 'Upstox',
    'wazirx': 'WazirX',
    'binance': 'Binance',
    'lic': 'LIC',
    'bajaj': 'Bajaj Finserv',
    'irctc': 'IRCTC',
    'makemytrip': 'MakeMyTrip',
    'com.phonepe.app': 'PhonePe',
    'net.one97.paytm': 'Paytm',
    'com.google.android.apps.nbu.paisa.user': 'Google Pay',
    'com.citibank.mobile.india': 'Citibank',
    'com.hdfcbank.smartbuy': 'HDFC Bank',
    'com.msf.kbank.mobile': 'Kotak Bank',
    'com.axis.mobile': 'Axis Bank',
    'in.amazon.mShop.android.shopping': 'Amazon Pay',
  };

  static final Map<String, List<String>> _categoryKeywords = {
    'Food': [
      'zomato',
      'swiggy',
      'restaurant',
      'kfcl',
      'dominos',
      'eat',
      'food'
    ],
    'Transport': [
      'uber',
      'ola',
      'metro',
      'irctc',
      'flight',
      'bus',
      'fuel',
      'petrol',
      'shell',
      'hpcl',
      'bpcl'
    ],
    'Shopping': [
      'amazon',
      'flipkart',
      'myntra',
      'ajio',
      'nykaa',
      'meesho',
      'blinkit',
      'zepto',
      'bigbasket',
      'grocery',
      'mart',
      'kirana'
    ],
    'Bills': [
      'airtel',
      'jio',
      'vi ',
      'electricity',
      'bescom',
      'water',
      'gas',
      'recharge',
      'broadband',
      'bses'
    ],
    'Entertainment': [
      'netflix',
      'spotify',
      'youtube',
      'prime',
      'hotstar',
      'bookmyshow',
      'pvr',
      'inox',
      'movie'
    ],
    'Investment': [
      'zerodha',
      'upstox',
      'groww',
      'mutual fund',
      'sip',
      'stock',
      'dividend',
      'wazirx',
      'binance',
      'crypto'
    ],
    'Health': [
      'apollo',
      'pharmeasy',
      'medplus',
      'hospital',
      'clinic',
      'dentist',
      'pharmacy'
    ],
    'Travel': ['makemytrip', 'agoda', 'goibibo', 'hotel', 'stay'],
    'Salary': ['salary', 'wages', 'stipend'],
    'Education': ['school', 'college', 'course', 'udemy', 'coursera', 'fee'],
    'Loan': ['emi', 'loan', 'bajaj', 'finserv', 'interest'],
    'Tax': ['gst', 'income tax', 'challan', 'tds'],
  };

  static ParsedTransaction? parse(String text, {String? packageName}) {
    if (text.isEmpty) return null;

    final lowerText = text.toLowerCase();

    // Add package name to text for bank detection if available
    String searchContext = lowerText;
    if (packageName != null) {
      searchContext += ' ${packageName.toLowerCase()}';
    }

    // Check if it's a notification about a transaction or just noise
    if (!_isTransactionRelated(searchContext)) return null;

    // 1. Extract Amount
    double? amount;
    for (final pattern in _amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1)?.replaceAll(',', '');
        if (amountStr != null) {
          amount = double.tryParse(amountStr);
          if (amount != null && amount > 0) break;
        }
      }
    }

    if (amount == null) return null;

    // 2. Determine Transaction Type (Income/Expense)
    bool isIncome = false;

    // Check for explicit keywords
    int incomeIndex = -1;
    for (final kw in _incomeKeywords) {
      final index = lowerText.indexOf(kw);
      if (index != -1) {
        incomeIndex = index;
        isIncome = true;
        break;
      }
    }

    for (final kw in _expenseKeywords) {
      final index = lowerText.indexOf(kw);
      if (index != -1) {
        if (incomeIndex == -1 || index < incomeIndex) {
          isIncome = false;
        }
        break;
      }
    }

    // Special case for GPay: "₹500 sent to..." is expense
    if (lowerText.contains('sent to')) isIncome = false;
    if (lowerText.contains('received from')) isIncome = true;

    // 3. Extract Bank/App
    String? bank;
    for (final entry in _bankLogos.entries) {
      if (searchContext.contains(entry.key)) {
        bank = entry.value;
        break;
      }
    }

    // 4. Extract Category
    String category = 'Bank Transaction';
    if (bank != null) {
      category = bank;
    }

    for (final entry in _categoryKeywords.entries) {
      for (final kw in entry.value) {
        if (lowerText.contains(kw)) {
          category = entry.key;
          break;
        }
      }
    }

    // 5. Extract Account (last 4 digits)
    String? account;
    final accountMatch =
        RegExp(r'a/c\s*(?:xx|x+)?(\d{4})', caseSensitive: false)
                .firstMatch(text) ??
            RegExp(r'acct\s*(?:xx|x+)?(\d{4})', caseSensitive: false)
                .firstMatch(text);

    if (accountMatch != null) {
      account = 'A/c XX${accountMatch.group(1)}';
    } else if (lowerText.contains('upi')) {
      account = 'UPI';
    } else if (lowerText.contains('wallet')) {
      account = 'Wallet';
    }

    // 5. Extract Merchant/Recipient/Sender
    String? merchant;
    // Look for patterns like "paid to X", "sent to X", "received from X", "at X", "to X"
    final merchantMatch = RegExp(
            r'(?:to|from|at|towards)\s+([a-zA-Z0-9\.\s]+?)(?:\.|\s+via|\s+using|\s+on|\s+ref|\s+successful|\s+completed|\s+of|$)',
            caseSensitive: false)
        .firstMatch(text);
    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)?.trim();
      // Remove common noises from merchant name
      merchant = merchant
          ?.replaceAll(RegExp(r'\d{10}'), '')
          .trim(); // Remove phone numbers
      if (merchant?.isEmpty ?? true) merchant = null;
    }

    // Fallback for simple "Payment to Merchant"
    if (merchant == null) {
      final simpleMerchant = RegExp(
              r'to\s+([a-zA-Z0-9\s]+?)\s+(?:successful|completed)',
              caseSensitive: false)
          .firstMatch(text);
      if (simpleMerchant != null) {
        merchant = simpleMerchant.group(1)?.trim();
      }
    }

    // 6. Extract Reference
    String? reference;
    final refMatch = RegExp(r'(?:ref|txn|id|pnr|upi ref)[:\s]+([a-z0-9]+)',
            caseSensitive: false)
        .firstMatch(text);
    if (refMatch != null) {
      reference = refMatch.group(1);
    }

    // 7. Extract Balance
    double? balance;
    final balMatch = RegExp(
            r'(?:bal|balance|avl bal)\s*(?:Rs\.?|INR|₹|\$)?\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
            caseSensitive: false)
        .firstMatch(text);
    if (balMatch != null) {
      final balStr = balMatch.group(1)?.replaceAll(',', '');
      if (balStr != null) {
        balance = double.tryParse(balStr);
      }
    }

    return ParsedTransaction(
      amount: amount,
      isIncome: isIncome,
      bank: bank,
      account: account,
      category: category,
      merchant: merchant,
      reference: reference,
      balance: balance,
      rawText: text,
    );
  }

  static bool _isTransactionRelated(String text) {
    // Exclude OTPs, failed transactions, and pending requests
    if (text.contains('otp') ||
        text.contains('verification code') ||
        text.contains('failed') ||
        text.contains('declined') ||
        text.contains('unsuccessful') ||
        text.contains('request') ||
        text.contains('due') ||
        text.contains('expire') ||
        text.contains('limit exceeded') ||
        text.contains('data consumed') ||
        text.contains('speed data') ||
        text.contains('data balance') ||
        text.contains('usage alert')) {
      return false;
    }

    final keywords = [
      'credited',
      'debited',
      'paid',
      'sent',
      'received',
      'spent',
      'withdrawal',
      'withdrawn',
      'transfer',
      'txn',
      'transaction',
      'successful',
      'failed',
      'added',
      'wallet',
      'a/c',
      'acct',
      'upi',
      'refund',
      'cashback',
      'bill',
      'recharge'
    ];

    for (final kw in keywords) {
      if (text.contains(kw)) return true;
    }

    return false;
  }
}

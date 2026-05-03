import 'package:aspends_tracker/core/models/transaction.dart';

class ParsedTransaction {
  final double amount;
  final bool isIncome, isBalanceUpdate;
  final String? bank, account, category, merchant, reference, rawText;
  final double? balance;
  final DateTime? date;
  final double confidence;

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
    this.confidence = 0.0,
    this.isBalanceUpdate = false,
  });

  Transaction toTransaction() => Transaction(
        amount: amount,
        note: merchant ?? (isIncome ? 'Received' : 'Paid'),
        category: category ?? bank ?? 'Auto Detected',
        account: account ?? bank ?? 'Auto Detected',
        date: date ?? DateTime.now(),
        isIncome: isIncome,
        bankName: bank,
        reference: reference,
        balanceAfter: balance,
        originalText: rawText,
      );
}

class TransactionParser {
  // Regex bits
  static const _cur = r'(?:Rs\.?|INR|₹|\$|Amt|Amount)';
  static const _num = r'(\d+(?:,\d{3})*(?:\.\d{1,2})?)';

  static final _amtPatterns = [
    RegExp('$_cur\\s*$_num', caseSensitive: false),
    RegExp('$_num\\s*$_cur', caseSensitive: false),
    RegExp(
        r'(?:debited|credited|spent|paid|received|added|payment of)\s+(?:of|for|worth)?\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
        caseSensitive: false),
  ];

  // Pre-compiled global Regexes for extremely fast lookup
  static final _accPattern = RegExp(
      r'(?:a/c|acct|acc|account|card|vpa|ending|xx|x{1,}|[\*]{1,}|crd)\s*[x\*\-]*(\d{3,6})',
      caseSensitive: false);
  static final _balPattern = RegExp(
      r'(?:bal|balance|avl bal|available balance|bal is|balance|avl\.bal|available\.bal)[\s\w\/\.\:]*?'
      r'(?:rs\.?|inr|₹|\$|amt|amount)[\s]*' +
      _num,
      caseSensitive: false);
  static final _refPattern = RegExp(
      r'(?:ref|txn|id|pnr|upi ref|rrn|reference|ref\.no|utr)[:\s\#\-]+([a-z0-9]+)',
      caseSensitive: false);
  static final _datePattern = RegExp(
      r'(\d{1,2})[-/](0[1-9]|1[0-2]|[A-Z]{3})[-/](\d{2,4})',
      caseSensitive: false);
  static final _amountMarkerPattern = RegExp(r'rs|inr|₹|\$|amt|amount');
  static final _upiPattern = RegExp(
      r'(?:vpa|upi|to)\s*([a-zA-Z0-9\.\-_]+@[a-zA-Z0-9]+)',
      caseSensitive: false);
  static final _merchantInfoPattern = RegExp(
      r'(?:info|details|towards|narration|remarks)[:\s\-]+([^.\n,]{3,})',
      caseSensitive: false);
  static final _cleanupDatePattern1 =
      RegExp(r'\d{1,2}[-/][A-Z]{3}[-/]\d{2,4}', caseSensitive: false);
  static final _cleanupDatePattern2 = RegExp(r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}');

  static const _incomeKW = [
    'credited',
    'received',
    'added',
    'refund',
    'cashback',
    'deposited',
    'dividend',
    'salary',
    'cr to',
    'money received',
    'monies credited',
    'cash added',
    'topup of',
  ];

  static const _expenseKW = [
    'debited',
    'spent',
    'paid',
    'sent',
    'withdrawal',
    'withdrawn',
    'dr from',
    'payment to',
    'transfer to',
    'payment of',
    'purchase at',
    'online txn',
    'dr a/c',
    'monies debited',
    'charge of',
    'bill payment',
  ];

  static const _promoKeywords = [
    'offer',
    'cashback',
    'reward',
    'get up to',
    'win',
    'voucher',
    'discount',
    'coupon',
    'apply now',
    'limited period',
    'first spend',
    'shopping offer',
    'earn',
    'instant cashback',
    'guaranteed cashback',
    'unlocked',
    'special reward',
    'joining fee',
    'annual fee',
    'loot offer',
    'quick funds',
    'processing fee',
    'valid: today',
    'prizes',
    'gift card',
    'bonus',
    'lifetime free',
    'no cibil',
    'best for online shoppers',
    'submit details',
    'video kyc',
    'waived on',
    'price dropped',
    'order anything',
    'dealztrendz',
    'dealbee',
  ];

  static List<String> dynamicIgnoredPatterns = [];

  static const _hardMarkers = [
    'ref',
    'txn',
    'txn id',
    'id',
    'reference',
    'rrn',
    'upi ref',
    'pnr',
    'a/c',
    'ending',
    'debited',
    'credited',
    'cr to',
    'dr from',
    'xx',
    'vpa',
    'card ending',
    'acc ending',
    'paid to',
    'sent to',
    'received from',
    'successfully',
    'completed',
    'transfer',
    'txn id',
    'monies',
    'available bal',
    'alert',
    'spent ₹',
    'paid ₹',
    'received ₹',
    'credited ₹',
  ];

  static const _bankMap = {
    'icici': 'ICICI Bank',
    'hdfc': 'HDFC Bank',
    'sbi': 'SBI',
    'axis': 'Axis Bank',
    'kotak': 'Kotak Bank',
    'paytm': 'Paytm',
    'phonepe': 'PhonePe',
    'gpay': 'Google Pay',
    'amazon': 'Amazon Pay',
    'airtel': 'Airtel Payments Bank',
    'canara': 'Canara Bank',
    'bob': 'Bank of Baroda',
    'pnb': 'PNB',
    'federal': 'Federal Bank',
    'idfc': 'IDFC First',
  };

  static const _catKW = {
    'Food': [
      'zomato',
      'swiggy',
      'restaurant',
      'kfcl',
      'dominos',
      'eat',
      'pizza',
      'burger',
      'bakery',
      'starbucks',
      'cafe'
    ],
    'Transport': [
      'uber',
      'ola',
      'metro',
      'irctc',
      'fuel',
      'petrol',
      'shell',
      'hpcl',
      'bpcl',
      'fastag'
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
      'market'
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
      'broadband'
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
      'movie',
      'gaming',
      'nintendo',
      'playstation'
    ],
    'Investment': [
      'zerodha',
      'upstox',
      'groww',
      'mutual fund',
      'sip',
      'stock',
      'crypto'
    ],
    'Health': [
      'apollo',
      'pharmeasy',
      'medplus',
      'hospital',
      'clinic',
      'pharmacy',
      'practo',
      'doctor',
      'wellness'
    ],
    'Travel': [
      'makemytrip',
      'mmt',
      'goibibo',
      'booking.com',
      'agoda',
      'hotel',
      'stay',
      'indigo',
      'air india',
      'travel',
      'trip'
    ],
    'Education': [
      'college',
      'school',
      'university',
      'fees',
      'udemy',
      'coursera',
      'education',
      'learning'
    ],
    'Insurance': ['lic', 'insurance', 'policy', 'premium'],
  };

  static final _balOnlyKW = [
    'available balance',
    'avl bal',
    'bal is',
    'balance in your a/c',
    'current balance',
    'outstanding balance',
  ];

  static ParsedTransaction? parse(String text, {String? packageName}) {
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();

    // 1. Transaction Validity Filter (Early exits for speed)
    if (_isPromotional(lower)) return null;
    if (lower.contains('otp') || lower.contains('verification code')) {
      return null;
    }
    if (lower.contains('declined') || lower.contains('failed')) return null;
    if (!_amountMarkerPattern.hasMatch(lower)) return null;

    // 2. Determine if it's a balance update only or a transaction
    final bool hasStrongAction = (lower.contains('debited') ||
        lower.contains('credited') ||
        lower.contains('received') ||
        lower.contains('paid') ||
        lower.contains('payment successful') ||
        lower.contains('spent'));
    
    final bool isBalOnlyMatch = _balOnlyKW.any((kw) => lower.contains(kw));

    if (!hasStrongAction && !isBalOnlyMatch) return null;

    // 3. Amount Extraction (Prioritized, Mandatory)
    final amounts = _extractAllAmounts(text);
    if (amounts.isEmpty) return null;

    // 4. Direction & Priority Keywords
    bool isIncome = _incomeKW.any((kw) => lower.contains(kw));
    if (_expenseKW.any((kw) => lower.contains(kw))) isIncome = false;
    if (lower.contains('received from') || lower.contains('credited by')) {
      isIncome = true;
    }
    if (lower.contains('sent to') || lower.contains('paid to')) {
      isIncome = false;
    }

    // Pick the best amount based on proximity to action keywords
    final double amount = _prioritizeAmount(text, amounts, isIncome);
    if (amount <= 0 && !isBalOnlyMatch) return null;

    // Extract balance if possible
    double? balance;
    final balMatch = _balPattern.firstMatch(text);
    if (balMatch != null) {
      balance = double.tryParse(balMatch.group(1)!.replaceAll(',', ''));
    }

    // If it's a balance only update (no transaction action)
    if (balance != null && !hasStrongAction && isBalOnlyMatch) {
      return ParsedTransaction(
        amount: 0,
        isIncome: false,
        balance: balance,
        rawText: text,
        isBalanceUpdate: true,
        confidence: 0.9, // High confidence for explicit balance messages
      );
    }

    if (!_isLikelyTransaction(lower)) return null;

    // 3. Marker Validation (Relaxed, but enforced strictly for empty senders)
    final bool hasHardMarker = _hardMarkers.any((m) => lower.contains(m));

    // If it has a package/sender, we prefer a marker or strong action
    if (packageName != null) {
      if (!hasHardMarker && !hasStrongAction) return null;
    } else {
      // For general text, we strictly require a hard marker to avoid false positives AND a strong action
      if (!hasHardMarker || !hasStrongAction) return null;
    }

    // 4. Account Number (3-6 digits)
    String? account;
    final accMatch = _accPattern.firstMatch(text);

    if (accMatch != null) {
      final val = accMatch.group(1)!;
      final isYear =
          val.length == 4 && (val.startsWith('20') || val.startsWith('19'));
      final isLikelyAmount =
          amounts.any((a) => a.value.toString().contains(val));
      final hasStrictMarker = lower.contains('ending') ||
          lower.contains('acct') ||
          lower.contains('account') ||
          lower.contains('card');

      if ((!isYear && !isLikelyAmount) || hasStrictMarker) {
        account = 'XX$val';
      }
    }

    // 5. Account/Balance Conflict Resolution
    if (account != null && balance != null) {
      final balValRaw = balance.toInt().toString();
      if (balValRaw.endsWith(account.replaceFirst('XX', ''))) {
        final accIdx =
            lower.indexOf(account.replaceFirst('XX', '').toLowerCase());
        final balIdx = lower.indexOf('bal');
        if (balIdx != -1 && accIdx != -1 && (accIdx - balIdx).abs() < 12) {
          account = null;
        }
      }
    }

    // 6. Bank/Provider
    String? bank;
    if (packageName != null) {
      final pkgLower = packageName.toLowerCase();
      _bankMap.forEach((k, v) {
        if (pkgLower.contains(k)) bank = v;
      });
    }
    if (bank == null) {
      for (final e in _bankMap.entries) {
        if (lower.contains(e.key)) {
          bank = e.value;
          break;
        }
      }
    }

    // 7. Merchant / Entity
    String? merchant = _extractMerchant(text, isIncome);

    // 8. Category
    String? category;
    _catKW.forEach((k, keywords) {
      if (keywords.any((kw) => lower.contains(kw))) category = k;
    });
    if (category == null && merchant != null) {
      _catKW.forEach((k, keywords) {
        if (keywords.any((kw) => merchant.toLowerCase().contains(kw))) {
          category = k;
        }
      });
    }

    // 9. Reference
    String? reference;
    final refMatch = _refPattern.firstMatch(text);
    if (refMatch != null) reference = refMatch.group(1);

    // 10. Date
    DateTime? date = _extractDate(text);

    return ParsedTransaction(
      amount: amount,
      isIncome: isIncome,
      bank: bank,
      account: account,
      category: category,
      merchant: merchant,
      reference: reference,
      balance: balance,
      date: date,
      rawText: text,
      confidence: _calculateConfidence(account, bank, merchant, reference),
    );
  }

  static List<_MatchRange> _extractAllAmounts(String text) {
    final matches = <_MatchRange>[];
    for (final p in _amtPatterns) {
      final allMatches = p.allMatches(text);
      for (final m in allMatches) {
        final val = double.tryParse(m.group(1)!.replaceAll(',', ''));
        if (val != null && val > 0) {
          matches.add(_MatchRange(val, m.start, m.end));
        }
      }
    }
    // Remove duplicates/overlapping
    matches.sort((a, b) => a.start.compareTo(b.start));
    return matches;
  }

  static double _prioritizeAmount(
      String text, List<_MatchRange> amounts, bool isIncome) {
    if (amounts.length == 1) return amounts.first.value;

    final lower = text.toLowerCase();
    final actionKeywords = isIncome ? _incomeKW : _expenseKW;

    double bestScore = -1.0;
    double bestValue = amounts.first.value;

    for (final amt in amounts) {
      double score = 0.0;
      // Distance to action keywords
      for (final kw in actionKeywords) {
        final idx = lower.indexOf(kw);
        if (idx != -1) {
          final dist = (amt.start - idx).abs();
          score += 1000 / (dist + 1);
        }
      }

      // Bonus if it's NOT following "Balance"
      final balIdx = lower.lastIndexOf('bal', amt.start);
      if (balIdx != -1 && (amt.start - balIdx) < 15) {
        score -= 500;
      }

      if (score > bestScore) {
        bestScore = score;
        bestValue = amt.value;
      }
    }
    return bestValue;
  }

  static DateTime? _extractDate(String text) {
    // DD-MM-YY or DD/MM/YYYY etc
    final dateMatch = _datePattern.firstMatch(text);
    if (dateMatch != null) {
      try {
        final day = int.parse(dateMatch.group(1)!);
        final monthStr = dateMatch.group(2)!;
        final yearStr = dateMatch.group(3)!;

        int month;
        if (int.tryParse(monthStr) != null) {
          month = int.parse(monthStr);
        } else {
          final months = [
            'JAN',
            'FEB',
            'MAR',
            'APR',
            'MAY',
            'JUN',
            'JUL',
            'AUG',
            'SEP',
            'OCT',
            'NOV',
            'DEC'
          ];
          month = months.indexOf(monthStr.toUpperCase()) + 1;
        }

        int year = int.parse(yearStr);
        if (year < 100) year += 2000;

        if (month > 0 && month <= 12 && day > 0 && day <= 31) {
          return DateTime(year, month, day);
        }
      } catch (e) {/* Ignore */}
    }
    return null;
  }

  static double _calculateConfidence(
      String? acc, String? bank, String? merc, String? ref) {
    // Much stricter confidence requirements
    double score = 0.3; // Base score for having an amount and action keyword
    if (acc != null) score += 0.2; // Account is a strong signal
    if (bank != null) score += 0.2; // Bank name is a strong signal
    if (merc != null && merc != 'Paid' && merc != 'Received') score += 0.2;
    if (ref != null && ref.length > 5) score += 0.1; // Valid ref number

    // Penalize if it missing fundamental context
    if (bank == null && acc == null) score -= 0.3;

    return score.clamp(0.0, 1.0);
  }

  static bool _isLikelyTransaction(String lower) {
    if (lower.contains('otp') || lower.contains('verification code')) {
      return false;
    }
    if (lower.contains('declined') || lower.contains('failed')) return false;

    final hasAmountMarker = _amountMarkerPattern.hasMatch(lower);
    if (!hasAmountMarker) return false;
    return _incomeKW.any((kw) => lower.contains(kw)) ||
        _expenseKW.any((kw) => lower.contains(kw)) ||
        lower.contains('available balance') ||
        lower.contains('payment successful') ||
        lower.contains('successfully sent');
  }

  static bool _isPromotional(String lower) {
    // Avoid marking "Cashback Received" as promotional if it's a real transaction
    if (lower.contains('received') || lower.contains('credited')) {
      if (lower.contains('bank') ||
          lower.contains('a/c') ||
          lower.contains('acct')) {
        return false;
      }
    }

    if (dynamicIgnoredPatterns.any((kw) => lower.contains(kw.toLowerCase()))) {
      return true;
    }

    return _promoKeywords.any((kw) => lower.contains(kw));
  }

  static final _incomeMerchantPatterns = ['from', 'received by']
      .map((marker) =>
          RegExp('(?<=\\s|^)$marker\\s+([^\\.\\n,]{2,})', caseSensitive: false))
      .toList();

  static final _expenseMerchantPatterns = [
    'to',
    'at',
    'towards',
    'for',
    'spent on',
    'paid to',
    'on'
  ]
      .map((marker) =>
          RegExp('(?<=\\s|^)$marker\\s+([^\\.\\n,]{2,})', caseSensitive: false))
      .toList();

  static final _merchantSplitPattern = RegExp(
      r'\s+via\s+|\s+using\s+|\s+on\s+|\s+ref\s+|\s+bal\s+|\s+₹|\s+Rs|\s+INR|\s+at\s+|\(',
      caseSensitive: false);

  static String? _extractMerchant(String text, bool isIncome) {
    final upiMatch = _upiPattern.firstMatch(text);
    if (upiMatch != null) return upiMatch.group(1);

    final infoMatch = _merchantInfoPattern.firstMatch(text);
    if (infoMatch != null) {
      final name = _cleanName(infoMatch.group(1)!);
      if (name != null) return name;
    }

    final patterns =
        isIncome ? _incomeMerchantPatterns : _expenseMerchantPatterns;
    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        var name = match.group(1)!.trim();
        
        // Check for VPA within the name or nearby
        final vpaMatchInName = _upiPattern.firstMatch(name);
        if (vpaMatchInName != null) return vpaMatchInName.group(1);

        final matchSplit = _merchantSplitPattern.firstMatch(name);
        if (matchSplit != null) {
          name = name.substring(0, matchSplit.start);
        }
        name = name.trim();
        final cleaned = _cleanName(name);
        if (cleaned != null) return cleaned;
      }
    }
    return null;
  }

  static String? _cleanName(String name) {
    final noise = [
      'bangalore',
      'mumbai',
      'delhi',
      'chennai',
      'hyderabad',
      'pune',
      'kolkata',
      'a purchase',
      'your account',
      'your a/c',
      'mobile',
      'card',
      'bank',
      'payment',
      'transfer',
      'inr',
      'rs',
      'ending',
      'successful',
      'completed'
    ];
    if (noise.any((n) =>
        name.toLowerCase() == n || name.toLowerCase().startsWith('$n '))) {
      return null;
    }

    var cleaned = name
        .replaceAll(_cleanupDatePattern1, '')
        .replaceAll(_cleanupDatePattern2, '')
        .trim();
    if (cleaned.length < 2) return null;
    return _capitalize(cleaned);
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static bool isTxPossible(String t) => _isLikelyTransaction(t.toLowerCase());

  static double? parseAmount(String text) {
    final amounts = _extractAllAmounts(text);
    if (amounts.isEmpty) return null;
    return amounts.first.value;
  }
}

class _MatchRange {
  final double value;
  final int start, end;
  _MatchRange(this.value, this.start, this.end);
}

import '../models/transaction.dart';

class ParsedTransaction {
  final double amount;
  final bool isIncome;
  final String? bank, account, category, merchant, reference, rawText;
  final double? balance;
  final DateTime? date;

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

  Transaction toTransaction() => Transaction(
        amount: amount,
        note: merchant ??
            (isIncome ? 'Received' : 'Paid') +
                (reference != null ? ' (Ref: $reference)' : ''),
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
  static final _amtPatterns = [
    RegExp(r'(?:Rs\.?|INR|₹|\$)\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
        caseSensitive: false),
    RegExp(r'(?:of|for)\s*(?:Rs\.?|INR|₹|\$)?\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
        caseSensitive: false),
    RegExp(r'(\d+(?:,\d{3})*(?:\.\d{1,2})?)\s*(?:Rs\.?|INR|₹|\$)',
        caseSensitive: false),
  ];

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
    'credited to',
    'received from'
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

  static const _catKW = {
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
    final lower = text.toLowerCase();
    final ctx =
        packageName != null ? '$lower ${packageName.toLowerCase()}' : lower;

    if (!_isTx(ctx)) return null;

    double? amt;
    for (final p in _amtPatterns) {
      final m = p.firstMatch(text);
      if (m != null) {
        amt = double.tryParse(m.group(1)!.replaceAll(',', ''));
        if (amt != null && amt > 0) break;
      }
    }
    if (amt == null) return null;

    bool isInc = _incomeKW.any((kw) => lower.contains(kw));
    if (lower.contains('sent to')) isInc = false;
    if (lower.contains('received from')) isInc = true;

    String? bank;
    for (final e in _bankMap.entries) {
      if (ctx.contains(e.key)) {
        bank = e.value;
        break;
      }
    }

    String cat = bank ?? 'Bank Transaction';
    _catKW.forEach((k, v) {
      if (v.any((kw) => lower.contains(kw))) cat = k;
    });

    String? acc;
    final accM = RegExp(r'(?:a/c|acct|acc|account|card)\s*(?:xx|x+)?(\d{4})',
                caseSensitive: false)
            .firstMatch(text) ??
        RegExp(r'\b\d{4}\b', caseSensitive: false).firstMatch(text);
    if (accM != null) {
      acc = 'A/c XX${accM.group(1) ?? accM.group(0)}';
    } else if (lower.contains('upi')) {
      acc = 'UPI';
    } else if (lower.contains('wallet')) {
      acc = 'Wallet';
    }

    String? merc;
    final mercP = [
      RegExp(
          r'(?:to|from|at|towards|for)\s+([a-zA-Z0-9\.\s&]+?)(?:\.|\s+via|\s+using|\s+on|\s+ref|\s+successful|\s+completed|\s+of|$)',
          caseSensitive: false),
      RegExp(r'spent\s+on\s+([a-zA-Z0-9\.\s&]+?)(?:\.|\s+via|\s+using|$)',
          caseSensitive: false),
      RegExp(r'payment\s+to\s+([a-zA-Z0-9\.\s&]+?)(?:\.|\s+for|$)',
          caseSensitive: false),
    ];
    for (final p in mercP) {
      final m = p.firstMatch(text);
      if (m != null) {
        merc = m.group(1)?.trim();
        if (merc != null && merc.isNotEmpty) break;
      }
    }
    if (merc != null) {
      merc = merc
          .replaceAll(RegExp(r'\d{10}'), '')
          .replaceAll(RegExp(r'vpa|upi|bank', caseSensitive: false), '')
          .trim();
      if (merc.isEmpty) merc = null;
    }

    String? ref;
    final refM = RegExp(r'(?:ref|txn|id|pnr|upi ref|rrn)[:\s\#]+([a-z0-9]+)',
            caseSensitive: false)
        .firstMatch(text);
    if (refM != null) ref = refM.group(1);

    double? bal;
    final balM = RegExp(
            r'(?:bal|balance|avl bal|available balance)\s*(?:Rs\.?|INR|₹|\$)?\s*(\d+(?:,\d{3})*(?:\.\d{1,2})?)',
            caseSensitive: false)
        .firstMatch(text);
    if (balM != null) bal = double.tryParse(balM.group(1)!.replaceAll(',', ''));

    return ParsedTransaction(
      amount: amt,
      isIncome: isInc,
      bank: bank,
      account: acc,
      category: cat,
      merchant: merc,
      reference: ref,
      balance: bal,
      rawText: text,
    );
  }

  static bool _isTx(String t) {
    if (t.isEmpty) return false;
    if (RegExp(
            r'otp|verification code|secret code|one time password|failed|declined|unsuccessful|limit exceeded|insufficient funds|rejected|data consumed|speed data|data balance|usage alert')
        .hasMatch(t)) return false;
    if ([
      'exclusive',
      'limited',
      'get up to',
      'win',
      'grab',
      'congratulations',
      'reward',
      'claim',
      'gift',
      'offer',
      'bonus',
      'available',
      'unlocked',
      'eligible',
      'pre-approved',
      'apply now',
      'disbursed',
      'ready for',
      'increase your limit',
      'unsubscribe',
      'remind',
      'lowest interest',
      '0% emi'
    ].any((kw) => t.contains(kw))) return false;
    if (t.contains('pay your bill') || t.contains('received payment against')) {
      return false;
    }
    if (t.contains('http') || t.contains('.ly/') || t.contains('.co/')) {
      if (!['debited', 'credited', 'spent', 'received', 'sent']
          .any((kw) => t.contains(kw))) {
        return false;
      }
    }
    final hasAmt = RegExp(r'rs|inr|₹|\$|amt').hasMatch(t);
    final hasDir = [
      'credited',
      'debited',
      'paid',
      'sent',
      'received',
      'spent',
      'withdrawal',
      'withdrawn',
      'transfer',
      'added',
      'refund',
      'cashback'
    ].any((kw) => t.contains(kw));
    final hasAcc = RegExp(r'a/c|acct|card xx|upi|wallet').hasMatch(t);
    return hasDir && (hasAmt || hasAcc);
  }
}

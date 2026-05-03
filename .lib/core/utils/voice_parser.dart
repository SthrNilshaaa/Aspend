import 'transaction_parser.dart';

class VoiceParsedResult {
  final double? amount;
  final bool? isIncome;
  final String? category;
  final String? personName;
  final String note;
  final bool isRequest; // New flag for money requests

  VoiceParsedResult({
    this.amount,
    this.isIncome,
    this.category,
    this.personName,
    required this.note,
    this.isRequest = false,
  });
}

class VoiceParser {
  // Income keywords: Extensive multi-lingual set for 'Request Money'
  static const _requestKeywords = [
    // English
    'request', 'collect', 'ask', 'demand', 'claim', 'invoice', 'charge', 'collecting',
    // Hindi/Hinglish
    'mango', 'maang', 'mangna', 'maango', 'maanglo', 'le', 'lena', 'lelo', 'vasool', 
    'mangao', 'bulalo', 'requestkar', 'collectkar', 'maanglo', 'mangle', 'askkar', 
    'mangde', 'mangdo', 'mangdiya', 'leliya', 'chahiye', 'dilao', 'lena', 'lete', 'mangva',
    // Gujarati
    'levu', 'mango', 'mangvo', 'mangjo', 'levanu', 'lidha', 'lavo', 'mangiye',
    // Marathi
    'mag', 'maga', 'ghya', 'ghene', 'vasul', 'magayche', 'ghyo',
    // Tamil
    'ketu', 'kekka', 'vangu', 'vangik', 'peru', 'vangikko', 'kél',
    // Telugu
    'adugu', 'adugandi', 'teesko', 'theesuko', 'pondi', 'koru', 'theeskoni'
  ];

  static const _incomeKeywords = [
    'salary', 'received', 'got', 'get', 'income', 'bonus', 'cashback', 'won', 
    'refund', 'added', 'credited', 'took', 'borrowed', 'earn', 'earned', 'positive',
    'mila', 'aaya', 'mile', 'reward', 'stipend', ..._requestKeywords
  ];
  
  static const _expenseKeywords = [
    'spent', 'paid', 'buy', 'expense', 'gave', 'purchased', 'sent', 'negative',
    'debited', 'bill', 'lend', 'lent', 'kharcha', 'diya', 'bheja', 
    'fees', 'bought', 'pay', 'checkout', 'nuksan', 'loss'
  ];

  static VoiceParsedResult parse(String text, {List<String>? knownPeople}) {
    String lower = text.toLowerCase();
    
    // 1. Extract Amount
    double? amount = TransactionParser.parseAmount(text);
    if (amount == null) {
      final numberMatch = RegExp(r'(\d+)').firstMatch(text);
      if (numberMatch != null) {
        amount = double.tryParse(numberMatch.group(1)!);
      }
    }

    // 2. Determine Type & Request Status
    bool isIncome = false; 
    bool isRequest = false;

    // Check for Request intent specifically
    for (var kw in _requestKeywords) {
      if (RegExp(r'\b' + kw + r'\b').hasMatch(lower)) {
        isRequest = true;
        isIncome = true; // Requesting money is an income intent
        break;
      }
    }

    if (!isRequest) {
      for (var kw in _incomeKeywords) {
        if (RegExp(r'\b' + kw + r'\b').hasMatch(lower)) {
          isIncome = true;
          break;
        }
      }
      for (var kw in _expenseKeywords) {
        if (RegExp(r'\b' + kw + r'\b').hasMatch(lower)) {
          isIncome = false;
          break;
        }
      }
    }
    
    // Advanced phrase matching
    if (lower.contains('got from') || lower.contains('received from')) isIncome = true;
    if (lower.contains('gave to') || lower.contains('paid to')) isIncome = false;

    // 3. Entity/Person Detection
    String? personName;
    if (knownPeople != null) {
      for (var name in knownPeople) {
        if (lower.contains(name.toLowerCase())) {
          personName = name;
          break;
        }
      }
    }

    // 4. Determine Category
    String? category;
    final categories = {
      'Food': ['food', 'lunch', 'dinner', 'breakfast', 'tea', 'coffee', 'zomato', 'swiggy', 'restaurant', 'burger', 'pizza', 'maggi', 'eat', 'grocery', 'blinkit', 'zepto', 'bigbasket', 'instamart'],
      'Transport': ['transport', 'bus', 'train', 'metro', 'uber', 'ola', 'auto', 'taxi', 'fuel', 'petrol', 'diesel', 'travel', 'flight', 'ticket', 'rapido'],
      'Shopping': ['shopping', 'amazon', 'flipkart', 'cloth', 'shoes', 'gadget', 'myntra', 'buy', 'purchased', 'gift', 'ajio', 'meesho'],
      'Bills': ['bill', 'electricity', 'water', 'recharge', 'rent', 'wifi', 'subscription', 'netflix', 'prime', 'jio', 'airtel', 'vi', 'broadband', 'piped gas'],
      'Entertainment': ['movie', 'netflix', 'game', 'entertainment', 'cinema', 'pvr', 'inox', 'party', 'club', 'outing'],
      'Health': ['health', 'medicine', 'doctor', 'hospital', 'pharmacy', 'clinic', 'gym', 'cult', 'pharmeasy'],
      'Salary': ['salary', 'stipend', 'pension', 'income', 'hike', 'bonus'],
      'Investment': ['stock', 'mutual fund', 'crypto', 'invest', 'trading', 'gold', 'zerodha', 'groww', 'upstox'],
      'Loan': ['loan', 'emi', 'borrowed', 'lent', 'debt', 'interest', 'kist'],
      'Household': ['maid', 'cook', 'driver', 'laundry', 'cleaner', 'maintenance', 'kamwali'],
    };

    for (var entry in categories.entries) {
      if (entry.value.any((kw) => lower.contains(kw))) {
        category = entry.key;
        break;
      }
    }
    
    // Categorize Requests as 'Personal' or 'Loan' if not specified
    if (isRequest && category == null) {
      category = 'Personal';
    }

    // Default peer recovery
    if (personName != null && category == null) {
      category = 'Personal';
    }

    return VoiceParsedResult(
      amount: amount,
      isIncome: isIncome,
      category: category,
      personName: personName,
      note: text,
      isRequest: isRequest,
    );
  }
}

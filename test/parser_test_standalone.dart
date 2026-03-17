import 'dart:io';
import '../lib/core/utils/transaction_parser.dart';

void main() {
  print('--- TransactionParser Standalone Tests ---');
  
  final tests = [
    {
      'name': 'Debit Notification - ICICI Bank',
      'text': 'ICICI Bank: Acct XX123 debited for Rs 1,500.00 on 08-MAR-26. Info: ZOMATO. Avl Bal: Rs 10,000.00',
      'expect': (ParsedTransaction? p) => 
        p != null && p.amount == 1500.0 && p.isIncome == false && p.account == 'XX123' && p.merchant == 'Zomato' && p.balance == 10000.0
    },
    {
      'name': 'Credit Notification - HDFC Bank',
      'text': 'HDFC Bank: Rs 5,000.00 credited to a/c XX789 on 08-03-26. Ref: 12345678. Avl Bal: INR 25,000',
      'expect': (ParsedTransaction? p) => 
        p != null && p.amount == 5000.0 && p.isIncome == true && p.account == 'XX789' && p.reference == '12345678' && p.balance == 25000.0
    },
    {
      'name': 'UPI Payment - GPay',
      'text': 'You paid ₹250.00 to Chai Point via Google Pay. Ref: 87654321',
      'expect': (ParsedTransaction? p) => 
        p != null && p.amount == 250.0 && p.isIncome == false && p.merchant == 'Chai Point'
    },
    {
      'name': 'UPI Received - PhonePe',
      'text': 'Rs. 1000.00 received from John Doe (vpa: john@upi). Ref: 11223344',
      'expect': (ParsedTransaction? p) => 
        p != null && p.amount == 1000.0 && p.isIncome == true && (p.merchant == 'john@upi' || p.merchant == 'John Doe') && p.reference == '11223344'
    },
    {
      'name': 'Promotional Message (Should ignore)',
      'text': 'Win up to Rs 500 cashback! Apply for a card now. Limited period offer.',
      'expect': (ParsedTransaction? p) => p == null
    },
    {
      'name': 'Failed Transaction (Should ignore)',
      'text': 'Transaction of Rs. 500.00 failed at Zomato.',
      'expect': (ParsedTransaction? p) => p == null,
    },
    {
      'name': 'Balance Only Update',
      'text': 'Available Balance in your A/c XX1234 is Rs. 15,000.00.',
      'expect': (ParsedTransaction? p) => 
        p != null && p.amount == 0 && p.isBalanceUpdate == true && p.balance == 15000.0,
    },
    {
      'name': 'Duplicate Hash Detection',
      'text': 'Rs. 100.00 debited from card XX1234 at Swiggy.',
      'expect': (ParsedTransaction? p) => 
        p != null && p.amount == 100.0 && p.isIncome == false && p.merchant == 'Swiggy',
    },
  ];

  int passed = 0;
  for (var test in tests) {
    final name = test['name'] as String;
    final text = test['text'] as String;
    final expect = test['expect'] as bool Function(ParsedTransaction?);

    final result = TransactionParser.parse(text);
    if (expect(result)) {
      print('[PASS] $name');
      passed++;
    } else {
      print('[FAIL] $name');
      print('  Text: $text');
      if (result != null) {
        print('  Result: Amt=${result.amount}, Inc=${result.isIncome}, Merch=${result.merchant}, Bal=${result.balance}, BalUpd=${result.isBalanceUpdate}');
      } else {
        print('  Result: null');
      }
    }
  }

  print('--- Result: $passed/${tests.length} passed ---');
  if (passed < tests.length) exit(1);
}

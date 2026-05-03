import 'package:aspends_tracker/core/utils/transaction_parser.dart';

void main() {
  final testCases = [
    // Original cases
    'Alert: Your account XX1234 has been debited by Rs. 500.00 for a purchase at AMAZON. Ref: TXN123456.',
    'HDFC Bank: Rs 1200.00 credited to a/c XX5678 from Zomato via UPI. Ref: 1234567890.',
    'Spent Rs.150.00 on Swiggy using card ending 9999 at Bangalore.',
    'Your A/c XX4321 is debited for INR 45.00 on 22-02-24. Transfer to mobile 9876543210. Ref 4444.',
    'Rs. 5000.00 received from Father. A/c balance is Rs. 15000.00.',
    'Electricity Bill payment of Rs 2500.00 successful for Consumer 123456.',

    // New complex cases
    'HDFC Bank: Rs 500.00 debited from a/c **1234 on 23-02-24 to VPA paytmqr@paytm. Not you? Call 1800...',
    'SBI: Your A/c XX9876 has been Credited by Rs. 10,000.00 on 23Feb24. (Ref: 123456). Total Bal: Rs. 50,234.12',
    'ICICI Bank: Acct XX111 debited for INR 2,500.00 on 23-FEB-24. Info: UPI-SWIGGY-12345. Bal: INR 12,000.50',
    'Axis Bank: Rs. 200.00 debited from Ac XXXXCRD1234 at STARBUCKS. Avl Bal Rs. 5000.',
    'Money Received! INR 500.00 from FRIEND (VPA: friend@okaxis) to your Paytm Wallet. Ref: 9876543210',
    'Your A/c XXX321 has been credited with Rs 50000.00 towards Salary for Feb 2024.',
  ];

  for (final text in testCases) {
    final parsed = TransactionParser.parse(text);
    print('---');
    print('Text: $text');
    if (parsed != null) {
      print('Amount: ${parsed.amount}');
      print('Income: ${parsed.isIncome}');
      print('Merchant: ${parsed.merchant}');
      print('Account: ${parsed.account}');
      print('Bank: ${parsed.bank}');
      print('Ref: ${parsed.reference}');
      print('Confidence: ${parsed.confidence}');
    } else {
      print('RESULT: FAILED TO PARSE');
    }
  }
}

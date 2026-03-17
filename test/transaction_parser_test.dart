import 'package:flutter_test/flutter_test.dart';
import 'package:aspends_tracker/core/utils/transaction_parser.dart';

void main() {
  group('TransactionParser Tests', () {
    test('Debit Notification - ICICI Bank', () {
      const text = 'ICICI Bank: Acct XX123 debited for Rs 1,500.00 on 08-MAR-26. Info: ZOMATO. Avl Bal: Rs 10,000.00';
      final parsed = TransactionParser.parse(text);
      
      expect(parsed, isNotNull);
      expect(parsed!.amount, 1500.0);
      expect(parsed.isIncome, false);
      expect(parsed.account, 'XX123');
      expect(parsed.merchant, 'Zomato');
      expect(parsed.balance, 10000.0);
    });

    test('Credit Notification - HDFC Bank', () {
      const text = 'HDFC Bank: Rs 5,000.00 credited to a/c XX789 on 08-03-26. Ref: 12345678. Avl Bal: INR 25,000';
      final parsed = TransactionParser.parse(text);
      
      expect(parsed, isNotNull);
      expect(parsed!.amount, 5000.0);
      expect(parsed.isIncome, true);
      expect(parsed.account, 'XX789');
      expect(parsed.reference, '12345678');
      expect(parsed.balance, 25000.0);
    });

    test('UPI Payment - GPay', () {
      const text = 'You paid ₹250.00 to Chai Point via Google Pay. Ref: 87654321';
      final parsed = TransactionParser.parse(text);
      
      expect(parsed, isNotNull);
      expect(parsed!.amount, 250.0);
      expect(parsed.isIncome, false);
      expect(parsed.merchant, 'Chai Point');
    });

    test('UPI Received - PhonePe', () {
      const text = 'Rs. 1000.00 received from John Doe (vpa: john@upi). Ref: 11223344';
      final parsed = TransactionParser.parse(text);
      
      expect(parsed, isNotNull);
      expect(parsed!.amount, 1000.0);
      expect(parsed.isIncome, true);
      expect(parsed.merchant, 'john@upi'); // Currently extract VPA if present
    });

    test('Promotional Message (Should ignore)', () {
      const text = 'Win up to Rs 500 cashback! Apply for a card now. Limited period offer.';
      final parsed = TransactionParser.parse(text);
      
      expect(parsed, isNull);
    });

    test('Failed Transaction (Should ignore)', () {
      const text = 'Transaction of Rs 200 at Amazon failed due to insufficient funds.';
      final parsed = TransactionParser.parse(text);
      
      expect(parsed, isNull);
    });
  });
}

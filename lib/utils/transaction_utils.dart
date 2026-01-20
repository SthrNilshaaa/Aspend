import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionUtils {
  static Map<String, List<Transaction>> groupTransactionsByDate(
      List<Transaction> txns) {
    final Map<String, List<Transaction>> grouped = {};
    for (final tx in txns) {
      final dateKey =
          "${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateKey, () => []).add(tx);
    }
    return grouped;
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt_long;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'salary':
        return Icons.payments;
      case 'freelance':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'refund':
        return Icons.replay;
      case 'bank transaction':
      case 'hdfc bank':
      case 'state bank of india':
      case 'icici bank':
      case 'axis bank':
      case 'pnb':
      case 'bank':
        return Icons.account_balance;
      case 'paytm':
      case 'phonepe':
      case 'google pay':
      case 'gpay':
      case 'amazon pay':
      case 'upi':
        return Icons.account_balance_wallet;
      case 'zomato':
      case 'swiggy':
        return Icons.fastfood;
      case 'amazon':
      case 'flipkart':
        return Icons.shopping_cart;
      case 'uber':
      case 'ola':
        return Icons.local_taxi;
      case 'groceries':
        return Icons.shopping_basket;
      case 'fuel':
        return Icons.local_gas_station;
      case 'rent':
      case 'rent received':
        return Icons.home;
      case 'travel':
        return Icons.flight;
      case 'maintenance':
        return Icons.settings;
      case 'insurance':
        return Icons.security;
      case 'subscription':
        return Icons.subscriptions;
      case 'personal care':
        return Icons.face;
      case 'tax':
        return Icons.gavel;
      case 'charity':
        return Icons.favorite;
      case 'loan repayment':
        return Icons.credit_score;
      case 'bonus':
        return Icons.card_giftcard;
      case 'interest':
        return Icons.account_balance_wallet;
      case 'cashback':
        return Icons.account_balance_wallet;
      case 'business':
        return Icons.business_center;
      default:
        return Icons.category;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'bills':
        return Colors.red;
      case 'entertainment':
        return Colors.pink;
      case 'health':
        return Colors.green;
      case 'education':
        return Colors.indigo;
      case 'salary':
        return Colors.teal;
      case 'freelance':
        return Colors.amber;
      case 'investment':
        return Colors.cyan;
      case 'gift':
        return Colors.deepOrange;
      case 'refund':
        return Colors.lightGreen;
      case 'hdfc bank':
      case 'icici bank':
      case 'axis bank':
        return Colors.blue.shade800;
      case 'paytm':
        return Colors.lightBlue;
      case 'google pay':
      case 'gpay':
        return Colors.blueAccent;
      case 'phonepe':
        return Colors.deepPurple;
      case 'zomato':
        return Colors.redAccent;
      case 'swiggy':
        return Colors.orangeAccent;
      case 'groceries':
        return Colors.lightGreen;
      case 'fuel':
        return Colors.amber;
      case 'rent':
      case 'rent received':
        return Colors.blueGrey;
      case 'travel':
        return Colors.cyan;
      case 'maintenance':
        return Colors.brown;
      case 'insurance':
        return Colors.blueAccent;
      case 'subscription':
        return Colors.redAccent;
      case 'personal care':
        return Colors.pinkAccent;
      case 'tax':
        return Colors.deepPurple;
      case 'charity':
        return Colors.red;
      case 'loan repayment':
        return Colors.blue;
      case 'bonus':
        return Colors.amber;
      case 'interest':
        return Colors.indigo;
      case 'cashback':
        return Colors.lightBlue;
      case 'business':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  static IconData getAccountIcon(String account) {
    switch (account.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'online':
        return Icons.account_balance;
      case 'credit card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'wallet':
        return Icons.account_balance_wallet;
      case 'upi':
        return Icons
            .pix; // Pix is similar to UPI icon in some contexts, but let's use account_balance_wallet or similar
      case 'debit card':
        return Icons.credit_card;
      default:
        return Icons.wallet;
    }
  }
}

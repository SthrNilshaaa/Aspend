// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Aspends';

  @override
  String get appTagline => 'Smart spending, simplified.';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get monthlyBudget => 'Monthly Budget';

  @override
  String get transactions => 'Transactions';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See All';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get adaptiveColor => 'Adaptive Color';

  @override
  String get customColor => 'Custom Color';

  @override
  String get backup => 'Backup & Restore';

  @override
  String get export => 'Export Data';

  @override
  String get import => 'Import Data';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get telegramSupport => 'Telegram Support';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get account => 'Account';

  @override
  String get date => 'Date';

  @override
  String get note => 'Note (Optional)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search transactions...';

  @override
  String get noTransactions => 'No transactions found';

  @override
  String get voiceInput => 'Voice Input';

  @override
  String get speechUnavailable => 'Speech recognition unavailable';

  @override
  String get microPermissionDenied => 'Microphone permission denied';

  @override
  String get appearance => 'Appearance';

  @override
  String get security => 'Security';

  @override
  String get autoDetection => 'Auto Transaction Detection';

  @override
  String get backupExport => 'Backup & Export';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get budgetingBalance => 'Budgeting & Balance';

  @override
  String get customDropdowns => 'Custom Dropdown Items';

  @override
  String get appInformation => 'App Information';

  @override
  String get developedBy => 'Developed with ❤️ by Sthrnilshaa';

  @override
  String get chooseTheme => 'Choose your preferred theme';

  @override
  String get appLock => 'App Lock';

  @override
  String get appLockDesc => 'Require device authentication to open app';

  @override
  String get upiId => 'UPI ID';

  @override
  String get upiIdDesc => 'Set your UPI ID for money requests';

  @override
  String get upiName => 'Display Name';

  @override
  String get upiNameDesc => 'Optional: Name shown in UPI request';

  @override
  String get analytics => 'Analytics';

  @override
  String get people => 'People';

  @override
  String get charts => 'Charts';

  @override
  String get sortBy => 'Sort By';

  @override
  String get holdToRecord => 'Hold to record transaction';

  @override
  String get couldNotFindAmount =>
      'Couldn\'t find amount. Try: \'Spent 500 on Food\'';

  @override
  String savedAmount(String amount, String category) {
    return 'Saved ₹$amount for $category';
  }

  @override
  String logsDeleted(int count) {
    return 'Deleted $count logs';
  }

  @override
  String patternsIgnored(int count) {
    return 'Permanently ignored $count patterns';
  }

  @override
  String get recheckComplete => 'Recheck complete';
}

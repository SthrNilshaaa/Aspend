// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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

  @override
  String get aboutApp => 'About Aspends';

  @override
  String get developerDesigner => 'Developer & Designer';

  @override
  String get leadDesigner => 'Lead Designer';

  @override
  String get developer => 'Developer';

  @override
  String get supportLegal => 'Support & Legal';

  @override
  String get privacyPolicyDesc => 'Read our privacy policy document';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get telegramSupportDesc => 'Join our Telegram for support';

  @override
  String get projectInfo => 'Project Info';

  @override
  String get openSource => 'Open Source';

  @override
  String get openSourceDesc => 'Proudly open source on GitHub';

  @override
  String get rateApp => 'Rate Aspends';

  @override
  String get rateAppDesc => 'Support us with a 5-star rating';

  @override
  String get howAspendWorks => 'HOW ASPEND WORKS';

  @override
  String get howItWorksTitle1 => '1. Intelligent Interception';

  @override
  String get howItWorksDesc1 =>
      'A secure, battery-optimized background service listens for incoming SMS and banking notifications.';

  @override
  String get howItWorksTitle2 => '2. Zero-Cloud Local Parsing';

  @override
  String get howItWorksDesc2 =>
      'Smart offline algorithms extract amounts, categories, and merchants instantly—100% on your device.';

  @override
  String get howItWorksTitle3 => '3. Offline Auto-Recovery';

  @override
  String get howItWorksDesc3 =>
      'Every time you open or resume Aspend, it auto-scans history for missed transactions during your absence.';

  @override
  String get howItWorksTitle4 => '4. Ultimate Privacy Lock';

  @override
  String get howItWorksDesc4 =>
      'No servers, no web requests. Your financial data is protected locally inside encrypted Hive storage.';

  @override
  String get autoDetectionSetup => 'Auto-Detection Setup';

  @override
  String get autoDetectionSetupDesc =>
      'To automatically detect transactions, we need specific permissions. All banking and transaction apps will be monitored securely.';

  @override
  String get notificationAccess => '1. Notification Access';

  @override
  String get notificationAccessDesc =>
      'Allows us to read transaction alerts from bank and payment apps.';

  @override
  String get smsPermission => '2. SMS Permission';

  @override
  String get smsPermissionDesc =>
      'Enables reading transaction SMS from your bank.';

  @override
  String get finishSetup => 'Finish Setup';

  @override
  String get grant => 'Grant';

  @override
  String get appNameShort => 'Aspends';

  @override
  String get splashTagline => 'Smart Money Management';

  @override
  String get budget => 'Budget';

  @override
  String get balanceDetailsTitle => 'Balance Details';

  @override
  String get editBalanceTitle => 'Edit Balance';

  @override
  String get newBalanceLabel => 'New Balance';

  @override
  String get viewAll => 'View all';

  @override
  String get searchHint => 'Search categories or notes...';

  @override
  String get emptyWalletTitle => 'Your wallet is quiet';

  @override
  String get emptyWalletDesc =>
      'Start by adding a transaction manually or enable auto-detection to track your spending effortlessly.';

  @override
  String get addPerson => 'Add Person';

  @override
  String get addNewPerson => 'Add New Person';

  @override
  String get editPerson => 'Edit Person';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get personName => 'Person Name';

  @override
  String get youGet => 'You Own';

  @override
  String get youGive => 'You Borrow';

  @override
  String get youWillGet => 'You will Own';

  @override
  String get youWillGive => 'You will Borrow';

  @override
  String get noPeopleYet => 'No people added yet';

  @override
  String get searchPeople => 'Search people...';

  @override
  String get enterNameHint =>
      'Enter the name of the person you want to track transactions with';

  @override
  String get updateDetailsHint => 'Update the details for this person';

  @override
  String get expenses => 'Expenses';

  @override
  String get history => 'History';

  @override
  String get overview => 'Overview';

  @override
  String get trends => 'Trends';

  @override
  String get categories => 'Categories';

  @override
  String get noDataFound => 'No data records found';

  @override
  String get appColor => 'App Color';

  @override
  String get selectColor => 'Select a custom app color';

  @override
  String get welcomeTitle => 'Welcome to Aspends Tracker';

  @override
  String get welcomeSubtitle => 'Your personal finance companion';

  @override
  String get welcomeDesc =>
      'Track your income, expenses, and manage your money with ease. Stay on top of your financial goals.';

  @override
  String get smartTrackingTitle => 'Smart Transaction Tracking';

  @override
  String get smartTrackingSubtitle => 'Organize your finances';

  @override
  String get smartTrackingDesc =>
      'Categorize transactions, add notes, and get detailed insights into your spending patterns.';

  @override
  String get peopleTrackingTitle => 'Person-to-Person Tracking';

  @override
  String get peopleTrackingSubtitle => 'Manage shared expenses';

  @override
  String get peopleTrackingDesc =>
      'Track money you owe or are owed by others. Perfect for roommates, friends, and family.';

  @override
  String get analyticsTitle => 'Beautiful Analytics';

  @override
  String get analyticsSubtitle => 'Visualize your data';

  @override
  String get analyticsDesc =>
      'Charts and graphs help you understand your spending habits and financial trends.';

  @override
  String get offlineTitle => 'Fully Offline';

  @override
  String get offlineSubtitle => 'Your data stays private';

  @override
  String get offlineDesc =>
      'All your financial data is stored locally on your device. No internet required, complete privacy.';

  @override
  String get autoDetectTitle => 'Auto Transaction Detection';

  @override
  String get autoDetectSubtitle => 'Smart & Automated';

  @override
  String get autoDetectDesc =>
      'Automatically detect transactions from banking notifications. No more manual entry - your transactions are captured instantly!';

  @override
  String get readyTitle => 'Ready to Start?';

  @override
  String get readySubtitle => 'Let\'s begin your journey';

  @override
  String get readyDesc =>
      'You\'re all set! Start tracking your finances and take control of your money today.';

  @override
  String get settingUpApp => 'Setting up your app...';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get requestMoney => 'Request Money';

  @override
  String get generateQr => 'Generate Payment QR';

  @override
  String get sortByNameAZ => 'Name (A-Z)';

  @override
  String get sortByNameZA => 'Name (Z-A)';

  @override
  String get sortByBalanceHighest => 'Balance (Highest)';

  @override
  String get sortByBalanceLowest => 'Balance (Lowest)';

  @override
  String get upiIdNotSet =>
      'UPI ID not set for this person. Please add it from edit.';

  @override
  String get couldNotFindUpiApp => 'Could not find a UPI payment app';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get addFirstTransaction =>
      'Add your first transaction with the person';

  @override
  String get settleBalance => 'Settle Balance';

  @override
  String settleBalanceDesc(String amount) {
    return 'This will add a transaction of ₹$amount to bring the balance to zero. Continue?';
  }

  @override
  String get settle => 'Settle';

  @override
  String get deletePerson => 'Delete Person';

  @override
  String deletePersonDesc(String name) {
    return 'Are you sure you want to delete $name? This action cannot be undone.';
  }

  @override
  String get deleteTransactionDesc =>
      'Are you sure you want to delete this transaction?';

  @override
  String get update => 'Update';

  @override
  String get sortTransactionsBy => 'Sort Transactions By';

  @override
  String get sortByDateRecent => 'Date (Recent)';

  @override
  String get sortByDateOldest => 'Date (Oldest)';

  @override
  String get sortByAmountHighest => 'Amount (Highest)';

  @override
  String get sortByAmountLowest => 'Amount (Lowest)';

  @override
  String get rangeAll => 'All';

  @override
  String get rangeDay => 'Day';

  @override
  String get rangeWeek => 'Week';

  @override
  String get rangeMonth => 'Month';

  @override
  String get rangeYear => 'Year';

  @override
  String get topCategory => 'Top Category';

  @override
  String get noSpending => 'No spending';

  @override
  String get avgDailySpend => 'Avg. Daily Spend';

  @override
  String get perDay => 'Per day';

  @override
  String get monitoredApps => 'Monitored Apps';

  @override
  String get searchAppsHint => 'Search payment or banking apps...';

  @override
  String get noEligibleApps => 'No eligible apps found';

  @override
  String get noAppsMatchSearch => 'No apps match your search';

  @override
  String get unknownApp => 'Unknown App';

  @override
  String errorLoadingApps(String error) {
    return 'Error loading apps: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count Selected';
  }

  @override
  String get ignorePatternsTooltip => 'Ignore Patterns';

  @override
  String get deleteSelectedTooltip => 'Delete Selected';

  @override
  String get clearHistoryTitle => 'Clear History?';

  @override
  String get clearHistoryDesc => 'This will delete all saved detection logs.';

  @override
  String get clear => 'Clear';

  @override
  String get transactionDetected => 'Transaction Detected';

  @override
  String get notificationLogged => 'Notification Logged';

  @override
  String get patternNotMatched => 'Pattern not matched';

  @override
  String get notificationDataTitle => 'NOTIFICATION DATA';

  @override
  String get copiedToClipboard => 'Message copied to clipboard';

  @override
  String get copy => 'COPY';

  @override
  String get smsMessage => 'SMS Message';

  @override
  String get received => 'Received';

  @override
  String get paid => 'Paid';

  @override
  String get listeningHint => 'Listening...';

  @override
  String get keepSpeaking => 'Keep speaking...';

  @override
  String get done => 'Done';

  @override
  String get fullBackupTitle => 'Full Backup (JSON)';

  @override
  String get fullBackupDesc => 'Backup all data to JSON';

  @override
  String get restoreBackupTitle => 'Restore Backup (JSON)';

  @override
  String get restoreBackupDesc => 'Restore all data from JSON backup';

  @override
  String get backupCompleted => 'Backup completed!';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get restoreCompleted => 'Data restored successfully!';

  @override
  String get restoreFailedCancelled => 'Restore failed or cancelled';

  @override
  String restoreFailed(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get pdfExported => 'PDF exported successfully!';

  @override
  String pdfExportFailed(String error) {
    return 'PDF export failed: $error';
  }

  @override
  String get peopleExported => 'People data exported!';

  @override
  String peopleExportFailed(String error) {
    return 'People data export failed: $error';
  }

  @override
  String get allDataDeleted => 'All data deleted successfully!';

  @override
  String get introReset => 'Intro reset successfully!';

  @override
  String get selectRestoreMode => 'Select Restore Mode';

  @override
  String get restoreModeDesc =>
      'Choose how to handle existing transaction records during data restore.';

  @override
  String get mergeSkipDuplicates => 'Merge & Skip Duplicates';

  @override
  String get mergeSkipDesc =>
      'Avoid duplicate entries while keeping all unique new items.';

  @override
  String get overwriteConflicts => 'Overwrite & Update Conflicts';

  @override
  String get overwriteConflictsDesc =>
      'Replace existing transaction records with backup versions in case of conflicts.';

  @override
  String get exportCsvTitle => 'Export Transactions (CSV)';

  @override
  String get exportCsvDesc => 'Export your transactions to CSV';

  @override
  String get exportCsvSuccess => 'Export completed successfully!';

  @override
  String exportCsvFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get exportPeopleTitle => 'Export People Data';

  @override
  String get exportPeopleDesc => 'Backup people transactions';

  @override
  String get exportPdfTitle => 'Export as PDF';

  @override
  String get exportPdfDesc => 'Generate PDF reports';
}

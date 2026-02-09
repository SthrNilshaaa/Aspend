class AppConstants {
  // Hive Box Names
  static const String settingsBox = 'settings';
  static const String transactionsBox = 'transactions';
  static const String balanceBox = 'balanceBox';
  static const String peopleBox = 'people';
  static const String personTransactionsBox = 'personTransactions';
  static const String detectionHistoryBox = 'detection_history';

  // Settings Keys
  static const String themeKey = 'theme';
  static const String adaptiveColorKey = 'adaptiveColor';
  static const String customColorKey = 'customSeedColor';
  static const String introCompletedKey = 'introCompleted';
  static const String monthlyBudgetKey = 'monthlyBudget';
  static const String joinPreviousMonthBalanceKey = 'joinPreviousMonthBalance';
  static const String incomeCategoriesKey = 'incomeCategories';
  static const String expenseCategoriesKey = 'expenseCategories';
  static const String accountsKey = 'accounts_list';

  // Animation Durations
  static const Duration splashEntryDuration = Duration(milliseconds: 1000);
  static const Duration splashExitDuration = Duration(milliseconds: 1000);
  static const Duration splashWaitDuration = Duration(seconds: 2);
  static const Duration widgetWaitDuration = Duration(seconds: 1);
  static const Duration homeArrivalDelay = Duration(milliseconds: 2200);
}

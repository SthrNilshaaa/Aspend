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
  static const String autoDeleteUndetectedKey = 'autoDeleteUndetected';
  static const String incomeCategoriesKey = 'incomeCategories';
  static const String expenseCategoriesKey = 'expenseCategories';
  static const String accountsKey = 'accounts_list';
  static const String ignoredPatternsKey = 'ignoredPatterns';
  static const String autoSelectionFirstTimeKey = 'isFirstTimeAutoSelection';
  static const String upiIdKey = 'upiId';
  static const String upiNameKey = 'upiName';
  static const String localeKey = 'locale';

  // Animation Durations
  static const Duration splashEntryDuration = Duration(milliseconds: 1000);
  static const Duration splashExitDuration = Duration(milliseconds: 1000);
  static const Duration splashWaitDuration = Duration(milliseconds: 1000);
  static const Duration widgetWaitDuration = Duration(milliseconds: 500);
  static const Duration homeArrivalDelay = Duration(milliseconds: 500);

  // External URLs
  static const String supportTelegramUrl = 'https://t.me/+W7iMso5YsO1lZDM1';
  static const String privacyPolicyUrl =
      'https://github.com/SthrNilshaaa/Aspend/blob/main/PRIVACY_POLICY.md';

  // Default Monitored Packages (Common Payment & SMS apps)
  static const List<String> defaultMonitoredPackages = [
    // SMS Apps
    'com.google.android.apps.messaging',
    'com.samsung.android.messaging',
    'com.android.mms',
    // UPI & Payment Apps
    'com.google.android.apps.nbu.paisa.user', // Google Pay
    'com.phonepe.app', // PhonePe
    'net.one97.paytm', // Paytm
    'in.org.npci.upiapp', // BHIM
    'com.amazon.mShop.android.shopping', // Amazon
    'in.amazon.mShop.android.shopping', // Amazon India
    'com.freecharge.android', // Freecharge
    'com.mobikwik_new', // Mobikwik
    'com.upi.axispay', // Axis Pay
    'com.msf.kbank.mobile', // Kotak
    'com.dreamplug.androidapp', // CRED
  ];
}

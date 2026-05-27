import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Aspends'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart spending, simplified.'**
  String get appTagline;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @adaptiveColor.
  ///
  /// In en, this message translates to:
  /// **'Adaptive Color'**
  String get adaptiveColor;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom Color'**
  String get customColor;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backup;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get import;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @telegramSupport.
  ///
  /// In en, this message translates to:
  /// **'Telegram Support'**
  String get telegramSupport;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get note;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get search;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactions;

  /// No description provided for @voiceInput.
  ///
  /// In en, this message translates to:
  /// **'Voice Input'**
  String get voiceInput;

  /// No description provided for @speechUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition unavailable'**
  String get speechUnavailable;

  /// No description provided for @microPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get microPermissionDenied;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @autoDetection.
  ///
  /// In en, this message translates to:
  /// **'Auto Transaction Detection'**
  String get autoDetection;

  /// No description provided for @backupExport.
  ///
  /// In en, this message translates to:
  /// **'Backup & Export'**
  String get backupExport;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @budgetingBalance.
  ///
  /// In en, this message translates to:
  /// **'Budgeting & Balance'**
  String get budgetingBalance;

  /// No description provided for @customDropdowns.
  ///
  /// In en, this message translates to:
  /// **'Custom Dropdown Items'**
  String get customDropdowns;

  /// No description provided for @appInformation.
  ///
  /// In en, this message translates to:
  /// **'App Information'**
  String get appInformation;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed with ❤️ by Sthrnilshaa'**
  String get developedBy;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred theme'**
  String get chooseTheme;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockDesc.
  ///
  /// In en, this message translates to:
  /// **'Require device authentication to open app'**
  String get appLockDesc;

  /// No description provided for @upiId.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// No description provided for @upiIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Set your UPI ID for money requests'**
  String get upiIdDesc;

  /// No description provided for @upiName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get upiName;

  /// No description provided for @upiNameDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional: Name shown in UPI request'**
  String get upiNameDesc;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @charts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get charts;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @holdToRecord.
  ///
  /// In en, this message translates to:
  /// **'Hold to record transaction'**
  String get holdToRecord;

  /// No description provided for @couldNotFindAmount.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find amount. Try: \'Spent 500 on Food\''**
  String get couldNotFindAmount;

  /// No description provided for @savedAmount.
  ///
  /// In en, this message translates to:
  /// **'Saved ₹{amount} for {category}'**
  String savedAmount(String amount, String category);

  /// No description provided for @logsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} logs'**
  String logsDeleted(int count);

  /// No description provided for @patternsIgnored.
  ///
  /// In en, this message translates to:
  /// **'Permanently ignored {count} patterns'**
  String patternsIgnored(int count);

  /// No description provided for @recheckComplete.
  ///
  /// In en, this message translates to:
  /// **'Recheck complete'**
  String get recheckComplete;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Aspends'**
  String get aboutApp;

  /// No description provided for @developerDesigner.
  ///
  /// In en, this message translates to:
  /// **'Developer & Designer'**
  String get developerDesigner;

  /// No description provided for @leadDesigner.
  ///
  /// In en, this message translates to:
  /// **'Lead Designer'**
  String get leadDesigner;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @supportLegal.
  ///
  /// In en, this message translates to:
  /// **'Support & Legal'**
  String get supportLegal;

  /// No description provided for @privacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy document'**
  String get privacyPolicyDesc;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @telegramSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Join our Telegram for support'**
  String get telegramSupportDesc;

  /// No description provided for @projectInfo.
  ///
  /// In en, this message translates to:
  /// **'Project Info'**
  String get projectInfo;

  /// No description provided for @openSource.
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get openSource;

  /// No description provided for @openSourceDesc.
  ///
  /// In en, this message translates to:
  /// **'Proudly open source on GitHub'**
  String get openSourceDesc;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate Aspends'**
  String get rateApp;

  /// No description provided for @rateAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Support us with a 5-star rating'**
  String get rateAppDesc;

  /// No description provided for @howAspendWorks.
  ///
  /// In en, this message translates to:
  /// **'HOW ASPEND WORKS'**
  String get howAspendWorks;

  /// No description provided for @howItWorksTitle1.
  ///
  /// In en, this message translates to:
  /// **'1. Intelligent Interception'**
  String get howItWorksTitle1;

  /// No description provided for @howItWorksDesc1.
  ///
  /// In en, this message translates to:
  /// **'A secure, battery-optimized background service listens for incoming SMS and banking notifications.'**
  String get howItWorksDesc1;

  /// No description provided for @howItWorksTitle2.
  ///
  /// In en, this message translates to:
  /// **'2. Zero-Cloud Local Parsing'**
  String get howItWorksTitle2;

  /// No description provided for @howItWorksDesc2.
  ///
  /// In en, this message translates to:
  /// **'Smart offline algorithms extract amounts, categories, and merchants instantly—100% on your device.'**
  String get howItWorksDesc2;

  /// No description provided for @howItWorksTitle3.
  ///
  /// In en, this message translates to:
  /// **'3. Offline Auto-Recovery'**
  String get howItWorksTitle3;

  /// No description provided for @howItWorksDesc3.
  ///
  /// In en, this message translates to:
  /// **'Every time you open or resume Aspend, it auto-scans history for missed transactions during your absence.'**
  String get howItWorksDesc3;

  /// No description provided for @howItWorksTitle4.
  ///
  /// In en, this message translates to:
  /// **'4. Ultimate Privacy Lock'**
  String get howItWorksTitle4;

  /// No description provided for @howItWorksDesc4.
  ///
  /// In en, this message translates to:
  /// **'No servers, no web requests. Your financial data is protected locally inside encrypted Hive storage.'**
  String get howItWorksDesc4;

  /// No description provided for @autoDetectionSetup.
  ///
  /// In en, this message translates to:
  /// **'Auto-Detection Setup'**
  String get autoDetectionSetup;

  /// No description provided for @autoDetectionSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'To automatically detect transactions, we need specific permissions. All banking and transaction apps will be monitored securely.'**
  String get autoDetectionSetupDesc;

  /// No description provided for @notificationAccess.
  ///
  /// In en, this message translates to:
  /// **'1. Notification Access'**
  String get notificationAccess;

  /// No description provided for @notificationAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Allows us to read transaction alerts from bank and payment apps.'**
  String get notificationAccessDesc;

  /// No description provided for @smsPermission.
  ///
  /// In en, this message translates to:
  /// **'2. SMS Permission'**
  String get smsPermission;

  /// No description provided for @smsPermissionDesc.
  ///
  /// In en, this message translates to:
  /// **'Enables reading transaction SMS from your bank.'**
  String get smsPermissionDesc;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish Setup'**
  String get finishSetup;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// No description provided for @appNameShort.
  ///
  /// In en, this message translates to:
  /// **'Aspends'**
  String get appNameShort;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Smart Money Management'**
  String get splashTagline;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @balanceDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance Details'**
  String get balanceDetailsTitle;

  /// No description provided for @editBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Balance'**
  String get editBalanceTitle;

  /// No description provided for @newBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'New Balance'**
  String get newBalanceLabel;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories or notes...'**
  String get searchHint;

  /// No description provided for @emptyWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Your wallet is quiet'**
  String get emptyWalletTitle;

  /// No description provided for @emptyWalletDesc.
  ///
  /// In en, this message translates to:
  /// **'Start by adding a transaction manually or enable auto-detection to track your spending effortlessly.'**
  String get emptyWalletDesc;

  /// No description provided for @addPerson.
  ///
  /// In en, this message translates to:
  /// **'Add Person'**
  String get addPerson;

  /// No description provided for @addNewPerson.
  ///
  /// In en, this message translates to:
  /// **'Add New Person'**
  String get addNewPerson;

  /// No description provided for @editPerson.
  ///
  /// In en, this message translates to:
  /// **'Edit Person'**
  String get editPerson;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @personName.
  ///
  /// In en, this message translates to:
  /// **'Person Name'**
  String get personName;

  /// No description provided for @youGet.
  ///
  /// In en, this message translates to:
  /// **'You Own'**
  String get youGet;

  /// No description provided for @youGive.
  ///
  /// In en, this message translates to:
  /// **'You Borrow'**
  String get youGive;

  /// No description provided for @youWillGet.
  ///
  /// In en, this message translates to:
  /// **'You will Own'**
  String get youWillGet;

  /// No description provided for @youWillGive.
  ///
  /// In en, this message translates to:
  /// **'You will Borrow'**
  String get youWillGive;

  /// No description provided for @noPeopleYet.
  ///
  /// In en, this message translates to:
  /// **'No people added yet'**
  String get noPeopleYet;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people...'**
  String get searchPeople;

  /// No description provided for @enterNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the person you want to track transactions with'**
  String get enterNameHint;

  /// No description provided for @updateDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Update the details for this person'**
  String get updateDetailsHint;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data records found'**
  String get noDataFound;

  /// No description provided for @appColor.
  ///
  /// In en, this message translates to:
  /// **'App Color'**
  String get appColor;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select a custom app color'**
  String get selectColor;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Aspends Tracker'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal finance companion'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your income, expenses, and manage your money with ease. Stay on top of your financial goals.'**
  String get welcomeDesc;

  /// No description provided for @smartTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Transaction Tracking'**
  String get smartTrackingTitle;

  /// No description provided for @smartTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your finances'**
  String get smartTrackingSubtitle;

  /// No description provided for @smartTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Categorize transactions, add notes, and get detailed insights into your spending patterns.'**
  String get smartTrackingDesc;

  /// No description provided for @peopleTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Person-to-Person Tracking'**
  String get peopleTrackingTitle;

  /// No description provided for @peopleTrackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage shared expenses'**
  String get peopleTrackingSubtitle;

  /// No description provided for @peopleTrackingDesc.
  ///
  /// In en, this message translates to:
  /// **'Track money you owe or are owed by others. Perfect for roommates, friends, and family.'**
  String get peopleTrackingDesc;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Analytics'**
  String get analyticsTitle;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visualize your data'**
  String get analyticsSubtitle;

  /// No description provided for @analyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Charts and graphs help you understand your spending habits and financial trends.'**
  String get analyticsDesc;

  /// No description provided for @offlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Fully Offline'**
  String get offlineTitle;

  /// No description provided for @offlineSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your data stays private'**
  String get offlineSubtitle;

  /// No description provided for @offlineDesc.
  ///
  /// In en, this message translates to:
  /// **'All your financial data is stored locally on your device. No internet required, complete privacy.'**
  String get offlineDesc;

  /// No description provided for @autoDetectTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Transaction Detection'**
  String get autoDetectTitle;

  /// No description provided for @autoDetectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart & Automated'**
  String get autoDetectSubtitle;

  /// No description provided for @autoDetectDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically detect transactions from banking notifications. No more manual entry - your transactions are captured instantly!'**
  String get autoDetectDesc;

  /// No description provided for @readyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Start?'**
  String get readyTitle;

  /// No description provided for @readySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s begin your journey'**
  String get readySubtitle;

  /// No description provided for @readyDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set! Start tracking your finances and take control of your money today.'**
  String get readyDesc;

  /// No description provided for @settingUpApp.
  ///
  /// In en, this message translates to:
  /// **'Setting up your app...'**
  String get settingUpApp;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @requestMoney.
  ///
  /// In en, this message translates to:
  /// **'Request Money'**
  String get requestMoney;

  /// No description provided for @generateQr.
  ///
  /// In en, this message translates to:
  /// **'Generate Payment QR'**
  String get generateQr;

  /// No description provided for @sortByNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortByNameAZ;

  /// No description provided for @sortByNameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get sortByNameZA;

  /// No description provided for @sortByBalanceHighest.
  ///
  /// In en, this message translates to:
  /// **'Balance (Highest)'**
  String get sortByBalanceHighest;

  /// No description provided for @sortByBalanceLowest.
  ///
  /// In en, this message translates to:
  /// **'Balance (Lowest)'**
  String get sortByBalanceLowest;

  /// No description provided for @upiIdNotSet.
  ///
  /// In en, this message translates to:
  /// **'UPI ID not set for this person. Please add it from edit.'**
  String get upiIdNotSet;

  /// No description provided for @couldNotFindUpiApp.
  ///
  /// In en, this message translates to:
  /// **'Could not find a UPI payment app'**
  String get couldNotFindUpiApp;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @addFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction with the person'**
  String get addFirstTransaction;

  /// No description provided for @settleBalance.
  ///
  /// In en, this message translates to:
  /// **'Settle Balance'**
  String get settleBalance;

  /// No description provided for @settleBalanceDesc.
  ///
  /// In en, this message translates to:
  /// **'This will add a transaction of ₹{amount} to bring the balance to zero. Continue?'**
  String settleBalanceDesc(String amount);

  /// No description provided for @settle.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get settle;

  /// No description provided for @deletePerson.
  ///
  /// In en, this message translates to:
  /// **'Delete Person'**
  String get deletePerson;

  /// No description provided for @deletePersonDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}? This action cannot be undone.'**
  String deletePersonDesc(String name);

  /// No description provided for @deleteTransactionDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteTransactionDesc;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @sortTransactionsBy.
  ///
  /// In en, this message translates to:
  /// **'Sort Transactions By'**
  String get sortTransactionsBy;

  /// No description provided for @sortByDateRecent.
  ///
  /// In en, this message translates to:
  /// **'Date (Recent)'**
  String get sortByDateRecent;

  /// No description provided for @sortByDateOldest.
  ///
  /// In en, this message translates to:
  /// **'Date (Oldest)'**
  String get sortByDateOldest;

  /// No description provided for @sortByAmountHighest.
  ///
  /// In en, this message translates to:
  /// **'Amount (Highest)'**
  String get sortByAmountHighest;

  /// No description provided for @sortByAmountLowest.
  ///
  /// In en, this message translates to:
  /// **'Amount (Lowest)'**
  String get sortByAmountLowest;

  /// No description provided for @rangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rangeAll;

  /// No description provided for @rangeDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get rangeDay;

  /// No description provided for @rangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get rangeMonth;

  /// No description provided for @rangeYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get rangeYear;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top Category'**
  String get topCategory;

  /// No description provided for @noSpending.
  ///
  /// In en, this message translates to:
  /// **'No spending'**
  String get noSpending;

  /// No description provided for @avgDailySpend.
  ///
  /// In en, this message translates to:
  /// **'Avg. Daily Spend'**
  String get avgDailySpend;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get perDay;

  /// No description provided for @monitoredApps.
  ///
  /// In en, this message translates to:
  /// **'Monitored Apps'**
  String get monitoredApps;

  /// No description provided for @searchAppsHint.
  ///
  /// In en, this message translates to:
  /// **'Search payment or banking apps...'**
  String get searchAppsHint;

  /// No description provided for @noEligibleApps.
  ///
  /// In en, this message translates to:
  /// **'No eligible apps found'**
  String get noEligibleApps;

  /// No description provided for @noAppsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No apps match your search'**
  String get noAppsMatchSearch;

  /// No description provided for @unknownApp.
  ///
  /// In en, this message translates to:
  /// **'Unknown App'**
  String get unknownApp;

  /// No description provided for @errorLoadingApps.
  ///
  /// In en, this message translates to:
  /// **'Error loading apps: {error}'**
  String errorLoadingApps(String error);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String selectedCount(int count);

  /// No description provided for @ignorePatternsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Ignore Patterns'**
  String get ignorePatternsTooltip;

  /// No description provided for @deleteSelectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelectedTooltip;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'This will delete all saved detection logs.'**
  String get clearHistoryDesc;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @transactionDetected.
  ///
  /// In en, this message translates to:
  /// **'Transaction Detected'**
  String get transactionDetected;

  /// No description provided for @notificationLogged.
  ///
  /// In en, this message translates to:
  /// **'Notification Logged'**
  String get notificationLogged;

  /// No description provided for @patternNotMatched.
  ///
  /// In en, this message translates to:
  /// **'Pattern not matched'**
  String get patternNotMatched;

  /// No description provided for @notificationDataTitle.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATION DATA'**
  String get notificationDataTitle;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'COPY'**
  String get copy;

  /// No description provided for @smsMessage.
  ///
  /// In en, this message translates to:
  /// **'SMS Message'**
  String get smsMessage;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @listeningHint.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listeningHint;

  /// No description provided for @keepSpeaking.
  ///
  /// In en, this message translates to:
  /// **'Keep speaking...'**
  String get keepSpeaking;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @fullBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Backup (JSON)'**
  String get fullBackupTitle;

  /// No description provided for @fullBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup all data to JSON'**
  String get fullBackupDesc;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup (JSON)'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore all data from JSON backup'**
  String get restoreBackupDesc;

  /// No description provided for @backupCompleted.
  ///
  /// In en, this message translates to:
  /// **'Backup completed!'**
  String get backupCompleted;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @restoreCompleted.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully!'**
  String get restoreCompleted;

  /// No description provided for @restoreFailedCancelled.
  ///
  /// In en, this message translates to:
  /// **'Restore failed or cancelled'**
  String get restoreFailedCancelled;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// No description provided for @pdfExported.
  ///
  /// In en, this message translates to:
  /// **'PDF exported successfully!'**
  String get pdfExported;

  /// No description provided for @pdfExportFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF export failed: {error}'**
  String pdfExportFailed(String error);

  /// No description provided for @peopleExported.
  ///
  /// In en, this message translates to:
  /// **'People data exported!'**
  String get peopleExported;

  /// No description provided for @peopleExportFailed.
  ///
  /// In en, this message translates to:
  /// **'People data export failed: {error}'**
  String peopleExportFailed(String error);

  /// No description provided for @allDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'All data deleted successfully!'**
  String get allDataDeleted;

  /// No description provided for @introReset.
  ///
  /// In en, this message translates to:
  /// **'Intro reset successfully!'**
  String get introReset;

  /// No description provided for @selectRestoreMode.
  ///
  /// In en, this message translates to:
  /// **'Select Restore Mode'**
  String get selectRestoreMode;

  /// No description provided for @restoreModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how to handle existing transaction records during data restore.'**
  String get restoreModeDesc;

  /// No description provided for @mergeSkipDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Merge & Skip Duplicates'**
  String get mergeSkipDuplicates;

  /// No description provided for @mergeSkipDesc.
  ///
  /// In en, this message translates to:
  /// **'Avoid duplicate entries while keeping all unique new items.'**
  String get mergeSkipDesc;

  /// No description provided for @overwriteConflicts.
  ///
  /// In en, this message translates to:
  /// **'Overwrite & Update Conflicts'**
  String get overwriteConflicts;

  /// No description provided for @overwriteConflictsDesc.
  ///
  /// In en, this message translates to:
  /// **'Replace existing transaction records with backup versions in case of conflicts.'**
  String get overwriteConflictsDesc;

  /// No description provided for @exportCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Transactions (CSV)'**
  String get exportCsvTitle;

  /// No description provided for @exportCsvDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your transactions to CSV'**
  String get exportCsvDesc;

  /// No description provided for @exportCsvSuccess.
  ///
  /// In en, this message translates to:
  /// **'Export completed successfully!'**
  String get exportCsvSuccess;

  /// No description provided for @exportCsvFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportCsvFailed(String error);

  /// No description provided for @exportPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Export People Data'**
  String get exportPeopleTitle;

  /// No description provided for @exportPeopleDesc.
  ///
  /// In en, this message translates to:
  /// **'Backup people transactions'**
  String get exportPeopleDesc;

  /// No description provided for @exportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportPdfTitle;

  /// No description provided for @exportPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF reports'**
  String get exportPdfDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'ja',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

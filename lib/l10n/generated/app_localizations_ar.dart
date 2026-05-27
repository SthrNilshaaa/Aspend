// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'يصعد';

  @override
  String get appTagline => 'الإنفاق الذكي، مبسط.';

  @override
  String get totalBalance => 'الرصيد الإجمالي';

  @override
  String get income => 'دخل';

  @override
  String get expense => 'حساب';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get transactions => 'المعاملات';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get seeAll => 'رؤية الكل';

  @override
  String get settings => 'إعدادات';

  @override
  String get language => 'لغة';

  @override
  String get theme => 'سمة';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get lightMode => 'وضع الضوء';

  @override
  String get systemDefault => 'النظام الافتراضي';

  @override
  String get adaptiveColor => 'اللون التكيفي';

  @override
  String get customColor => 'لون مخصص';

  @override
  String get backup => 'النسخ الاحتياطي والاستعادة';

  @override
  String get export => 'تصدير البيانات';

  @override
  String get import => 'استيراد البيانات';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get telegramSupport => 'دعم برقية';

  @override
  String get addTransaction => 'إضافة المعاملة';

  @override
  String get editTransaction => 'تحرير المعاملة';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get amount => 'كمية';

  @override
  String get category => 'فئة';

  @override
  String get account => 'حساب';

  @override
  String get date => 'تاريخ';

  @override
  String get note => 'ملاحظة (اختياري)';

  @override
  String get save => 'يحفظ';

  @override
  String get cancel => 'يلغي';

  @override
  String get delete => 'يمسح';

  @override
  String get search => 'بحث المعاملات...';

  @override
  String get noTransactions => 'لم يتم العثور على أي معاملات';

  @override
  String get voiceInput => 'الإدخال الصوتي';

  @override
  String get speechUnavailable => 'التعرف على الكلام غير متوفر';

  @override
  String get microPermissionDenied => 'تم رفض إذن الميكروفون';

  @override
  String get appearance => 'مظهر';

  @override
  String get security => 'حماية';

  @override
  String get autoDetection => 'الكشف التلقائي عن المعاملات';

  @override
  String get backupExport => 'النسخ الاحتياطي والتصدير';

  @override
  String get dataManagement => 'إدارة البيانات';

  @override
  String get budgetingBalance => 'الميزانية والتوازن';

  @override
  String get customDropdowns => 'العناصر المنسدلة المخصصة';

  @override
  String get appInformation => 'معلومات التطبيق';

  @override
  String get developedBy => 'تم تطويره بواسطة ❤️ بواسطة Sthrnilshaa';

  @override
  String get chooseTheme => 'اختر الموضوع المفضل لديك';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appLockDesc => 'يتطلب مصادقة الجهاز لفتح التطبيق';

  @override
  String get upiId => 'معرف واجهة الدفعات الموحدة (UPI).';

  @override
  String get upiIdDesc => 'قم بتعيين معرف UPI الخاص بك لطلبات الأموال';

  @override
  String get upiName => 'اسم العرض';

  @override
  String get upiNameDesc => 'اختياري: الاسم الموضح في طلب UPI';

  @override
  String get analytics => 'التحليلات';

  @override
  String get people => 'الناس';

  @override
  String get charts => 'الرسوم البيانية';

  @override
  String get sortBy => 'فرز حسب';

  @override
  String get holdToRecord => 'اضغط لتسجيل المعاملة';

  @override
  String get couldNotFindAmount =>
      'تعذر العثور على المبلغ. جرّب: \"أنفق 500 دولار على الطعام\"';

  @override
  String savedAmount(String amount, String category) {
    return 'تم حفظ $amount لـ $category';
  }

  @override
  String logsDeleted(int count) {
    return 'تم حذف $count من السجلات';
  }

  @override
  String patternsIgnored(int count) {
    return 'تم تجاهل أنماط $count بشكل دائم';
  }

  @override
  String get recheckComplete => 'اكتملت عملية إعادة الفحص';

  @override
  String get aboutApp => 'حول اسبندس';

  @override
  String get developerDesigner => 'المطور والمصمم';

  @override
  String get leadDesigner => 'المصمم الرئيسي';

  @override
  String get developer => 'المطور';

  @override
  String get supportLegal => 'الدعم والشؤون القانونية';

  @override
  String get privacyPolicyDesc => 'اقرأ وثيقة سياسة الخصوصية الخاصة بنا';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get telegramSupportDesc => 'انضم إلى Telegram للحصول على الدعم';

  @override
  String get projectInfo => 'معلومات المشروع';

  @override
  String get openSource => 'مفتوح المصدر';

  @override
  String get openSourceDesc => 'مصدر مفتوح بفخر على جيثب';

  @override
  String get rateApp => 'معدل تصاعدي';

  @override
  String get rateAppDesc => 'ادعمنا بتقييم 5 نجوم';

  @override
  String get howAspendWorks => 'كيف يعمل أسبيند';

  @override
  String get howItWorksTitle1 => '1. الاعتراض الذكي';

  @override
  String get howItWorksDesc1 =>
      'تستمع خدمة الخلفية الآمنة والمُحسّنة للبطارية إلى الرسائل النصية القصيرة والإشعارات المصرفية الواردة.';

  @override
  String get howItWorksTitle2 => '2. التحليل المحلي للسحابة الصفرية';

  @override
  String get howItWorksDesc2 =>
      'تقوم الخوارزميات الذكية غير المتصلة بالإنترنت باستخراج المبالغ والفئات والتجار على الفور - بنسبة 100% على جهازك.';

  @override
  String get howItWorksTitle3 => '3. الاسترداد التلقائي دون اتصال بالإنترنت';

  @override
  String get howItWorksDesc3 =>
      'في كل مرة تقوم فيها بفتح Aspend أو استئنافه، يقوم تلقائيًا بمسح سجل المعاملات المفقودة أثناء غيابك.';

  @override
  String get howItWorksTitle4 => '4. قفل الخصوصية المطلق';

  @override
  String get howItWorksDesc4 =>
      'لا توجد خوادم ولا طلبات الويب. تتم حماية بياناتك المالية محليًا داخل وحدة تخزين الخلية المشفرة.';

  @override
  String get autoDetectionSetup => 'إعداد الكشف التلقائي';

  @override
  String get autoDetectionSetupDesc =>
      'لاكتشاف المعاملات تلقائيًا، نحتاج إلى أذونات محددة. سيتم مراقبة جميع التطبيقات المصرفية والمعاملات بشكل آمن.';

  @override
  String get notificationAccess => '1. الوصول إلى الإخطار';

  @override
  String get notificationAccessDesc =>
      'يسمح لنا بقراءة تنبيهات المعاملات من تطبيقات البنك والدفع.';

  @override
  String get smsPermission => '2. إذن الرسائل القصيرة';

  @override
  String get smsPermissionDesc =>
      'تمكن من قراءة الرسائل القصيرة الخاصة بالمعاملات من البنك الذي تتعامل معه.';

  @override
  String get finishSetup => 'إنهاء الإعداد';

  @override
  String get grant => 'منحة';

  @override
  String get appNameShort => 'يصعد';

  @override
  String get splashTagline => 'إدارة الأموال الذكية';

  @override
  String get budget => 'ميزانية';

  @override
  String get balanceDetailsTitle => 'تفاصيل الرصيد';

  @override
  String get editBalanceTitle => 'تحرير الرصيد';

  @override
  String get newBalanceLabel => 'توازن جديد';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get searchHint => 'البحث في الفئات أو الملاحظات...';

  @override
  String get emptyWalletTitle => 'محفظتك هادئة';

  @override
  String get emptyWalletDesc =>
      'ابدأ بإضافة معاملة يدويًا أو قم بتمكين الاكتشاف التلقائي لتتبع إنفاقك دون عناء.';

  @override
  String get addPerson => 'إضافة شخص';

  @override
  String get addNewPerson => 'إضافة شخص جديد';

  @override
  String get editPerson => 'تحرير الشخص';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get personName => 'اسم الشخص';

  @override
  String get youGet => 'أنت تملك';

  @override
  String get youGive => 'أنت تقترض';

  @override
  String get youWillGet => 'سوف تمتلك';

  @override
  String get youWillGive => 'سوف تقترض';

  @override
  String get noPeopleYet => 'لم تتم إضافة أي أشخاص حتى الآن';

  @override
  String get searchPeople => 'بحث عن الناس...';

  @override
  String get enterNameHint => 'أدخل اسم الشخص الذي تريد متابعة المعاملات معه';

  @override
  String get updateDetailsHint => 'تحديث التفاصيل لهذا الشخص';

  @override
  String get expenses => 'نفقات';

  @override
  String get history => 'تاريخ';

  @override
  String get overview => 'ملخص';

  @override
  String get trends => 'الاتجاهات';

  @override
  String get categories => 'فئات';

  @override
  String get noDataFound => 'لم يتم العثور على سجلات البيانات';

  @override
  String get appColor => 'لون التطبيق';

  @override
  String get selectColor => 'حدد لون التطبيق المخصص';

  @override
  String get welcomeTitle => 'مرحبًا بك في Aspends Tracker';

  @override
  String get welcomeSubtitle => 'رفيقك المالي الشخصي';

  @override
  String get welcomeDesc =>
      'تتبع دخلك ونفقاتك وإدارة أموالك بكل سهولة. البقاء على رأس أهدافك المالية.';

  @override
  String get smartTrackingTitle => 'تتبع المعاملات الذكية';

  @override
  String get smartTrackingSubtitle => 'تنظيم اموالك';

  @override
  String get smartTrackingDesc =>
      'قم بتصنيف المعاملات وإضافة الملاحظات والحصول على رؤى تفصيلية حول أنماط الإنفاق الخاصة بك.';

  @override
  String get peopleTrackingTitle => 'تتبع من شخص لآخر';

  @override
  String get peopleTrackingSubtitle => 'إدارة النفقات المشتركة';

  @override
  String get peopleTrackingDesc =>
      'تتبع الأموال المستحقة عليك أو المستحقة على الآخرين. مثالية لزملاء السكن والأصدقاء والعائلة.';

  @override
  String get analyticsTitle => 'تحليلات جميلة';

  @override
  String get analyticsSubtitle => 'تصور البيانات الخاصة بك';

  @override
  String get analyticsDesc =>
      'تساعدك المخططات والرسوم البيانية على فهم عادات الإنفاق والاتجاهات المالية لديك.';

  @override
  String get offlineTitle => 'غير متصل بالكامل';

  @override
  String get offlineSubtitle => 'تظل بياناتك خاصة';

  @override
  String get offlineDesc =>
      'يتم تخزين جميع بياناتك المالية محليًا على جهازك. لا حاجة للإنترنت، خصوصية كاملة.';

  @override
  String get autoDetectTitle => 'الكشف التلقائي عن المعاملات';

  @override
  String get autoDetectSubtitle => 'ذكية وآلية';

  @override
  String get autoDetectDesc =>
      'كشف المعاملات تلقائيا من الإخطارات المصرفية. لا مزيد من الإدخال اليدوي - سيتم تسجيل معاملاتك على الفور!';

  @override
  String get readyTitle => 'هل أنت مستعد للبدء؟';

  @override
  String get readySubtitle => 'لنبدأ رحلتك';

  @override
  String get readyDesc =>
      'أنت جاهز تمامًا! ابدأ بتتبع أموالك وتحكم في أموالك اليوم.';

  @override
  String get settingUpApp => 'جارٍ إعداد تطبيقك...';

  @override
  String get skip => 'يتخطى';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get requestMoney => 'طلب المال';

  @override
  String get generateQr => 'إنشاء QR للدفع';

  @override
  String get sortByNameAZ => 'الاسم (أ-ي)';

  @override
  String get sortByNameZA => 'الاسم (ي-أ)';

  @override
  String get sortByBalanceHighest => 'الرصيد (الأعلى)';

  @override
  String get sortByBalanceLowest => 'الرصيد (الأدنى)';

  @override
  String get upiIdNotSet =>
      'لم يتم تعيين معرف UPI لهذا الشخص. الرجاء إضافتها من التحرير.';

  @override
  String get couldNotFindUpiApp => 'تعذر العثور على تطبيق دفع UPI';

  @override
  String get noTransactionsYet => 'لا توجد معاملات حتى الآن';

  @override
  String get addFirstTransaction => 'أضف معاملتك الأولى مع الشخص';

  @override
  String get settleBalance => 'تسوية الرصيد';

  @override
  String settleBalanceDesc(String amount) {
    return 'سيؤدي هذا إلى إضافة معاملة بقيمة ₹$amount ليصل الرصيد إلى الصفر. يكمل؟';
  }

  @override
  String get settle => 'يستقر';

  @override
  String get deletePerson => 'حذف الشخص';

  @override
  String deletePersonDesc(String name) {
    return 'هل أنت متأكد من رغبتك في حذف $name؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get deleteTransactionDesc => 'هل أنت متأكد أنك تريد حذف هذه المعاملة؟';

  @override
  String get update => 'تحديث';

  @override
  String get sortTransactionsBy => 'فرز المعاملات حسب';

  @override
  String get sortByDateRecent => 'التاريخ (الأخير)';

  @override
  String get sortByDateOldest => 'التاريخ (الأقدم)';

  @override
  String get sortByAmountHighest => 'المبلغ (الأعلى)';

  @override
  String get sortByAmountLowest => 'المبلغ (الأدنى)';

  @override
  String get rangeAll => 'الجميع';

  @override
  String get rangeDay => 'يوم';

  @override
  String get rangeWeek => 'أسبوع';

  @override
  String get rangeMonth => 'شهر';

  @override
  String get rangeYear => 'سنة';

  @override
  String get topCategory => 'الفئة الأعلى';

  @override
  String get noSpending => 'لا الإنفاق';

  @override
  String get avgDailySpend => 'متوسط الإنفاق اليومي';

  @override
  String get perDay => 'في اليوم الواحد';

  @override
  String get monitoredApps => 'التطبيقات المراقبة';

  @override
  String get searchAppsHint => 'البحث في تطبيقات الدفع أو الخدمات المصرفية...';

  @override
  String get noEligibleApps => 'لم يتم العثور على تطبيقات مؤهلة';

  @override
  String get noAppsMatchSearch => 'لا توجد تطبيقات تطابق بحثك';

  @override
  String get unknownApp => 'تطبيق غير معروف';

  @override
  String errorLoadingApps(String error) {
    return 'حدث خطأ أثناء تحميل التطبيقات: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count تم التحديد';
  }

  @override
  String get ignorePatternsTooltip => 'تجاهل الأنماط';

  @override
  String get deleteSelectedTooltip => 'حذف المحدد';

  @override
  String get clearHistoryTitle => 'مسح التاريخ؟';

  @override
  String get clearHistoryDesc => 'سيؤدي هذا إلى حذف كافة سجلات الكشف المحفوظة.';

  @override
  String get clear => 'واضح';

  @override
  String get transactionDetected => 'تم الكشف عن المعاملة';

  @override
  String get notificationLogged => 'تم تسجيل الإخطار';

  @override
  String get patternNotMatched => 'النمط غير متطابق';

  @override
  String get notificationDataTitle => 'بيانات الإخطار';

  @override
  String get copiedToClipboard => 'تم نسخ الرسالة إلى الحافظة';

  @override
  String get copy => 'ينسخ';

  @override
  String get smsMessage => 'رسالة نصية قصيرة';

  @override
  String get received => 'تلقى';

  @override
  String get paid => 'مدفوع';

  @override
  String get listeningHint => 'جاري الاستماع...';

  @override
  String get keepSpeaking => 'استمر في الحديث...';

  @override
  String get done => 'منتهي';

  @override
  String get fullBackupTitle => 'النسخ الاحتياطي الكامل (JSON)';

  @override
  String get fullBackupDesc => 'النسخ الاحتياطي لجميع البيانات إلى JSON';

  @override
  String get restoreBackupTitle => 'استعادة النسخة الاحتياطية (JSON)';

  @override
  String get restoreBackupDesc =>
      'استعادة كافة البيانات من النسخة الاحتياطية JSON';

  @override
  String get backupCompleted => 'اكتمل النسخ الاحتياطي!';

  @override
  String backupFailed(String error) {
    return 'فشل النسخ الاحتياطي: $error';
  }

  @override
  String get restoreCompleted => 'تمت استعادة البيانات بنجاح!';

  @override
  String get restoreFailedCancelled => 'فشلت عملية الاستعادة أو تم إلغاؤها';

  @override
  String restoreFailed(String error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String get pdfExported => 'تم تصدير ملف PDF بنجاح!';

  @override
  String pdfExportFailed(String error) {
    return 'فشل تصدير ملف PDF: $error';
  }

  @override
  String get peopleExported => 'تم تصدير بيانات الأشخاص!';

  @override
  String peopleExportFailed(String error) {
    return 'فشل تصدير بيانات الأشخاص: $error';
  }

  @override
  String get allDataDeleted => 'تم حذف كافة البيانات بنجاح!';

  @override
  String get introReset => 'تمت إعادة ضبط المقدمة بنجاح!';

  @override
  String get selectRestoreMode => 'حدد وضع الاستعادة';

  @override
  String get restoreModeDesc =>
      'اختر كيفية التعامل مع سجلات المعاملات الموجودة أثناء استعادة البيانات.';

  @override
  String get mergeSkipDuplicates => 'دمج وتخطي التكرارات';

  @override
  String get mergeSkipDesc =>
      'تجنب الإدخالات المكررة مع الاحتفاظ بجميع العناصر الجديدة الفريدة.';

  @override
  String get overwriteConflicts => 'الكتابة فوق وتحديث الصراعات';

  @override
  String get overwriteConflictsDesc =>
      'استبدل سجلات المعاملات الحالية بإصدارات احتياطية في حالة حدوث تعارضات.';

  @override
  String get exportCsvTitle => 'معاملات التصدير (CSV)';

  @override
  String get exportCsvDesc => 'تصدير المعاملات الخاصة بك إلى CSV';

  @override
  String get exportCsvSuccess => 'اكتمل التصدير بنجاح!';

  @override
  String exportCsvFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get exportPeopleTitle => 'تصدير بيانات الأشخاص';

  @override
  String get exportPeopleDesc => 'النسخ الاحتياطي للمعاملات الناس';

  @override
  String get exportPdfTitle => 'تصدير بصيغة PDF';

  @override
  String get exportPdfDesc => 'إنشاء تقارير PDF';
}

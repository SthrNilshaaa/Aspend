// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Aspends';

  @override
  String get appTagline => 'स्मार्ट खर्च, सरल बनाया गया।';

  @override
  String get totalBalance => 'कुल शेष';

  @override
  String get income => 'आय';

  @override
  String get expense => 'व्यय';

  @override
  String get monthlyBudget => 'मासिक बजट';

  @override
  String get transactions => 'लेन-देन';

  @override
  String get recentTransactions => 'हाल के लेन-देन';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get theme => 'थीम';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get systemDefault => 'सिस्टम डिफॉल्ट';

  @override
  String get adaptiveColor => 'अनुकूली रंग';

  @override
  String get customColor => 'कस्टम रंग';

  @override
  String get backup => 'बैकअप और रिस्टोर';

  @override
  String get export => 'डेटा निर्यात करें';

  @override
  String get import => 'डेटा आयात करें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get telegramSupport => 'टेलीग्राम सहायता';

  @override
  String get addTransaction => 'लेन-देन जोड़ें';

  @override
  String get editTransaction => 'लेन-देन संपादित करें';

  @override
  String get deleteTransaction => 'लेन-देन हटाएं';

  @override
  String get amount => 'राशि';

  @override
  String get category => 'श्रेणी';

  @override
  String get account => 'खाता';

  @override
  String get date => 'दिनांक';

  @override
  String get note => 'नोट (वैकल्पिक)';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get search => 'लेन-देन खोजें...';

  @override
  String get noTransactions => 'कोई लेन-देन नहीं मिला';

  @override
  String get voiceInput => 'वॉयस इनपुट';

  @override
  String get speechUnavailable => 'भाषण पहचान अनुपलब्ध';

  @override
  String get microPermissionDenied => 'माइक्रोफोन अनुमति अस्वीकार कर दी गई';

  @override
  String get appearance => 'दिखावट';

  @override
  String get security => 'सुरक्षा';

  @override
  String get autoDetection => 'ऑटो लेन-देन का पता लगाना';

  @override
  String get backupExport => 'बैकअप और निर्यात';

  @override
  String get dataManagement => 'डेटा प्रबंधन';

  @override
  String get budgetingBalance => 'बजट और शेष';

  @override
  String get customDropdowns => 'कस्टम ड्रॉपडाउन आइटम';

  @override
  String get appInformation => 'ऐप की जानकारी';

  @override
  String get developedBy => 'Sthrnilshaa द्वारा ❤️ के साथ विकसित';

  @override
  String get chooseTheme => 'अपनी पसंदीदा थीम चुनें';

  @override
  String get appLock => 'ऐप लॉक';

  @override
  String get appLockDesc => 'ऐप खोलने के लिए डिवाइस प्रमाणीकरण की आवश्यकता है';

  @override
  String get upiId => 'यूपीआई आईडी';

  @override
  String get upiIdDesc => 'पैसे के अनुरोध के लिए अपनी यूपीआई आईडी सेट करें';

  @override
  String get upiName => 'प्रदर्शित नाम';

  @override
  String get upiNameDesc => 'वैकल्पिक: यूपीआई अनुरोध में दिखाया गया नाम';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get people => 'लोग';

  @override
  String get charts => 'चार्ट';

  @override
  String get sortBy => 'इसके द्वारा क्रमबद्ध करें';

  @override
  String get holdToRecord => 'लेन-देन रिकॉर्ड करने के लिए दबाकर रखें';

  @override
  String get couldNotFindAmount =>
      'राशि नहीं मिली। कोशिश करें: \'भोजन पर 500 खर्च किए\'';

  @override
  String savedAmount(String amount, String category) {
    return '$category के लिए ₹$amount सहेजे गए';
  }

  @override
  String logsDeleted(int count) {
    return '$count लॉग हटा दिए गए';
  }

  @override
  String patternsIgnored(int count) {
    return 'स्थायी रूप से $count पैटर्न को अनदेखा कर दिया गया';
  }

  @override
  String get recheckComplete => 'पुनः जाँच पूर्ण';
}

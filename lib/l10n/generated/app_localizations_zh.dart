// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '阿斯彭德斯';

  @override
  String get appTagline => '智能支出，简化。';

  @override
  String get totalBalance => '总余额';

  @override
  String get income => '收入';

  @override
  String get expense => '费用';

  @override
  String get monthlyBudget => '每月预算';

  @override
  String get transactions => '交易';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get seeAll => '查看全部';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get darkMode => '深色模式';

  @override
  String get lightMode => '灯光模式';

  @override
  String get systemDefault => '系统默认值';

  @override
  String get adaptiveColor => '自适应颜色';

  @override
  String get customColor => '定制颜色';

  @override
  String get backup => '备份与恢复';

  @override
  String get export => '导出数据';

  @override
  String get import => '导入数据';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get telegramSupport => '电报支持';

  @override
  String get addTransaction => '添加交易';

  @override
  String get editTransaction => '编辑交易';

  @override
  String get deleteTransaction => '删除交易';

  @override
  String get amount => '数量';

  @override
  String get category => '类别';

  @override
  String get account => '帐户';

  @override
  String get date => '日期';

  @override
  String get note => '注意（可选）';

  @override
  String get save => '节省';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get search => '搜索交易...';

  @override
  String get noTransactions => '未找到交易';

  @override
  String get voiceInput => '语音输入';

  @override
  String get speechUnavailable => '语音识别不可用';

  @override
  String get microPermissionDenied => '麦克风权限被拒绝';

  @override
  String get appearance => '外貌';

  @override
  String get security => '安全';

  @override
  String get autoDetection => '自动交易检测';

  @override
  String get backupExport => '备份与导出';

  @override
  String get dataManagement => '数据管理';

  @override
  String get budgetingBalance => '预算与平衡';

  @override
  String get customDropdowns => '自定义下拉项';

  @override
  String get appInformation => '应用信息';

  @override
  String get developedBy => '由 Sthrnilshaa 与 ❤️ 一起开发';

  @override
  String get chooseTheme => '选择您喜欢的主题';

  @override
  String get appLock => '应用锁';

  @override
  String get appLockDesc => '需要设备身份验证才能打开应用程序';

  @override
  String get upiId => '统一识别​​码';

  @override
  String get upiIdDesc => '为付款请求设置您的 UPI ID';

  @override
  String get upiName => '显示名称';

  @override
  String get upiNameDesc => '可选：UPI 请求中显示的名称';

  @override
  String get analytics => '分析';

  @override
  String get people => '人们';

  @override
  String get charts => '图表';

  @override
  String get sortBy => '排序方式';

  @override
  String get holdToRecord => '按住记录交易';

  @override
  String get couldNotFindAmount => '找不到金额。尝试：“在食物上花了 500 美元”';

  @override
  String savedAmount(String amount, String category) {
    return '为 $category 节省了 卢比$amount';
  }

  @override
  String logsDeleted(int count) {
    return '已删除 $count 条日志';
  }

  @override
  String patternsIgnored(int count) {
    return '永久忽略 $count 模式';
  }

  @override
  String get recheckComplete => '复检完成';

  @override
  String get aboutApp => '关于阿斯彭德斯';

  @override
  String get developerDesigner => '开发商及设计师';

  @override
  String get leadDesigner => '首席设计师';

  @override
  String get developer => '开发商';

  @override
  String get supportLegal => '支持与法律';

  @override
  String get privacyPolicyDesc => '阅读我们的隐私政策文件';

  @override
  String get helpSupport => '帮助与支持';

  @override
  String get telegramSupportDesc => '加入我们的 Telegram 以获得支持';

  @override
  String get projectInfo => '项目信息';

  @override
  String get openSource => '开源';

  @override
  String get openSourceDesc => '自豪地在 GitHub 上开源';

  @override
  String get rateApp => '费率上升';

  @override
  String get rateAppDesc => '支持我们并给予 5 星评级';

  @override
  String get howAspendWorks => 'ASPEND 如何运作';

  @override
  String get howItWorksTitle1 => '1. 智能拦截';

  @override
  String get howItWorksDesc1 => '安全、电池优化的后台服务监听传入的短信和银行通知。';

  @override
  String get howItWorksTitle2 => '2. 零云本地解析';

  @override
  String get howItWorksDesc2 => '智能离线算法可在您的设备上 100% 即时提取金额、类别和商家。';

  @override
  String get howItWorksTitle3 => '3. 离线自动恢复';

  @override
  String get howItWorksDesc3 => '每次您打开或恢复 Aspend 时，它都会自动扫描历史记录以查找您不在期间错过的交易。';

  @override
  String get howItWorksTitle4 => '4.终极隐私锁';

  @override
  String get howItWorksDesc4 => '没有服务器，没有网络请求。您的财务数据在加密的 Hive 存储中受到本地保护。';

  @override
  String get autoDetectionSetup => '自动检测设置';

  @override
  String get autoDetectionSetupDesc =>
      '为了自动检测交易，我们需要特定的权限。所有银行和交易应用程序都将受到安全监控。';

  @override
  String get notificationAccess => '1. 通知访问';

  @override
  String get notificationAccessDesc => '允许我们读取来自银行和支付应用程序的交易警报。';

  @override
  String get smsPermission => '2.短信权限';

  @override
  String get smsPermissionDesc => '启用从银行读取交易短信。';

  @override
  String get finishSetup => '完成设置';

  @override
  String get grant => '授予';

  @override
  String get appNameShort => '阿斯彭德斯';

  @override
  String get splashTagline => '智能资金管理';

  @override
  String get budget => '预算';

  @override
  String get balanceDetailsTitle => '余额详情';

  @override
  String get editBalanceTitle => '编辑余额';

  @override
  String get newBalanceLabel => '新百伦';

  @override
  String get viewAll => '查看全部';

  @override
  String get searchHint => '搜索类别或注释...';

  @override
  String get emptyWalletTitle => '你的钱包很安静';

  @override
  String get emptyWalletDesc => '首先手动添加交易或启用自动检测以轻松跟踪您的支出。';

  @override
  String get addPerson => '添加人员';

  @override
  String get addNewPerson => '添加新人';

  @override
  String get editPerson => '编辑人物';

  @override
  String get addPhoto => '添加照片';

  @override
  String get personName => '人名';

  @override
  String get youGet => '你拥有';

  @override
  String get youGive => '你借';

  @override
  String get youWillGet => '你将拥有';

  @override
  String get youWillGive => '你会借';

  @override
  String get noPeopleYet => '尚未添加人员';

  @override
  String get searchPeople => '搜人...';

  @override
  String get enterNameHint => '输入您想要跟踪交易的人员的姓名';

  @override
  String get updateDetailsHint => '更新此人的详细信息';

  @override
  String get expenses => '开支';

  @override
  String get history => '历史';

  @override
  String get overview => '概述';

  @override
  String get trends => '趋势';

  @override
  String get categories => '类别';

  @override
  String get noDataFound => '没有找到数据记录';

  @override
  String get appColor => '应用程序颜色';

  @override
  String get selectColor => '选择自定义应用程序颜色';

  @override
  String get welcomeTitle => '欢迎来到阿斯彭德跟踪器';

  @override
  String get welcomeSubtitle => '您的个人理财伴侣';

  @override
  String get welcomeDesc => '跟踪您的收入、支出并轻松管理您的资金。掌控您的财务目标。';

  @override
  String get smartTrackingTitle => '智能交易追踪';

  @override
  String get smartTrackingSubtitle => '整理你的财务';

  @override
  String get smartTrackingDesc => '对交易进行分类、添加注释并详细了解您的支出模式。';

  @override
  String get peopleTrackingTitle => '人对人追踪';

  @override
  String get peopleTrackingSubtitle => '管理共享费用';

  @override
  String get peopleTrackingDesc => '跟踪您欠下的钱或别人欠下的钱。非常适合室友、朋友和家人。';

  @override
  String get analyticsTitle => '美丽的分析';

  @override
  String get analyticsSubtitle => '可视化您的数据';

  @override
  String get analyticsDesc => '图表和图表可帮助您了解您的消费习惯和财务趋势。';

  @override
  String get offlineTitle => '完全离线';

  @override
  String get offlineSubtitle => '您的数据保持私密';

  @override
  String get offlineDesc => '您的所有财务数据都存储在您的本地设备上。无需互联网，完全隐私。';

  @override
  String get autoDetectTitle => '自动交易检测';

  @override
  String get autoDetectSubtitle => '智能自动化';

  @override
  String get autoDetectDesc => '自动检测银行通知中的交易。不再需要手动输入 - 您的交易会立即被捕获！';

  @override
  String get readyTitle => '准备好开始了吗？';

  @override
  String get readySubtitle => '让我们开始你的旅程';

  @override
  String get readyDesc => '你都准备好了！从今天开始跟踪您的财务状况并掌控您的资金。';

  @override
  String get settingUpApp => '正在设置您的应用程序...';

  @override
  String get skip => '跳过';

  @override
  String get next => '下一个';

  @override
  String get getStarted => '开始使用';

  @override
  String get requestMoney => '索要钱';

  @override
  String get generateQr => '生成支付二维码';

  @override
  String get sortByNameAZ => '姓名（A-Z）';

  @override
  String get sortByNameZA => '姓名（Z-A）';

  @override
  String get sortByBalanceHighest => '余额（最高）';

  @override
  String get sortByBalanceLowest => '余额（最低）';

  @override
  String get upiIdNotSet => '未为此人设置 UPI ID。请从编辑中添加它。';

  @override
  String get couldNotFindUpiApp => '找不到 UPI 支付应用';

  @override
  String get noTransactionsYet => '还没有交易';

  @override
  String get addFirstTransaction => '添加您与此人的第一笔交易';

  @override
  String get settleBalance => '结算余额';

  @override
  String settleBalanceDesc(String amount) {
    return '这将添加 卢比$amount 的交易，使余额为零。继续？';
  }

  @override
  String get settle => '定居';

  @override
  String get deletePerson => '删除人员';

  @override
  String deletePersonDesc(String name) {
    return '您确定要删除$name吗？此操作无法撤消。';
  }

  @override
  String get deleteTransactionDesc => '您确定要删除此交易吗？';

  @override
  String get update => '更新';

  @override
  String get sortTransactionsBy => '交易排序依据';

  @override
  String get sortByDateRecent => '日期（最近）';

  @override
  String get sortByDateOldest => '日期（最早的）';

  @override
  String get sortByAmountHighest => '金额（最高）';

  @override
  String get sortByAmountLowest => '金额（最低）';

  @override
  String get rangeAll => '全部';

  @override
  String get rangeDay => '天';

  @override
  String get rangeWeek => '星期';

  @override
  String get rangeMonth => '月';

  @override
  String get rangeYear => '年';

  @override
  String get topCategory => '顶级类别';

  @override
  String get noSpending => '没有支出';

  @override
  String get avgDailySpend => '平均。每日消费';

  @override
  String get perDay => '每天';

  @override
  String get monitoredApps => '受监控的应用程序';

  @override
  String get searchAppsHint => '搜索支付或银行应用程序...';

  @override
  String get noEligibleApps => '找不到符合条件的应用程序';

  @override
  String get noAppsMatchSearch => '没有与您的搜索匹配的应用';

  @override
  String get unknownApp => '未知应用程序';

  @override
  String errorLoadingApps(String error) {
    return '加载应用程序时出错：$error';
  }

  @override
  String selectedCount(int count) {
    return '$count 已选择';
  }

  @override
  String get ignorePatternsTooltip => '忽略模式';

  @override
  String get deleteSelectedTooltip => '删除所选内容';

  @override
  String get clearHistoryTitle => '清除历史记录？';

  @override
  String get clearHistoryDesc => '这将删除所有保存的检测日志。';

  @override
  String get clear => '清除';

  @override
  String get transactionDetected => '检测到交易';

  @override
  String get notificationLogged => '已记录通知';

  @override
  String get patternNotMatched => '模式不匹配';

  @override
  String get notificationDataTitle => '通知数据';

  @override
  String get copiedToClipboard => '消息已复制到剪贴板';

  @override
  String get copy => '复制';

  @override
  String get smsMessage => '短信';

  @override
  String get received => '已收到';

  @override
  String get paid => '有薪酬的';

  @override
  String get listeningHint => '听...';

  @override
  String get keepSpeaking => '继续说...';

  @override
  String get done => '完毕';

  @override
  String get fullBackupTitle => '完整备份 (JSON)';

  @override
  String get fullBackupDesc => '备份所有数据到JSON';

  @override
  String get restoreBackupTitle => '恢复备份 (JSON)';

  @override
  String get restoreBackupDesc => '从 JSON 备份恢复所有数据';

  @override
  String get backupCompleted => '备份完成！';

  @override
  String backupFailed(String error) {
    return '备份失败：$error';
  }

  @override
  String get restoreCompleted => '数据恢复成功！';

  @override
  String get restoreFailedCancelled => '恢复失败或取消';

  @override
  String restoreFailed(String error) {
    return '恢复失败：$error';
  }

  @override
  String get pdfExported => 'PDF导出成功！';

  @override
  String pdfExportFailed(String error) {
    return 'PDF 导出失败：$error';
  }

  @override
  String get peopleExported => '人员数据导出！';

  @override
  String peopleExportFailed(String error) {
    return '人员数据导出失败：$error';
  }

  @override
  String get allDataDeleted => '全部数据删除成功！';

  @override
  String get introReset => '简介重置成功！';

  @override
  String get selectRestoreMode => '选择恢复模式';

  @override
  String get restoreModeDesc => '选择在数据恢复期间如何处理现有事务记录。';

  @override
  String get mergeSkipDuplicates => '合并和跳过重复项';

  @override
  String get mergeSkipDesc => '避免重复条目，同时保留所有独特的新项目。';

  @override
  String get overwriteConflicts => '覆盖和更新冲突';

  @override
  String get overwriteConflictsDesc => '如果发生冲突，请用备份版本替换现有事务记录。';

  @override
  String get exportCsvTitle => '出口交易 (CSV)';

  @override
  String get exportCsvDesc => '将您的交易导出为 CSV';

  @override
  String get exportCsvSuccess => '导出成功！';

  @override
  String exportCsvFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get exportPeopleTitle => '导出人员数据';

  @override
  String get exportPeopleDesc => '备份人员交易';

  @override
  String get exportPdfTitle => '导出为 PDF';

  @override
  String get exportPdfDesc => '生成 PDF 报告';
}

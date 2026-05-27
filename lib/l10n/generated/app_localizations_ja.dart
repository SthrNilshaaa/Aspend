// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'アスペンド';

  @override
  String get appTagline => '賢い支出をシンプルに。';

  @override
  String get totalBalance => '合計残高';

  @override
  String get income => '所得';

  @override
  String get expense => '費用';

  @override
  String get monthlyBudget => '月次予算';

  @override
  String get transactions => '取引';

  @override
  String get recentTransactions => '最近の取引';

  @override
  String get seeAll => 'すべて見る';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get theme => 'テーマ';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get lightMode => 'ライトモード';

  @override
  String get systemDefault => 'システムのデフォルト';

  @override
  String get adaptiveColor => 'アダプティブカラー';

  @override
  String get customColor => 'カスタムカラー';

  @override
  String get backup => 'バックアップと復元';

  @override
  String get export => 'データのエクスポート';

  @override
  String get import => 'データのインポート';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get telegramSupport => '電報サポート';

  @override
  String get addTransaction => 'トランザクションの追加';

  @override
  String get editTransaction => 'トランザクションの編集';

  @override
  String get deleteTransaction => 'トランザクションの削除';

  @override
  String get amount => '額';

  @override
  String get category => 'カテゴリ';

  @override
  String get account => 'アカウント';

  @override
  String get date => '日付';

  @override
  String get note => '注記 (オプション)';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '消去';

  @override
  String get search => 'トランザクションを検索...';

  @override
  String get noTransactions => 'トランザクションが見つかりませんでした';

  @override
  String get voiceInput => '音声入力';

  @override
  String get speechUnavailable => '音声認識は利用できません';

  @override
  String get microPermissionDenied => 'マイクの許可が拒否されました';

  @override
  String get appearance => '外観';

  @override
  String get security => '安全';

  @override
  String get autoDetection => '自動トランザクション検出';

  @override
  String get backupExport => 'バックアップとエクスポート';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get budgetingBalance => '予算とバランス';

  @override
  String get customDropdowns => 'カスタムドロップダウン項目';

  @override
  String get appInformation => 'アプリ情報';

  @override
  String get developedBy => 'Sthrnilshaa による ❤️ で開発されました';

  @override
  String get chooseTheme => '好みのテーマを選択してください';

  @override
  String get appLock => 'アプリロック';

  @override
  String get appLockDesc => 'アプリを開くにはデバイス認証が必要です';

  @override
  String get upiId => 'UPI ID';

  @override
  String get upiIdDesc => '送金リクエスト用の UPI ID を設定する';

  @override
  String get upiName => '表示名';

  @override
  String get upiNameDesc => 'オプション: UPI リクエストに表示される名前';

  @override
  String get analytics => '分析';

  @override
  String get people => '人々';

  @override
  String get charts => 'チャート';

  @override
  String get sortBy => '並べ替え';

  @override
  String get holdToRecord => '長押ししてトランザクションを記録する';

  @override
  String get couldNotFindAmount => '金額が見つかりませんでした。試してください: 「食費に 500 を費やしました」';

  @override
  String savedAmount(String amount, String category) {
    return '$category で ₹$amount を節約しました';
  }

  @override
  String logsDeleted(int count) {
    return '$count 個のログが削除されました';
  }

  @override
  String patternsIgnored(int count) {
    return '$count パターンを永久に無視します';
  }

  @override
  String get recheckComplete => '再チェック完了';

  @override
  String get aboutApp => 'アスペンズについて';

  @override
  String get developerDesigner => '開発者＆デザイナー';

  @override
  String get leadDesigner => 'リードデザイナー';

  @override
  String get developer => '開発者';

  @override
  String get supportLegal => 'サポートと法務';

  @override
  String get privacyPolicyDesc => '当社のプライバシーポリシー文書を読む';

  @override
  String get helpSupport => 'ヘルプとサポート';

  @override
  String get telegramSupportDesc => 'Telegram に参加してサポートを受けてください';

  @override
  String get projectInfo => 'プロジェクト情報';

  @override
  String get openSource => 'オープンソース';

  @override
  String get openSourceDesc => 'GitHub で堂々とオープンソース';

  @override
  String get rateApp => 'レートの上昇';

  @override
  String get rateAppDesc => '5 つ星の評価でサポートしてください';

  @override
  String get howAspendWorks => 'アスペンドの仕組み';

  @override
  String get howItWorksTitle1 => '1. インテリジェントな傍受';

  @override
  String get howItWorksDesc1 =>
      '安全でバッテリーが最適化されたバックグラウンド サービスは、SMS および銀行通知の受信を待機します。';

  @override
  String get howItWorksTitle2 => '2.ゼロクラウドローカル解析';

  @override
  String get howItWorksDesc2 =>
      'スマートなオフライン アルゴリズムにより、金額、カテゴリ、販売者が即座に、100% デバイス上で抽出されます。';

  @override
  String get howItWorksTitle3 => '3. オフライン自動回復';

  @override
  String get howItWorksDesc3 =>
      'Aspend を開いたり再開したりするたびに、不在中に見逃した取引の履歴が自動スキャンされます。';

  @override
  String get howItWorksTitle4 => '4.究極のプライバシーロック';

  @override
  String get howItWorksDesc4 =>
      'サーバーも Web リクエストもありません。財務データは、暗号化された Hive ストレージ内でローカルに保護されます。';

  @override
  String get autoDetectionSetup => '自動検出のセットアップ';

  @override
  String get autoDetectionSetupDesc =>
      'トランザクションを自動的に検出するには、特定の権限が必要です。すべてのバンキングおよびトランザクション アプリは安全に監視されます。';

  @override
  String get notificationAccess => '1. 通知へのアクセス';

  @override
  String get notificationAccessDesc => '銀行や支払いアプリからの取引アラートを読み取ることができます。';

  @override
  String get smsPermission => '2.SMSの許可';

  @override
  String get smsPermissionDesc => '銀行からのトランザクション SMS の読み取りを有効にします。';

  @override
  String get finishSetup => 'セットアップを完了する';

  @override
  String get grant => '付与';

  @override
  String get appNameShort => 'アスペンド';

  @override
  String get splashTagline => 'スマートなお金の管理';

  @override
  String get budget => '予算';

  @override
  String get balanceDetailsTitle => '残高詳細';

  @override
  String get editBalanceTitle => '残高の編集';

  @override
  String get newBalanceLabel => 'ニューバランス';

  @override
  String get viewAll => 'すべて見る';

  @override
  String get searchHint => 'カテゴリまたはメモを検索...';

  @override
  String get emptyWalletTitle => 'あなたの財布は静かです';

  @override
  String get emptyWalletDesc => 'まずトランザクションを手動で追加するか、自動検出を有効にして支出を簡単に追跡します。';

  @override
  String get addPerson => '人物を追加';

  @override
  String get addNewPerson => '新しい人を追加';

  @override
  String get editPerson => '人物の編集';

  @override
  String get addPhoto => '写真を追加';

  @override
  String get personName => '人名';

  @override
  String get youGet => 'あなたが所有する';

  @override
  String get youGive => 'あなたが借りる';

  @override
  String get youWillGet => 'あなたが所有するでしょう';

  @override
  String get youWillGive => 'あなたは借ります';

  @override
  String get noPeopleYet => 'まだ人が追加されていません';

  @override
  String get searchPeople => '人を検索...';

  @override
  String get enterNameHint => '取引を追跡したい人の名前を入力してください';

  @override
  String get updateDetailsHint => 'この人の詳細を更新します';

  @override
  String get expenses => '経費';

  @override
  String get history => '歴史';

  @override
  String get overview => '概要';

  @override
  String get trends => 'トレンド';

  @override
  String get categories => 'カテゴリー';

  @override
  String get noDataFound => 'データレコードが見つかりませんでした';

  @override
  String get appColor => 'アプリの色';

  @override
  String get selectColor => 'カスタムアプリの色を選択してください';

  @override
  String get welcomeTitle => 'アスペンズトラッカーへようこそ';

  @override
  String get welcomeSubtitle => 'あなたのパーソナルファイナンスパートナー';

  @override
  String get welcomeDesc => '収入と支出を追跡し、お金を簡単に管理します。財務目標を常に把握しましょう。';

  @override
  String get smartTrackingTitle => 'スマートなトランザクション追跡';

  @override
  String get smartTrackingSubtitle => '財務を整理する';

  @override
  String get smartTrackingDesc => '取引を分類し、メモを追加し、支出パターンに関する詳細な洞察を取得します。';

  @override
  String get peopleTrackingTitle => '個人間の追跡';

  @override
  String get peopleTrackingSubtitle => '共有経費を管理する';

  @override
  String get peopleTrackingDesc =>
      'あなたが借りているお金、または他人が借りているお金を追跡します。ルームメイト、友人、家族に最適です。';

  @override
  String get analyticsTitle => '美しい分析';

  @override
  String get analyticsSubtitle => 'データを視覚化する';

  @override
  String get analyticsDesc => 'チャートやグラフは、支出習慣や財務傾向を理解するのに役立ちます。';

  @override
  String get offlineTitle => '完全にオフライン';

  @override
  String get offlineSubtitle => 'データは機密性を保ちます';

  @override
  String get offlineDesc =>
      'すべての財務データはデバイス上にローカルに保存されます。インターネットは不要で、完全なプライバシーが保たれます。';

  @override
  String get autoDetectTitle => '自動トランザクション検出';

  @override
  String get autoDetectSubtitle => 'スマートかつ自動化';

  @override
  String get autoDetectDesc =>
      '銀行通知からトランザクションを自動的に検出します。手動入力はもう必要ありません - 取引は即座に記録されます。';

  @override
  String get readyTitle => '始める準備はできていますか?';

  @override
  String get readySubtitle => '旅を始めましょう';

  @override
  String get readyDesc => '準備は完了です!今すぐ家計の追跡を始めて、お金を管理しましょう。';

  @override
  String get settingUpApp => 'アプリをセットアップしています...';

  @override
  String get skip => 'スキップ';

  @override
  String get next => '次';

  @override
  String get getStarted => '始めましょう';

  @override
  String get requestMoney => 'お金を要求する';

  @override
  String get generateQr => '支払いQRの生成';

  @override
  String get sortByNameAZ => '名前 (A ～ Z)';

  @override
  String get sortByNameZA => '名前 (Z-A)';

  @override
  String get sortByBalanceHighest => 'バランス（最高）';

  @override
  String get sortByBalanceLowest => '残高（最低）';

  @override
  String get upiIdNotSet => 'この人には UPI ID が設定されていません。編集から追加してください。';

  @override
  String get couldNotFindUpiApp => 'UPI 支払いアプリが見つかりませんでした';

  @override
  String get noTransactionsYet => 'まだ取引はありません';

  @override
  String get addFirstTransaction => 'その人との最初のトランザクションを追加します';

  @override
  String get settleBalance => '残高の決済';

  @override
  String settleBalanceDesc(String amount) {
    return 'これにより、₹$amount のトランザクションが追加され、残高がゼロになります。続く？';
  }

  @override
  String get settle => '解決する';

  @override
  String get deletePerson => '個人の削除';

  @override
  String deletePersonDesc(String name) {
    return '$name を削除してもよろしいですか?この操作は元に戻すことができません。';
  }

  @override
  String get deleteTransactionDesc => 'このトランザクションを削除してもよろしいですか?';

  @override
  String get update => 'アップデート';

  @override
  String get sortTransactionsBy => 'トランザクションの並べ替え基準';

  @override
  String get sortByDateRecent => '日付 (最近)';

  @override
  String get sortByDateOldest => '日付 (最も古いもの)';

  @override
  String get sortByAmountHighest => '金額（最高額）';

  @override
  String get sortByAmountLowest => '金額（最低額）';

  @override
  String get rangeAll => '全て';

  @override
  String get rangeDay => '日';

  @override
  String get rangeWeek => '週';

  @override
  String get rangeMonth => '月';

  @override
  String get rangeYear => '年';

  @override
  String get topCategory => 'トップカテゴリー';

  @override
  String get noSpending => '支出なし';

  @override
  String get avgDailySpend => '平均毎日の支出';

  @override
  String get perDay => '1日あたり';

  @override
  String get monitoredApps => '監視対象アプリ';

  @override
  String get searchAppsHint => '支払いアプリや銀行アプリを検索...';

  @override
  String get noEligibleApps => '対象となるアプリが見つかりませんでした';

  @override
  String get noAppsMatchSearch => '検索に一致するアプリはありません';

  @override
  String get unknownApp => '不明なアプリ';

  @override
  String errorLoadingApps(String error) {
    return 'アプリの読み込みエラー: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count 個が選択されました';
  }

  @override
  String get ignorePatternsTooltip => 'パターンを無視する';

  @override
  String get deleteSelectedTooltip => '選択したものを削除';

  @override
  String get clearHistoryTitle => '履歴をクリアしますか?';

  @override
  String get clearHistoryDesc => 'これにより、保存されているすべての検出ログが削除されます。';

  @override
  String get clear => 'クリア';

  @override
  String get transactionDetected => 'トランザクションが検出されました';

  @override
  String get notificationLogged => '通知が記録されました';

  @override
  String get patternNotMatched => 'パターンが一致しません';

  @override
  String get notificationDataTitle => '通知データ';

  @override
  String get copiedToClipboard => 'メッセージがクリップボードにコピーされました';

  @override
  String get copy => 'コピー';

  @override
  String get smsMessage => 'SMSメッセージ';

  @override
  String get received => '受け取った';

  @override
  String get paid => '有料';

  @override
  String get listeningHint => 'リスニング...';

  @override
  String get keepSpeaking => '話し続けてください...';

  @override
  String get done => '終わり';

  @override
  String get fullBackupTitle => 'フルバックアップ(JSON)';

  @override
  String get fullBackupDesc => 'すべてのデータを JSON にバックアップする';

  @override
  String get restoreBackupTitle => 'バックアップの復元 (JSON)';

  @override
  String get restoreBackupDesc => 'JSONバックアップからすべてのデータを復元します';

  @override
  String get backupCompleted => 'バックアップが完了しました！';

  @override
  String backupFailed(String error) {
    return 'バックアップに失敗しました: $error';
  }

  @override
  String get restoreCompleted => 'データは無事復元されました！';

  @override
  String get restoreFailedCancelled => '復元が失敗したか、キャンセルされました';

  @override
  String restoreFailed(String error) {
    return '復元に失敗しました: $error';
  }

  @override
  String get pdfExported => 'PDF が正常にエクスポートされました。';

  @override
  String pdfExportFailed(String error) {
    return 'PDF のエクスポートに失敗しました: $error';
  }

  @override
  String get peopleExported => '人物データがエクスポートされました!';

  @override
  String peopleExportFailed(String error) {
    return '人物データのエクスポートに失敗しました: $error';
  }

  @override
  String get allDataDeleted => 'すべてのデータが正常に削除されました。';

  @override
  String get introReset => 'イントロリセット成功！';

  @override
  String get selectRestoreMode => '復元モードの選択';

  @override
  String get restoreModeDesc => 'データの復元中に既存のトランザクション レコードを処理する方法を選択します。';

  @override
  String get mergeSkipDuplicates => '重複のマージとスキップ';

  @override
  String get mergeSkipDesc => 'すべての一意の新しいアイテムを維持しながら、重複したエントリを回避します。';

  @override
  String get overwriteConflicts => '上書きと更新の競合';

  @override
  String get overwriteConflictsDesc =>
      '競合が発生した場合に備えて、既存のトランザクション レコードをバックアップ バージョンに置き換えます。';

  @override
  String get exportCsvTitle => 'トランザクションのエクスポート (CSV)';

  @override
  String get exportCsvDesc => 'トランザクションを CSV にエクスポートする';

  @override
  String get exportCsvSuccess => 'エクスポートは正常に完了しました。';

  @override
  String exportCsvFailed(String error) {
    return 'エクスポートに失敗しました: $error';
  }

  @override
  String get exportPeopleTitle => '人物データのエクスポート';

  @override
  String get exportPeopleDesc => '人のトランザクションをバックアップする';

  @override
  String get exportPdfTitle => 'PDFとしてエクスポート';

  @override
  String get exportPdfDesc => 'PDF レポートを生成する';
}

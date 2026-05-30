// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Аспендирует';

  @override
  String get appTagline => 'Разумные траты, упрощенные.';

  @override
  String get totalBalance => 'Общий баланс';

  @override
  String get income => 'Доход';

  @override
  String get expense => 'Расход';

  @override
  String get monthlyBudget => 'Ежемесячный бюджет';

  @override
  String get transactions => 'Транзакции';

  @override
  String get recentTransactions => 'Недавние транзакции';

  @override
  String get seeAll => 'Посмотреть все';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get darkMode => 'Темный режим';

  @override
  String get lightMode => 'Светлый режим';

  @override
  String get systemDefault => 'Системные настройки по умолчанию';

  @override
  String get adaptiveColor => 'Адаптивный цвет';

  @override
  String get customColor => 'Пользовательский цвет';

  @override
  String get backup => 'Резервное копирование и восстановление';

  @override
  String get export => 'Экспортировать данные';

  @override
  String get import => 'Импортировать данные';

  @override
  String get privacyPolicy => 'политика конфиденциальности';

  @override
  String get telegramSupport => 'Поддержка Телеграм';

  @override
  String get addTransaction => 'Добавить транзакцию';

  @override
  String get editTransaction => 'Редактировать транзакцию';

  @override
  String get deleteTransaction => 'Удалить транзакцию';

  @override
  String get amount => 'Количество';

  @override
  String get category => 'Категория';

  @override
  String get account => 'Счет';

  @override
  String get date => 'Дата';

  @override
  String get note => 'Примечание (необязательно)';

  @override
  String get save => 'Сохранять';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get search => 'Поиск транзакций...';

  @override
  String get noTransactions => 'Транзакции не найдены';

  @override
  String get voiceInput => 'Голосовой ввод';

  @override
  String get speechUnavailable => 'Распознавание речи недоступно';

  @override
  String get microPermissionDenied =>
      'Разрешение на использование микрофона отклонено';

  @override
  String get appearance => 'Появление';

  @override
  String get security => 'Безопасность';

  @override
  String get autoDetection => 'Автоматическое обнаружение транзакций';

  @override
  String get backupExport => 'Резервное копирование и экспорт';

  @override
  String get dataManagement => 'Управление данными';

  @override
  String get budgetingBalance => 'Бюджетирование и баланс';

  @override
  String get customDropdowns => 'Пользовательские раскрывающиеся элементы';

  @override
  String get appInformation => 'Информация о приложении';

  @override
  String get developedBy => 'Разработано с ❤️ автором Sthrnilshaa';

  @override
  String get chooseTheme => 'Выберите предпочитаемую тему';

  @override
  String get appLock => 'Блокировка приложения';

  @override
  String get appLockDesc =>
      'Требовать аутентификацию устройства для открытия приложения';

  @override
  String get upiId => 'идентификатор УПИ';

  @override
  String get upiIdDesc =>
      'Установите свой идентификатор UPI для запросов денег';

  @override
  String get upiName => 'Отображаемое имя';

  @override
  String get upiNameDesc => 'Необязательно: имя, отображаемое в запросе UPI.';

  @override
  String get analytics => 'Аналитика';

  @override
  String get people => 'Люди';

  @override
  String get charts => 'Графики';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get holdToRecord => 'Удерживайте, чтобы записать транзакцию';

  @override
  String get couldNotFindAmount =>
      'Не удалось найти сумму. Попробуйте: «Потратил 500 на еду»';

  @override
  String savedAmount(String amount, String category) {
    return 'Сохранено ₹$amount для $category';
  }

  @override
  String logsDeleted(int count) {
    return 'Удалено $count логов';
  }

  @override
  String patternsIgnored(int count) {
    return 'Постоянно игнорируемые шаблоны: $count';
  }

  @override
  String get recheckComplete => 'Повторная проверка завершена';

  @override
  String get aboutApp => 'О Аспенде';

  @override
  String get developerDesigner => 'Разработчик и дизайнер';

  @override
  String get leadDesigner => 'Ведущий дизайнер';

  @override
  String get developer => 'Разработчик';

  @override
  String get supportLegal => 'Поддержка и юридическая поддержка';

  @override
  String get privacyPolicyDesc =>
      'Прочтите наш документ о политике конфиденциальности';

  @override
  String get helpSupport => 'Помощь и поддержка';

  @override
  String get telegramSupportDesc =>
      'Присоединяйтесь к нашему Telegram для поддержки';

  @override
  String get projectInfo => 'Информация о проекте';

  @override
  String get openSource => 'Открытый исходный код';

  @override
  String get openSourceDesc => 'С гордостью открытый исходный код на GitHub';

  @override
  String get rateApp => 'Ставка расходов';

  @override
  String get rateAppDesc => 'Поддержите нас, поставив 5-звездочный рейтинг';

  @override
  String get howAspendWorks => 'КАК РАБОТАЕТ АСПЕНД';

  @override
  String get howItWorksTitle1 => '1. Интеллектуальный перехват';

  @override
  String get howItWorksDesc1 =>
      'Безопасная фоновая служба, оптимизированная для работы от аккумулятора, прослушивает входящие SMS и банковские уведомления.';

  @override
  String get howItWorksTitle2 => '2. Локальный анализ без облака';

  @override
  String get howItWorksDesc2 =>
      'Умные оффлайн-алгоритмы мгновенно извлекают суммы, категории и продавцов — 100% на вашем устройстве.';

  @override
  String get howItWorksTitle3 => '3. Автономное автоматическое восстановление';

  @override
  String get howItWorksDesc3 =>
      'Каждый раз, когда вы открываете или возобновляете работу Aspend, он автоматически сканирует историю на предмет пропущенных транзакций во время вашего отсутствия.';

  @override
  String get howItWorksTitle4 => '4. Полная блокировка конфиденциальности';

  @override
  String get howItWorksDesc4 =>
      'Никаких серверов, никаких веб-запросов. Ваши финансовые данные защищены локально в зашифрованном хранилище Hive.';

  @override
  String get autoDetectionSetup => 'Настройка автоматического обнаружения';

  @override
  String get autoDetectionSetupDesc =>
      'Для автоматического обнаружения транзакций нам нужны определенные разрешения. Все банковские и транзакционные приложения будут надежно контролироваться.';

  @override
  String get notificationAccess => '1. Доступ к уведомлениям';

  @override
  String get notificationAccessDesc =>
      'Позволяет нам читать оповещения о транзакциях из банковских и платежных приложений.';

  @override
  String get smsPermission => '2. Разрешение по СМС';

  @override
  String get smsPermissionDesc =>
      'Позволяет читать транзакционные SMS от вашего банка.';

  @override
  String get finishSetup => 'Завершить настройку';

  @override
  String get grant => 'Грант';

  @override
  String get appNameShort => 'Аспендирует';

  @override
  String get splashTagline => 'Умное управление деньгами';

  @override
  String get budget => 'Бюджет';

  @override
  String get balanceDetailsTitle => 'Детали баланса';

  @override
  String get editBalanceTitle => 'Изменить баланс';

  @override
  String get newBalanceLabel => 'Новый Баланс';

  @override
  String get viewAll => 'Посмотреть все';

  @override
  String get searchHint => 'Поиск по категориям или заметкам...';

  @override
  String get emptyWalletTitle => 'Ваш кошелек молчит';

  @override
  String get emptyWalletDesc =>
      'Начните с добавления транзакции вручную или включите автоматическое обнаружение, чтобы легко отслеживать свои расходы.';

  @override
  String get addPerson => 'Добавить человека';

  @override
  String get addNewPerson => 'Добавить нового человека';

  @override
  String get editPerson => 'Редактировать человека';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get personName => 'Имя человека';

  @override
  String get youGet => 'Вы владеете';

  @override
  String get youGive => 'Вы берете взаймы';

  @override
  String get youWillGet => 'Вы будете владеть';

  @override
  String get youWillGive => 'Вы будете брать взаймы';

  @override
  String get noPeopleYet => 'Никто еще не добавил людей';

  @override
  String get searchPeople => 'Поиск людей...';

  @override
  String get enterNameHint =>
      'Введите имя человека, с которым вы хотите отслеживать транзакции';

  @override
  String get updateDetailsHint => 'Обновить данные этого человека';

  @override
  String get expenses => 'Затраты';

  @override
  String get history => 'История';

  @override
  String get overview => 'Обзор';

  @override
  String get trends => 'Тенденции';

  @override
  String get categories => 'Категории';

  @override
  String get noDataFound => 'Записи данных не найдены';

  @override
  String get appColor => 'Цвет приложения';

  @override
  String get selectColor => 'Выберите собственный цвет приложения';

  @override
  String get welcomeTitle => 'Добро пожаловать в Aspends Tracker';

  @override
  String get welcomeSubtitle => 'Ваш личный финансовый помощник';

  @override
  String get welcomeDesc =>
      'Отслеживайте свои доходы, расходы и с легкостью управляйте своими деньгами. Будьте в курсе своих финансовых целей.';

  @override
  String get smartTrackingTitle => 'Интеллектуальное отслеживание транзакций';

  @override
  String get smartTrackingSubtitle => 'Организуйте свои финансы';

  @override
  String get smartTrackingDesc =>
      'Классифицируйте транзакции, добавляйте примечания и получайте подробную информацию о своей структуре расходов.';

  @override
  String get peopleTrackingTitle => 'Индивидуальное отслеживание';

  @override
  String get peopleTrackingSubtitle => 'Управляйте общими расходами';

  @override
  String get peopleTrackingDesc =>
      'Отслеживайте деньги, которые вы должны или вам должны другие. Идеально подходит для соседей по комнате, друзей и семьи.';

  @override
  String get analyticsTitle => 'Красивая аналитика';

  @override
  String get analyticsSubtitle => 'Визуализируйте свои данные';

  @override
  String get analyticsDesc =>
      'Диаграммы и графики помогут вам понять ваши привычки расходования средств и финансовые тенденции.';

  @override
  String get offlineTitle => 'Полностью оффлайн';

  @override
  String get offlineSubtitle => 'Ваши данные остаются конфиденциальными';

  @override
  String get offlineDesc =>
      'Все ваши финансовые данные хранятся локально на вашем устройстве. Интернет не требуется, полная конфиденциальность.';

  @override
  String get autoDetectTitle => 'Автоматическое обнаружение транзакций';

  @override
  String get autoDetectSubtitle => 'Умный и автоматизированный';

  @override
  String get autoDetectDesc =>
      'Автоматически обнаруживайте транзакции из банковских уведомлений. Больше никакого ручного ввода — ваши транзакции фиксируются мгновенно!';

  @override
  String get readyTitle => 'Готовы начать?';

  @override
  String get readySubtitle => 'Давайте начнем ваше путешествие';

  @override
  String get readyDesc =>
      'Все готово! Начните отслеживать свои финансы и возьмите под контроль свои деньги уже сегодня.';

  @override
  String get settingUpApp => 'Настройка приложения...';

  @override
  String get skip => 'Пропускать';

  @override
  String get next => 'Следующий';

  @override
  String get getStarted => 'Начать';

  @override
  String get requestMoney => 'Запросить деньги';

  @override
  String get generateQr => 'Создать платежный QR-код';

  @override
  String get sortByNameAZ => 'Имя (А-Я)';

  @override
  String get sortByNameZA => 'Имя (Я-А)';

  @override
  String get sortByBalanceHighest => 'Баланс (самый высокий)';

  @override
  String get sortByBalanceLowest => 'Баланс (самый низкий)';

  @override
  String get upiIdNotSet =>
      'Идентификатор UPI не установлен для этого человека. Пожалуйста, добавьте его из редактирования.';

  @override
  String get couldNotFindUpiApp => 'Не удалось найти платежное приложение UPI.';

  @override
  String get noTransactionsYet => 'Транзакций пока нет';

  @override
  String get addFirstTransaction =>
      'Добавьте свою первую транзакцию с человеком';

  @override
  String get settleBalance => 'Погасить баланс';

  @override
  String settleBalanceDesc(String amount) {
    return 'Это добавит транзакцию на сумму ₹$amount чтобы свести баланс к нулю. Продолжать?';
  }

  @override
  String get settle => 'Решить';

  @override
  String get deletePerson => 'Удалить человека';

  @override
  String deletePersonDesc(String name) {
    return 'Вы уверены, что хотите удалить $name? Это действие невозможно отменить.';
  }

  @override
  String get deleteTransactionDesc =>
      'Вы уверены, что хотите удалить эту транзакцию?';

  @override
  String get update => 'Обновлять';

  @override
  String get sortTransactionsBy => 'Сортировать транзакции по';

  @override
  String get sortByDateRecent => 'Дата (недавняя)';

  @override
  String get sortByDateOldest => 'Дата (самая старая)';

  @override
  String get sortByAmountHighest => 'Сумма (максимальная)';

  @override
  String get sortByAmountLowest => 'Сумма (самая низкая)';

  @override
  String get rangeAll => 'Все';

  @override
  String get rangeDay => 'День';

  @override
  String get rangeWeek => 'Неделя';

  @override
  String get rangeMonth => 'Месяц';

  @override
  String get rangeYear => 'Год';

  @override
  String get topCategory => 'Высшая категория';

  @override
  String get noSpending => 'Нет расходов';

  @override
  String get avgDailySpend => 'Среднее Ежедневные расходы';

  @override
  String get perDay => 'в день';

  @override
  String get monitoredApps => 'Контролируемые приложения';

  @override
  String get searchAppsHint => 'Поиск платежных или банковских приложений...';

  @override
  String get noEligibleApps => 'Подходящие приложения не найдены';

  @override
  String get noAppsMatchSearch =>
      'Нет приложений, соответствующих вашему запросу';

  @override
  String get unknownApp => 'Неизвестное приложение';

  @override
  String errorLoadingApps(String error) {
    return 'Ошибка загрузки приложений: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count Выбрано';
  }

  @override
  String get ignorePatternsTooltip => 'Игнорировать шаблоны';

  @override
  String get deleteSelectedTooltip => 'Удалить выбранное';

  @override
  String get clearHistoryTitle => 'Очистить историю?';

  @override
  String get clearHistoryDesc =>
      'При этом будут удалены все сохраненные журналы обнаружения.';

  @override
  String get clear => 'Прозрачный';

  @override
  String get transactionDetected => 'Транзакция обнаружена';

  @override
  String get notificationLogged => 'Уведомление зарегистрировано';

  @override
  String get patternNotMatched => 'Шаблон не совпадает';

  @override
  String get notificationDataTitle => 'ДАННЫЕ УВЕДОМЛЕНИЯ';

  @override
  String get copiedToClipboard => 'Сообщение скопировано в буфер обмена';

  @override
  String get copy => 'КОПИРОВАТЬ';

  @override
  String get smsMessage => 'SMS-сообщение';

  @override
  String get received => 'Полученный';

  @override
  String get paid => 'Оплаченный';

  @override
  String get listeningHint => 'Слушаю...';

  @override
  String get keepSpeaking => 'Продолжайте говорить...';

  @override
  String get done => 'Сделанный';

  @override
  String get fullBackupTitle => 'Полное резервное копирование (JSON)';

  @override
  String get fullBackupDesc => 'Резервное копирование всех данных в JSON';

  @override
  String get restoreBackupTitle => 'Восстановить резервную копию (JSON)';

  @override
  String get restoreBackupDesc =>
      'Восстановить все данные из резервной копии JSON';

  @override
  String get backupCompleted => 'Резервное копирование завершено!';

  @override
  String backupFailed(String error) {
    return 'Не удалось выполнить резервное копирование: $error';
  }

  @override
  String get restoreCompleted => 'Данные успешно восстановлены!';

  @override
  String get restoreFailedCancelled =>
      'Восстановление не выполнено или отменено';

  @override
  String restoreFailed(String error) {
    return 'Не удалось восстановить: $error';
  }

  @override
  String get pdfExported => 'PDF успешно экспортирован!';

  @override
  String pdfExportFailed(String error) {
    return 'Не удалось экспортировать PDF: $error';
  }

  @override
  String get peopleExported => 'Данные о людях экспортированы!';

  @override
  String peopleExportFailed(String error) {
    return 'Не удалось экспортировать данные о людях: $error';
  }

  @override
  String get allDataDeleted => 'Все данные успешно удалены!';

  @override
  String get introReset => 'Интро сброшено успешно!';

  @override
  String get selectRestoreMode => 'Выберите режим восстановления';

  @override
  String get restoreModeDesc =>
      'Выберите, как обрабатывать существующие записи транзакций во время восстановления данных.';

  @override
  String get mergeSkipDuplicates => 'Объединить и пропустить дубликаты';

  @override
  String get mergeSkipDesc =>
      'Избегайте дублирования записей, сохраняя при этом все уникальные новые элементы.';

  @override
  String get overwriteConflicts => 'Конфликты перезаписи и обновления';

  @override
  String get overwriteConflictsDesc =>
      'Замените существующие записи транзакций резервными версиями в случае конфликтов.';

  @override
  String get exportCsvTitle => 'Экспортные транзакции (CSV)';

  @override
  String get exportCsvDesc => 'Экспортируйте свои транзакции в CSV';

  @override
  String get exportCsvSuccess => 'Экспорт успешно завершен!';

  @override
  String exportCsvFailed(String error) {
    return 'Не удалось экспортировать: $error';
  }

  @override
  String get exportPeopleTitle => 'Экспорт данных о людях';

  @override
  String get exportPeopleDesc => 'Резервное копирование транзакций людей';

  @override
  String get exportPdfTitle => 'Экспортировать в PDF';

  @override
  String get exportPdfDesc => 'Создание отчетов в формате PDF';
}

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
  String get appTagline => 'Intelligente Ausgaben, vereinfacht.';

  @override
  String get totalBalance => 'Gesamtsaldo';

  @override
  String get income => 'Einkommen';

  @override
  String get expense => 'Kosten';

  @override
  String get monthlyBudget => 'Monatsbudget';

  @override
  String get transactions => 'Transaktionen';

  @override
  String get recentTransactions => 'Letzte Transaktionen';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Thema';

  @override
  String get darkMode => 'Dunkler Modus';

  @override
  String get lightMode => 'Lichtmodus';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get adaptiveColor => 'Adaptive Farbe';

  @override
  String get customColor => 'Benutzerdefinierte Farbe';

  @override
  String get backup => 'Sichern und Wiederherstellen';

  @override
  String get export => 'Daten exportieren';

  @override
  String get import => 'Daten importieren';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get telegramSupport => 'Telegram-Unterstützung';

  @override
  String get addTransaction => 'Transaktion hinzufügen';

  @override
  String get editTransaction => 'Transaktion bearbeiten';

  @override
  String get deleteTransaction => 'Transaktion löschen';

  @override
  String get amount => 'Menge';

  @override
  String get category => 'Kategorie';

  @override
  String get account => 'Konto';

  @override
  String get date => 'Datum';

  @override
  String get note => 'Hinweis (optional)';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Stornieren';

  @override
  String get delete => 'Löschen';

  @override
  String get search => 'Transaktionen suchen...';

  @override
  String get noTransactions => 'Keine Transaktionen gefunden';

  @override
  String get voiceInput => 'Spracheingabe';

  @override
  String get speechUnavailable => 'Spracherkennung nicht verfügbar';

  @override
  String get microPermissionDenied => 'Mikrofonberechtigung verweigert';

  @override
  String get appearance => 'Aussehen';

  @override
  String get security => 'Sicherheit';

  @override
  String get autoDetection => 'Automatische Transaktionserkennung';

  @override
  String get backupExport => 'Sichern und Exportieren';

  @override
  String get dataManagement => 'Datenmanagement';

  @override
  String get budgetingBalance => 'Budgetierung und Bilanz';

  @override
  String get customDropdowns => 'Benutzerdefinierte Dropdown-Elemente';

  @override
  String get appInformation => 'App-Informationen';

  @override
  String get developedBy => 'Entwickelt mit ❤️ von Sthrnilshaa';

  @override
  String get chooseTheme => 'Wählen Sie Ihr bevorzugtes Thema';

  @override
  String get appLock => 'App-Sperre';

  @override
  String get appLockDesc =>
      'Zum Öffnen der App ist eine Geräteauthentifizierung erforderlich';

  @override
  String get upiId => 'UPI-ID';

  @override
  String get upiIdDesc => 'Legen Sie Ihre UPI-ID für Geldanfragen fest';

  @override
  String get upiName => 'Anzeigename';

  @override
  String get upiNameDesc =>
      'Optional: Name, der in der UPI-Anfrage angezeigt wird';

  @override
  String get analytics => 'Analytik';

  @override
  String get people => 'Menschen';

  @override
  String get charts => 'Diagramme';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get holdToRecord =>
      'Halten Sie gedrückt, um die Transaktion aufzuzeichnen';

  @override
  String get couldNotFindAmount =>
      'Betrag konnte nicht gefunden werden. Versuchen Sie: „500 für Essen ausgegeben“';

  @override
  String savedAmount(String amount, String category) {
    return '₹$amount für $category gespart';
  }

  @override
  String logsDeleted(int count) {
    return '$count Protokolle wurden gelöscht';
  }

  @override
  String patternsIgnored(int count) {
    return 'Dauerhaft ignorierte $count Muster';
  }

  @override
  String get recheckComplete => 'Nachprüfung abgeschlossen';

  @override
  String get aboutApp => 'Über Aspends';

  @override
  String get developerDesigner => 'Entwickler & Designer';

  @override
  String get leadDesigner => 'Leitender Designer';

  @override
  String get developer => 'Entwickler';

  @override
  String get supportLegal => 'Support & Recht';

  @override
  String get privacyPolicyDesc =>
      'Lesen Sie unser Dokument mit den Datenschutzbestimmungen';

  @override
  String get helpSupport => 'Hilfe und Support';

  @override
  String get telegramSupportDesc =>
      'Nehmen Sie an unserem Telegram teil, um Unterstützung zu erhalten';

  @override
  String get projectInfo => 'Projektinformationen';

  @override
  String get openSource => 'Open Source';

  @override
  String get openSourceDesc => 'Stolz Open Source auf GitHub';

  @override
  String get rateApp => 'Bewerten Sie Aspends';

  @override
  String get rateAppDesc => 'Unterstützen Sie uns mit einer 5-Sterne-Bewertung';

  @override
  String get howAspendWorks => 'WIE ASPEND FUNKTIONIERT';

  @override
  String get howItWorksTitle1 => '1. Intelligentes Abfangen';

  @override
  String get howItWorksDesc1 =>
      'Ein sicherer, batterieoptimierter Hintergrunddienst wartet auf eingehende SMS- und Bankbenachrichtigungen.';

  @override
  String get howItWorksTitle2 => '2. Lokales Zero-Cloud-Parsing';

  @override
  String get howItWorksDesc2 =>
      'Intelligente Offline-Algorithmen extrahieren sofort Beträge, Kategorien und Händler – 100 % auf Ihrem Gerät.';

  @override
  String get howItWorksTitle3 => '3. Automatische Offline-Wiederherstellung';

  @override
  String get howItWorksDesc3 =>
      'Jedes Mal, wenn Sie Aspend öffnen oder fortsetzen, durchsucht es den Verlauf automatisch nach verpassten Transaktionen während Ihrer Abwesenheit.';

  @override
  String get howItWorksTitle4 => '4. Ultimative Privatsphärensperre';

  @override
  String get howItWorksDesc4 =>
      'Keine Server, keine Webanfragen. Ihre Finanzdaten werden lokal im verschlüsselten Hive-Speicher geschützt.';

  @override
  String get autoDetectionSetup => 'Einrichtung der automatischen Erkennung';

  @override
  String get autoDetectionSetupDesc =>
      'Um Transaktionen automatisch zu erkennen, benötigen wir bestimmte Berechtigungen. Alle Banking- und Transaktions-Apps werden sicher überwacht.';

  @override
  String get notificationAccess => '1. Benachrichtigungszugriff';

  @override
  String get notificationAccessDesc =>
      'Ermöglicht uns das Lesen von Transaktionswarnungen von Bank- und Zahlungs-Apps.';

  @override
  String get smsPermission => '2. SMS-Erlaubnis';

  @override
  String get smsPermissionDesc =>
      'Ermöglicht das Lesen von Transaktions-SMS Ihrer Bank.';

  @override
  String get finishSetup => 'Beenden Sie die Einrichtung';

  @override
  String get grant => 'Gewähren';

  @override
  String get appNameShort => 'Aspends';

  @override
  String get splashTagline => 'Intelligentes Geldmanagement';

  @override
  String get budget => 'Budget';

  @override
  String get balanceDetailsTitle => 'Kontostanddetails';

  @override
  String get editBalanceTitle => 'Kontostand bearbeiten';

  @override
  String get newBalanceLabel => 'Neue Balance';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get searchHint => 'Kategorien oder Notizen durchsuchen...';

  @override
  String get emptyWalletTitle => 'Ihr Geldbeutel ist ruhig';

  @override
  String get emptyWalletDesc =>
      'Fügen Sie zunächst manuell eine Transaktion hinzu oder aktivieren Sie die automatische Erkennung, um Ihre Ausgaben mühelos zu verfolgen.';

  @override
  String get addPerson => 'Person hinzufügen';

  @override
  String get addNewPerson => 'Neue Person hinzufügen';

  @override
  String get editPerson => 'Person bearbeiten';

  @override
  String get addPhoto => 'Foto hinzufügen';

  @override
  String get personName => 'Personenname';

  @override
  String get youGet => 'Sie besitzen';

  @override
  String get youGive => 'Sie leihen';

  @override
  String get youWillGet => 'Du wirst es besitzen';

  @override
  String get youWillGive => 'Sie werden leihen';

  @override
  String get noPeopleYet => 'Es wurden noch keine Personen hinzugefügt';

  @override
  String get searchPeople => 'Personen suchen...';

  @override
  String get enterNameHint =>
      'Geben Sie den Namen der Person ein, mit der Sie Transaktionen verfolgen möchten';

  @override
  String get updateDetailsHint =>
      'Aktualisieren Sie die Details für diese Person';

  @override
  String get expenses => 'Kosten';

  @override
  String get history => 'Geschichte';

  @override
  String get overview => 'Überblick';

  @override
  String get trends => 'Trends';

  @override
  String get categories => 'Kategorien';

  @override
  String get noDataFound => 'Keine Datensätze gefunden';

  @override
  String get appColor => 'App-Farbe';

  @override
  String get selectColor => 'Wählen Sie eine benutzerdefinierte App-Farbe aus';

  @override
  String get welcomeTitle => 'Willkommen bei Aspends Tracker';

  @override
  String get welcomeSubtitle => 'Ihr persönlicher Finanzbegleiter';

  @override
  String get welcomeDesc =>
      'Verfolgen Sie Ihre Einnahmen und Ausgaben und verwalten Sie Ihr Geld ganz einfach. Behalten Sie den Überblick über Ihre finanziellen Ziele.';

  @override
  String get smartTrackingTitle => 'Intelligente Transaktionsverfolgung';

  @override
  String get smartTrackingSubtitle => 'Organisieren Sie Ihre Finanzen';

  @override
  String get smartTrackingDesc =>
      'Kategorisieren Sie Transaktionen, fügen Sie Notizen hinzu und erhalten Sie detaillierte Einblicke in Ihr Ausgabeverhalten.';

  @override
  String get peopleTrackingTitle => 'Person-zu-Person-Tracking';

  @override
  String get peopleTrackingSubtitle => 'Gemeinsame Ausgaben verwalten';

  @override
  String get peopleTrackingDesc =>
      'Verfolgen Sie Geld, das Sie schulden oder das anderen schuldet. Perfekt für Mitbewohner, Freunde und Familie.';

  @override
  String get analyticsTitle => 'Schöne Analytik';

  @override
  String get analyticsSubtitle => 'Visualisieren Sie Ihre Daten';

  @override
  String get analyticsDesc =>
      'Diagramme und Grafiken helfen Ihnen, Ihre Ausgabegewohnheiten und Finanztrends zu verstehen.';

  @override
  String get offlineTitle => 'Vollständig offline';

  @override
  String get offlineSubtitle => 'Ihre Daten bleiben privat';

  @override
  String get offlineDesc =>
      'Alle Ihre Finanzdaten werden lokal auf Ihrem Gerät gespeichert. Kein Internet erforderlich, absolute Privatsphäre.';

  @override
  String get autoDetectTitle => 'Automatische Transaktionserkennung';

  @override
  String get autoDetectSubtitle => 'Intelligent und automatisiert';

  @override
  String get autoDetectDesc =>
      'Erkennen Sie Transaktionen automatisch anhand von Bankbenachrichtigungen. Keine manuelle Eingabe mehr – Ihre Transaktionen werden sofort erfasst!';

  @override
  String get readyTitle => 'Bereit zum Start?';

  @override
  String get readySubtitle => 'Beginnen wir Ihre Reise';

  @override
  String get readyDesc =>
      'Sie sind bereit! Beginnen Sie noch heute mit der Verfolgung Ihrer Finanzen und übernehmen Sie die Kontrolle über Ihr Geld.';

  @override
  String get settingUpApp => 'Richten Sie Ihre App ein...';

  @override
  String get skip => 'Überspringen';

  @override
  String get next => 'Nächste';

  @override
  String get getStarted => 'Legen Sie los';

  @override
  String get requestMoney => 'Geld anfordern';

  @override
  String get generateQr => 'Zahlungs-QR generieren';

  @override
  String get sortByNameAZ => 'Name (A-Z)';

  @override
  String get sortByNameZA => 'Name (Z-A)';

  @override
  String get sortByBalanceHighest => 'Guthaben (höchste)';

  @override
  String get sortByBalanceLowest => 'Saldo (niedrigster Wert)';

  @override
  String get upiIdNotSet =>
      'Für diese Person ist keine UPI-ID festgelegt. Bitte fügen Sie es aus der Bearbeitung hinzu.';

  @override
  String get couldNotFindUpiApp =>
      'Es konnte keine UPI-Zahlungs-App gefunden werden';

  @override
  String get noTransactionsYet => 'Noch keine Transaktionen';

  @override
  String get addFirstTransaction =>
      'Fügen Sie Ihre erste Transaktion mit der Person hinzu';

  @override
  String get settleBalance => 'Saldo ausgleichen';

  @override
  String settleBalanceDesc(String amount) {
    return 'Dadurch wird eine Transaktion von ₹$amount hinzugefügt, um den Saldo auf Null zu bringen. Weitermachen?';
  }

  @override
  String get settle => 'Siedeln';

  @override
  String get deletePerson => 'Person löschen';

  @override
  String deletePersonDesc(String name) {
    return 'Sind Sie sicher, dass Sie $name löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get deleteTransactionDesc =>
      'Sind Sie sicher, dass Sie diese Transaktion löschen möchten?';

  @override
  String get update => 'Aktualisieren';

  @override
  String get sortTransactionsBy => 'Transaktionen sortieren nach';

  @override
  String get sortByDateRecent => 'Datum (aktuell)';

  @override
  String get sortByDateOldest => 'Datum (ältestes)';

  @override
  String get sortByAmountHighest => 'Betrag (höchster)';

  @override
  String get sortByAmountLowest => 'Betrag (niedrigster)';

  @override
  String get rangeAll => 'Alle';

  @override
  String get rangeDay => 'Tag';

  @override
  String get rangeWeek => 'Woche';

  @override
  String get rangeMonth => 'Monat';

  @override
  String get rangeYear => 'Jahr';

  @override
  String get topCategory => 'Top-Kategorie';

  @override
  String get noSpending => 'Keine Ausgaben';

  @override
  String get avgDailySpend => 'Durchschn. Tägliche Ausgaben';

  @override
  String get perDay => 'Pro Tag';

  @override
  String get monitoredApps => 'Überwachte Apps';

  @override
  String get searchAppsHint => 'Suchen Sie nach Zahlungs- oder Banking-Apps...';

  @override
  String get noEligibleApps => 'Keine geeigneten Apps gefunden';

  @override
  String get noAppsMatchSearch => 'Keine Apps entsprechen Ihrer Suche';

  @override
  String get unknownApp => 'Unbekannte App';

  @override
  String errorLoadingApps(String error) {
    return 'Fehler beim Laden von Apps: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count Ausgewählt';
  }

  @override
  String get ignorePatternsTooltip => 'Muster ignorieren';

  @override
  String get deleteSelectedTooltip => 'Ausgewählte löschen';

  @override
  String get clearHistoryTitle => 'Verlauf löschen?';

  @override
  String get clearHistoryDesc =>
      'Dadurch werden alle gespeicherten Erkennungsprotokolle gelöscht.';

  @override
  String get clear => 'Klar';

  @override
  String get transactionDetected => 'Transaktion erkannt';

  @override
  String get notificationLogged => 'Benachrichtigung protokolliert';

  @override
  String get patternNotMatched => 'Muster nicht übereinstimmend';

  @override
  String get notificationDataTitle => 'Benachrichtigungsdaten';

  @override
  String get copiedToClipboard => 'Nachricht in die Zwischenablage kopiert';

  @override
  String get copy => 'KOPIE';

  @override
  String get smsMessage => 'SMS-Nachricht';

  @override
  String get received => 'Erhalten';

  @override
  String get paid => 'Bezahlt';

  @override
  String get listeningHint => 'Hören...';

  @override
  String get keepSpeaking => 'Sprich weiter...';

  @override
  String get done => 'Erledigt';

  @override
  String get fullBackupTitle => 'Vollständige Sicherung (JSON)';

  @override
  String get fullBackupDesc => 'Sichern Sie alle Daten in JSON';

  @override
  String get restoreBackupTitle => 'Backup wiederherstellen (JSON)';

  @override
  String get restoreBackupDesc =>
      'Stellen Sie alle Daten aus der JSON-Sicherung wieder her';

  @override
  String get backupCompleted => 'Sicherung abgeschlossen!';

  @override
  String backupFailed(String error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String get restoreCompleted => 'Daten erfolgreich wiederhergestellt!';

  @override
  String get restoreFailedCancelled =>
      'Wiederherstellung fehlgeschlagen oder abgebrochen';

  @override
  String restoreFailed(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get pdfExported => 'PDF erfolgreich exportiert!';

  @override
  String pdfExportFailed(String error) {
    return 'PDF-Export fehlgeschlagen: $error';
  }

  @override
  String get peopleExported => 'Personendaten exportiert!';

  @override
  String peopleExportFailed(String error) {
    return 'Der Export von Personendaten ist fehlgeschlagen: $error';
  }

  @override
  String get allDataDeleted => 'Alle Daten erfolgreich gelöscht!';

  @override
  String get introReset => 'Intro erfolgreich zurückgesetzt!';

  @override
  String get selectRestoreMode => 'Wählen Sie den Wiederherstellungsmodus';

  @override
  String get restoreModeDesc =>
      'Wählen Sie aus, wie mit vorhandenen Transaktionsdatensätzen während der Datenwiederherstellung umgegangen werden soll.';

  @override
  String get mergeSkipDuplicates => 'Duplikate zusammenführen und überspringen';

  @override
  String get mergeSkipDesc =>
      'Vermeiden Sie doppelte Einträge und behalten Sie gleichzeitig alle einzigartigen neuen Artikel bei.';

  @override
  String get overwriteConflicts => 'Konflikte überschreiben und aktualisieren';

  @override
  String get overwriteConflictsDesc =>
      'Ersetzen Sie bei Konflikten vorhandene Transaktionsdatensätze durch Sicherungsversionen.';

  @override
  String get exportCsvTitle => 'Transaktionen exportieren (CSV)';

  @override
  String get exportCsvDesc => 'Exportieren Sie Ihre Transaktionen in CSV';

  @override
  String get exportCsvSuccess => 'Export erfolgreich abgeschlossen!';

  @override
  String exportCsvFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get exportPeopleTitle => 'Personendaten exportieren';

  @override
  String get exportPeopleDesc => 'Sichern Sie Personentransaktionen';

  @override
  String get exportPdfTitle => 'Als PDF exportieren';

  @override
  String get exportPdfDesc => 'PDF-Berichte erstellen';
}

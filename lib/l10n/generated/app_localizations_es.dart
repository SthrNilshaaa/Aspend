// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'álamo temblón';

  @override
  String get appTagline => 'Gasto inteligente, simplificado.';

  @override
  String get totalBalance => 'Saldo Total';

  @override
  String get income => 'Ingreso';

  @override
  String get expense => 'Gastos';

  @override
  String get monthlyBudget => 'Presupuesto mensual';

  @override
  String get transactions => 'Actas';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get lightMode => 'Modo de luz';

  @override
  String get systemDefault => 'Valor predeterminado del sistema';

  @override
  String get adaptiveColor => 'Color adaptable';

  @override
  String get customColor => 'Color personalizado';

  @override
  String get backup => 'Copia de seguridad y restauración';

  @override
  String get export => 'Exportar datos';

  @override
  String get import => 'Importar datos';

  @override
  String get privacyPolicy => 'política de privacidad';

  @override
  String get telegramSupport => 'Soporte de telegramas';

  @override
  String get addTransaction => 'Agregar transacción';

  @override
  String get editTransaction => 'Editar transacción';

  @override
  String get deleteTransaction => 'Eliminar transacción';

  @override
  String get amount => 'Cantidad';

  @override
  String get category => 'Categoría';

  @override
  String get account => 'Cuenta';

  @override
  String get date => 'Fecha';

  @override
  String get note => 'Nota (opcional)';

  @override
  String get save => 'Ahorrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Borrar';

  @override
  String get search => 'Buscar transacciones...';

  @override
  String get noTransactions => 'No se encontraron transacciones';

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String get speechUnavailable => 'Reconocimiento de voz no disponible';

  @override
  String get microPermissionDenied => 'Permiso de micrófono denegado';

  @override
  String get appearance => 'Apariencia';

  @override
  String get security => 'Seguridad';

  @override
  String get autoDetection => 'Detección automática de transacciones';

  @override
  String get backupExport => 'Copia de seguridad y exportación';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get budgetingBalance => 'Presupuesto y equilibrio';

  @override
  String get customDropdowns => 'Elementos desplegables personalizados';

  @override
  String get appInformation => 'Información de la aplicación';

  @override
  String get developedBy => 'Desarrollado con ❤️ por Sthrnilshaa';

  @override
  String get chooseTheme => 'Elige tu tema preferido';

  @override
  String get appLock => 'Bloqueo de aplicaciones';

  @override
  String get appLockDesc =>
      'Requerir autenticación del dispositivo para abrir la aplicación';

  @override
  String get upiId => 'ID de UPI';

  @override
  String get upiIdDesc => 'Configure su ID de UPI para solicitudes de dinero';

  @override
  String get upiName => 'Nombre para mostrar';

  @override
  String get upiNameDesc =>
      'Opcional: nombre que se muestra en la solicitud de UPI';

  @override
  String get analytics => 'Analítica';

  @override
  String get people => 'Gente';

  @override
  String get charts => 'Gráficos';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get holdToRecord => 'Mantener para registrar la transacción';

  @override
  String get couldNotFindAmount =>
      'No se pudo encontrar la cantidad. Pruebe: \'Gasté 500 en comida\'';

  @override
  String savedAmount(String amount, String category) {
    return 'Ahorró ₹$amount para $category';
  }

  @override
  String logsDeleted(int count) {
    return 'Registros $count eliminados';
  }

  @override
  String patternsIgnored(int count) {
    return 'Patrones $count ignorados permanentemente';
  }

  @override
  String get recheckComplete => 'Vuelva a verificar completa';

  @override
  String get aboutApp => 'Acerca de Aspen';

  @override
  String get developerDesigner => 'Desarrollador y Diseñador';

  @override
  String get leadDesigner => 'Diseñador principal';

  @override
  String get developer => 'Revelador';

  @override
  String get supportLegal => 'Soporte y Legal';

  @override
  String get privacyPolicyDesc =>
      'Lea nuestro documento de política de privacidad';

  @override
  String get helpSupport => 'Ayuda y soporte';

  @override
  String get telegramSupportDesc =>
      'Únase a nuestro Telegram para obtener ayuda';

  @override
  String get projectInfo => 'Información del proyecto';

  @override
  String get openSource => 'Código abierto';

  @override
  String get openSourceDesc => 'Orgullosamente de código abierto en GitHub';

  @override
  String get rateApp => 'Tarifa Aspens';

  @override
  String get rateAppDesc => 'Apóyanos con una calificación de 5 estrellas';

  @override
  String get howAspendWorks => 'CÓMO FUNCIONA';

  @override
  String get howItWorksTitle1 => '1. Intercepción inteligente';

  @override
  String get howItWorksDesc1 =>
      'Un servicio en segundo plano seguro y optimizado para la batería escucha los SMS entrantes y las notificaciones bancarias.';

  @override
  String get howItWorksTitle2 => '2. Análisis local en la nube cero';

  @override
  String get howItWorksDesc2 =>
      'Los algoritmos inteligentes fuera de línea extraen cantidades, categorías y comerciantes al instante, 100 % en su dispositivo.';

  @override
  String get howItWorksTitle3 => '3. Recuperación automática sin conexión';

  @override
  String get howItWorksDesc3 =>
      'Cada vez que abre o reanuda Aspend, escanea automáticamente el historial en busca de transacciones perdidas durante su ausencia.';

  @override
  String get howItWorksTitle4 => '4. Bloqueo de privacidad definitivo';

  @override
  String get howItWorksDesc4 =>
      'Sin servidores, sin solicitudes web. Sus datos financieros están protegidos localmente dentro del almacenamiento cifrado de Hive.';

  @override
  String get autoDetectionSetup => 'Configuración de detección automática';

  @override
  String get autoDetectionSetupDesc =>
      'Para detectar transacciones automáticamente, necesitamos permisos específicos. Todas las aplicaciones bancarias y de transacciones serán monitoreadas de forma segura.';

  @override
  String get notificationAccess => '1. Acceso a notificaciones';

  @override
  String get notificationAccessDesc =>
      'Nos permite leer alertas de transacciones de aplicaciones bancarias y de pago.';

  @override
  String get smsPermission => '2. Permiso por SMS';

  @override
  String get smsPermissionDesc =>
      'Permite leer SMS de transacciones de su banco.';

  @override
  String get finishSetup => 'Finalizar la configuración';

  @override
  String get grant => 'Conceder';

  @override
  String get appNameShort => 'álamo temblón';

  @override
  String get splashTagline => 'Gestión inteligente del dinero';

  @override
  String get budget => 'Presupuesto';

  @override
  String get balanceDetailsTitle => 'Detalles del saldo';

  @override
  String get editBalanceTitle => 'Editar saldo';

  @override
  String get newBalanceLabel => 'nuevo equilibrio';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get searchHint => 'Buscar categorías o notas...';

  @override
  String get emptyWalletTitle => 'Tu billetera está tranquila';

  @override
  String get emptyWalletDesc =>
      'Comience agregando una transacción manualmente o habilite la detección automática para realizar un seguimiento de sus gastos sin esfuerzo.';

  @override
  String get addPerson => 'Agregar persona';

  @override
  String get addNewPerson => 'Agregar nueva persona';

  @override
  String get editPerson => 'Editar persona';

  @override
  String get addPhoto => 'Agregar foto';

  @override
  String get personName => 'Nombre de la persona';

  @override
  String get youGet => 'Eres dueño';

  @override
  String get youGive => 'usted pide prestado';

  @override
  String get youWillGet => 'Serás dueño';

  @override
  String get youWillGive => 'pedirás prestado';

  @override
  String get noPeopleYet => 'Aún no se ha añadido gente';

  @override
  String get searchPeople => 'Buscar personas...';

  @override
  String get enterNameHint =>
      'Ingrese el nombre de la persona con la que desea realizar un seguimiento de las transacciones';

  @override
  String get updateDetailsHint => 'Actualizar los detalles de esta persona';

  @override
  String get expenses => 'Gastos';

  @override
  String get history => 'Historia';

  @override
  String get overview => 'Descripción general';

  @override
  String get trends => 'Tendencias';

  @override
  String get categories => 'Categorías';

  @override
  String get noDataFound => 'No se encontraron registros de datos';

  @override
  String get appColor => 'Color de la aplicación';

  @override
  String get selectColor => 'Seleccione un color de aplicación personalizado';

  @override
  String get welcomeTitle => 'Bienvenido a Aspens Tracker';

  @override
  String get welcomeSubtitle => 'Tu compañero de finanzas personales';

  @override
  String get welcomeDesc =>
      'Realice un seguimiento de sus ingresos, gastos y administre su dinero con facilidad. Manténgase al tanto de sus objetivos financieros.';

  @override
  String get smartTrackingTitle => 'Seguimiento inteligente de transacciones';

  @override
  String get smartTrackingSubtitle => 'Organiza tus finanzas';

  @override
  String get smartTrackingDesc =>
      'Clasifique transacciones, agregue notas y obtenga información detallada sobre sus patrones de gasto.';

  @override
  String get peopleTrackingTitle => 'Seguimiento de persona a persona';

  @override
  String get peopleTrackingSubtitle => 'Gestionar gastos compartidos';

  @override
  String get peopleTrackingDesc =>
      'Realice un seguimiento del dinero que debe o que le deben otros. Perfecto para compañeros de cuarto, amigos y familiares.';

  @override
  String get analyticsTitle => 'Hermosos análisis';

  @override
  String get analyticsSubtitle => 'Visualiza tus datos';

  @override
  String get analyticsDesc =>
      'Los cuadros y gráficos lo ayudan a comprender sus hábitos de gasto y tendencias financieras.';

  @override
  String get offlineTitle => 'Totalmente desconectado';

  @override
  String get offlineSubtitle => 'Tus datos permanecen privados';

  @override
  String get offlineDesc =>
      'Todos sus datos financieros se almacenan localmente en su dispositivo. No se requiere Internet, total privacidad.';

  @override
  String get autoDetectTitle => 'Detección automática de transacciones';

  @override
  String get autoDetectSubtitle => 'Inteligente y automatizado';

  @override
  String get autoDetectDesc =>
      'Detecta automáticamente transacciones a partir de notificaciones bancarias. No más entradas manuales: ¡sus transacciones se capturan al instante!';

  @override
  String get readyTitle => '¿Listo para empezar?';

  @override
  String get readySubtitle => 'Comencemos tu viaje';

  @override
  String get readyDesc =>
      '¡Estás listo! Comience a realizar un seguimiento de sus finanzas y tome el control de su dinero hoy.';

  @override
  String get settingUpApp => 'Configurando tu aplicación...';

  @override
  String get skip => 'Saltar';

  @override
  String get next => 'Próximo';

  @override
  String get getStarted => 'Empezar';

  @override
  String get requestMoney => 'Solicitar dinero';

  @override
  String get generateQr => 'Generar QR de pago';

  @override
  String get sortByNameAZ => 'Nombre (A-Z)';

  @override
  String get sortByNameZA => 'Nombre (Z-A)';

  @override
  String get sortByBalanceHighest => 'Saldo (más alto)';

  @override
  String get sortByBalanceLowest => 'Saldo (más bajo)';

  @override
  String get upiIdNotSet =>
      'ID de UPI no establecido para esta persona. Por favor agréguelo desde la edición.';

  @override
  String get couldNotFindUpiApp =>
      'No se pudo encontrar una aplicación de pago UPI';

  @override
  String get noTransactionsYet => 'Aún no hay transacciones';

  @override
  String get addFirstTransaction =>
      'Añade tu primera transacción con la persona';

  @override
  String get settleBalance => 'Liquidar saldo';

  @override
  String settleBalanceDesc(String amount) {
    return 'Esto agregará una transacción de ₹$amount para llevar el saldo a cero. ¿Continuar?';
  }

  @override
  String get settle => 'Asentarse';

  @override
  String get deletePerson => 'Eliminar persona';

  @override
  String deletePersonDesc(String name) {
    return '¿Está seguro de que desea eliminar $name? Esta acción no se puede deshacer.';
  }

  @override
  String get deleteTransactionDesc =>
      '¿Está seguro de que desea eliminar esta transacción?';

  @override
  String get update => 'Actualizar';

  @override
  String get sortTransactionsBy => 'Ordenar transacciones por';

  @override
  String get sortByDateRecent => 'Fecha (reciente)';

  @override
  String get sortByDateOldest => 'Fecha (más antigua)';

  @override
  String get sortByAmountHighest => 'Cantidad (más alta)';

  @override
  String get sortByAmountLowest => 'Cantidad (más baja)';

  @override
  String get rangeAll => 'Todo';

  @override
  String get rangeDay => 'Día';

  @override
  String get rangeWeek => 'Semana';

  @override
  String get rangeMonth => 'Mes';

  @override
  String get rangeYear => 'Año';

  @override
  String get topCategory => 'Categoría superior';

  @override
  String get noSpending => 'Sin gastar';

  @override
  String get avgDailySpend => 'Promedio Gasto diario';

  @override
  String get perDay => 'por dia';

  @override
  String get monitoredApps => 'Aplicaciones monitoreadas';

  @override
  String get searchAppsHint => 'Buscar aplicaciones bancarias o de pago...';

  @override
  String get noEligibleApps => 'No se encontraron aplicaciones elegibles';

  @override
  String get noAppsMatchSearch => 'Ninguna aplicación coincide con tu búsqueda';

  @override
  String get unknownApp => 'Aplicación desconocida';

  @override
  String errorLoadingApps(String error) {
    return 'Error al cargar aplicaciones: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count Seleccionado';
  }

  @override
  String get ignorePatternsTooltip => 'Ignorar patrones';

  @override
  String get deleteSelectedTooltip => 'Eliminar seleccionado';

  @override
  String get clearHistoryTitle => '¿Borrar historial?';

  @override
  String get clearHistoryDesc =>
      'Esto eliminará todos los registros de detección guardados.';

  @override
  String get clear => 'Claro';

  @override
  String get transactionDetected => 'Transacción detectada';

  @override
  String get notificationLogged => 'Notificación registrada';

  @override
  String get patternNotMatched => 'Patrón no coincidente';

  @override
  String get notificationDataTitle => 'DATOS DE NOTIFICACIÓN';

  @override
  String get copiedToClipboard => 'Mensaje copiado al portapapeles';

  @override
  String get copy => 'COPIAR';

  @override
  String get smsMessage => 'Mensaje SMS';

  @override
  String get received => 'Recibió';

  @override
  String get paid => 'Pagado';

  @override
  String get listeningHint => 'Escuchando...';

  @override
  String get keepSpeaking => 'Sigue hablando...';

  @override
  String get done => 'Hecho';

  @override
  String get fullBackupTitle => 'Copia de seguridad completa (JSON)';

  @override
  String get fullBackupDesc => 'Copia de seguridad de todos los datos en JSON';

  @override
  String get restoreBackupTitle => 'Restaurar copia de seguridad (JSON)';

  @override
  String get restoreBackupDesc =>
      'Restaurar todos los datos de la copia de seguridad JSON';

  @override
  String get backupCompleted => '¡Copia de seguridad completada!';

  @override
  String backupFailed(String error) {
    return 'Error en la copia de seguridad: $error';
  }

  @override
  String get restoreCompleted => '¡Datos restaurados exitosamente!';

  @override
  String get restoreFailedCancelled => 'Restauración fallida o cancelada';

  @override
  String restoreFailed(String error) {
    return 'Error de restauración: $error';
  }

  @override
  String get pdfExported => '¡PDF exportado exitosamente!';

  @override
  String pdfExportFailed(String error) {
    return 'Error al exportar PDF: $error';
  }

  @override
  String get peopleExported => '¡Datos de personas exportados!';

  @override
  String peopleExportFailed(String error) {
    return 'Error al exportar datos de personas: $error';
  }

  @override
  String get allDataDeleted => '¡Todos los datos eliminados exitosamente!';

  @override
  String get introReset => '¡La introducción se restableció correctamente!';

  @override
  String get selectRestoreMode => 'Seleccione el modo de restauración';

  @override
  String get restoreModeDesc =>
      'Elija cómo manejar los registros de transacciones existentes durante la restauración de datos.';

  @override
  String get mergeSkipDuplicates => 'Fusionar y omitir duplicados';

  @override
  String get mergeSkipDesc =>
      'Evite entradas duplicadas y mantenga todos los elementos nuevos únicos.';

  @override
  String get overwriteConflicts =>
      'Conflictos de sobrescritura y actualización';

  @override
  String get overwriteConflictsDesc =>
      'Reemplace los registros de transacciones existentes con versiones de respaldo en caso de conflictos.';

  @override
  String get exportCsvTitle => 'Transacciones de exportación (CSV)';

  @override
  String get exportCsvDesc => 'Exporta tus transacciones a CSV';

  @override
  String get exportCsvSuccess => '¡Exportación completada exitosamente!';

  @override
  String exportCsvFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get exportPeopleTitle => 'Exportar datos de personas';

  @override
  String get exportPeopleDesc => 'Transacciones de personas de respaldo';

  @override
  String get exportPdfTitle => 'Exportar como PDF';

  @override
  String get exportPdfDesc => 'Generar informes en PDF';
}

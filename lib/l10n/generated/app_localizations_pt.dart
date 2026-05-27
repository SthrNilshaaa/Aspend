// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Aspende';

  @override
  String get appTagline => 'Gastos inteligentes, simplificados.';

  @override
  String get totalBalance => 'Saldo Total';

  @override
  String get income => 'Renda';

  @override
  String get expense => 'Despesa';

  @override
  String get monthlyBudget => 'Orçamento Mensal';

  @override
  String get transactions => 'Transações';

  @override
  String get recentTransactions => 'Transações recentes';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get settings => 'Configurações';

  @override
  String get language => 'Linguagem';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get adaptiveColor => 'Cor Adaptável';

  @override
  String get customColor => 'Cor personalizada';

  @override
  String get backup => 'Backup e restauração';

  @override
  String get export => 'Exportar dados';

  @override
  String get import => 'Importar dados';

  @override
  String get privacyPolicy => 'política de Privacidade';

  @override
  String get telegramSupport => 'Suporte de telegrama';

  @override
  String get addTransaction => 'Adicionar transação';

  @override
  String get editTransaction => 'Editar transação';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get amount => 'Quantia';

  @override
  String get category => 'Categoria';

  @override
  String get account => 'Conta';

  @override
  String get date => 'Data';

  @override
  String get note => 'Nota (opcional)';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get search => 'Pesquisar transações...';

  @override
  String get noTransactions => 'Nenhuma transação encontrada';

  @override
  String get voiceInput => 'Entrada de voz';

  @override
  String get speechUnavailable => 'Reconhecimento de fala indisponível';

  @override
  String get microPermissionDenied => 'Permissão de microfone negada';

  @override
  String get appearance => 'Aparência';

  @override
  String get security => 'Segurança';

  @override
  String get autoDetection => 'Detecção automática de transações';

  @override
  String get backupExport => 'Backup e exportação';

  @override
  String get dataManagement => 'Gerenciamento de dados';

  @override
  String get budgetingBalance => 'Orçamento e Equilíbrio';

  @override
  String get customDropdowns => 'Itens suspensos personalizados';

  @override
  String get appInformation => 'Informações do aplicativo';

  @override
  String get developedBy => 'Desenvolvido com ❤️ por Sthrnilshaa';

  @override
  String get chooseTheme => 'Escolha o seu tema preferido';

  @override
  String get appLock => 'Bloqueio de aplicativo';

  @override
  String get appLockDesc =>
      'Exigir autenticação do dispositivo para abrir o aplicativo';

  @override
  String get upiId => 'ID da UPI';

  @override
  String get upiIdDesc => 'Defina seu ID UPI para solicitações de dinheiro';

  @override
  String get upiName => 'Nome de exibição';

  @override
  String get upiNameDesc => 'Opcional: nome mostrado na solicitação UPI';

  @override
  String get analytics => 'Análise';

  @override
  String get people => 'Pessoas';

  @override
  String get charts => 'Gráficos';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get holdToRecord => 'Segure para registrar a transação';

  @override
  String get couldNotFindAmount =>
      'Não foi possível encontrar o valor. Experimente: \'Gastei 500 em comida\'';

  @override
  String savedAmount(String amount, String category) {
    return 'Salvo ₹$amount para $category';
  }

  @override
  String logsDeleted(int count) {
    return '$count registros excluídos';
  }

  @override
  String patternsIgnored(int count) {
    return 'Padrões $count permanentemente ignorados';
  }

  @override
  String get recheckComplete => 'Nova verificação concluída';

  @override
  String get aboutApp => 'Sobre Aspens';

  @override
  String get developerDesigner => 'Desenvolvedor e Designer';

  @override
  String get leadDesigner => 'Designer Líder';

  @override
  String get developer => 'Desenvolvedor';

  @override
  String get supportLegal => 'Suporte e Jurídico';

  @override
  String get privacyPolicyDesc =>
      'Leia nosso documento de política de privacidade';

  @override
  String get helpSupport => 'Ajuda e suporte';

  @override
  String get telegramSupportDesc => 'Junte-se ao nosso Telegram para suporte';

  @override
  String get projectInfo => 'Informações do projeto';

  @override
  String get openSource => 'Código aberto';

  @override
  String get openSourceDesc => 'Código aberto orgulhosamente no GitHub';

  @override
  String get rateApp => 'Taxa de despesas';

  @override
  String get rateAppDesc => 'Apoie-nos com uma classificação de 5 estrelas';

  @override
  String get howAspendWorks => 'COMO FUNCIONA O ASPEND';

  @override
  String get howItWorksTitle1 => '1. Interceptação Inteligente';

  @override
  String get howItWorksDesc1 =>
      'Um serviço de segundo plano seguro e com bateria otimizada escuta SMS recebidos e notificações bancárias.';

  @override
  String get howItWorksTitle2 => '2. Análise local de nuvem zero';

  @override
  String get howItWorksDesc2 =>
      'Algoritmos off-line inteligentes extraem valores, categorias e comerciantes instantaneamente – 100% no seu dispositivo.';

  @override
  String get howItWorksTitle3 => '3. Recuperação automática offline';

  @override
  String get howItWorksDesc3 =>
      'Cada vez que você abre ou retoma o Aspend, ele verifica automaticamente o histórico em busca de transações perdidas durante sua ausência.';

  @override
  String get howItWorksTitle4 => '4. Bloqueio de privacidade final';

  @override
  String get howItWorksDesc4 =>
      'Sem servidores, sem solicitações da web. Seus dados financeiros são protegidos localmente no armazenamento criptografado do Hive.';

  @override
  String get autoDetectionSetup => 'Configuração de detecção automática';

  @override
  String get autoDetectionSetupDesc =>
      'Para detectar transações automaticamente, precisamos de permissões específicas. Todos os aplicativos bancários e de transações serão monitorados com segurança.';

  @override
  String get notificationAccess => '1. Acesso à notificação';

  @override
  String get notificationAccessDesc =>
      'Permite-nos ler alertas de transações de bancos e aplicativos de pagamento.';

  @override
  String get smsPermission => '2. Permissão de SMS';

  @override
  String get smsPermissionDesc =>
      'Permite a leitura de SMS de transações do seu banco.';

  @override
  String get finishSetup => 'Concluir configuração';

  @override
  String get grant => 'Conceder';

  @override
  String get appNameShort => 'Aspende';

  @override
  String get splashTagline => 'Gestão Inteligente de Dinheiro';

  @override
  String get budget => 'Orçamento';

  @override
  String get balanceDetailsTitle => 'Detalhes do saldo';

  @override
  String get editBalanceTitle => 'Editar saldo';

  @override
  String get newBalanceLabel => 'Novo equilíbrio';

  @override
  String get viewAll => 'Ver tudo';

  @override
  String get searchHint => 'Pesquisar categorias ou notas...';

  @override
  String get emptyWalletTitle => 'Sua carteira está tranquila';

  @override
  String get emptyWalletDesc =>
      'Comece adicionando uma transação manualmente ou ative a detecção automática para rastrear seus gastos sem esforço.';

  @override
  String get addPerson => 'Adicionar pessoa';

  @override
  String get addNewPerson => 'Adicionar nova pessoa';

  @override
  String get editPerson => 'Editar pessoa';

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get personName => 'Nome da pessoa';

  @override
  String get youGet => 'Você possui';

  @override
  String get youGive => 'Você pede emprestado';

  @override
  String get youWillGet => 'Você será o dono';

  @override
  String get youWillGive => 'Você vai pedir emprestado';

  @override
  String get noPeopleYet => 'Nenhuma pessoa adicionada ainda';

  @override
  String get searchPeople => 'Pesquise pessoas...';

  @override
  String get enterNameHint =>
      'Digite o nome da pessoa com quem você deseja rastrear transações';

  @override
  String get updateDetailsHint => 'Atualizar os detalhes desta pessoa';

  @override
  String get expenses => 'Despesas';

  @override
  String get history => 'História';

  @override
  String get overview => 'Visão geral';

  @override
  String get trends => 'Tendências';

  @override
  String get categories => 'Categorias';

  @override
  String get noDataFound => 'Nenhum registro de dados encontrado';

  @override
  String get appColor => 'Cor do aplicativo';

  @override
  String get selectColor => 'Selecione uma cor personalizada para o aplicativo';

  @override
  String get welcomeTitle => 'Bem-vindo ao Aspends Tracker';

  @override
  String get welcomeSubtitle => 'Seu companheiro de finanças pessoais';

  @override
  String get welcomeDesc =>
      'Acompanhe suas receitas, despesas e gerencie seu dinheiro com facilidade. Fique por dentro de seus objetivos financeiros.';

  @override
  String get smartTrackingTitle => 'Rastreamento inteligente de transações';

  @override
  String get smartTrackingSubtitle => 'Organize suas finanças';

  @override
  String get smartTrackingDesc =>
      'Categorize transações, adicione notas e obtenha insights detalhados sobre seus padrões de gastos.';

  @override
  String get peopleTrackingTitle => 'Rastreamento pessoa a pessoa';

  @override
  String get peopleTrackingSubtitle => 'Gerenciar despesas compartilhadas';

  @override
  String get peopleTrackingDesc =>
      'Rastreie o dinheiro que você deve ou é devido por terceiros. Perfeito para colegas de quarto, amigos e familiares.';

  @override
  String get analyticsTitle => 'Belas análises';

  @override
  String get analyticsSubtitle => 'Visualize seus dados';

  @override
  String get analyticsDesc =>
      'Tabelas e gráficos ajudam você a entender seus hábitos de consumo e tendências financeiras.';

  @override
  String get offlineTitle => 'Totalmente off-line';

  @override
  String get offlineSubtitle => 'Seus dados permanecem privados';

  @override
  String get offlineDesc =>
      'Todos os seus dados financeiros são armazenados localmente no seu dispositivo. Não é necessária internet, privacidade total.';

  @override
  String get autoDetectTitle => 'Detecção automática de transações';

  @override
  String get autoDetectSubtitle => 'Inteligente e Automatizado';

  @override
  String get autoDetectDesc =>
      'Detecte automaticamente transações de notificações bancárias. Chega de entradas manuais - suas transações são capturadas instantaneamente!';

  @override
  String get readyTitle => 'Pronto para começar?';

  @override
  String get readySubtitle => 'Vamos começar sua jornada';

  @override
  String get readyDesc =>
      'Está tudo pronto! Comece a monitorar suas finanças e assuma o controle do seu dinheiro hoje.';

  @override
  String get settingUpApp => 'Configurando seu aplicativo...';

  @override
  String get skip => 'Pular';

  @override
  String get next => 'Próximo';

  @override
  String get getStarted => 'Comece';

  @override
  String get requestMoney => 'Solicitar dinheiro';

  @override
  String get generateQr => 'Gerar QR de pagamento';

  @override
  String get sortByNameAZ => 'Nome (A-Z)';

  @override
  String get sortByNameZA => 'Nome (Z-A)';

  @override
  String get sortByBalanceHighest => 'Saldo (mais alto)';

  @override
  String get sortByBalanceLowest => 'Saldo (mais baixo)';

  @override
  String get upiIdNotSet =>
      'ID UPI não definido para esta pessoa. Por favor, adicione-o da edição.';

  @override
  String get couldNotFindUpiApp =>
      'Não foi possível encontrar um aplicativo de pagamento UPI';

  @override
  String get noTransactionsYet => 'Nenhuma transação ainda';

  @override
  String get addFirstTransaction =>
      'Adicione sua primeira transação com a pessoa';

  @override
  String get settleBalance => 'Liquidar Saldo';

  @override
  String settleBalanceDesc(String amount) {
    return 'Isso adicionará uma transação de ₹$amount para zerar o saldo. Continuar?';
  }

  @override
  String get settle => 'Resolver';

  @override
  String get deletePerson => 'Excluir pessoa';

  @override
  String deletePersonDesc(String name) {
    return 'Tem certeza de que deseja excluir $name? Esta ação não pode ser desfeita.';
  }

  @override
  String get deleteTransactionDesc =>
      'Tem certeza de que deseja excluir esta transação?';

  @override
  String get update => 'Atualizar';

  @override
  String get sortTransactionsBy => 'Classificar transações por';

  @override
  String get sortByDateRecent => 'Data (recente)';

  @override
  String get sortByDateOldest => 'Data (mais antiga)';

  @override
  String get sortByAmountHighest => 'Quantidade (mais alta)';

  @override
  String get sortByAmountLowest => 'Quantidade (menor)';

  @override
  String get rangeAll => 'Todos';

  @override
  String get rangeDay => 'Dia';

  @override
  String get rangeWeek => 'Semana';

  @override
  String get rangeMonth => 'Mês';

  @override
  String get rangeYear => 'Ano';

  @override
  String get topCategory => 'Categoria principal';

  @override
  String get noSpending => 'Sem gastos';

  @override
  String get avgDailySpend => 'Média Gasto Diário';

  @override
  String get perDay => 'Por dia';

  @override
  String get monitoredApps => 'Aplicativos monitorados';

  @override
  String get searchAppsHint =>
      'Pesquisar aplicativos de pagamento ou bancários...';

  @override
  String get noEligibleApps => 'Nenhum aplicativo qualificado encontrado';

  @override
  String get noAppsMatchSearch =>
      'Nenhum aplicativo corresponde à sua pesquisa';

  @override
  String get unknownApp => 'Aplicativo desconhecido';

  @override
  String errorLoadingApps(String error) {
    return 'Erro ao carregar aplicativos: $error';
  }

  @override
  String selectedCount(int count) {
    return '$count Selecionado';
  }

  @override
  String get ignorePatternsTooltip => 'Ignorar padrões';

  @override
  String get deleteSelectedTooltip => 'Excluir selecionado';

  @override
  String get clearHistoryTitle => 'Limpar histórico?';

  @override
  String get clearHistoryDesc =>
      'Isso excluirá todos os logs de detecção salvos.';

  @override
  String get clear => 'Claro';

  @override
  String get transactionDetected => 'Transação detectada';

  @override
  String get notificationLogged => 'Notificação registrada';

  @override
  String get patternNotMatched => 'Padrão não correspondido';

  @override
  String get notificationDataTitle => 'DADOS DE NOTIFICAÇÃO';

  @override
  String get copiedToClipboard =>
      'Mensagem copiada para a área de transferência';

  @override
  String get copy => 'CÓPIA';

  @override
  String get smsMessage => 'Mensagem SMS';

  @override
  String get received => 'Recebido';

  @override
  String get paid => 'Pago';

  @override
  String get listeningHint => 'Audição...';

  @override
  String get keepSpeaking => 'Continue falando...';

  @override
  String get done => 'Feito';

  @override
  String get fullBackupTitle => 'Backup completo (JSON)';

  @override
  String get fullBackupDesc => 'Faça backup de todos os dados para JSON';

  @override
  String get restoreBackupTitle => 'Restaurar backup (JSON)';

  @override
  String get restoreBackupDesc => 'Restaure todos os dados do backup JSON';

  @override
  String get backupCompleted => 'Backup concluído!';

  @override
  String backupFailed(String error) {
    return 'Falha no backup: $error';
  }

  @override
  String get restoreCompleted => 'Dados restaurados com sucesso!';

  @override
  String get restoreFailedCancelled => 'A restauração falhou ou foi cancelada';

  @override
  String restoreFailed(String error) {
    return 'Falha na restauração: $error';
  }

  @override
  String get pdfExported => 'PDF exportado com sucesso!';

  @override
  String pdfExportFailed(String error) {
    return 'Falha na exportação de PDF: $error';
  }

  @override
  String get peopleExported => 'Dados de pessoas exportados!';

  @override
  String peopleExportFailed(String error) {
    return 'Falha na exportação de dados de pessoas: $error';
  }

  @override
  String get allDataDeleted => 'Todos os dados excluídos com sucesso!';

  @override
  String get introReset => 'Introdução redefinida com sucesso!';

  @override
  String get selectRestoreMode => 'Selecione o modo de restauração';

  @override
  String get restoreModeDesc =>
      'Escolha como lidar com os registros de transações existentes durante a restauração de dados.';

  @override
  String get mergeSkipDuplicates => 'Mesclar e pular duplicatas';

  @override
  String get mergeSkipDesc =>
      'Evite entradas duplicadas, mantendo todos os novos itens exclusivos.';

  @override
  String get overwriteConflicts => 'Conflitos de substituição e atualização';

  @override
  String get overwriteConflictsDesc =>
      'Substitua os registros de transações existentes por versões de backup em caso de conflitos.';

  @override
  String get exportCsvTitle => 'Transações de exportação (CSV)';

  @override
  String get exportCsvDesc => 'Exporte suas transações para CSV';

  @override
  String get exportCsvSuccess => 'Exportação concluída com sucesso!';

  @override
  String exportCsvFailed(String error) {
    return 'Falha na exportação: $error';
  }

  @override
  String get exportPeopleTitle => 'Exportar dados de pessoas';

  @override
  String get exportPeopleDesc => 'Faça backup de transações de pessoas';

  @override
  String get exportPdfTitle => 'Exportar como PDF';

  @override
  String get exportPdfDesc => 'Gere relatórios em PDF';
}

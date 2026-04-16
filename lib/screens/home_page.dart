import 'dart:ui';
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../models/transaction.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/transaction_view_model.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/balance_card.dart';
import '../widgets/add_transaction_dialog.dart';
import '../utils/responsive_utils.dart';
import '../utils/transaction_utils.dart';
import '../services/native_bridge.dart';
import 'dart:async';
=======
import 'dart:async';

import 'package:aspends_tracker/core/models/transaction.dart';
import 'package:aspends_tracker/widgets/request_money_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/view_models/theme_view_model.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/services/native_bridge.dart';
import '../core/services/transaction_detection_service.dart';
import '../../core/const/app_strings.dart';
import '../core/const/app_constants.dart';
import '../core/const/app_colors.dart';
import '../../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../../core/const/app_assets.dart';
import '../core/utils/blur_utils.dart';

import '../../widgets/header_delegate.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/glass_action_button.dart';
import '../../widgets/recording_hud.dart';
import '../core/view_models/person_view_model.dart';
import '../core/models/person_transaction.dart';
import '../core/utils/voice_parser.dart';
import '../core/services/speech_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../shared/widgets/home_app_bar.dart';
import '../shared/widgets/home_balance_section.dart';
import '../shared/widgets/home_search_bar.dart';
import '../shared/widgets/home_transaction_list.dart';

import 'settings_page.dart';
import 'transactions_history_page.dart';
>>>>>>> master

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showFab = true;
<<<<<<< HEAD
  String? _searchQuery;
  List<Transaction>? _filteredTransactions;
  StreamSubscription<String>? _uiEventSubscription;
=======
  double _turns = 0.0;
  StreamSubscription<String>? _uiEventSubscription;
  
  final SpeechService _speechService = SpeechService();
  String _recordingText = "";
  bool _isRecording = false;
>>>>>>> master

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
<<<<<<< HEAD
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final atTop = _scrollController.position.pixels <= 0;
      final shouldShowFab =
          atTop || context.read<TransactionViewModel>().transactions.isEmpty;
      if (shouldShowFab != _showFab) {
        setState(() => _showFab = shouldShowFab);
      }
    });

    // Handle incoming events from NativeBridge
    _uiEventSubscription = NativeBridge.uiEvents.listen((event) {
      _handleUiEvent(event);
    });

    // Check for any events that were missed during Splash screen
=======
    _scrollController.addListener(_scrollListener);

    _uiEventSubscription = NativeBridge.uiEvents.listen(_handleUiEvent);

>>>>>>> master
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingEvent = NativeBridge.consumePendingEvent();
      if (pendingEvent != null) {
        _handleUiEvent(pendingEvent);
      }
    });
  }

<<<<<<< HEAD
  void _handleUiEvent(String event) {
    // Solid delay to ensure: Splash is gone (1.5s) -> Transition finished (0.3s) -> Home visible (0.4s)
    // 2200ms ensures the user feels they have correctly "arrived" at the home screen.
    Future.delayed(const Duration(milliseconds: 2200), () {
=======
  void _scrollListener() {
    if (!_scrollController.hasClients || !mounted) return;

    final position = _scrollController.position;
    final atTop = position.pixels <= 0;

    final scrollingUp = position.userScrollDirection == ScrollDirection.forward;
    final scrollingDown =
        position.userScrollDirection == ScrollDirection.reverse;
    final isEmpty = context.read<TransactionViewModel>().transactions.isEmpty;

    bool nextShowFab = _showFab;

    if (isEmpty || atTop || scrollingUp) {
      nextShowFab = true;
    } else if (scrollingDown) {
      nextShowFab = false;
    }

    if (nextShowFab != _showFab) {
      setState(() => _showFab = nextShowFab);
    }
  }

  void _handleUiEvent(String event) {
    Future.delayed(AppConstants.homeArrivalDelay, () {
>>>>>>> master
      if (!mounted) return;
      if (event == 'SHOW_ADD_INCOME') {
        _showAddTransactionDialog(isIncome: true);
      } else if (event == 'SHOW_ADD_EXPENSE') {
        _showAddTransactionDialog(isIncome: false);
<<<<<<< HEAD
=======
      } else if (event == 'SHOW_VOICE_INPUT') {
        _startRecording();
      } else if (event == 'SYNC_STARTED') {
        context.read<TransactionViewModel>().setSyncing(true);
      } else if (event == 'SYNC_FINISHED') {
        context.read<TransactionViewModel>().setSyncing(false);
>>>>>>> master
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  void _showAddTransactionDialog({required bool isIncome}) {
<<<<<<< HEAD
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionDialog(isIncome: isIncome),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final transactionViewModel = context.watch<TransactionViewModel>();

    final txns =
        _filteredTransactions ?? transactionViewModel.sortedTransactions;
    final grouped = TransactionUtils.groupTransactionsByDate(txns);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, theme, themeViewModel.isDarkMode,
              themeViewModel.useAdaptiveColor),
          _buildBalanceSection(context, transactionViewModel),
          if (txns.isNotEmpty)
            _buildTransactionList(
                grouped, theme, themeViewModel.useAdaptiveColor)
          else
            _buildEmptyState(),
          SliverToBoxAdapter(
              child:
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80)),
        ],
      ),
      floatingActionButton: _showFab ? _buildDualFab(theme) : null,
    );
  }

  Widget _buildAppBar(
      BuildContext context, ThemeData theme, bool isDark, bool useAdaptive) {
    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getResponsiveAppBarHeight(context),
      floating: true,
      pinned: true,
      elevation: 1,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Aspends Tracker',
          style: GoogleFonts.nunito(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                mobile: 20, tablet: 24, desktop: 28),
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        background: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.8),
                    theme.colorScheme.primaryContainer.withOpacity(0.8)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.analytics_outlined),
          onPressed: () => _showAnalyticsDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
      ],
    );
  }

  Widget _buildBalanceSection(
      BuildContext context, TransactionViewModel viewModel) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                horizontal: 16, vertical: 8),
            child: BalanceCard(
              balance: viewModel.totalBalance,
              onBalanceUpdate: (newBalance) =>
                  viewModel.updateBalance(newBalance),
            ),
          ),
          Padding(
            padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.history,
                    size: ResponsiveUtils.getResponsiveIconSize(context,
                        mobile: 20, tablet: 24, desktop: 28)),
                const SizedBox(width: 8),
                Text('Recent Transactions',
                    style: GoogleFonts.nunito(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 18, tablet: 20, desktop: 22),
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.sort_rounded,
                      size: ResponsiveUtils.getResponsiveIconSize(context,
                          mobile: 20, tablet: 24, desktop: 28)),
                  onPressed: () => _showSortDialog(context, viewModel),
                ),
=======
    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: AddTransactionDialog(isIncome: isIncome),
    );
  }

  Future<void> _startRecording() async {
    final success = await _speechService.initSpeech();
    if (success) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isRecording = true;
        _recordingText = "";
      });
      _speechService.startListening((text) {
        setState(() => _recordingText = text);
      });
    } else {
      Fluttertoast.showToast(msg: "Speech recognition unavailable");
    }
  }

  Future<void> _stopAndSaveRecording() async {
    if (!_isRecording) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _isRecording = false);
    await _speechService.stopListening();

    if (_recordingText.isEmpty) return;

    final pvm = context.read<PersonViewModel>();
    final tvm = context.read<TransactionViewModel>();
    
    final result = VoiceParser.parse(
      _recordingText, 
      knownPeople: pvm.people.map((p) => p.name).toList(),
    );

    if (result.isRequest && result.amount != null && result.personName != null) {
      showDialog(
        context: context,
        builder: (context) => RequestMoneyDialog(
          personName: result.personName!,
          amount: result.amount!,
        ),
      );
      Fluttertoast.showToast(msg: "Opening Request QR for ${result.personName}");
      return; 
    }

    if (result.amount != null) {
      final tx = Transaction(
        amount: result.amount!,
        note: result.note,
        category: result.category ?? 'Other',
        account: 'Cash',
        date: DateTime.now(),
        isIncome: result.isIncome ?? false,
      );

      await tvm.addTransaction(tx);

      if (result.personName != null) {
        pvm.addPersonTransaction(
          PersonTransaction(
            personName: result.personName!,
            amount: tx.amount,
            note: tx.note,
            date: tx.date,
            isIncome: tx.isIncome,
          ), 
          result.personName!,
        );
      }

      Fluttertoast.showToast(
        msg: "Saved ₹${result.amount} for ${result.category ?? 'Other'}",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      HapticFeedback.vibrate();
      Fluttertoast.showToast(
        msg: "Couldn't find amount. Try: 'Spent 500 on Food'",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      // Fallback: Open manual dialog
      _showAddTransactionDialog(isIncome: result.isIncome ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionViewModel = context.watch<TransactionViewModel>();
    final isDark = context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode);

    final grouped = transactionViewModel.groupedFilteredTransactions;
    final txns = transactionViewModel.filteredTransactions;

    return Scaffold(
      extendBody: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              HomeAppBar(
                isDark: isDark,
                turns: _turns,
                isSyncing: transactionViewModel.isSyncing,
                onLeadingTap: () => setState(() => _turns += 4),
              ),
              HomeBalanceSection(viewModel: transactionViewModel),
              SliverPersistentHeader(
                pinned: true,
                delegate: HomeHeaderDelegate(
                  height: 140 * MediaQuery.textScalerOf(context).scale(1) +
                      20, // Dynamic height prevents overflow when system font size is increased
                  child: _buildPinnedHeader(context),
                ),
              ),
              if (txns.isNotEmpty)
                HomeTransactionList(grouped: grouped)
              else
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: txns.isNotEmpty
                      ? MediaQuery.of(context).padding.bottom +
                          AppDimensions.paddingXLarge * 2.5
                      : MediaQuery.of(context).padding.bottom +
                          AppDimensions.paddingXLarge * 3,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 130, // Lifted slightly higher for better layout
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              reverseDuration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                    ),
                    child: child,
                  ),
                );
              },
              child: _isRecording
                  ? RecordingHUD(
                      key: const ValueKey('recording_hud'),
                      text: _recordingText,
                      isListening: _isRecording,
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
          AnimatedSlide(
            offset: _showFab ? Offset.zero : const Offset(0, 2),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedOpacity(
              opacity: _showFab ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: _buildDualFab(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedHeader(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.15),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildDragHandle(context),
              const SizedBox(height: AppDimensions.paddingXSmall),
              HomeSearchBar(onFilterTap: () {
                HapticFeedback.mediumImpact();
                _showSortDialog(context);
              }),
              const SizedBox(height: AppDimensions.paddingXSmall),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingStandard,
                  vertical: AppDimensions.paddingSmall,
                ),
                child: _buildTransactionHeaderRow(context),
              ),
            ],
          ),
      ),
      ),
    );
  }

  Widget _buildTransactionHeaderRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.transactionsTitle,
            style: GoogleFonts.dmSans(
              fontSize: AppTypography.fontSizeSubHeader +
                  2, // Slightly larger for section header
              fontWeight: AppTypography
                  .fontWeightBlack, // Stronger weight for premium feel
              letterSpacing: -0.5,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TransactionsHistoryPage(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Text(
                  AppStrings.viewAllLabel,
                  style: GoogleFonts.dmSans(
                    fontSize: AppTypography.fontSizeSmall + 1,
                    fontWeight: AppTypography.fontWeightBold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                )
>>>>>>> master
              ],
            ),
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildTransactionList(Map<String, List<Transaction>> grouped,
      ThemeData theme, bool useAdaptive) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dateKey = grouped.keys.elementAt(index);
          final dayTxs = grouped[dateKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                    horizontal: 16, vertical: 8),
                child: Text(
                  dateKey,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                        mobile: 14, tablet: 16, desktop: 18),
                  ),
                ),
              ),
              ...dayTxs.asMap().entries.map((entry) => TransactionTile(
                    transaction: entry.value,
                    index: entry.key,
                  )),
            ],
          );
        },
        childCount: grouped.length,
=======
  void _showSortDialog(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<TransactionViewModel>();

    BlurUtils.showBlurredBottomSheet(
      context: context,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.borderRadiusXLarge)),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sort By',
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeLarge,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(
                context, 'Date (Newest)', SortOption.dateNewest, vm),
            _buildSortOption(
                context, 'Date (Oldest)', SortOption.dateOldest, vm),
            _buildSortOption(
                context, 'Amount (Highest)', SortOption.amountHighest, vm),
            _buildSortOption(
                context, 'Amount (Lowest)', SortOption.amountLowest, vm),
            _buildSortOption(context, 'Category', SortOption.category, vm),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String title, SortOption option,
      TransactionViewModel vm) {
    final theme = Theme.of(context);
    final isSelected = vm.currentSortOption == option;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        vm.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    return Center(
      child: Container(
        width: AppDimensions.avatarSizeStandard,
        height: AppDimensions.spacingXSmall,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppDimensions.spacingTiny),
        ),
>>>>>>> master
      ),
    );
  }

  Widget _buildEmptyState() {
<<<<<<< HEAD
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('No Transactions Yet',
                style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600)),
          ],
        ),
=======
    return EmptyStateView(
      icon: Icons.account_balance_wallet_outlined,
      title: AppStrings.emptyWalletTitle,
      description: AppStrings.emptyWalletDesc,
      action: FutureBuilder<bool>(
        future: TransactionDetectionService.isEnabled(),
        builder: (context, snapshot) {
          final isEnabled = snapshot.data ?? false;
          if (isEnabled) return const SizedBox.shrink();

          return ZoomTapAnimation(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                    blurRadius: AppDimensions.blurRadiusStandard,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.enableAutoDetection,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: AppTypography.fontWeightBold,
                      fontSize: AppTypography.fontSizeMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
>>>>>>> master
      ),
    );
  }

  Widget _buildDualFab(ThemeData theme) {
<<<<<<< HEAD
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionFab(
                  icon: Icons.add,
                  label: '',
                  color: Colors.green,
                  onTap: () => _showAddTransactionDialog(isIncome: true),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildActionFab(
                  icon: Icons.remove,
                  label: '',
                  color: Colors.red,
                  onTap: () => _showAddTransactionDialog(isIncome: false),
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionFab({
    required IconData icon,
    String? label,
    required Color color,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return ZoomTapAnimation(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            //const SizedBox(width: 8),
            Text(
              label!,
              style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController(text: _searchQuery);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'Search note, category...'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final query = controller.text.toLowerCase();
              setState(() {
                _searchQuery = query.isEmpty ? null : query;
                _filteredTransactions = query.isEmpty
                    ? null
                    : context
                        .read<TransactionViewModel>()
                        .transactions
                        .where((t) =>
                            t.note.toLowerCase().contains(query) ||
                            t.category.toLowerCase().contains(query))
                        .toList();
              });
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context, TransactionViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _sortOptionTile(context, viewModel, SortOption.dateNewest,
                'Date: NewestFirst', Icons.calendar_today),
            _sortOptionTile(context, viewModel, SortOption.dateOldest,
                'Date: Oldest First', Icons.history),
            _sortOptionTile(context, viewModel, SortOption.amountHighest,
                'Amount: Highest', Icons.arrow_upward),
            _sortOptionTile(context, viewModel, SortOption.amountLowest,
                'Amount: Lowest', Icons.arrow_downward),
            _sortOptionTile(context, viewModel, SortOption.category, 'Category',
                Icons.category),
          ],
        ),
      ),
    );
  }

  Widget _sortOptionTile(BuildContext context, TransactionViewModel viewModel,
      SortOption option, String title, IconData icon) {
    final isSelected = viewModel.currentSortOption == option;
    return ListTile(
      leading:
          Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
      title: Text(title,
          style: GoogleFonts.nunito(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        viewModel.setSortOption(option);
        Navigator.pop(context);
      },
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
    );
  }

  void _showAnalyticsDialog() {
    final viewModel = context.read<TransactionViewModel>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
                title: const Text('Total Income'),
                trailing: Text('₹${viewModel.totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green))),
            ListTile(
                title: const Text('Total Expenses'),
                trailing: Text('₹${viewModel.totalSpend.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.red))),
            ListTile(
                title: const Text('Net Balance'),
                trailing:
                    Text('₹${viewModel.totalBalance.toStringAsFixed(2)}')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
=======
    return GlassFab(
      marginBottom: 65,
      children: [
        ClipOval(
          child: GlassActionButton(
            icon: SvgAppIcons.incomeIcon,
            color: AppColors.accentGreen,
            onTap: () => _showAddTransactionDialog(isIncome: true),
          ),
        ),
        const SizedBox(width: 8),
        ClipOval(
          child: GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) async {
              await Future.delayed(const Duration(milliseconds: 900));
              _stopAndSaveRecording();
            },
            onLongPressUp: () async {
              // Both handlers used for robustness, delay ensures last words captured
              await Future.delayed(const Duration(milliseconds: 900));
              _stopAndSaveRecording();
            },
            child: GlassActionButton(
              icon: Icons.mic_rounded,
              color: theme.colorScheme.primary,
              onTap: () {
                Fluttertoast.showToast(msg: "Hold to record transaction");
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        ClipOval(
          child: GlassActionButton(
            icon: SvgAppIcons.expenseIcon,
            color: AppColors.accentRed,
            onTap: () => _showAddTransactionDialog(isIncome: false),
          ),
        ),
      ],
>>>>>>> master
    );
  }
}

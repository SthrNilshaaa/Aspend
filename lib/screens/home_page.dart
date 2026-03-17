import 'dart:ui';
import 'dart:async';

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

import '../../widgets/header_delegate.dart';
import '../../widgets/add_transaction_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/glass_action_button.dart';
import '../../widgets/floating_action_button.dart';
import '../../widgets/glass_app_bar.dart';

import '../shared/widgets/home_app_bar.dart';
import '../shared/widgets/home_balance_section.dart';
import '../shared/widgets/home_search_bar.dart';
import '../shared/widgets/home_transaction_list.dart';

import 'settings_page.dart';
import 'transactions_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showFab = true;
  double _turns = 0.0;
  StreamSubscription<String>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _uiEventSubscription = NativeBridge.uiEvents.listen(_handleUiEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingEvent = NativeBridge.consumePendingEvent();
      if (pendingEvent != null) {
        _handleUiEvent(pendingEvent);
      }
    });
  }

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
      if (!mounted) return;
      if (event == 'SHOW_ADD_INCOME') {
        _showAddTransactionDialog(isIncome: true);
      } else if (event == 'SHOW_ADD_EXPENSE') {
        _showAddTransactionDialog(isIncome: false);
      } else if (event == 'SYNC_STARTED') {
        context.read<TransactionViewModel>().setSyncing(true);
      } else if (event == 'SYNC_FINISHED') {
        context.read<TransactionViewModel>().setSyncing(false);
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AddTransactionDialog(isIncome: isIncome),
      ),
    );
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
      body: CustomScrollView(
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedSlide(
        offset: _showFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedOpacity(
          opacity: _showFab ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: _buildDualFab(theme),
        ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<TransactionViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
      )
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
      ),
    );
  }

  Widget _buildEmptyState() {
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
      ),
    );
  }

  Widget _buildDualFab(ThemeData theme) {
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
          child: GlassActionButton(
            icon: SvgAppIcons.expenseIcon,
            color: AppColors.accentRed,
            onTap: () => _showAddTransactionDialog(isIncome: false),
          ),
        ),
      ],
    );
  }
}

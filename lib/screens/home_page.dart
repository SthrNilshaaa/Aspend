import 'package:aspends_tracker/screens/detection_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../models/transaction.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/transaction_view_model.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/balance_card.dart';
import '../widgets/add_transaction_dialog.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/range_selector.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/glass_action_button.dart';
import '../utils/responsive_utils.dart';
import '../utils/transaction_utils.dart';
import 'settings_page.dart';
import 'transactions_history_page.dart';
import '../services/native_bridge.dart';
import '../services/transaction_detection_service.dart';
import '../const/app_assets.dart';
import '../const/app_strings.dart';
import '../const/app_constants.dart';
import '../const/app_colors.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _showFab = true;
  String? _searchQuery;
  List<Transaction>? _filteredTransactions;
  String _selectedRange = 'All'; // Day, Week, Month, Year, All
  DateTime _startDate = DateTime(2000);
  DateTime _endDate = DateTime.now();
  double _turns = 0.0;
  StreamSubscription<String>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pendingEvent = NativeBridge.consumePendingEvent();
      if (pendingEvent != null) {
        _handleUiEvent(pendingEvent);
      }
    });
  }

  void _handleUiEvent(String event) {
    // Solid delay to ensure: Splash is gone (1.5s) -> Transition finished (0.3s) -> Home visible (0.4s)
    // 2200ms ensures the user feels they have correctly "arrived" at the home screen.
    Future.delayed(AppConstants.homeArrivalDelay, () {
      if (!mounted) return;
      if (event == 'SHOW_ADD_INCOME') {
        _showAddTransactionDialog(isIncome: true);
      } else if (event == 'SHOW_ADD_EXPENSE') {
        _showAddTransactionDialog(isIncome: false);
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
      builder: (context) => AddTransactionDialog(isIncome: isIncome),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final transactionViewModel = context.watch<TransactionViewModel>();

    final rawTxns =
        _filteredTransactions ?? transactionViewModel.sortedTransactions;

    final txns = _selectedRange == 'All'
        ? rawTxns
        : transactionViewModel.getTransactionsInRange(_startDate, _endDate);

    final grouped = TransactionUtils.groupTransactionsByDate(txns);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            floating: false,
            title: AppStrings.appNameShort,
            leading: GestureDetector(
              onTap: () {
                setState(() {
                  _turns += 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppDimensions.paddingSmall +
                        AppDimensions.paddingXSmall),
                child: AnimatedRotation(
                  turns: _turns,
                  duration: const Duration(seconds: 1),
                  child: Center(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: SvgPicture.asset(
                          themeViewModel.isDarkMode
                              ? SvgAppIcons.lightLogoIcon
                              : SvgAppIcons.darkLogoIcon,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  //navigate to notification page
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DetectionHistoryPage()),
                    );
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surface.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: const Icon(Icons.notifications_none_rounded,
                            size: AppDimensions.iconSizeLarge),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: theme.colorScheme.surface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildBalanceSection(context, transactionViewModel),
          if (txns.isNotEmpty)
            _buildTransactionList(
                grouped, theme, themeViewModel.useAdaptiveColor)
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            ),
          SliverToBoxAdapter(
              child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom +
                      AppDimensions.paddingXLarge * 2.5)),
        ],
      ),
      floatingActionButton: _showFab ? _buildDualFab(theme) : null,
    );
  }

  void _updateDateRange() {
    final range = TransactionUtils.getDateRange(_selectedRange);
    _startDate = range.$1;
    _endDate = range.$2;
  }

  Widget _buildBalanceSection(
      BuildContext context, TransactionViewModel viewModel) {
    final isLargeScreen = !ResponsiveUtils.isMobile(context);

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingStandard,
                vertical:
                    AppDimensions.paddingSmall + AppDimensions.paddingXSmall),
            child: isLargeScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: BalanceCard(
                          balance: viewModel.totalBalance,
                          onBalanceUpdate: (newBalance) =>
                              viewModel.updateBalance(newBalance),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildBudgetProgress(context, viewModel,
                            isCompact: true),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      BalanceCard(
                        balance: viewModel.totalBalance,
                        onBalanceUpdate: (newBalance) =>
                            viewModel.updateBalance(newBalance),
                      ),
                      _buildBudgetProgress(context, viewModel),
                    ],
                  ),
          ),

          _buildDragHandle(context),

          const SizedBox(height: AppDimensions.paddingXSmall),
          _buildSearchSection(context),
          //
          const SizedBox(height: AppDimensions.paddingStandard),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingStandard,
                vertical: AppDimensions.paddingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.transactionsTitle,
                  style: GoogleFonts.dmSans(
                    fontSize: AppTypography.fontSizeSubHeader,
                    fontWeight: AppTypography.fontWeightBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const TransactionsHistoryPage()),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        AppStrings.viewAllLabel,
                        style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeSmall,
                          fontWeight: AppTypography.fontWeightMedium,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: AppDimensions.iconSizeMedium,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.paddingXSmall),
          _buildRangeSelector(context),
          const SizedBox(height: AppDimensions.paddingStandard),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    final transactionViewModel = context.watch<TransactionViewModel>();
    final isDark = context.watch<ThemeViewModel>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingStandard,
          vertical: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusFull),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          SvgAppIcons.searchIcon,
                          colorFilter: ColorFilter.mode(
                              theme.colorScheme.primary, BlendMode.srcIn),
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        final query = val.toLowerCase();
                        setState(() {
                          _searchQuery = query.isEmpty ? null : query;
                          _filteredTransactions = query.isEmpty
                              ? null
                              : transactionViewModel.transactions
                                  .where((t) =>
                                      t.note.toLowerCase().contains(query) ||
                                      t.category.toLowerCase().contains(query))
                                  .toList();
                        });
                      },
                      //transaparnt search bar
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        hintStyle: GoogleFonts.dmSans(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: AppTypography.fontSizeSmall,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchQuery != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = null;
                                    _filteredTransactions = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      style: GoogleFonts.dmSans(
                        fontSize: AppTypography.fontSizeSmall,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ZoomTapAnimation(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSortDialog(context);
            },
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  SvgAppIcons.filterIcon,
                  colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary, BlendMode.srcIn),
                  width: 20,
                  height: 20,
                ),
              ),
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
      builder: (context) => Container(
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

  Widget _buildRangeSelector(BuildContext context) {
    return RangeSelector(
      ranges: const ['All', 'Day', 'Week', 'Month', 'Year'],
      selectedRange: _selectedRange,
      onRangeSelected: (range) {
        setState(() {
          _selectedRange = range;
          _updateDateRange();
        });
      },
    );
  }

  Widget _buildTransactionList(Map<String, List<Transaction>> grouped,
      ThemeData theme, bool useAdaptive) {
    return SliverPadding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppDimensions.paddingStandard),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dateKey = grouped.keys.elementAt(index);
            final dayTxs = grouped[dateKey]!;
            final relativeDate = TransactionUtils.formatRelativeDate(dateKey);

            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: AppDimensions.paddingXSmall,
                        bottom: AppDimensions.paddingXSmall),
                    child: Text(
                      relativeDate,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: AppTypography.fontSizeSmall,
                            tablet: AppTypography.fontSizeMedium,
                            desktop: AppTypography.fontSizeSmall + 4),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...dayTxs.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingSmall),
                        child: TransactionTile(
                          transaction: entry.value,
                          index: entry.key,
                        ),
                      )),
                ],
              ),
            );
          },
          childCount: grouped.length,
        ),
      ),
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
      children: [
        GlassActionButton(
          icon: SvgAppIcons.incomeIcon,
          color: AppColors.accentGreen,
          onTap: () => _showAddTransactionDialog(isIncome: true),
        ),
        const SizedBox(width: 8),
        GlassActionButton(
          icon: SvgAppIcons.expenseIcon,
          color: AppColors.accentRed,
          onTap: () => _showAddTransactionDialog(isIncome: false),
        ),
      ],
    );
  }

  Widget _buildBudgetProgress(
      BuildContext context, TransactionViewModel viewModel,
      {bool isCompact = false}) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final budget = themeViewModel.monthlyBudget;
    if (budget <= 0) return const SizedBox.shrink();

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyTxs =
        viewModel.getTransactionsInRange(startOfMonth, endOfMonth);
    final spent = monthlyTxs
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final percentage = (spent / budget).clamp(0.0, 1.0);
    final isOverBudget = spent > budget;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 16, vertical: isCompact ? 8 : 8),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(
            color: isOverBudget
                ? Colors.redAccent.withValues(alpha: 0.3)
                : theme.dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppDimensions.spacingStandard - 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.budget,
                    style: GoogleFonts.dmSans(
                      fontWeight: AppTypography.fontWeightExtraBold,
                      fontSize: isCompact
                          ? AppTypography.fontSizeSmall
                          : AppTypography.fontSizeMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${spent.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: isCompact ? 13 : 14,
                    color: isOverBudget ? Colors.redAccent : Colors.grey,
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: isCompact ? 8 : 10,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget
                      ? AppColors.accentRed
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            if (!isCompact && isOverBudget) ...[
              const SizedBox(height: AppDimensions.paddingLarge),
              Text(
                '⚠️ Over by ₹${(spent - budget).toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeXSmall,
                  color: AppColors.accentRed,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

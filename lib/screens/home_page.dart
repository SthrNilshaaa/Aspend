import 'package:flutter/material.dart';
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
import '../services/native_bridge.dart';
import '../services/transaction_detection_service.dart';
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
    Future.delayed(const Duration(milliseconds: 2200), () {
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
          GlassAppBar(title: 'Aspends Tracker'),
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
              child:
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 80)),
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
            padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                horizontal: 8, vertical: 8),
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
          _buildSearchSection(context),
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
              ],
            ),
          ),
          _buildRangeSelector(context),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (val) {
          final query = val.toLowerCase();
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
        },
        decoration: InputDecoration(
          hintText: 'Search note, category...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery != null
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      _searchQuery = null;
                      _filteredTransactions = null;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        style: GoogleFonts.nunito(),
      ),
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
                    horizontal: 10, vertical: 6),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateView(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Your wallet is quiet',
      description:
          'Start by adding a transaction manually or enable auto-detection to track your spending effortlessly.',
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
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                    blurRadius: 15,
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
                    'Enable Auto-Detection',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
          icon: Icons.add,
          color: Colors.green,
          onTap: () => _showAddTransactionDialog(isIncome: true),
        ),
        const SizedBox(width: 8),
        GlassActionButton(
          icon: Icons.remove,
          color: Colors.red,
          onTap: () => _showAddTransactionDialog(isIncome: false),
        ),
      ],
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isOverBudget
                ? Colors.redAccent.withValues(alpha: 0.3)
                : theme.dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
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
                    'Budget',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: isCompact ? 14 : 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${spent.toStringAsFixed(0)}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: isCompact ? 13 : 14,
                    color: isOverBudget ? Colors.redAccent : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: isCompact ? 8 : 10,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget ? Colors.redAccent : theme.colorScheme.primary,
                ),
              ),
            ),
            if (!isCompact && isOverBudget) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Over by ₹${(spent - budget).toStringAsFixed(0)}',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

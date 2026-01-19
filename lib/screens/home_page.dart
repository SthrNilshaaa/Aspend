import 'dart:ui';
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
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.8)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDialog(),
        ),
      ],
    );
  }

  void _updateDateRange() {
    final now = DateTime.now();
    _endDate = now;
    if (_selectedRange == 'Day') {
      _startDate = DateTime(now.year, now.month, now.day);
    } else if (_selectedRange == 'Week') {
      _startDate = now.subtract(Duration(days: now.weekday - 1));
      _startDate = DateTime(_startDate.year, _startDate.month, _startDate.day);
    } else if (_selectedRange == 'Month') {
      _startDate = DateTime(now.year, now.month, 1);
    } else if (_selectedRange == 'Year') {
      _startDate = DateTime(now.year, 1, 1);
    } else {
      _startDate = DateTime(2000);
    }
  }

  Widget _buildBalanceSection(
      BuildContext context, TransactionViewModel viewModel) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                horizontal: 8, vertical: 8),
            child: BalanceCard(
              balance: viewModel.totalBalance,
              onBalanceUpdate: (newBalance) =>
                  viewModel.updateBalance(newBalance),
            ),
          ),
          _buildBudgetProgress(context, viewModel),
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

  Widget _buildRangeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final ranges = ['All', 'Day', 'Week', 'Month', 'Year'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ranges.map((range) {
          final isSelected = _selectedRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ZoomTapAnimation(
              onTap: () {
                setState(() {
                  _selectedRange = range;
                  _updateDateRange();
                });
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor.withValues(alpha: 0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  range,
                  style: GoogleFonts.nunito(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
    final theme = Theme.of(context);
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Your wallet is quiet',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Start by adding a transaction manually or enable auto-detection to track your spending effortlessly.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              FutureBuilder<bool>(
                future: TransactionDetectionService.isEnabled(),
                builder: (context, snapshot) {
                  final isEnabled = snapshot.data ?? false;
                  if (isEnabled) return const SizedBox.shrink();

                  return ZoomTapAnimation(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDualFab(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
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

  Widget _buildBudgetProgress(
      BuildContext context, TransactionViewModel viewModel) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
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
                Text(
                  'Monthly Budget',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₹${spent.toStringAsFixed(0)} / ₹${budget.toStringAsFixed(0)}',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
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
                minHeight: 10,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget ? Colors.redAccent : theme.colorScheme.primary,
                ),
              ),
            ),
            if (isOverBudget) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ You have exceeded your budget by ₹${(spent - budget).toStringAsFixed(0)}',
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

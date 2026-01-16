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
import '../services/native_bridge.dart';
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
              ],
            ),
          ),
        ],
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
      ),
    );
  }

  Widget _buildEmptyState() {
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
    );
  }
}

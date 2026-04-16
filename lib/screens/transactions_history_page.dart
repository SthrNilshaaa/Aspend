import 'dart:ui';
import 'package:aspends_tracker/core/models/transaction.dart';

import '../../widgets/history_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/view_models/theme_view_model.dart';
import '../../widgets/range_selector.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/glass_app_bar.dart';
import '../core/utils/transaction_utils.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';

class TransactionsHistoryPage extends StatefulWidget {
  const TransactionsHistoryPage({super.key});

  @override
  State<TransactionsHistoryPage> createState() =>
      _TransactionsHistoryPageState();
}

class _TransactionsHistoryPageState extends State<TransactionsHistoryPage> {
  bool _isSelectionMode = false;
  final Set<Transaction> _selectedTransactions = {};

  void _toggleSelection(Transaction tx) {
    setState(() {
      if (_selectedTransactions.contains(tx)) {
        _selectedTransactions.remove(tx);
        if (_selectedTransactions.isEmpty) _isSelectionMode = false;
      } else {
        _selectedTransactions.add(tx);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _enterSelectionMode(Transaction tx) {
    setState(() {
      _isSelectionMode = true;
      _selectedTransactions.add(tx);
    });
    HapticFeedback.mediumImpact();
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTransactions.clear();
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_selectedTransactions.length} transactions?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final txsToDelete = _selectedTransactions.toList();
      _exitSelectionMode();
      await context
          .read<TransactionViewModel>()
          .deleteMultipleTransactions(txsToDelete);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted ${txsToDelete.length} transactions')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<TransactionViewModel>();

    final grouped = viewModel.groupedFilteredTransactions;
    final hasTransactions = grouped.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          GlassAppBar(
            title: _isSelectionMode
                ? '${_selectedTransactions.length} Selected'
                : 'Transaction History',
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (_isSelectionMode) {
                  _exitSelectionMode();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppDimensions.paddingSmall +
                        AppDimensions.paddingSmall),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Icon(
                        _isSelectionMode ? Icons.close : Icons.arrow_back,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: _deleteSelected,
                  ),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: HistorySearchBar(
              searchQuery: context.select<TransactionViewModel, String?>(
                  (vm) => vm.searchQuery),
              isDark:
                  context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode),
              onSearchChanged: (val) =>
                  context.read<TransactionViewModel>().setSearchQuery(val),
              onClear: () =>
                  context.read<TransactionViewModel>().setSearchQuery(null),
              onFilterTap: () {
                HapticFeedback.mediumImpact();
                _showSortDialog(context);
              },
            ),
          ),
          SliverToBoxAdapter(
            child: _buildRangeSelector(context),
          ),
          if (!hasTransactions)
            const SliverFillRemaining(
              child: Center(child: Text('No transactions found')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingStandard),
              sliver: SliverList.builder(
                itemCount: grouped.entries.length,
                itemBuilder: (context, index) {
                  final entry = grouped.entries.elementAt(index);
                  final dateKey = entry.key;
                  final dayTxs = entry.value;

                  final dateKeyStr =
                      "${dateKey.year}-${dateKey.month.toString().padLeft(2, '0')}-${dateKey.day.toString().padLeft(2, '0')}";
                  final relativeDate =
                      TransactionUtils.formatRelativeDate(dateKeyStr);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        child: Text(
                          relativeDate,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.8),
                            fontSize: AppTypography.fontSizeSmall,
                          ),
                        ),
                      ),
                      // Inner column is fine here since it only holds a single day's transactions (usually small)
                      // and changing it to nested slivers is overly complex for a date-grouped list.
                      ...dayTxs.asMap().entries.map((txEntry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TransactionTile(
                              transaction: txEntry.value,
                              index: txEntry.key,
                              isSelectionMode: _isSelectionMode,
                              isSelected:
                                  _selectedTransactions.contains(txEntry.value),
                              onSelectionToggled: () =>
                                  _toggleSelection(txEntry.value),
                              onLongPress: () =>
                                  _enterSelectionMode(txEntry.value),
                            ),
                          )),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRangeSelector(BuildContext context) {
    final selectedRange =
        context.select<TransactionViewModel, String>((vm) => vm.selectedRange);
    return RangeSelector(
      ranges: const ['All', 'Day', 'Week', 'Month', 'Year'],
      selectedRange: selectedRange,
      onRangeSelected: (range) {
        context.read<TransactionViewModel>().setSelectedRange(range);
      },
    );
  }

  void _showSortDialog(BuildContext context) {
    final theme = Theme.of(context);
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
              _buildSortOption(context, 'Date (Newest)', SortOption.dateNewest),
              _buildSortOption(context, 'Date (Oldest)', SortOption.dateOldest),
              _buildSortOption(
                  context, 'Amount (Highest)', SortOption.amountHighest),
              _buildSortOption(
                  context, 'Amount (Lowest)', SortOption.amountLowest),
              _buildSortOption(context, 'Category', SortOption.category),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(
      BuildContext context, String title, SortOption option) {
    final theme = Theme.of(context);
    final vm = context.read<TransactionViewModel>();
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
}

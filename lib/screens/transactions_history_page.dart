import '../widgets/history_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../widgets/range_selector.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/glass_app_bar.dart';
import '../utils/transaction_utils.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../const/app_assets.dart';

class TransactionsHistoryPage extends StatefulWidget {
  const TransactionsHistoryPage({super.key});

  @override
  State<TransactionsHistoryPage> createState() =>
      _TransactionsHistoryPageState();
}

class _TransactionsHistoryPageState extends State<TransactionsHistoryPage> {
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
            title: 'Transaction History',
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
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
                      child: SvgPicture.asset(
                        SvgAppIcons.backButtonIcon,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
              sliver: SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: Column(
                    children: grouped.entries.map((entry) {
                      final dateKey = entry.key;
                      final dayTxs = entry.value;

                      // Convert DateTime back to the format history expects or update history to handle DateTime
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
                          ...dayTxs.asMap().entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TransactionTile(
                                  transaction: entry.value,
                                  index: entry.key,
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../view_models/transaction_view_model.dart';
import '../view_models/theme_view_model.dart';
import '../widgets/range_selector.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/glass_app_bar.dart';
import '../utils/transaction_utils.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../const/app_assets.dart';
import '../const/app_strings.dart';

class TransactionsHistoryPage extends StatefulWidget {
  const TransactionsHistoryPage({super.key});

  @override
  State<TransactionsHistoryPage> createState() =>
      _TransactionsHistoryPageState();
}

class _TransactionsHistoryPageState extends State<TransactionsHistoryPage> {
  String? _searchQuery;
  // String? _searchQuery; // Handled by state
  // List<Transaction>? _filteredTransactions; // Removing to ensure reactivity
  String _selectedRange = 'All';

  void _updateDateRange() {
    // This now just triggers a rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionViewModel = context.watch<TransactionViewModel>();
    final allSorted = transactionViewModel.sortedTransactions;

    DateTime? startDate;
    final now = DateTime.now();

    switch (_selectedRange) {
      case 'Day':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'Month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'All':
      default:
        startDate = null;
    }

    final rawTxns = allSorted.where((t) {
      final matchesRange = startDate == null ||
          t.date.isAfter(startDate!.subtract(const Duration(seconds: 1)));
      final matchesSearch = _searchQuery == null ||
          t.note.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
          t.category.toLowerCase().contains(_searchQuery!.toLowerCase());
      return matchesRange && matchesSearch;
    }).toList();

    final grouped = TransactionUtils.groupTransactionsByDate(rawTxns);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const GlassAppBar(
            title: 'Transaction History',
            centerTitle: true,
          ),
          SliverToBoxAdapter(
            child: _buildSearchSection(context),
          ),
          SliverToBoxAdapter(
            child: _buildRangeSelector(context),
          ),
          if (rawTxns.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text('No transactions found')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingStandard),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dateKey = grouped.keys.elementAt(index);
                    final dayTxs = grouped[dateKey]!;
                    final relativeDate =
                        TransactionUtils.formatRelativeDate(dateKey);

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
                  },
                  childCount: grouped.length,
                ),
              ),
            ),
        ],
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
                        setState(() {
                          _searchQuery = val.toLowerCase().isEmpty
                              ? null
                              : val.toLowerCase();
                          _updateDateRange();
                        });
                      },
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
                                    _updateDateRange();
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
}

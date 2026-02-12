import 'package:aspends_tracker/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../const/app_colors.dart';
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
                    decoration:   BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding:   const EdgeInsets.all(15.0),
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
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final transactionViewModel = context.watch<TransactionViewModel>();
    // return SearchFilterBar(
    //   searchQuery: _searchQuery,
    //   onSearchChanged: (val) {
    //     setState(() {
    //       _searchQuery = val.toLowerCase().isEmpty ? null : val.toLowerCase();
    //       _updateDateRange();
    //     });
    //   },
    //   onClear: () {
    //     setState(() {
    //     _searchQuery = null;
    //     _updateDateRange();
    //   }); },
    //   onSortTap: () {
    //
    //     HapticFeedback.mediumImpact();
    //     _showSortDialog(context);      },
    //
    // );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingStandard,
          vertical: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.primaryColor.withValues(alpha: 0.05)
                // : Colors.black.withValues(alpha: 0.05),
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMinLarge),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.balanceCardDarkModePositive
                            : AppColors.balanceCardLightModePositive,
                        // color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        border: Border.all(
                            color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            width: 1.4),
                        borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusRegular),),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.borderRadiusMedium),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              SvgAppIcons.searchIcon,
                              colorFilter:const ColorFilter.mode(
                                // theme.colorScheme.primary,
                                  AppColors.accentGreen,
                                  BlendMode.srcIn),
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase().isEmpty ? null : val.toLowerCase();
                          _updateDateRange();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeSmall,
                          color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _searchQuery != null
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchQuery = null;
                            });
                          },
                        )
                            : null,
                      ),
                      style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeRegular,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.1
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          ZoomTapAnimation(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showSortDialog(context);
            },
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(

                borderRadius:  BorderRadius.circular(AppDimensions.borderRadiusMinLarge),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.4,
                ),
              ),
              child: Center(
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color:isDark
                        ?AppColors.balanceCardDarkModePositive
                        :AppColors.balanceCardLightModePositive,
                    // color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                        width: 1.4
                    ),
                    borderRadius:  BorderRadius.circular(AppDimensions.borderRadiusRegular
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(

                        borderRadius:  BorderRadius.circular(AppDimensions.borderRadiusMedium),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          SvgAppIcons.filterIcon,
                          colorFilter: const ColorFilter.mode(
                             AppColors.accentGreen, BlendMode.srcIn),
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                  ),
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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/models/transaction.dart';
import '../core/view_models/theme_view_model.dart';
import '../core/view_models/transaction_view_model.dart';
import '../../widgets/transaction_tile.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/modern_card.dart';
import '../../widgets/glass_app_bar.dart';
import '../../widgets/range_selector.dart';
import '../../widgets/empty_state_view.dart';
import '../core/utils/responsive_utils.dart';
import '../core/utils/transaction_utils.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_assets.dart';
import 'package:aspends_tracker/l10n/generated/app_localizations.dart';

class _TrendData {
  double income = 0.0;
  double expense = 0.0;
}

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRange = 'All'; // Day, Week, Month, Year
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
    _updateDateRange();
  }

  void _updateDateRange() {
    final range = TransactionUtils.getDateRange(_selectedRange);
    _startDate = range.$1;
    _endDate = range.$2;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final vm = context.watch<TransactionViewModel>();

    final filteredTxs = vm.getTransactionsInRange(_startDate, _endDate);
    final totalIncome =
        filteredTxs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount);
    final totalSpend =
        filteredTxs.where((t) => !t.isIncome).fold(0.0, (s, t) => s + t.amount);

    // --- NEW INSIGHT CALCULATIONS ---
    // 1. Top Category
    final categoryMap = <String, double>{};
    for (var tx in filteredTxs.where((t) => !t.isIncome)) {
      categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amount;
    }
    String? topCategory;
    double topCategoryAmount = 0;
    categoryMap.forEach((cat, amt) {
      if (amt > topCategoryAmount) {
        topCategoryAmount = amt;
        topCategory = cat;
      }
    });

    // 2. Average Daily spending
    final days = _endDate.difference(_startDate).inDays + 1;
    final avgSpending = totalSpend / (days > 0 ? days : 1);
    // -------------------------------

    final isLargeScreen = !ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              GlassAppBar(
                title: l10n.analytics,
                centerTitle: true,
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.paddingLarge)),
              SliverToBoxAdapter(
                child: RangeSelector(
                  ranges: const ['All', 'Day', 'Week', 'Month', 'Year'],
                  selectedRange: _selectedRange,
                  labels: {
                    'All': l10n.rangeAll,
                    'Day': l10n.rangeDay,
                    'Week': l10n.rangeWeek,
                    'Month': l10n.rangeMonth,
                    'Year': l10n.rangeYear,
                  },
                  onRangeSelected: (range) {
                    setState(() {
                      _selectedRange = range;
                      _updateDateRange();
                    });
                  },
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.paddingLarge)),
              if (filteredTxs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(isDark, l10n),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                        horizontal: AppDimensions.paddingStandard, vertical: 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                title: l10n.income,
                                amount: totalIncome,
                                color: AppColors.accentGreen,
                                icon: SvgAppIcons.incomeIcon,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(
                                width: AppDimensions.paddingSmall +
                                    AppDimensions.paddingXSmall),
                            Expanded(
                              child: StatCard(
                                title: l10n.expenses,
                                amount: totalSpend,
                                color: AppColors.accentRed,
                                icon: SvgAppIcons.expenseIcon,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Insight Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildInsightCard(
                                context,
                                title: l10n.topCategory,
                                value: topCategory ?? 'N/A',
                                subtitle: topCategory != null
                                    ? '₹${topCategoryAmount.toStringAsFixed(0)}'
                                    : l10n.noSpending,
                                icon: topCategory != null
                                    ? TransactionUtils.getCategorySvg(
                                        topCategory!)
                                    : Icons.category_rounded,
                                color: topCategory != null
                                    ? TransactionUtils.getCategoryColor(
                                        topCategory!)
                                    : Colors.blueAccent,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildInsightCard(
                                context,
                                title: l10n.avgDailySpend,
                                value: '₹${avgSpending.toStringAsFixed(0)}',
                                subtitle: l10n.perDay,
                                icon: Icons.timer_rounded,
                                color: Colors.orangeAccent,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingLarge),
                      ],
                    ),
                  ),
                ),
                if (isLargeScreen)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                          horizontal: AppDimensions.paddingStandard,
                          vertical: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _buildChartTabs(isDark),
                                const SizedBox(
                                    height: AppDimensions.paddingStandard),
                                ModernCard(
                                  padding: const EdgeInsets.all(
                                      AppDimensions.paddingLarge),
                                  child: SizedBox(
                                    height: ResponsiveUtils
                                        .getResponsiveChartHeight(context),
                                    child: TabBarView(
                                      controller: _tabController,
                                      children: [
                                        _buildPieChart(
                                            totalIncome, totalSpend, isDark, l10n),
                                        _buildBarChart(filteredTxs, isDark, l10n),
                                        _buildCategoryChart(
                                            filteredTxs, isDark, l10n),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingLarge),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                    height: AppDimensions.paddingStandard),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxHeight: ResponsiveUtils
                                            .getResponsiveChartHeight(context) +
                                        100,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filteredTxs.length,
                                    itemBuilder: (context, index) =>
                                        TransactionTile(
                                      transaction: filteredTxs[index],
                                      index: index,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                          horizontal: AppDimensions.paddingStandard,
                          vertical: 0),
                      child: Column(
                        children: [
                          _buildChartTabs(isDark),
                          const SizedBox(height: AppDimensions.paddingStandard),
                          ModernCard(
                            padding: const EdgeInsets.all(
                                AppDimensions.paddingLarge),
                            child: SizedBox(
                              height: ResponsiveUtils.getResponsiveChartHeight(
                                  context),
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildPieChart(
                                      totalIncome, totalSpend, isDark, l10n),
                                  _buildBarChart(filteredTxs, isDark, l10n),
                                  _buildCategoryChart(filteredTxs, isDark, l10n),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingXLarge),
                          _buildSectionHeader(l10n.history),
                          const SizedBox(height: AppDimensions.paddingStandard),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                        horizontal: AppDimensions.paddingStandard, vertical: 0),
                    sliver: SliverList.builder(
                      itemCount: filteredTxs.length,
                      itemBuilder: (context, index) => TransactionTile(
                          transaction: filteredTxs[index], index: index),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: AppTypography.fontSizeLarge,
            fontWeight: AppTypography.fontWeightBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required dynamic icon,
    required Color color,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: icon is String
                ? SvgPicture.asset(icon,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    width: 18,
                    height: 18)
                : Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartTabs(bool isDark) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: AppDimensions.tabBarHeight,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
        labelStyle: GoogleFonts.dmSans(
            fontWeight: AppTypography.fontWeightExtraBold,
            fontSize: AppTypography.fontSizeSmall - 1),
        unselectedLabelStyle: GoogleFonts.dmSans(
            fontWeight: AppTypography.fontWeightSemiBold,
            fontSize: AppTypography.fontSizeSmall - 1),
        dividerColor: Colors.transparent,
        onTap: (index) {
          setState(() {});
          HapticFeedback.lightImpact();
        },
        tabs: [
          Tab(text: l10n.overview),
          Tab(text: l10n.trends),
          Tab(text: l10n.categories),
        ],
      ),
    );
  }

  Widget _buildPieChart(double totalIncome, double totalSpend, bool isDark, AppLocalizations l10n) {
    final total = totalIncome + totalSpend;
    if (total == 0) return _buildEmptyState(isDark, l10n);

    final netBalance = totalIncome - totalSpend;
    final isSurplus = netBalance >= 0;
    final theme = Theme.of(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.totalBalance,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${isSurplus ? '+' : ''}₹${netBalance.toStringAsFixed(0)}',
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeMedium,
                fontWeight: FontWeight.w800,
                color: isSurplus ? AppColors.accentGreen : AppColors.accentRed,
              ),
            ),
          ],
        ),
        PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    _touchedPieIndex = -1;
                    return;
                  }
                  _touchedPieIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            sections: [
              PieChartSectionData(
                value: totalSpend,
                title: '${((totalSpend / total) * 100).toStringAsFixed(0)}%',
                color: AppColors.accentRed.withValues(alpha: 0.8),
                radius: _touchedPieIndex == 0
                    ? AppDimensions.chartRadiusSmall + 10
                    : AppDimensions.chartRadiusSmall,
                titleStyle: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: AppTypography.fontWeightBold,
                    fontSize: AppTypography.fontSizeXSmall),
                badgeWidget:
                    _buildPieBadge(SvgAppIcons.expenseIcon, AppColors.accentRed),
                badgePositionPercentageOffset: 1.15,
              ),
              PieChartSectionData(
                value: totalIncome,
                title: '${((totalIncome / total) * 100).toStringAsFixed(0)}%',
                color: AppColors.accentGreen.withValues(alpha: 0.8),
                radius: _touchedPieIndex == 1
                    ? AppDimensions.chartRadiusLarge + 10
                    : AppDimensions.chartRadiusLarge,
                titleStyle: GoogleFonts.dmSans(
                    color: Colors.white,
                    fontWeight: AppTypography.fontWeightBold,
                    fontSize: AppTypography.fontSizeXSmall),
                badgeWidget:
                    _buildPieBadge(SvgAppIcons.incomeIcon, AppColors.accentGreen),
                badgePositionPercentageOffset: 1.15,
              ),
            ],
            centerSpaceRadius: AppDimensions.avatarSizeStandard + 8,
            sectionsSpace: AppDimensions.paddingXSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildPieBadge(dynamic icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXSmall),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: icon is String
          ? SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: AppTypography.fontSizeMedium,
              height: AppTypography.fontSizeMedium,
            )
          : Icon(icon, color: color, size: AppTypography.fontSizeMedium),
    );
  }

  Widget _buildBarChart(List<Transaction> transactions, bool isDark, AppLocalizations l10n) {
    if (transactions.isEmpty) return _buildEmptyState(isDark, l10n);

    // 1. Group transactions by selected range
    final Map<String, _TrendData> groupedData = {};
    final Map<String, String> labels = {};

    // Sort all transactions chronologically first
    final sortedTx = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (var tx in sortedTx) {
      String key;
      String label;

      if (_selectedRange == 'Year' || _selectedRange == 'All') {
        key = DateFormat('yyyy-MM').format(tx.date);
        label = DateFormat.MMM().format(tx.date);
      } else if (_selectedRange == 'Day') {
        key = DateFormat('HH').format(tx.date);
        label = '${DateFormat('HH').format(tx.date)}:00';
      } else {
        key = DateFormat('yyyy-MM-dd').format(tx.date);
        label = DateFormat.Md().format(tx.date);
      }

      final data = groupedData.putIfAbsent(key, () => _TrendData());
      if (tx.isIncome) {
        data.income += tx.amount;
      } else {
        data.expense += tx.amount;
      }
      labels[key] = label;
    }

    final entries = groupedData.entries.toList();
    // Already sorted because we iterated over sorted transactions

    double maxVal = 0;
    for (var entry in entries) {
      if (entry.value.income > maxVal) maxVal = entry.value.income;
      if (entry.value.expense > maxVal) maxVal = entry.value.expense;
    }
    if (maxVal == 0) maxVal = 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final isIncome = rodIndex == 0;
              return BarTooltipItem(
                '${isIncome ? l10n.income : l10n.expense}\n₹${rod.toY.toStringAsFixed(0)}',
                GoogleFonts.dmSans(
                  fontWeight: AppTypography.fontWeightBold,
                  color: isIncome ? AppColors.accentGreen : AppColors.accentRed,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  // Show fewer labels if there are many bars
                  if (entries.length > 10 &&
                      index % (entries.length ~/ 5) != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        labels[entries[index].key] ?? '',
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: Colors.grey,
                          fontWeight: AppTypography.fontWeightBold,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          final index = e.key;
          final value = e.value.value;
          return BarChartGroupData(
            x: index,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: value.income,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentGreen,
                    AppColors.accentGreen.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                width: entries.length > 15 ? 6 : 10,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: value.expense,
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentRed,
                    AppColors.accentRed.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                width: entries.length > 15 ? 6 : 10,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChart(List<Transaction> transactions, bool isDark, AppLocalizations l10n) {
    Map<String, double> categoryData = {};
    for (var tx in transactions) {
      if (!tx.isIncome) {
        categoryData[tx.category] =
            (categoryData[tx.category] ?? 0) + tx.amount;
      }
    }

    final sortedItems = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedItems.isEmpty) return _buildEmptyState(isDark, l10n);

    // Calculate total once outside the builder to prevent O(n^2) complexity
    final total = categoryData.values.reduce((a, b) => a + b);

    return ListView.builder(
      itemCount: sortedItems.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        final percentage = (item.value / total);

        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingSmall + AppDimensions.paddingTiny),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppDimensions.spacingMedium,
                        height: AppDimensions.spacingMedium,
                        decoration: BoxDecoration(
                          color: TransactionUtils.getCategoryColor(item.key)
                              .withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SvgPicture.asset(
                            TransactionUtils.getCategorySvg(item.key),
                            colorFilter: ColorFilter.mode(
                                TransactionUtils.getCategoryColor(item.key),
                                BlendMode.srcIn),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.paddingSmall),
                      Text(item.key,
                          style: GoogleFonts.dmSans(
                              fontWeight: AppTypography.fontWeightBold)),
                    ],
                  ),
                  Text('₹${item.value.toStringAsFixed(0)}',
                      style: GoogleFonts.dmSans(
                          fontWeight: AppTypography.fontWeightExtraBold,
                          color: Colors.grey)),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSmall),
              Stack(
                children: [
                  Container(
                    height: AppDimensions.paddingSmall,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.paddingXSmall),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: percentage),
                    builder: (context, animatedValue, child) {
                      return FractionallySizedBox(
                        widthFactor: animatedValue,
                        child: Container(
                          height: AppDimensions.paddingSmall,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.paddingXSmall),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, AppLocalizations l10n) {
    return EmptyStateView(
      icon: Icons.auto_graph_rounded,
      title: l10n.noDataFound,
    );
  }
}

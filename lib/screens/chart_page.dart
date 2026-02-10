import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/transaction.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/transaction_view_model.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/stat_card.dart';
import '../widgets/modern_card.dart';
import '../widgets/glass_app_bar.dart';
import '../widgets/range_selector.dart';
import '../widgets/empty_state_view.dart';
import '../utils/responsive_utils.dart';
import '../utils/transaction_utils.dart';
import '../const/app_strings.dart';
import '../const/app_colors.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../const/app_assets.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedRange = 'Month'; // Day, Week, Month, Year
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

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
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          GlassAppBar(
            title: AppStrings.analytics,
            centerTitle: true,
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.paddingLarge)),
          SliverToBoxAdapter(
            child: RangeSelector(
              ranges: const ['Day', 'Week', 'Month', 'Year'],
              selectedRange: _selectedRange,
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
          SliverToBoxAdapter(
            child: Consumer<TransactionViewModel>(
              builder: (context, vm, child) {
                final filteredTxs =
                    vm.getTransactionsInRange(_startDate, _endDate);
                final totalIncome = filteredTxs
                    .where((t) => t.isIncome)
                    .fold(0.0, (s, t) => s + t.amount);
                final totalSpend = filteredTxs
                    .where((t) => !t.isIncome)
                    .fold(0.0, (s, t) => s + t.amount);

                // --- NEW INSIGHT CALCULATIONS ---
                // 1. Top Category
                final categoryMap = <String, double>{};
                for (var tx in filteredTxs.where((t) => !t.isIncome)) {
                  categoryMap[tx.category] =
                      (categoryMap[tx.category] ?? 0) + tx.amount;
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

                if (filteredTxs.isEmpty) return _buildEmptyState(isDark);

                final isLargeScreen = !ResponsiveUtils.isMobile(context);

                return Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                      horizontal: AppDimensions.paddingStandard, vertical: 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: AppStrings.income,
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
                              title: AppStrings.expenses,
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
                              title: 'Top Category',
                              value: topCategory ?? 'N/A',
                              subtitle: topCategory != null
                                  ? '₹${topCategoryAmount.toStringAsFixed(0)}'
                                  : 'No spending',
                              icon: Icons.category_rounded,
                              color: Colors.blueAccent,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInsightCard(
                              context,
                              title: 'Avg. Daily Spend',
                              value: '₹${avgSpending.toStringAsFixed(0)}',
                              subtitle: 'Per day',
                              icon: Icons.timer_rounded,
                              color: Colors.orangeAccent,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingLarge),
                      if (isLargeScreen)
                        Row(
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
                                              totalIncome, totalSpend, isDark),
                                          _buildBarChart(filteredTxs, isDark),
                                          _buildCategoryChart(
                                              filteredTxs, isDark),
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
                                              .getResponsiveChartHeight(
                                                  context) +
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
                        )
                      else
                        Column(
                          children: [
                            _buildChartTabs(isDark),
                            const SizedBox(
                                height: AppDimensions.paddingStandard),
                            ModernCard(
                              padding: const EdgeInsets.all(
                                  AppDimensions.paddingLarge),
                              child: SizedBox(
                                height:
                                    ResponsiveUtils.getResponsiveChartHeight(
                                        context),
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildPieChart(
                                        totalIncome, totalSpend, isDark),
                                    _buildBarChart(filteredTxs, isDark),
                                    _buildCategoryChart(filteredTxs, isDark),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingXLarge),
                            _buildSectionHeader(AppStrings.history),
                            const SizedBox(
                                height: AppDimensions.paddingStandard),
                            ...filteredTxs.map((tx) =>
                                TransactionTile(transaction: tx, index: 0)),
                          ],
                        ),
                      const SizedBox(height: AppDimensions.borderRadiusFull),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
    required IconData icon,
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
          color: theme.dividerColor.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
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
        tabs: const [
          Tab(text: AppStrings.overview),
          Tab(text: AppStrings.trends),
          Tab(text: AppStrings.categories),
        ],
      ),
    );
  }

  Widget _buildPieChart(double totalIncome, double totalSpend, bool isDark) {
    final total = totalIncome + totalSpend;
    if (total == 0) return _buildEmptyState(isDark);

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: totalSpend,
            title: '${((totalSpend / total) * 100).toStringAsFixed(0)}%',
            color: AppColors.accentRed.withValues(alpha: 0.8),
            radius: AppDimensions.chartRadiusSmall,
            titleStyle: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: AppTypography.fontWeightBold,
                fontSize: AppTypography.fontSizeXSmall),
            badgeWidget:
                _buildPieBadge(SvgAppIcons.expenseIcon, AppColors.accentRed),
            badgePositionPercentageOffset: 1.1,
          ),
          PieChartSectionData(
            value: totalIncome,
            title: '${((totalIncome / total) * 100).toStringAsFixed(0)}%',
            color: AppColors.accentGreen.withValues(alpha: 0.8),
            radius: AppDimensions.chartRadiusLarge,
            titleStyle: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: AppTypography.fontWeightBold,
                fontSize: AppTypography.fontSizeXSmall),
            badgeWidget:
                _buildPieBadge(SvgAppIcons.incomeIcon, AppColors.accentGreen),
            badgePositionPercentageOffset: 1.1,
          ),
        ],
        centerSpaceRadius: AppDimensions.avatarSizeStandard,
        sectionsSpace: AppDimensions.paddingXSmall,
      ),
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

  Widget _buildBarChart(List<Transaction> transactions, bool isDark) {
    Map<String, double> monthlyData = {};
    for (var tx in transactions) {
      String day = DateFormat.Md().format(tx.date);
      monthlyData[day] = (monthlyData[day] ?? 0) + tx.amount;
    }

    if (monthlyData.isEmpty) return _buildEmptyState(isDark);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.3,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${rod.toY.toStringAsFixed(0)}',
                GoogleFonts.dmSans(
                    fontWeight: AppTypography.fontWeightBold,
                    color: Theme.of(context).colorScheme.primary),
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
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      monthlyData.keys.elementAt(value.toInt()),
                      style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeXSmall - 2,
                          color: Colors.grey,
                          fontWeight: AppTypography.fontWeightBold),
                    ),
                  );
                }
                return const Text('');
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
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: monthlyData.entries.toList().asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: Theme.of(context).colorScheme.primary,
                width: AppDimensions.paddingStandard,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.paddingSmall - 2)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: monthlyData.values.reduce((a, b) => a > b ? a : b) * 1.3,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChart(List<Transaction> transactions, bool isDark) {
    Map<String, double> categoryData = {};
    for (var tx in transactions) {
      if (!tx.isIncome) {
        categoryData[tx.category] =
            (categoryData[tx.category] ?? 0) + tx.amount;
      }
    }

    final sortedItems = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedItems.isEmpty) return _buildEmptyState(isDark);

    return ListView.builder(
      itemCount: sortedItems.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final item = sortedItems[index];
        final total = categoryData.values.reduce((a, b) => a + b);
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
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(
                                  alpha: 0.8 - (index * 0.1).clamp(0.2, 0.8)),
                          shape: BoxShape.circle,
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
                  FractionallySizedBox(
                    widthFactor: percentage,
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
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return EmptyStateView(
      icon: Icons.auto_graph_rounded,
      title: AppStrings.noDataFound,
    );
  }
}

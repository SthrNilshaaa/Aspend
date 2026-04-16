import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:flutter_svg/svg.dart';
>>>>>>> master
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
<<<<<<< HEAD
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'dart:ui';
import '../models/transaction.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/transaction_view_model.dart';
import '../widgets/transaction_tile.dart';
import '../utils/responsive_utils.dart';

class ChartPage extends StatefulWidget {
  ChartPage({super.key});
=======

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
import '../core/const/app_strings.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_assets.dart';

class _TrendData {
  double income = 0.0;
  double expense = 0.0;
}

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});
>>>>>>> master

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with TickerProviderStateMixin {
  late TabController _tabController;
<<<<<<< HEAD
  int _selectedChartIndex = 0;
=======
  String _selectedRange = 'All'; // Day, Week, Month, Year
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
>>>>>>> master

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
    });
<<<<<<< HEAD
=======
    _updateDateRange();
  }

  void _updateDateRange() {
    final range = TransactionUtils.getDateRange(_selectedRange);
    _startDate = range.$1;
    _endDate = range.$2;
>>>>>>> master
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final transactionViewModel = Provider.of<TransactionViewModel>(context);
    final transactions = transactionViewModel.sortedTransactions;
    final spends = transactionViewModel.spends;
    final incomes = transactionViewModel.incomes;
    final totalSpend = transactionViewModel.totalSpend;
    final totalIncome = transactionViewModel.totalIncome;
    final hasData = totalSpend > 0 || totalIncome > 0;
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final useAdaptive = themeViewModel.useAdaptiveColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Enhanced App Bar
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveAppBarHeight(context),
            floating: true,
            pinned: true,
            elevation: 1,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Analytics',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    mobile: 24,
                    tablet: 28,
                    desktop: 32,
                  ),
                  color: theme.colorScheme.onSurface,
                ),
              ),
              background: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: useAdaptive
                          ? LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primaryContainer
                              ],
                            )
                          : isDark
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primaryContainer
                                        .withOpacity(0.8)
                                  ],
                                )
                              : LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.8),
                                    theme.colorScheme.primaryContainer
                                        .withOpacity(0.8)
                                  ],
                                ),
                    ),
                  ),
                ),
              ),
            ),
            centerTitle: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: hasData
                ? Padding(
                    padding: ResponsiveUtils.getResponsiveEdgeInsets(
                      context,
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Summary Cards
                        _buildSummaryCards(totalIncome, totalSpend, isDark),
                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                mobile: 18,
                                tablet: 24,
                                desktop: 32)),
                        // Chart Tabs
                        _buildChartTabs(isDark),
                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                mobile: 10,
                                tablet: 16,
                                desktop: 20)),
                        // Chart Content
                        SizedBox(
                          height:
                              ResponsiveUtils.getResponsiveChartHeight(context),
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildPieChart(totalIncome, totalSpend, isDark),
                              _buildBarChart(transactions, isDark),
                              _buildCategoryChart(transactions, isDark),
                            ],
                          ),
                        ),
                        SizedBox(
                            height: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                mobile: 16,
                                tablet: 24,
                                desktop: 32)),
                      ],
                    ),
                  )
                : _buildEmptyState(isDark),
          ),
          if (hasData) ..._buildTransactionLists(spends, incomes, isDark),
          if (hasData)
            const SliverToBoxAdapter(
                child: SizedBox(height: 50)), // Reduced bottom spacing
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      double totalIncome, double totalSpend, bool isDark) {
    final netBalance = totalIncome - totalSpend;

    return ResponsiveUtils.responsiveBuilder(
      context: context,
      mobile: Row(
        children: [
          Expanded(
            child: ZoomTapAnimation(
              child: _buildSummaryCard(
                "Income",
                totalIncome,
                Colors.green,
                Icons.trending_up,
                isDark,
              ),
            ),
          ),
          SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20)),
          Expanded(
            child: ZoomTapAnimation(
              child: _buildSummaryCard(
                "Expenses",
                totalSpend,
                Colors.red,
                Icons.trending_down,
                isDark,
              ),
            ),
          ),
          SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20)),
          Expanded(
            child: ZoomTapAnimation(
              child: _buildSummaryCard(
                "Balance",
                netBalance,
                netBalance >= 0 ? Colors.blue : Colors.orange,
                Icons.account_balance_wallet,
                isDark,
              ),
            ),
          ),
        ],
      ),
      tablet: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ZoomTapAnimation(
                  child: _buildSummaryCard(
                    "Income",
                    totalIncome,
                    Colors.green,
                    Icons.trending_up,
                    isDark,
                  ),
                ),
              ),
              SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(context,
                      mobile: 12, tablet: 16, desktop: 20)),
              Expanded(
                child: ZoomTapAnimation(
                  child: _buildSummaryCard(
                    "Expenses",
                    totalSpend,
                    Colors.red,
                    Icons.trending_down,
                    isDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20)),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: ZoomTapAnimation(
              child: _buildSummaryCard(
                "Balance",
                netBalance,
                netBalance >= 0 ? Colors.blue : Colors.orange,
                Icons.account_balance_wallet,
                isDark,
              ),
            ),
          ),
        ],
      ),
      desktop: Row(
        children: [
          Expanded(
            child: ZoomTapAnimation(
              child: _buildSummaryCard(
                "Income",
                totalIncome,
                Colors.green,
                Icons.trending_up,
                isDark,
              ),
            ),
          ),
          SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20)),
          Expanded(
            child: ZoomTapAnimation(
              child: _buildSummaryCard(
                "Expenses",
                totalSpend,
                Colors.red,
                Icons.trending_down,
                isDark,
              ),
            ),
          ),
          SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(context,
                  mobile: 12, tablet: 16, desktop: 20)),
          Expanded(
            child: ZoomTapAnimation(
              child: _buildSummaryCard(
                "Balance",
                netBalance,
                netBalance >= 0 ? Colors.blue : Colors.orange,
                Icons.account_balance_wallet,
                isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, Color color, IconData icon, bool isDark) {
    final theme = Theme.of(context);
    final c = color;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context,
            mobile: 12, tablet: 16, desktop: 20)),
        child: Column(
          children: [
            Container(
              width: ResponsiveUtils.getResponsiveIconSize(context,
                  mobile: 32, tablet: 40, desktop: 48),
              height: ResponsiveUtils.getResponsiveIconSize(context,
                  mobile: 32, tablet: 40, desktop: 48),
              decoration: BoxDecoration(
                color: c.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: c.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: c,
                size: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: 16, tablet: 20, desktop: 24),
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 6, tablet: 8, desktop: 10)),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 10, tablet: 12, desktop: 14),
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 2, tablet: 4, desktop: 6)),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: GoogleFonts.nunito(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 14, tablet: 16, desktop: 18),
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
          ],
        ),
      ),
=======
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;
    final vm = context.watch<TransactionViewModel>();

    final filteredTxs = vm.getTransactionsInRange(_startDate, _endDate);
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
    
    final isLargeScreen = !ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
          const GlassAppBar(
            title: AppStrings.analytics,
            centerTitle: true,
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.paddingLarge)),
          SliverToBoxAdapter(
            child: RangeSelector(
              ranges: const ['All', 'Day', 'Week', 'Month', 'Year'],
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
          if (filteredTxs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(isDark),
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
                  ],
                ),
              ),
            ),
            if (isLargeScreen)
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                      horizontal: AppDimensions.paddingStandard, vertical: 0),
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
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                      horizontal: AppDimensions.paddingStandard, vertical: 0),
                  child: Column(
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
>>>>>>> master
    );
  }

  Widget _buildChartTabs(bool isDark) {
    final theme = Theme.of(context);
<<<<<<< HEAD
    final useAdaptive = context.watch<ThemeViewModel>().useAdaptiveColor;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context,
            mobile: 8, tablet: 12, desktop: 16),
        vertical: ResponsiveUtils.getResponsiveSpacing(context,
            mobile: 4, tablet: 6, desktop: 8),
      ),
      height: ResponsiveUtils.getResponsiveIconSize(context,
          mobile: 38, tablet: 44, desktop: 50),
      decoration: BoxDecoration(
        color: useAdaptive
            ? theme.colorScheme.surface
            : (isDark
                ? Colors.grey.shade900.withOpacity(0.3)
                : Colors.grey.shade100.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: useAdaptive
              ? theme.colorScheme.outline.withOpacity(0.2)
              : (isDark
                  ? Colors.grey.shade700.withOpacity(0.3)
                  : Colors.grey.shade300.withOpacity(0.5)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: useAdaptive
                ? theme.colorScheme.shadow.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: useAdaptive ? theme.colorScheme.primary : Colors.teal.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        indicatorPadding: EdgeInsets.symmetric(
          vertical: ResponsiveUtils.getResponsiveSpacing(context,
              mobile: 3, tablet: 4, desktop: 5),
          horizontal: ResponsiveUtils.getResponsiveSpacing(context,
              mobile: -6, tablet: -8, desktop: -10),
        ),
        labelColor: useAdaptive
            ? theme.colorScheme.onPrimary
            : isDark
                ? Colors.white
                : Colors.black,
        unselectedLabelColor: useAdaptive
            ? theme.colorScheme.primary.withOpacity(0.7)
            : (isDark ? Colors.white70 : Colors.black87),
        labelStyle: GoogleFonts.nunito(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context,
              mobile: 13, tablet: 14, desktop: 16),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context,
              mobile: 13, tablet: 14, desktop: 16),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        tabs: [
          const ZoomTapAnimation(child: Tab(text: "Overview")),
          const ZoomTapAnimation(child: Tab(text: "Trends")),
          const ZoomTapAnimation(child: Tab(text: "Categories")),
=======
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
>>>>>>> master
        ],
      ),
    );
  }

  Widget _buildPieChart(double totalIncome, double totalSpend, bool isDark) {
<<<<<<< HEAD
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context,
            mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          children: [
            Text(
              "Income vs Expenses",
              style: GoogleFonts.nunito(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 12, tablet: 16, desktop: 20)),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalSpend,
                      title: 'Expenses\n₹${totalSpend.toStringAsFixed(2)}',
                      color: Colors.red.shade400,
                      radius: ResponsiveUtils.getResponsiveIconSize(context,
                          mobile: 70, tablet: 80, desktop: 90),
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 10, tablet: 12, desktop: 14),
                      ),
                    ),
                    PieChartSectionData(
                      value: totalIncome,
                      title: 'Income\n₹${totalIncome.toStringAsFixed(2)}',
                      color: Colors.green.shade400,
                      radius: ResponsiveUtils.getResponsiveIconSize(context,
                          mobile: 70, tablet: 80, desktop: 90),
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 10, tablet: 12, desktop: 14),
                      ),
                    ),
                  ],
                  sectionsSpace: 5,
                  centerSpaceRadius: ResponsiveUtils.getResponsiveIconSize(
                      context,
                      mobile: 25,
                      tablet: 30,
                      desktop: 35),
                ),
              ),
            ),
          ],
        ),
=======
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
>>>>>>> master
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildBarChart(List<Transaction> transactions, bool isDark) {
    // Group transactions by month
    Map<String, double> monthlyData = {};
    for (var tx in transactions) {
      String month = DateFormat.yMMM().format(tx.date);
      if (!monthlyData.containsKey(month)) {
        monthlyData[month] = 0;
      }
      monthlyData[month] = monthlyData[month]! + tx.amount;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context,
            mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          children: [
            Text(
              "Monthly Trends",
              style: GoogleFonts.nunito(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 12, tablet: 16, desktop: 20)),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyData.values.isEmpty
                      ? 100
                      : monthlyData.values.reduce((a, b) => a > b ? a : b) *
                          1.2,
                  barTouchData: const BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < monthlyData.length) {
                            String month =
                                monthlyData.keys.elementAt(value.toInt());
                            return Text(
                              month,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                    context,
                                    mobile: 8,
                                    tablet: 10,
                                    desktop: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  mobile: 8,
                                  tablet: 10,
                                  desktop: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: monthlyData.entries.map((entry) {
                    int index = monthlyData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: Colors.teal,
                          width: ResponsiveUtils.getResponsiveIconSize(context,
                              mobile: 16, tablet: 20, desktop: 24),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                  ResponsiveUtils.getResponsiveSpacing(context,
                                      mobile: 6, tablet: 8, desktop: 10))),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
=======
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
    if (transactions.isEmpty) return _buildEmptyState(isDark);

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
                '${isIncome ? 'Income' : 'Expense'}\n₹${rod.toY.toStringAsFixed(0)}',
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
                  if (entries.length > 10 && index % (entries.length ~/ 5) != 0) {
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
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            strokeWidth: 1,
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
                color: AppColors.accentGreen,
                width: entries.length > 15 ? 4 : 8,
                borderRadius: BorderRadius.circular(2),
              ),
              BarChartRodData(
                toY: value.expense,
                color: AppColors.accentRed,
                width: entries.length > 15 ? 4 : 8,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          );
        }).toList(),
>>>>>>> master
      ),
    );
  }

  Widget _buildCategoryChart(List<Transaction> transactions, bool isDark) {
<<<<<<< HEAD
    final theme = Theme.of(context);
    final useAdaptive = context.watch<ThemeViewModel>().useAdaptiveColor;
    // Group by category
    Map<String, double> categoryData = {};
    for (var tx in transactions) {
      if (!categoryData.containsKey(tx.category)) {
        categoryData[tx.category] = 0;
      }
      categoryData[tx.category] = categoryData[tx.category]! + tx.amount;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsiveSpacing(context,
            mobile: 16, tablet: 20, desktop: 24)),
        child: Column(
          children: [
            Text(
              "Spending by Category",
              style: GoogleFonts.nunito(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 12, tablet: 16, desktop: 20)),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryData.length,
                itemBuilder: (context, index) {
                  String category = categoryData.keys.elementAt(index);
                  double amount = categoryData[category]!;
                  double percentage =
                      (amount / categoryData.values.reduce((a, b) => a + b)) *
                          100;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: ResponsiveUtils.getResponsiveSpacing(context,
                            mobile: 4, tablet: 6, desktop: 8)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            category,
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  mobile: 12,
                                  tablet: 14,
                                  desktop: 16),
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  useAdaptive
                                      ? theme.colorScheme.primary
                                      : Colors.teal),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(context,
                                mobile: 6, tablet: 8, desktop: 10)),
                        Text(
                          '₹${amount.toStringAsFixed(2)}',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16),
                            color: useAdaptive
                                ? theme.colorScheme.primary
                                : Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTransactionLists(
      List<Transaction> spends, List<Transaction> incomes, bool isDark) {
    final allTransactions = [...spends, ...incomes];
    final grouped = Provider.of<TransactionViewModel>(context, listen: false)
        .groupedTransactions;

    return grouped.entries.map((entry) {
      final dateKey = entry.key;
      final dayTxs = entry.value;
      final dayIncomes = dayTxs.where((t) => t.isIncome).toList();
      final dayExpenses = dayTxs.where((t) => !t.isIncome).toList();

      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                  horizontal: 16, vertical: 8),
              child: Text(
                dateKey,
                style: GoogleFonts.nunito(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 16, tablet: 18, desktop: 20),
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            ...dayIncomes
                .map((tx) => TransactionTile(transaction: tx, index: 0))
                .toList(),
            ...dayExpenses
                .map((tx) => TransactionTile(transaction: tx, index: 0))
                .toList(),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 12, tablet: 16, desktop: 20)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ResponsiveUtils.getResponsiveIconSize(context,
                  mobile: 120, tablet: 140, desktop: 160),
              height: ResponsiveUtils.getResponsiveIconSize(context,
                  mobile: 120, tablet: 140, desktop: 160),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveIconSize(context,
                        mobile: 60, tablet: 70, desktop: 80)),
              ),
              child: Icon(
                Icons.bar_chart,
                size: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: 60, tablet: 70, desktop: 80),
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 24, tablet: 32, desktop: 40)),
            Text(
              'No Data Available',
              style: GoogleFonts.nunito(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 24, tablet: 28, desktop: 32),
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(context,
                    mobile: 8, tablet: 12, desktop: 16)),
            Padding(
              padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                  horizontal: 32, vertical: 0),
              child: Text(
                'Add some transactions to see analytics',
                style: GoogleFonts.nunito(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 16, tablet: 18, desktop: 20),
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
=======
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
    return const EmptyStateView(
      icon: Icons.auto_graph_rounded,
      title: AppStrings.noDataFound,
>>>>>>> master
    );
  }
}

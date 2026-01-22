import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../models/transaction.dart';
import '../view_models/theme_view_model.dart';
import '../view_models/transaction_view_model.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/stat_card.dart';
import '../widgets/modern_card.dart';
import '../utils/responsive_utils.dart';

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
    }
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
          SliverAppBar(
            expandedHeight: ResponsiveUtils.getResponsiveAppBarHeight(context),
            floating: true,
            pinned: true,
            elevation: 1,
            backgroundColor: Colors.transparent,
            flexibleSpace: Stack(
              fit: StackFit.expand,
              children: [
                // Persistent Glass Effect Layer
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                            theme.colorScheme.surface.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Subtle Bottom Border
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: Container(
                //     height: 1,
                //     color: isDark
                //         ? Colors.white.withValues(alpha: 0.1)
                //         : Colors.black.withValues(alpha: 0.05),
                //   ),
                // ),
                FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Analytics',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                          mobile: 20, tablet: 24, desktop: 28),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRangeSelector('Day'),
                  _buildRangeSelector('Week'),
                  _buildRangeSelector('Month'),
                  _buildRangeSelector('Year'),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

                if (filteredTxs.isEmpty) return _buildEmptyState(isDark);

                final isLargeScreen = !ResponsiveUtils.isMobile(context);

                return Padding(
                  padding: ResponsiveUtils.getResponsiveEdgeInsets(context,
                      horizontal: 16, vertical: 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Income',
                              amount: totalIncome,
                              color: Colors.greenAccent.shade700,
                              icon: Icons.trending_up,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              title: 'Expenses',
                              amount: totalSpend,
                              color: Colors.redAccent,
                              icon: Icons.trending_down,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (isLargeScreen)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildChartTabs(isDark),
                                  const SizedBox(height: 16),
                                  ModernCard(
                                    padding: const EdgeInsets.all(24),
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
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader('History'),
                                  const SizedBox(height: 16),
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
                            const SizedBox(height: 16),
                            ModernCard(
                              padding: const EdgeInsets.all(24),
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
                            const SizedBox(height: 32),
                            _buildSectionHeader('History'),
                            const SizedBox(height: 16),
                            ...filteredTxs
                                .map((tx) =>
                                    TransactionTile(transaction: tx, index: 0))
                                .toList(),
                          ],
                        ),
                      const SizedBox(height: 100),
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

  Widget _buildRangeSelector(String range) {
    final isSelected = _selectedRange == range;
    final theme = Theme.of(context);
    return ZoomTapAnimation(
      onTap: () {
        setState(() {
          _selectedRange = range;
          _updateDateRange();
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        ),
        child: Text(
          range,
          style: GoogleFonts.nunito(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            fontSize: 13,
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
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildChartTabs(bool isDark) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
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
        labelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        onTap: (index) {
          setState(() {});
          HapticFeedback.lightImpact();
        },
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Trends'),
          Tab(text: 'Categories'),
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
            color: Colors.redAccent.withValues(alpha: 0.8),
            radius: 80,
            titleStyle: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            badgeWidget: _buildPieBadge(Icons.trending_down, Colors.redAccent),
            badgePositionPercentageOffset: 1.1,
          ),
          PieChartSectionData(
            value: totalIncome,
            title: '${((totalIncome / total) * 100).toStringAsFixed(0)}%',
            color: Colors.greenAccent.shade700.withValues(alpha: 0.8),
            radius: 85,
            titleStyle: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            badgeWidget:
                _buildPieBadge(Icons.trending_up, Colors.greenAccent.shade700),
            badgePositionPercentageOffset: 1.1,
          ),
        ],
        centerSpaceRadius: 40,
        sectionsSpace: 4,
      ),
    );
  }

  Widget _buildPieBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(4),
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
      child: Icon(icon, color: color, size: 16),
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
                GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
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
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
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
                width: 16,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(
                                  alpha: 0.8 - (index * 0.1).clamp(0.2, 0.8)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.key,
                          style:
                              GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Text('₹${item.value.toStringAsFixed(0)}',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: percentage,
                    child: Container(
                      height: 8,
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
                        borderRadius: BorderRadius.circular(4),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded,
              size: 64, color: Colors.grey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'No data records found',
            style: GoogleFonts.nunito(
                fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

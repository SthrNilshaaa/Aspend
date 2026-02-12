import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../view_models/theme_view_model.dart';
import '../view_models/transaction_view_model.dart';
import '../const/app_colors.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../const/app_strings.dart';
import '../const/app_assets.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final Function(double) onBalanceUpdate;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.onBalanceUpdate,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Optimized rebuilds with select
    final isDark = context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode);
    final totalIncome =
        context.select<TransactionViewModel, double>((vm) => vm.totalIncome);
    final totalExpenses =
        context.select<TransactionViewModel, double>((vm) => vm.totalSpend);

    final isNegative = totalIncome < totalExpenses;

    final Color backgroundColor;
    final Color lineColor;
    final Color borderColor;

    if (isNegative) {
      backgroundColor = isDark
          ? AppColors.balanceCardDarkModeNegative
          : AppColors.balanceCardLightModeNegative;
      lineColor = isDark
          ? AppColors.balanceCardLineDarkModeNegative
          : AppColors.balanceCardLineLightModeNegative;
      borderColor = isDark
          ? AppColors.balanceCardBorderDarkModeNegative
          : AppColors.balanceCardBorderLightModeNegative;
    } else {
      backgroundColor = isDark
          ? AppColors.balanceCardDarkModePositive
          : AppColors.balanceCardLightModePositive;
      lineColor = isDark
          ? AppColors.balanceCardLineDarkModePositive
          : AppColors.balanceCardLineLightModePositive;
      borderColor = isDark
          ? AppColors.balanceCardBorderDarkModePositive
          : AppColors.balanceCardBorderLightModePositive;
    }

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.lightImpact();
        _showEditBalanceDialog(context, isDark);
      },
      onTap: () {
        HapticFeedback.selectionClick();
        _showBalanceDetails(context, isDark);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ClipRRect(
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingTiny,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor,
                      width: 1.4,
                      style: BorderStyle.solid,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusXLarge),
                    color: backgroundColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingLarge,
                      vertical: AppDimensions.paddingXStandard,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.totalBalanceLabel,
                              style: GoogleFonts.dmSans(
                                fontSize: AppTypography.fontSizeLarge,
                                fontWeight: AppTypography.fontWeightMedium,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : Colors.black.withValues(alpha: 0.9),
                                letterSpacing: -0.4,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showEditBalanceDialog(context, isDark);
                              },
                              child: Container(
                                width: AppDimensions.avatarSizeStandard,
                                height: AppDimensions.avatarSizeStandard,
                                padding: const EdgeInsets.all(
                                    AppDimensions.paddingSmall),
                                decoration: BoxDecoration(
                                  color: backgroundColor.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.borderRadiusFull),
                                  border: Border.all(
                                    color: isNegative
                                        ? AppColors.accentRed
                                        : AppColors.accentGreen,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: SvgPicture.asset(
                                    SvgAppIcons.editIcon,
                                    colorFilter: ColorFilter.mode(
                                      isNegative
                                          ? AppColors.accentRed
                                          : AppColors.accentGreen,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        CurrencyText(
                          amount: widget.balance,
                          isNegative: isNegative,
                          isDark: isDark,
                          integerSize: 55,
                        ),
                        const SizedBox(height: AppDimensions.paddingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: StatItem(
                                label: AppStrings.incomeLabel,
                                amount: totalIncome,
                                icon: SvgAppIcons.incomeIcon,
                                color: AppColors.accentGreen,
                                isDark: isDark,
                              ),
                            ),
                            Container(
                              height: AppDimensions.avatar2SizeStandard,
                              width: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.1),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingStandard),
                            ),
                            Expanded(
                              child: StatItem(
                                label: AppStrings.expenseLabel,
                                amount: totalExpenses,
                                icon: SvgAppIcons.expenseIcon,
                                color: AppColors.accentRed,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Thin decorative lines
              Positioned(
                bottom: 3,
                left: 50,
                right: 50,
                child: DecorativeLine(
                    color: lineColor, position: LinePosition.bottom),
              ),
              Positioned(
                left: 50,
                right: 50,
                top: 3,
                child: DecorativeLine(
                    color: lineColor, position: LinePosition.top),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showBalanceDetails(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimensions.avatarSizeStandard,
              height: AppDimensions.spacingXSmall,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppDimensions.spacingTiny),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.balanceDetailsTitle,
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeLarge,
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSmall),
                ),
                child: SvgPicture.asset(
                  SvgAppIcons.walletIcon,
                  colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary, BlendMode.srcIn),
                  width: AppDimensions.iconSizeMedium,
                  height: AppDimensions.iconSizeMedium,
                ),
              ),
              title: const Text('Tap and hold to edit balance'),
              subtitle:
                  const Text('Long press the balance card on the home screen'),
            ),
            const SizedBox(
                height:
                    AppDimensions.paddingSmall + AppDimensions.paddingXSmall),
          ],
        ),
      ),
    );
  }

  void _showEditBalanceDialog(BuildContext context, bool isDark) {
    final controller =
        TextEditingController(text: widget.balance.toStringAsFixed(2));
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          AppStrings.editBalanceTitle,
          style: TextStyle(fontWeight: AppTypography.fontWeightBold),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall + 4),
              child: SvgPicture.asset(
                SvgAppIcons.searchIcon,
                colorFilter:
                    ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newBalance = double.tryParse(controller.text);
              if (newBalance != null) {
                widget.onBalanceUpdate(newBalance);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                  vertical:
                      AppDimensions.paddingSmall + AppDimensions.paddingXSmall),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusSmall)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class CurrencyText extends StatelessWidget {
  final double amount;
  final bool isNegative;
  final bool isDark;
  final double integerSize;

  const CurrencyText({
    super.key,
    required this.amount,
    required this.isNegative,
    required this.isDark,
    required this.integerSize,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(amount);

    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '₹',
            style: GoogleFonts.dmSans(
              fontSize: integerSize * 0.63,
              fontWeight: AppTypography.fontWeightBlack,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.black.withValues(alpha: 0.9),
            ),
          ),
          const TextSpan(text: '  '),
          TextSpan(
            text: integerPart,
            style: GoogleFonts.bayon(
              fontSize: integerSize,
              height: 1,
              fontWeight: AppTypography.fontWeightMedium,
              color: isNegative ? AppColors.accentRed : AppColors.accentGreen,
              letterSpacing: 1,
            ),
          ),
          TextSpan(
            text: '.$decimalPart',
            style: GoogleFonts.bayon(
              fontSize: integerSize * 0.63,
              fontWeight: AppTypography.fontWeightMedium,
              color: isNegative ? AppColors.accentRed : AppColors.accentGreen,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final String icon;
  final Color color;
  final bool isDark;

  const StatItem({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: AppDimensions.iconSizeXSmall,
              height: AppDimensions.iconSizeXSmall,
            ),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeMedium,
                fontWeight: AppTypography.fontWeightMedium,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        CurrencyText(
          amount: amount,
          isNegative:
              false, // Stats are always shown in their respective colors
          isDark: isDark,
          integerSize: AppTypography.fontSizeLarge + 2,
        ),
      ],
    );
  }
}

enum LinePosition { top, bottom }

class DecorativeLine extends StatelessWidget {
  final Color color;
  final LinePosition position;

  const DecorativeLine({
    super.key,
    required this.color,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: position == LinePosition.top
              ? const Radius.circular(AppDimensions.borderRadiusFull)
              : Radius.zero,
          topRight: position == LinePosition.top
              ? const Radius.circular(AppDimensions.borderRadiusFull)
              : Radius.zero,
          bottomLeft: position == LinePosition.bottom
              ? const Radius.circular(AppDimensions.borderRadiusFull)
              : Radius.zero,
          bottomRight: position == LinePosition.bottom
              ? const Radius.circular(AppDimensions.borderRadiusFull)
              : Radius.zero,
        ),
      ),
    );
  }
}

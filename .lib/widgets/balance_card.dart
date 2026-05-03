import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/view_models/theme_view_model.dart';
import '../core/view_models/transaction_view_model.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_strings.dart';
import '../core/const/app_assets.dart';

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
    final isDark = context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode);
    final totalIncome =
        context.select<TransactionViewModel, double>((vm) => vm.totalIncome);
    final totalExpenses =
        context.select<TransactionViewModel, double>((vm) => vm.totalSpend);

    final isNegative = totalIncome < totalExpenses;

    final Color backgroundColor;

    if (isNegative) {
      backgroundColor = isDark
          ? AppColors.balanceCardDarkModeNegative
          : AppColors.balanceCardLightModeNegative;
    } else {
      backgroundColor = isDark
          ? AppColors.balanceCardDarkModePositive
          : AppColors.balanceCardLightModePositive;
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
          child: Stack(children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingTiny,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusXLarge),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color:
                          backgroundColor.withOpacity(isDark ? 0.1 : 0.2),
                      blurRadius: 30,
                      spreadRadius: -5,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusXLarge),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadiusXLarge),
                        color: backgroundColor.withOpacity(
                            isDark ? 0.05 : 0.15),
                        border: Border.all(
                          color: Colors.white
                              .withOpacity(isDark ? 0.1 : 0.6),
                          width: 1.5,
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? (isNegative
                                  ? [
                                      AppColors.accentRed
                                          .withOpacity(0.2),
                                      AppColors.accentRed
                                          .withOpacity(0.05),
                                      Colors.transparent,
                                    ]
                                  : [
                                      AppColors.accentGreen
                                          .withOpacity(0.2),
                                      AppColors.accentGreen
                                          .withOpacity(0.05),
                                      Colors.transparent,
                                    ])
                              : (isNegative
                                  ? [
                                      Colors.white.withOpacity(0.6),
                                      AppColors.accentRed
                                          .withOpacity(0.1),
                                      AppColors.accentRed
                                          .withOpacity(0.05),
                                    ]
                                  : [
                                      Colors.white.withOpacity(0.6),
                                      AppColors.accentGreen
                                          .withOpacity(0.1),
                                      AppColors.accentGreen
                                          .withOpacity(0.05),
                                    ]),
                          stops: const [0.0, 0.5, 1.0],
                        ),
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
                                    fontWeight: AppTypography.fontWeightNormal,
                                    color: isDark
                                        ? Colors.white.withOpacity(0.9)
                                        : Colors.black.withOpacity(0.9),
                                    letterSpacing: -0.2,
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
                                      color: (isNegative
                                              ? AppColors.accentRed
                                              : AppColors.accentGreen)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.borderRadiusFull),
                                      border: Border.all(
                                        color: (isNegative
                                                ? AppColors.accentRed
                                                : AppColors.accentGreen)
                                            .withOpacity(0.3),
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CurrencyText(
                                  amount: widget.balance,
                                  isNegative: isNegative,
                                  isDark: isDark,
                                  integerSize: 55,
                                  symbolSize: 40,
                                  fontName: GoogleFonts.bayon(),
                                  extraColor: isDark
                                      ? isNegative
                                          ? AppColors.balanceCardLineDarkModeNegative
                                          : AppColors.balanceCardLineDarkModePositive
                                      : isNegative
                                          ? AppColors.balanceCardLineLightModeNegative
                                          : AppColors.balanceCardLineLightModePositive,
                                ),
                              ],
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
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal:
                                          AppDimensions.paddingStandard),
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
                ),
              ),
            ),
            Positioned(
              bottom: 3,
              left: 50,
              right: 50,
              child: DecorativeLine(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                  position: LinePosition.bottom),
            ),
          ]),
        ),
      ),
    );
  }

  void _showBalanceDetails(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.8),
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
                  borderRadius:
                      BorderRadius.circular(AppDimensions.spacingTiny),
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
                subtitle: const Text(
                    'Long press the balance card on the home screen'),
              ),
              const SizedBox(
                  height: AppDimensions.paddingSmall +
                      AppDimensions.paddingXSmall),
            ],
          ),
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
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: theme.colorScheme.surface.withOpacity(0.8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            AppStrings.editBalanceTitle,
            style: TextStyle(fontWeight: AppTypography.fontWeightBold),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter new balance',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingSmall + 4),
                child: SvgPicture.asset(
                  SvgAppIcons.walletIcon,
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
                    vertical: AppDimensions.paddingSmall +
                        AppDimensions.paddingXSmall),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadiusSmall)),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyText extends StatelessWidget {
  final double amount;
  final bool isNegative;
  final bool isDark;
  final double integerSize;
  final double symbolSize;
  final TextStyle fontName;
  final Color extraColor;

  const CurrencyText({
    super.key,
    required this.amount,
    required this.isNegative,
    required this.isDark,
    required this.integerSize,
    required this.symbolSize,
    required this.fontName,
    this.extraColor = Colors.transparent,
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
              fontSize: symbolSize,
              fontWeight: AppTypography.fontWeightSemiBold,
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : Colors.black.withOpacity(0.9),
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: integerPart,
            style: fontName.copyWith(
              fontSize: integerSize,
              height: 1,
              fontWeight: AppTypography.fontWeightMedium,
              color: extraColor,
              letterSpacing: 0,
            ),
          ),
          TextSpan(
            text: '.$decimalPart',
            style: fontName.copyWith(
              fontSize: integerSize * 0.63,
              fontWeight: AppTypography.fontWeightMedium,
              color: extraColor,
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                fontWeight: AppTypography.fontWeightNormal,
                color: isDark
                    ? Colors.white.withOpacity(0.9)
                    : Colors.black.withOpacity(0.9),
              ),
            ),
          ],
        ),
        CurrencyText(
          amount: amount,
          isNegative: false,
          isDark: isDark,
          integerSize: AppTypography.fontSizeRegular + 2,
          symbolSize: AppTypography.fontSizeRegular + 2,
          extraColor: isDark ? Colors.white : Colors.black,
          fontName: GoogleFonts.dmSans(
            fontWeight: AppTypography.fontWeightMedium,
            color: isDark
                ? Colors.white.withOpacity(0.9)
                : Colors.black.withOpacity(0.9),
          ),
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

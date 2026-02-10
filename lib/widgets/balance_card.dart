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
    final isDark = context.watch<ThemeViewModel>().isDarkMode;
    final transactionViewModel = context.watch<TransactionViewModel>();
    final totalIncome = transactionViewModel.totalIncome;
    final totalExpenses = transactionViewModel.totalSpend;
    final isNegative = totalIncome < totalExpenses;

    Color backgroundColor;
    Color lineColor;
    Color borderColor;

    if (isNegative && isDark) {
      backgroundColor =
          AppColors.balanceCardDarkModeNegative; // dark + negative
      lineColor =
          AppColors.balanceCardLineDarkModeNegative; // dark + negative
      borderColor =
          AppColors.balanceCardBorderDarkModeNegative; // dark + negative

    } else if (isNegative) {
      backgroundColor =
          AppColors.balanceCardLightModeNegative; // light + negative
      lineColor =
          AppColors.balanceCardLineLightModeNegative; // light + negative
      borderColor =
          AppColors.balanceCardBorderLightModeNegative; // light + negative
    } else if (isDark) {
      backgroundColor =
          AppColors.balanceCardDarkModePositive; // dark + positive
      lineColor =
          AppColors.balanceCardLineDarkModePositive; // dark + positive
      borderColor =
          AppColors.balanceCardBorderDarkModePositive; // dark + positive
    } else {
      backgroundColor =
          AppColors.balanceCardLightModePositive; // light + positive
      lineColor =
          AppColors.balanceCardLineLightModePositive; // light + positive
      borderColor =
          AppColors.balanceCardBorderLightModePositive; // light + positive
    }
    final formatted = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
    ).format(widget.balance);

    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

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
              Container(
                margin: const EdgeInsets.symmetric(
                    vertical: AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:borderColor,
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
                    vertical: AppDimensions.paddingLarge - 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // spacing: -15,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.totalBalanceLabel,
                                  style: GoogleFonts.dmSans(
                                    fontSize: AppTypography.fontSizeLarge,
                                    fontWeight: AppTypography.fontWeightMedium,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.black.withValues(alpha: 0.9),
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
                                      color: backgroundColor.withValues(
                                          alpha: 0.4),
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.borderRadiusFull),
                                      border: Border.all(
                                        color: isNegative
                                            ? AppColors.accentRed
                                            : AppColors.accentGreen,
                                        width: 1,
                                      ),
                                    ),
                                    child: SvgPicture.asset(
                                      SvgAppIcons.editIcon,
                                      colorFilter: isNegative
                                          ? const ColorFilter.mode(
                                              AppColors.accentRed,
                                              BlendMode.srcIn)
                                          : const ColorFilter.mode(
                                              AppColors.accentGreen,
                                              BlendMode.srcIn),
                                      width: AppDimensions.iconSizeLarge,
                                      height: AppDimensions.iconSizeLarge,
                                    ),
                                  ),
                                ),
                              ]),
                          // const SizedBox(
                          //     height: AppDimensions.paddingXSmall),
                          Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '₹',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 35,
                                        fontWeight:
                                            AppTypography.fontWeightBlack,
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.9)
                                            : Colors.black
                                                .withValues(alpha: 0.9),
                                      ),
                                    ),
                                    const TextSpan(text: '  '),
                                    TextSpan(
                                      children: [
                                        // Integer part (55)
                                        TextSpan(
                                          text: integerPart,
                                          style: GoogleFonts.bayon(
                                            fontSize: 55,
                                            fontWeight:
                                                AppTypography.fontWeightBold,
                                            color: isNegative
                                                ? AppColors.accentRed
                                                : AppColors.accentGreen,
                                            letterSpacing: 1,
                                          ),
                                        ),

                                        // Decimal point + decimals (35)
                                        TextSpan(
                                          text: '.$decimalPart',
                                          style: GoogleFonts.bayon(
                                            fontSize: 35,
                                            fontWeight:
                                                AppTypography.fontWeightBold,
                                            color: isNegative
                                                ? AppColors.accentRed
                                                : AppColors.accentGreen,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // const SizedBox(height: AppDimensions.paddingSmall),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernStatItem(
                              AppStrings.incomeLabel,
                              totalIncome,
                              SvgAppIcons.incomeIcon,
                              AppColors.accentGreen,
                              isDark,
                            ),
                          ),
                          Container(
                            height: AppDimensions.avatarSizeStandard,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.2),
                            margin: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingStandard),
                          ),
                          Expanded(
                            child: _buildModernStatItem(
                              AppStrings.expenseLabel,
                              totalExpenses,
                              SvgAppIcons.expenseIcon,
                              AppColors.accentRed,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Thin decorative line at the bottom
              Positioned(
                bottom: 4,
                left: 35,
                right: 35,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: lineColor,
                    // rounded corners only on the top
                    borderRadius: const BorderRadius.only(
                      bottomLeft:
                          Radius.circular(AppDimensions.borderRadiusFull),
                      bottomRight:
                          Radius.circular(AppDimensions.borderRadiusFull),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 35,
                right: 35,
                top: 4,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color:  lineColor,
                    // rounded corners only on the top
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.borderRadiusFull),
                      topRight: Radius.circular(AppDimensions.borderRadiusFull),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatItem(
      String label, double amount, dynamic icon, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon is String
                ? SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    width: AppDimensions.iconSizeXSmall,
                    height: AppDimensions.iconSizeXSmall,
                  )
                : Icon(icon, color: color, size: AppDimensions.iconSizeSmall),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeRegular,
                fontWeight: AppTypography.fontWeightMedium,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount)}',
          style: GoogleFonts.dmSans(
            fontSize: AppTypography.fontSizeLarge,
            fontWeight: AppTypography.fontWeightSemiBold,
            color: isDark
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.black.withValues(alpha: 0.9),
          ),
        ),
      ],
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

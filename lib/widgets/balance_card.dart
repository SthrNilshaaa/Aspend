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
                  color: Colors.red,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusXLarge),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            AppColors.balanceCardDarkStart,
                            AppColors.balanceCardDarkEnd,
                          ]
                        : [
                            AppColors.balanceCardLightStart,
                            AppColors.balanceCardLightEnd,
                          ],
                  ),
                  // Thin decorative line at the bottom
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusXLarge),
                  child: Stack(
                    children: [
                      //bottom right circle
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppStrings.totalBalanceLabel,
                                        style: GoogleFonts.dmSans(
                                          fontSize: AppTypography.fontSizeLarge,
                                          fontWeight:
                                              AppTypography.fontWeightExtraBold,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _showEditBalanceDialog(
                                              context, isDark);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                              AppDimensions.paddingSmall),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                                AppDimensions.borderRadiusFull),
                                            border: Border.all(
                                              color: AppColors.accentGreen
                                                  .withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: SvgPicture.asset(
                                            SvgAppIcons.editIcon,
                                            colorFilter: const ColorFilter.mode(
                                                AppColors.accentGreen,
                                                BlendMode.srcIn),
                                            width: AppDimensions.iconSizeLarge,
                                            height: AppDimensions.iconSizeLarge,
                                          ),
                                        ),
                                      ),
                                    ]),
                                const SizedBox(
                                    height: AppDimensions.paddingXSmall),
                                Row(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '₹',
                                            style: GoogleFonts.dmSans(
                                              fontSize:
                                                  AppTypography.fontSizeXLarge,
                                              fontWeight: AppTypography
                                                  .fontWeightExtraBold,
                                              color:
                                                  Colors.white.withOpacity(0.9),
                                            ),
                                          ),
                                          TextSpan(
                                            text: NumberFormat.currency(
                                                    symbol: '',
                                                    decimalDigits: 2)
                                                .format(widget.balance),
                                            style: GoogleFonts.dmSans(
                                              fontSize: AppTypography
                                                  .fontSizeGigantic,
                                              fontWeight:
                                                  AppTypography.fontWeightBold,
                                              color: AppColors.accentGreen,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.paddingSmall),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernStatItem(
                                    AppStrings.incomeLabel,
                                    totalIncome,
                                    SvgAppIcons.incomeIcon,
                                    AppColors.accentGreen,
                                  ),
                                ),
                                Container(
                                  height: AppDimensions.avatarSizeStandard,
                                  width: 1,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal:
                                          AppDimensions.paddingStandard),
                                ),
                                Expanded(
                                  child: _buildModernStatItem(
                                    AppStrings.expenseLabel,
                                    totalExpenses,
                                    SvgAppIcons.expenseIcon,
                                    AppColors.accentRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                    color: AppColors.accentGreen.withValues(alpha: 0.4),
                    // rounded corners only on the top
                    borderRadius: const BorderRadius.only(
                      bottomLeft:
                          Radius.circular(AppDimensions.borderRadiusFull),
                      bottomRight:
                          Radius.circular(AppDimensions.borderRadiusFull),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.3),
                        blurRadius: 22,
                        offset: const Offset(0, 0),
                      ),
                    ],
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
      String label, double amount, dynamic icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            icon is String
                ? SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                    width: AppDimensions.iconSizeSmall,
                    height: AppDimensions.iconSizeSmall,
                  )
                : Icon(icon, color: color, size: AppDimensions.iconSizeSmall),
            const SizedBox(width: AppDimensions.paddingSmall),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeSmall,
                fontWeight: AppTypography.fontWeightMedium,
                color: Colors.white.withValues(alpha: 0.9),
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
            color: Colors.white,
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

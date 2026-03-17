import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/const/app_colors.dart';
import '../../core/const/app_dimensions.dart';
import '../../core/const/app_strings.dart';
import '../../core/const/app_typography.dart';
import '../../core/view_models/theme_view_model.dart';
import '../../core/view_models/transaction_view_model.dart';

class HomeBudgetProgress extends StatelessWidget {
  final TransactionViewModel viewModel;
  final bool isCompact;

  const HomeBudgetProgress({
    super.key,
    required this.viewModel,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeViewModel = context.watch<ThemeViewModel>();
    final budget = themeViewModel.monthlyBudget;
    if (budget <= 0) return const SizedBox.shrink();

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthlyTxs =
        viewModel.getTransactionsInRange(startOfMonth, endOfMonth);
    final spent = monthlyTxs
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + (t.amount ?? 0.0));

    final percentage = (spent / budget).clamp(0.0, 1.0);
    final isOverBudget = spent > budget;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 16, vertical: isCompact ? 8 : 8),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 16 : 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(
            color: isOverBudget
                ? Colors.redAccent.withValues(alpha: 0.3)
                : theme.dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: AppDimensions.spacingStandard - 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppStrings.budget,
                    style: GoogleFonts.dmSans(
                      fontWeight: AppTypography.fontWeightExtraBold,
                      fontSize: isCompact
                          ? AppTypography.fontSizeSmall
                          : AppTypography.fontSizeMedium,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹${spent.toStringAsFixed(0)}',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: isCompact ? 13 : 14,
                    color: isOverBudget ? Colors.redAccent : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.paddingSmall),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: isCompact ? 8 : 10,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(
                  isOverBudget
                      ? AppColors.accentRed
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            if (!isCompact && isOverBudget) ...[
              const SizedBox(height: AppDimensions.paddingLarge),
              Text(
                '⚠️ Over by ₹${(spent - budget).toStringAsFixed(0)}',
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeXSmall,
                  color: AppColors.accentRed,
                  fontWeight: AppTypography.fontWeightSemiBold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

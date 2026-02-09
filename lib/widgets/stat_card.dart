import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../const/app_assets.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final dynamic icon;
  final bool isDark;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingStandard),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: icon is String
                  ? SvgPicture.asset(
                      icon,
                      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                      width: AppDimensions.iconSizeMedium,
                      height: AppDimensions.iconSizeMedium,
                    )
                  : Icon(icon,
                      color: color, size: AppDimensions.iconSizeMedium),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeXSmall,
                fontWeight: AppTypography.fontWeightBold,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXSmall),
            FittedBox(
              child: Text(
                '₹${NumberFormat.compactCurrency(symbol: '', decimalDigits: 2).format(amount)}',
                style: GoogleFonts.dmSans(
                  fontSize: AppTypography.fontSizeLarge,
                  fontWeight: AppTypography.fontWeightBlack,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../const/app_dimensions.dart';

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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.04),
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusMedium + 4),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: icon is String
                      ? SvgPicture.asset(
                          icon,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                          width: 20,
                          height: 20,
                        )
                      : Icon(icon, color: color, size: 20),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: color.withValues(alpha: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.4),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(amount)}',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

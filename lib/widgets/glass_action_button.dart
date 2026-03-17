import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/const/app_typography.dart';

class GlassActionButton extends StatelessWidget {
  final dynamic icon;
  final String? label;
  final Color color;
  final VoidCallback onTap;

  const GlassActionButton({
    super.key,
    required this.icon,
    this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ZoomTapAnimation(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              // borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon is String
                    ? SvgPicture.asset(
                        icon,
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        width: 20,
                        height: 20,
                      )
                    : Icon(icon, color: color, size: 22),
                if (label != null && label!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    label!,
                    style: GoogleFonts.dmSans(
                      fontSize: AppTypography.fontSizeSmall,
                      fontWeight: AppTypography.fontWeightBold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassFab extends StatelessWidget {
  final List<Widget> children;
  final double marginBottom;

  const GlassFab({
    super.key,
    required this.children,
    this.marginBottom = 50,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

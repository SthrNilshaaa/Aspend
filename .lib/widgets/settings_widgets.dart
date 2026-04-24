import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../core/utils/responsive_utils.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_colors.dart';

class TitledSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;
  final List<Widget> children;

  const TitledSection({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: ResponsiveUtils.getResponsiveIconSize(context,
                    mobile: AppDimensions.iconSizeMedium,
                    tablet: AppDimensions.iconSizeLarge,
                    desktop: AppDimensions.iconSizeXLarge),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: AppTypography.fontSizeLarge - 2,
                      tablet: AppTypography.fontSizeLarge,
                      desktop: AppTypography.fontSizeLarge + 2),
                  fontWeight: AppTypography.fontWeightBold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor =
        isDestructive ? AppColors.accentRed : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: EdgeInsets.zero,
          quality: GlassQuality.standard,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSmall),
              ),
              child: Icon(icon, color: primaryColor, size: 22),
            ),
            title: Text(
              title,
              style: GoogleFonts.dmSans(
                fontWeight: AppTypography.fontWeightBold,
                fontSize: AppTypography.fontSizeMedium,
                color: isDestructive ? AppColors.accentRed : null,
              ),
            ),
            subtitle: subtitle != null
                ? Text(
                    subtitle!,
                    style: GoogleFonts.dmSans(
                      fontSize: AppTypography.fontSizeXSmall + 1,
                      color: isDestructive
                          ? AppColors.accentRed.withValues(alpha: 0.7)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  )
                : null,
            trailing: trailing,
          ),
        ),
      ),
    );
  }
}


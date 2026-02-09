import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../const/app_typography.dart';
import '../const/app_dimensions.dart';

class EmptyStateView extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String? description;
  final Widget? action;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: icon is String
                ? SvgPicture.asset(
                    icon,
                    colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary.withValues(alpha: 0.4),
                        BlendMode.srcIn),
                    width: AppDimensions.chartRadiusSmall,
                    height: AppDimensions.chartRadiusSmall,
                  )
                : Icon(
                    icon,
                    size: AppDimensions.chartRadiusSmall,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
          ),
          const SizedBox(height: AppDimensions.paddingXLarge),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: AppTypography.fontSizeXLarge,
              fontWeight: AppTypography.fontWeightBold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: AppTypography.fontSizeMedium,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppDimensions.categoryIconSizeMobile),
            action!,
          ],
        ],
      ),
    );
  }
}

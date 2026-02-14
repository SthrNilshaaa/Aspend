import 'package:aspends_tracker/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../const/app_dimensions.dart';
import '../const/app_typography.dart';
import '../view_models/theme_view_model.dart';

class RangeSelector extends StatelessWidget {
  final List<String> ranges;
  final String selectedRange;
  final Function(String) onRangeSelected;
  final EdgeInsets? padding;

  const RangeSelector({
    super.key,
    required this.ranges,
    required this.selectedRange,
    required this.onRangeSelected,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark =  context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: padding ??
          const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingStandard,
              vertical: AppDimensions.paddingSmall),
      child: Row(
        children: ranges.map((range) {
          final isSelected = selectedRange == range;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.paddingSmall),
            child: ZoomTapAnimation(
              onTap: () {
                onRangeSelected(range);
                HapticFeedback.lightImpact();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingStandard,
                    vertical: AppDimensions.paddingSmall),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen.withValues(alpha: 0.5)
                      : theme.colorScheme.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.borderRadiusMedium),
                  border: Border.all(
                    color: isSelected
                        ?  AppColors.balanceCardBorderDarkModePositive
                        : theme.dividerColor.withValues(alpha: 0.1),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.accentGreen
                                .withValues(alpha: 0.3),
                            blurRadius: AppDimensions.blurRadiusStandard,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Text(
                  range,
                  style: GoogleFonts.dmSans(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? isDark
                        ? Colors.white
                        : Colors.black
                        : theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                    fontSize: AppTypography.fontSizeSmall - 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

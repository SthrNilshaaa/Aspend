import 'package:aspends_tracker/core/const/app_dimensions.dart';
import 'package:aspends_tracker/core/const/app_strings.dart';
import 'package:aspends_tracker/core/const/app_typography.dart';
import 'package:aspends_tracker/core/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../core/const/app_assets.dart';
import '../core/const/app_colors.dart';

class SearchFilterBar extends StatelessWidget {
  final String? searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final VoidCallback onSortTap;

  const SearchFilterBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onClear,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeViewModel = context.watch<ThemeViewModel>();
    final isDark = themeViewModel.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingStandard,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          /// SEARCH FIELD
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.primaryColor.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: const BorderRadius.all(
                    Radius.circular(AppDimensions.borderRadiusMinLarge)),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  _buildSearchIcon(context, theme, isDark),
                  const SizedBox(width: 2),
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 8),

                  /// TEXT FIELD
                  Expanded(
                    child: TextField(
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        hintStyle: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeSmall,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: searchQuery != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: onClear,
                              )
                            : null,
                      ),
                      style: GoogleFonts.dmSans(
                        fontSize: AppTypography.fontSizeRegular,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          /// FILTER BUTTON
          ZoomTapAnimation(
            onTap: () {
              HapticFeedback.mediumImpact();
              onSortTap();
            },
            child: _buildFilterButton(context, theme, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchIcon(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.balanceCardDarkModePositive
              : AppColors.balanceCardLightModePositive,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            width: 1.4,
          ),
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusRegular),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            child: Center(
              child: SvgPicture.asset(
                SvgAppIcons.searchIcon,
                colorFilter: const ColorFilter.mode(
                    AppColors.accentGreen, BlendMode.srcIn),
                width: 16,
                height: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMinLarge),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
          width: 1.4,
        ),
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.balanceCardDarkModePositive
                : AppColors.balanceCardLightModePositive,
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              width: 1.4,
            ),
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusRegular),
          ),
          child: Center(
            child: SvgPicture.asset(
              SvgAppIcons.filterIcon,
              colorFilter: const ColorFilter.mode(
                  AppColors.accentGreen, BlendMode.srcIn),
              width: 16,
              height: 16,
            ),
          ),
        ),
      ),
    );
  }
}

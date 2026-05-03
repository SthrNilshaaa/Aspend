import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../core/const/app_colors.dart';
import '../../core/const/app_dimensions.dart';
import '../../core/const/app_strings.dart';
import '../../core/const/app_typography.dart';
import '../../core/const/app_assets.dart';
import '../../core/view_models/theme_view_model.dart';
import '../../core/view_models/transaction_view_model.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onFilterTap;

  const HomeSearchBar({
    super.key,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.select<ThemeViewModel, bool>((vm) => vm.isDarkMode);
    final searchQuery =
        context.select<TransactionViewModel, String?>((vm) => vm.searchQuery);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingStandard,
          vertical: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: GlassContainer(
              height: 56,
              shape: LiquidRoundedSuperellipse(
                borderRadius: AppDimensions.borderRadiusMinLarge,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.balanceCardDarkModePositive
                              : AppColors.balanceCardLightModePositive,
                          border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.15),
                              width: 1.4),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.borderRadiusRegular)),
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
                  Container(
                    width: 1,
                    height: 24,
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: searchQuery)
                        ..selection = TextSelection.fromPosition(
                            TextPosition(offset: searchQuery?.length ?? 0)),
                      onChanged: (val) {
                        context
                            .read<TransactionViewModel>()
                            .setSearchQuery(val);
                      },
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        hintStyle: GoogleFonts.dmSans(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          fontSize: AppTypography.fontSizeSmall,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: searchQuery != null
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  context
                                      .read<TransactionViewModel>()
                                      .setSearchQuery(null);
                                },
                              )
                            : null,
                      ),
                      style: GoogleFonts.dmSans(
                          fontSize: AppTypography.fontSizeRegular,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          ZoomTapAnimation(
            onTap: onFilterTap,
            child: GlassCard(
              width: 54,
              height: 54,
              padding: EdgeInsets.zero,
              shape: LiquidRoundedSuperellipse(
                borderRadius: AppDimensions.borderRadiusMinLarge,
              ),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.balanceCardDarkModePositive
                      : AppColors.balanceCardLightModePositive,
                  border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      width: 1.4),
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
          ),
        ],
      ),
    );
  }
}


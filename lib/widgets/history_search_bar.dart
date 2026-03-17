import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../core/const/app_colors.dart';
import '../core/const/app_dimensions.dart';
import '../core/const/app_typography.dart';
import '../core/const/app_assets.dart';
import '../core/const/app_strings.dart';

class HistorySearchBar extends StatelessWidget {
  final String? searchQuery;
  final bool isDark;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterTap;

  const HistorySearchBar({
    super.key,
    required this.searchQuery,
    required this.isDark,
    required this.onSearchChanged,
    required this.onClear,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingStandard,
          vertical: AppDimensions.paddingSmall),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.primaryColor.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMinLarge),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  _SearchIcon(isDark: isDark),
                  const SizedBox(width: 2),
                  _VerticalDivider(theme: theme),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SearchTextField(
                      searchQuery: searchQuery,
                      theme: theme,
                      onChanged: onSearchChanged,
                      onClear: onClear,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          _FilterButton(
            isDark: isDark,
            theme: theme,
            onTap: onFilterTap,
          ),
        ],
      ),
    );
  }
}

class _SearchIcon extends StatelessWidget {
  final bool isDark;
  const _SearchIcon({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              width: 1.4),
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusRegular),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
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
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final ThemeData theme;
  const _VerticalDivider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: theme.dividerColor.withValues(alpha: 0.2),
    );
  }
}

class _SearchTextField extends StatefulWidget {
  final String? searchQuery;
  final ThemeData theme;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchTextField({
    required this.searchQuery,
    required this.theme,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<_SearchTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(_SearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery ?? '';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: AppStrings.searchHint,
        hintStyle: GoogleFonts.dmSans(
          fontSize: AppTypography.fontSizeSmall,
          color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        suffixIcon: widget.searchQuery != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: widget.onClear,
              )
            : null,
      ),
      style: GoogleFonts.dmSans(
          fontSize: AppTypography.fontSizeRegular,
          color: widget.theme.colorScheme.onSurface,
          letterSpacing: -0.1),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onTap;

  const _FilterButton({
    required this.isDark,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(AppDimensions.borderRadiusMinLarge),
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
                  width: 1.4),
              borderRadius:
                  BorderRadius.circular(AppDimensions.borderRadiusRegular),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
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
      ),
    );
  }
}

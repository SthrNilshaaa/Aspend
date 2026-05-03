import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../core/const/app_dimensions.dart';
import '../core/utils/responsive_utils.dart';

class CustomGlassAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool floating;

  final Widget? leading;
  final bool automaticallyImplyLeading;

  const CustomGlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.floating = true,
    this.centerTitle = false,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingStandard,
          ),
          child: Container(
            color: theme.dividerColor.withValues(alpha: 0.1),
            height: 1,
          ),
        ),
      ),
      toolbarHeight: ResponsiveUtils.isMobile(context) ? 80 : 80,
      expandedHeight: ResponsiveUtils.isMobile(context) ? 80 : 80,
      floating: floating,
      pinned: true,
      scrolledUnderElevation: 0.0,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: actions,
      leading: leading,
      leadingWidth: 70,
      titleSpacing: 4,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context,
              mobile: 20, tablet: 24, desktop: 28),
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        background: GlassContainer(
          shape: const LiquidRoundedRectangle(borderRadius: 0),
          quality: GlassQuality.premium,
          child: Container(
            color: theme.colorScheme.surface.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }
}


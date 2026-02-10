import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_utils.dart';

class GlassAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool floating;

  final Widget? leading;
  final bool automaticallyImplyLeading;

  const GlassAppBar({
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
      toolbarHeight: ResponsiveUtils.isMobile(context) ? 70 : 80,
      expandedHeight: ResponsiveUtils.isMobile(context) ? 70 : 80,
      floating: floating,
      pinned: true,
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
              mobile: 32, tablet: 24, desktop: 28),
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          // Persistent Glass Effect Layer
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                      theme.colorScheme.surface.withValues(alpha: 0.15),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const FlexibleSpaceBar(
            centerTitle: false,
          ),
        ],
      ),
    );
  }
}

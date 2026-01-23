import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_utils.dart';

class GlassAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: ResponsiveUtils.getResponsiveAppBarHeight(context),
      floating: true,
      pinned: true,
      elevation: 1,
      backgroundColor: Colors.transparent,
      actions: actions,
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
          FlexibleSpaceBar(
            centerTitle: centerTitle,
            title: Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 20, tablet: 24, desktop: 28),
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

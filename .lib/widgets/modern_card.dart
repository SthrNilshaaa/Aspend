import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../core/const/app_dimensions.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppDimensions.borderRadiusLarge,
    this.color,
    this.boxShadow,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingStandard),
      shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
      child: child,
    );
  }
}


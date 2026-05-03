import 'dart:ui';

import 'package:flutter/material.dart';

class GradientBlurContainer extends StatelessWidget {
  final double width;
  final double height;
  final double blurStrength;
  final List<Color> gradientColors;
  final BorderRadius? borderRadius;
  final Widget? child;

  const GradientBlurContainer({
    super.key,
    required this.width,
    required this.height,
    this.blurStrength = 5.0,
    this.gradientColors = const [Colors.white24, Colors.white10],
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Layer 1: The Gradient Blur Effect
            ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(rect);
              },
              blendMode: BlendMode.dstIn,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: blurStrength, sigmaY: blurStrength),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

            // Layer 2: The Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors:
                      gradientColors.map((c) => c.withValues(alpha: 0.4)).toList(),
                ),
              ),
            ),

            // Layer 3: Optional Child Content (e.g. buttons)
            if (child != null) Center(child: child),
          ],
        ),
      ),
    );
  }
}

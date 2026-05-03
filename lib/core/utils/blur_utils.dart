import 'dart:ui';
import 'package:flutter/material.dart';

class BlurUtils {
  static const double blurSigma = 5.0;

  static ImageFilter get standardBlur =>
      ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma);

  static Future<T?> showBlurredDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: standardBlur,
        child: child,
      ),
    );
  }

  static Future<T?> showBlurredBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: clipBehavior,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: standardBlur,
        child: child,
      ),
    );
  }
}

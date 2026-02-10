import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGreen = Colors.green;
  static const Color launcherBackground = Color(0xFF0D1311);

  // You can add more specific theme colors here if needed
  static const Color cardShadowLight = Color(0x08000000); // 0.03 opacity black
  static const Color cardShadowDark = Color(0x33000000); // 0.2 opacity black

  // Balance Card Gradients
  static const Color balanceCardDarkStart = Color(0xFF0A1A12);
  static const Color balanceCardDarkEnd = Color(0xFF0F2A1E);
  static const Color balanceCardLightStart = Color(0xFFB4EABC);
  static const Color balanceCardLightEnd = Color(0xFFB4EABC);

  // Status & Accent Colors
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color accentRed = Color(0xFFFF5252);

  static Color getCardShadow(bool isDark) =>
      isDark ? cardShadowDark : cardShadowLight;
}

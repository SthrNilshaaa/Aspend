import 'package:flutter/material.dart';

class AppColors {
  // Deep, premium Emerald/Teal instead of standard green
  static const Color primaryGreen = Color(0xFF047857);

  // Slightly softer rich black for a more "crafted" look
  static const Color launcherBackground = Color(0xFF0A0F0D);

  // Make shadows softer and more elegant
  static const Color cardShadowLight = Color(0x06000000); // Softer light shadow
  static const Color cardShadowDark = Color(0x20000000); // Softer dark shadow
  // Balance Card Gradients - More Premium and Subtle
  static const Color balanceCardDarkStart =
      Color(0xFF0D0F0E); // Very deep charcoal
  static const Color balanceCardDarkEnd = Color(0xFF050806); // Near black
  static const Color balanceCardLightStart = Color(0xFFE5F7E8); // Softer mint
  static const Color balanceCardLightEnd =
      Color(0xFFF1FAF3); // Almost white mint
  static const Color balanceCardLightBorder =
      Color(0xFFC8EED0); // Elegant subtle border
  static const Color balanceCardDarkBorder =
      Color(0xFF1E2824); // Sharp dark border

  static const Color balanceCardDarkModeNegative =
      Color(0xFF1E1312); // Softer red bg
  static const Color balanceCardLightModeNegative = Color(0xFFFFF0F0);
  static const Color balanceCardDarkModePositive =
      Color(0xFF0F2418); // Deeper green bg
  static const Color balanceCardLightModePositive = Color(0xFFE1F4E6);

  static const Color balanceCardBorderDarkModeNegative = Color(0xFF322220);
  static const Color balanceCardBorderLightModeNegative = Color(0xFFFFE0E0);
  static const Color balanceCardBorderDarkModePositive = Color(0xFF263D30);
  static const Color balanceCardBorderLightModePositive = Color(0xFFCEEDD5);

  static const Color balanceCardLineDarkModeNegative = Color(0xFFFF4D4D);
  static const Color balanceCardLineLightModeNegative =
      Color(0xFFDC2626); // Stronger hierarchy
  static const Color balanceCardLineDarkModePositive =
    Color(0xFF55DF69);
     // Color(0xFF34D399); // Electric mint
  static const Color balanceCardLineLightModePositive =
  Color(0xFF55DF69);
  //    Color(0xFF059669); // Deep emerald

  // Status & Accent Colors
  static const Color accentGreen = Color(0xFF55DF69);
  static const Color accentRed = Color(0xFFD32E2E);

  static Color getCardShadow(bool isDark) =>
      isDark ? cardShadowDark : cardShadowLight;
}

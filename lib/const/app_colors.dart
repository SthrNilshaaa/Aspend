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
  static const Color balanceCardLightStart = Color(0xFFDBF5E0);
  static const Color balanceCardLightEnd = Color(0xFFDBF5E0);
  static const Color balanceCardLightBorder = Color(0xFFB4EABC);
  static const Color balanceCardDarkBorder = Color(0xFF191D1C);

  static const Color balanceCardDarkModeNegative = Color(0xFF261716);
  static const Color balanceCardLightModeNegative = Color(0xFFFFE4E3);
static const Color balanceCardDarkModePositive = Color(0xFF173223);
  static const Color balanceCardLightModePositive = Color(0xFFD9F1DD);

  static const Color balanceCardBorderDarkModeNegative = Color(0xFF322C2B);
  static const Color balanceCardBorderLightModeNegative = Color(0xFFFFF3F3);
static const Color balanceCardBorderDarkModePositive = Color(0xFF354D40);
  static const Color balanceCardBorderLightModePositive = Color(0xFFDBF5E0);

static const Color balanceCardLineDarkModeNegative = Color(0xFFFF5656);
  static const Color balanceCardLineLightModeNegative = Color(0xFFD32E2E);
static const Color balanceCardLineDarkModePositive = Color(0xFF55DF69);
  static const Color balanceCardLineLightModePositive = Color(0xFF2B9D3C);




  // Status & Accent Colors
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color accentRed = Color(0xFFD32E2E);

  static Color getCardShadow(bool isDark) =>
      isDark ? cardShadowDark : cardShadowLight;
}

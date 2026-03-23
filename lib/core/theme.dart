import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8BC34A); // 연녹색
  static const Color primaryLight = Color(0xFFC5E1A5);
  static const Color primaryVeryLight = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFFAFFFA);
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF2E3A2E);
  static const Color textSecondary = Color(0xFF6B7B6B);
  static const Color cardHover = Color(0x1A000000);
}

ThemeData appTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Pretendard',
    useMaterial3: true,
  );
}

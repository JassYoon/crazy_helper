import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF8BC34A);
  static const Color primaryDark = Color(0xFF689F38);
  static const Color primaryLight = Color(0xFFC5E1A5);
  static const Color primaryVeryLight = Color(0xFFE8F5E9);

  // Backgrounds
  static const Color background = Color(0xFFFAFFFA);
  static const Color surface = Colors.white;
  static const Color surfaceLight = Color(0xFFF1F8E9);

  // Text
  static const Color textPrimary = Color(0xFF2E3A2E);
  static const Color textSecondary = Color(0xFF6B7B6B);
  static const Color textHint = Color(0xFFA5B5A5);

  // Borders & dividers
  static const Color border = Color(0xFFD5E8C0);
  static const Color divider = Color(0xFFE8F0E0);

  // Functional
  static const Color white = Colors.white;
  static const Color cardHover = Color(0x0D4CAF50);
  static const Color star = Color(0xFFFFB74D);
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF66BB6A);
}

ThemeData appTheme() {
  final textTheme = GoogleFonts.notoSansKrTextTheme();

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    useMaterial3: true,
  );
}

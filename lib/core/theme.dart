import 'dart:ui' show FontFeature;

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

/// 플로팅 위젯(원형 버튼)과 메뉴 바 — 홈 화면과 동일한 흰 배경·[border]·프라이머리 톤 그림자.
abstract final class AppFloatingChrome {
  AppFloatingChrome._();

  static const double widgetSize = 56;
  static const double menuBarHeight = 52;
  static const double menuBarGap = 8;

  static List<BoxShadow> get _shadow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 3),
        ),
      ];

  /// 메뉴 바·빈 상태 안내 패널
  static BoxDecoration get menuPanel => BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: _shadow,
      );

  /// 메인 플로팅 위젯(로고) 원
  static BoxDecoration get widgetOrb => BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: _shadow,
      );
}

ThemeData appTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
  return base.copyWith(
    textTheme: GoogleFonts.notoSansKrTextTheme(base.textTheme),
    primaryTextTheme: GoogleFonts.notoSansKrTextTheme(base.primaryTextTheme),
  );
}

/// [appTheme]의 본문 글꼴(Noto Sans KR)을 유지한 채 크기·색만 덮어씁니다.
TextStyle appStyle(
  BuildContext context, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  TextDecoration? decoration,
  Color? decorationColor,
  double? height,
  double? letterSpacing,
  List<FontFeature>? fontFeatures,
}) {
  return Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        height: height,
        letterSpacing: letterSpacing,
        fontFeatures: fontFeatures,
      );
}

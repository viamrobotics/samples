import 'package:flutter/material.dart';

abstract final class AppColors {
  static const black = Color(0xFF30323D);
  static const bg1 = Color(0xFFF5F7F8);
  static const gray5 = Color(0xFFC5C6CC);
  static const gray6 = Color(0xFF9C9CA4);
  static const subtle1 = Color(0xFF67717A);
  static const secondary = Color(0xFFF5F7F8);
  static const outline = Color(0xFFE4E4E6);
  static const highlight = Color(0xFFE6F3FA);
  static const blue = Color(0xFF1A7BBD);
  static const error = Color(0xFFBE3536);
  static const errorlight = Color(0xFFFCECEA);
  static const onError = Colors.white;
  static const bgmedium = Color(0xFFF1F1F4);
  static const successlight = Color(0xFFE0FAE3);
  static const successdark = Color(0xFF3D7D3F);
  static const infolight = Color(0xFFE1F3FF);
  static const infodark = Color(0xFF0066CC);

  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.black,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.black,
    surface: AppColors.bg1,
    onSurface: Colors.black,
    error: AppColors.error,
    onError: AppColors.onError,
    outline: AppColors.gray5,
    outlineVariant: AppColors.outline,
  );
}

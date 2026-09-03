import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'zaiwan_colors.dart';
import 'app_radius.dart';

/// 负责创建应用统一使用的 Flutter 主题
final class AppTheme {
  AppTheme._();

  /// 创建应用的亮色主题
  static ThemeData get light {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.cobaltBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.cobaltBlue,
          onPrimary: AppColors.white,
          secondary: AppColors.warmOrange,
          onSecondary: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.darkNavy,
          error: AppColors.errorRed,
          onError: AppColors.white,
        );

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: const [ZaiwanColors.light],
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.warmWhite,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.warmWhite,
        foregroundColor: AppColors.darkNavy,
      ),
      textTheme: baseTheme.textTheme.copyWith(
        headlineMedium: const TextStyle(
          color: AppColors.darkNavy,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleMedium: const TextStyle(
          color: AppColors.darkNavy,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.blueGray,
          fontSize: 16,
          height: 1.5,
        ),
        labelLarge: const TextStyle(
          color: AppColors.cobaltBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cobaltBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppRadius.medium,
            ),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

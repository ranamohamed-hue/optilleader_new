import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_text_style.dart';

class AppTextThemes {
  // --- 1. ثيم النصوص للوضع الفاتح ---
  static TextTheme get lightTextTheme => TextTheme(
    displayLarge: AppTextStyles.displayLarge.copyWith(
      color: AppColors.lightPrimary,
    ),
    displayMedium: AppTextStyles.displayMedium.copyWith(
      color: AppColors.lightPrimary,
    ),
    displaySmall: AppTextStyles.displaySmall.copyWith(
      color: AppColors.lightPrimary,
    ),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(
      color: AppColors.lightPrimary,
    ),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(
      color: AppColors.lightPrimary,
    ),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(
      color: AppColors.lightPrimary,
    ),
    titleLarge: AppTextStyles.titleLarge.copyWith(
      color: AppColors.lightPrimary,
    ),
    titleMedium: AppTextStyles.titleMedium.copyWith(
      color: AppColors.lightPrimary,
    ),
    titleSmall: AppTextStyles.titleSmall.copyWith(
      color: AppColors.lightPrimary,
    ),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightPrimary),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.lightPrimary,
    ),
    bodySmall: AppTextStyles.bodySmall.copyWith(
      color: AppColors.lightTextSecondary,
    ),
    labelLarge: AppTextStyles.labelLarge.copyWith(
      color: AppColors.lightPrimary,
    ),
    labelMedium: AppTextStyles.labelMedium.copyWith(
      color: AppColors.lightTextSecondary,
    ),
    labelSmall: AppTextStyles.labelSmall.copyWith(
      color: AppColors.lightTextSecondary,
    ),
  );

  // --- 2. ثيم النصوص للوضع المظلم ---
  static TextTheme get darkTextTheme => TextTheme(
    displayLarge: AppTextStyles.displayLarge.copyWith(
      color: AppColors.darkText,
    ),
    displayMedium: AppTextStyles.displayMedium.copyWith(
      color: AppColors.darkText,
    ),
    displaySmall: AppTextStyles.displaySmall.copyWith(
      color: AppColors.darkText,
    ),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(
      color: AppColors.darkText,
    ),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(
      color: AppColors.darkText,
    ),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(
      color: AppColors.darkText,
    ),
    titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkText),
    titleMedium: AppTextStyles.titleMedium.copyWith(
      color: AppColors.darkText.withOpacity(0.9),
    ),
    titleSmall: AppTextStyles.titleSmall.copyWith(
      color: AppColors.darkText.withOpacity(0.8),
    ),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkText),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.darkText.withOpacity(0.7),
    ),
    bodySmall: AppTextStyles.bodySmall.copyWith(color: Colors.white38),
    labelLarge: AppTextStyles.labelLarge.copyWith(
      color: AppColors.darkGoldBright,
    ),
    labelMedium: AppTextStyles.labelMedium.copyWith(color: Colors.white54),
    labelSmall: AppTextStyles.labelSmall.copyWith(color: Colors.white38),
  );
}

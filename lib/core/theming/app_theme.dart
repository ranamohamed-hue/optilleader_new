import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_text_theme.dart';

class AppTheme {
  // --- 1. الثيم الفاتح (Light Theme) الكـامل ---
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromARGB(255, 228, 206, 163),
      textTheme: AppTextThemes.lightTextTheme,

      // نظام الألوان (ColorScheme)
      colorScheme: const ColorScheme.light(
        primary: AppColors.navyDark,
        primaryContainer: AppColors.navyLight,
        secondary: AppColors.darkGold,
        surface: AppColors.pureWhite,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.navyDark,
      ),

      // الـ AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextThemes.lightTextTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // الأزرار (Buttons)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyDark,
          foregroundColor: Colors.white,
          textStyle: AppTextThemes.lightTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyDark,
          side: const BorderSide(color: AppColors.navyDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.navyDark,
          textStyle: AppTextThemes.lightTextTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // خانات الإدخال (Inputs)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.darkGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
          color: Colors.grey,
        ),
        prefixIconColor: AppColors.navyDark,
      ),

      // عناصر التفاعل (Radio, Checkbox, Switch)
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.navyDark),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(AppColors.navyDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.darkGold
              : Colors.grey,
        ),
        trackColor: WidgetStateProperty.all(
          AppColors.darkGold.withOpacity(0.3),
        ),
      ),

      // التنقل (BottomNav, TabBar)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.navyDark,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.darkGold,
        unselectedLabelColor: Colors.black54,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: AppTextThemes.lightTextTheme.titleSmall,
        unselectedLabelStyle: AppTextThemes.lightTextTheme.titleSmall,
      ),

      // العناصر العائمة والتنبيهات
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkGold,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.navyDark,
        contentTextStyle: AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      // الكروت والديالوج (Cards & Dialogs)
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.9),
        elevation: 3,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // مطابق للـ Dashboard
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.pureWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        titleTextStyle: AppTextThemes.lightTextTheme.titleLarge,
      ),
    );
  }

  // --- 2. الثيم الداكن (Dark Theme) الكـامل ---
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTextThemes.darkTextTheme,

      // نظام الألوان الداكن
      colorScheme: const ColorScheme.dark(
        primary: AppColors.navyLight,
        primaryContainer: AppColors.navyDark,
        secondary: AppColors.darkGoldBright,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.darkText,
      ),

      // الـ AppBar الداكن
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextThemes.darkTextTheme.titleLarge?.copyWith(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkGoldBright),
      ),

      // الأزرار الداكنة
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navyLight,
          foregroundColor: Colors.white,
          textStyle: AppTextThemes.darkTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // خانات الإدخال في الدارك مود
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: AppColors.darkGoldBright,
            width: 1.5,
          ),
        ),
        hintStyle: AppTextThemes.darkTextTheme.bodyMedium?.copyWith(
          color: Colors.white38,
        ),
        prefixIconColor: AppColors.darkGoldBright,
      ),

      // الكروت في الدارك مود
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),

      // التنقل في الدارك مود
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkGoldBright,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkGoldBright,
        foregroundColor: AppColors.navyDark,
      ),
    );
  }
}

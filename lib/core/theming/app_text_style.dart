import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  // الأوزان (Weights)
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight regular = FontWeight.w400;

  // اسم الخط
  static const String fontFamily = 'Cairo';

  // --- العناوين الضخمة (Display) ---
  static TextStyle get displayLarge => TextStyle(
        fontSize: 57.sp,
        fontWeight: bold,
        fontFamily: fontFamily,
        height: 1.2,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 45.sp,
        fontWeight: bold,
        fontFamily: fontFamily,
      );

  static TextStyle get displaySmall => TextStyle(
        fontSize: 36.sp,
        fontWeight: bold,
        fontFamily: fontFamily,
      );

  // --- العناوين الرئيسية (Headlines) ---
  static TextStyle get headlineLarge => TextStyle(
        fontSize: 32.sp,
        fontWeight: bold,
        fontFamily: fontFamily,
        height: 1.3,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 28.sp,
        fontWeight: semiBold,
        fontFamily: fontFamily,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: 24.sp,
        fontWeight: semiBold,
        fontFamily: fontFamily,
      );

  // --- العناوين الفرعية وكروت البيانات (Titles) ---
  static TextStyle get titleLarge => TextStyle(
        fontSize: 22.sp,
        fontWeight: bold,
        fontFamily: fontFamily,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 16.sp,
        fontWeight: semiBold,
        fontFamily: fontFamily,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: 14.sp,
        fontWeight: medium,
        fontFamily: fontFamily,
      );

  // --- نصوص المحتوى (Body) ---
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: regular,
        fontFamily: fontFamily,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: regular,
        fontFamily: fontFamily,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: regular,
        fontFamily: fontFamily,
      );

  // --- النصوص الصغيرة والأزرار (Labels) ---
  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: bold,
        fontFamily: fontFamily,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: medium,
        fontFamily: fontFamily,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 10.sp,
        fontWeight: medium,
        fontFamily: fontFamily,
      );
}
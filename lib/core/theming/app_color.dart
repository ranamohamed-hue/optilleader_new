import 'package:flutter/material.dart';

class AppColors {
  // --- الألوان الملكية المعتمدة (الدرجات المحدثة) ---
static const Color navyDark = Color(0xFF0D1B2A); 
  static const Color navyLight = Color(0xFF1B263B); 
  static const Color lightBackground = Color.fromARGB(255, 226, 209, 176);
  static const Color darkGold = Color(0xFF8E6D3B); 
  static const Color royalGold = Color(0xFFC5A358); 
  static const Color pureWhite = Color(0xFFFFFFFF);

  // --- ألوان الحالة (Status) ---
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color statusWaitingBg = Color(0xFFFFE1E1); 
  static const Color statusWaitingText = Color(0xFFB71C1C);

  
  // --- ألوان الثيم الليلي (Dark Mode) ---
  static const Color darkBackground = Color(0xFF010B13); 
  static const Color darkSurface = Color(0xFF0D1B2A); 
  static const Color darkText = Color(0xFFE0E1DD); 
  static const Color darkGoldBright = Color(0xFFE9C46A);

  // --- الربط بالثيم الفاتح ونصوصه ---
  static const Color lightPrimary = navyDark;
  static const Color lightTextSecondary = Color.fromARGB(255, 241, 231, 231);
}
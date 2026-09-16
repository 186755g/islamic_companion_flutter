import 'package:flutter/material.dart';

/// لوحة الألوان: أخضر داكن هادئ + ذهبي + أبيض عاجي
class AppColors {
  static const Color deepGreen = Color(0xFF0B3D2E);
  static const Color mediumGreen = Color(0xFF14543E);
  static const Color gold = Color(0xFFC9A227);
  static const Color lightGold = Color(0xFFE8D48A);
  static const Color ivory = Color(0xFFFBF7EF);
  static const Color textDark = Color(0xFF1C2A22);
  static const Color success = Color(0xFF3E8E5A);
  static const Color softGreen = Color(0xFFE7F0E8);
  static const Color warmSand = Color(0xFFF2E6C9);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ivory,
      // ملاحظة: خط Amiri معطّل افتراضياً (راجع pubspec.yaml) لعدم توفر
      // ملفات الخط الفعلية. عند إضافتها وتفعيل القسم في pubspec.yaml،
      // أضف "fontFamily: 'Amiri'," هنا لتفعيله في كل التطبيق.
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepGreen,
        primary: AppColors.deepGreen,
        secondary: AppColors.gold,
        surface: AppColors.ivory,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: AppColors.ivory,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.ivory,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1.5,
        shadowColor: AppColors.deepGreen.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.25)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepGreen,
          foregroundColor: AppColors.ivory,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.warmSand,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.gold.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall:
            TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        titleMedium:
            TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark, height: 1.6),
      ),
    );
  }
}

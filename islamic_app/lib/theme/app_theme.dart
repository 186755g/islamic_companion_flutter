import 'package:flutter/material.dart';

enum AppThemeType {
  classicMinimal,
  ornateIslamic,
}

extension AppThemeTypeX on AppThemeType {
  String get storageName {
    switch (this) {
      case AppThemeType.classicMinimal:
        return 'classic_minimal';
      case AppThemeType.ornateIslamic:
        return 'ornate_islamic';
    }
  }

  static AppThemeType fromStorage(String? value) {
    switch (value) {
      case 'ornate_islamic':
        return AppThemeType.ornateIslamic;
      case 'classic_minimal':
      default:
        return AppThemeType.classicMinimal;
    }
  }
}

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

  static const Color ornateGreen = Color(0xFF113A2F);
  static const Color ornateGold = Color(0xFFC39A42);
  static const Color ornateCream = Color(0xFFF7F1E5);
  static const Color ornateBronze = Color(0xFF8A6536);
  static const Color ornateDark = Color(0xFF1C2C23);
}

class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.primary,
    required this.primarySoft,
    required this.secondary,
    required this.surface,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.cardShadow,
    required this.cardRadius,
    required this.buttonRadius,
    required this.goldGradient,
    required this.ornamentPattern,
    required this.ornamentFrame,
  });

  final Color primary;
  final Color primarySoft;
  final Color secondary;
  final Color surface;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final List<BoxShadow> cardShadow;
  final BorderRadius cardRadius;
  final BorderRadius buttonRadius;
  final LinearGradient goldGradient;
  final String ornamentPattern;
  final String ornamentFrame;

  static const AppThemeTokens classic = AppThemeTokens(
    primary: AppColors.deepGreen,
    primarySoft: AppColors.softGreen,
    secondary: AppColors.gold,
    surface: AppColors.ivory,
    background: AppColors.ivory,
    textPrimary: AppColors.textDark,
    textSecondary: Color(0xFF607068),
    border: Color(0xFFE1D6B8),
    cardShadow: [
      BoxShadow(
        color: Color(0x1A0B3D2E),
        blurRadius: 12,
        offset: Offset(0, 5),
      ),
    ],
    cardRadius: BorderRadius.all(Radius.circular(18)),
    buttonRadius: BorderRadius.all(Radius.circular(14)),
    goldGradient: LinearGradient(
      colors: [AppColors.gold, AppColors.lightGold],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    ornamentPattern: 'assets/ornaments/patterns/arabesque_pattern.svg',
    ornamentFrame: 'assets/ornaments/frames/gold_border.svg',
  );

  static const AppThemeTokens ornate = AppThemeTokens(
    primary: AppColors.ornateGreen,
    primarySoft: Color(0xFF1E453F),
    secondary: AppColors.ornateGold,
    surface: AppColors.ornateCream,
    background: AppColors.ornateCream,
    textPrimary: AppColors.ornateDark,
    textSecondary: Color(0xFF745F42),
    border: Color(0xFFD4B06B),
    cardShadow: [
      BoxShadow(
        color: Color(0x4D8A6536),
        blurRadius: 14,
        offset: Offset(0, 8),
      ),
    ],
    cardRadius: BorderRadius.all(Radius.circular(22)),
    buttonRadius: BorderRadius.all(Radius.circular(16)),
    goldGradient: LinearGradient(
      colors: [Color(0xFFD8B15D), Color(0xFFF1D99B), Color(0xFFB77C2C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ornamentPattern: 'assets/ornaments/patterns/arabesque_pattern.svg',
    ornamentFrame: 'assets/ornaments/frames/gold_border.svg',
  );

  @override
  AppThemeTokens copyWith({
    Color? primary,
    Color? primarySoft,
    Color? secondary,
    Color? surface,
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    List<BoxShadow>? cardShadow,
    BorderRadius? cardRadius,
    BorderRadius? buttonRadius,
    LinearGradient? goldGradient,
    String? ornamentPattern,
    String? ornamentFrame,
  }) {
    return AppThemeTokens(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      secondary: secondary ?? this.secondary,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      cardShadow: cardShadow ?? this.cardShadow,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      goldGradient: goldGradient ?? this.goldGradient,
      ornamentPattern: ornamentPattern ?? this.ornamentPattern,
      ornamentFrame: ornamentFrame ?? this.ornamentFrame,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) return this;
    return AppThemeTokens(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t) ?? primarySoft,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      background: Color.lerp(background, other.background, t) ?? background,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      border: Color.lerp(border, other.border, t) ?? border,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      cardRadius: BorderRadius.lerp(cardRadius, other.cardRadius, t) ?? cardRadius,
      buttonRadius:
          BorderRadius.lerp(buttonRadius, other.buttonRadius, t) ?? buttonRadius,
      goldGradient: t < 0.5 ? goldGradient : other.goldGradient,
      ornamentPattern: t < 0.5 ? ornamentPattern : other.ornamentPattern,
      ornamentFrame: t < 0.5 ? ornamentFrame : other.ornamentFrame,
    );
  }
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
      visualDensity: VisualDensity.standard,
      extensions: const [AppThemeTokens.classic],
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
        elevation: 1,
        shadowColor: AppColors.deepGreen.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.14)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
        linearTrackColor: Color(0xFFE7EDE8),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.warmSand,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.gold.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            height: 1.35),
        titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            height: 1.35),
        bodyMedium: TextStyle(color: AppColors.textDark, height: 1.65),
        bodySmall: TextStyle(color: Color(0xFF607068), height: 1.5),
      ),
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF121A16);
    const darkSurface = Color(0xFF1C2822);
    const darkText = Color(0xFFF5F1E8);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      extensions: const [AppThemeTokens.classic],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.deepGreen,
        brightness: Brightness.dark,
        primary: AppColors.lightGold,
        secondary: AppColors.gold,
        surface: darkSurface,
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
        color: darkSurface,
        elevation: 1,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightGold,
          foregroundColor: AppColors.deepGreen,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.lightGold,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 68,
        backgroundColor: darkSurface,
        indicatorColor: AppColors.deepGreen,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.gold.withValues(alpha: 0.25),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: darkText,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: darkText,
          height: 1.35,
        ),
        bodyMedium: TextStyle(color: darkText, height: 1.6),
        bodySmall: TextStyle(color: Color(0xFFB7C5BD), height: 1.5),
      ),
    );
  }

  static ThemeData get ornateTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ornateCream,
      extensions: const [AppThemeTokens.ornate],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ornateGreen,
        primary: AppColors.ornateGreen,
        secondary: AppColors.ornateGold,
        surface: AppColors.ornateCream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ornateGreen,
        foregroundColor: AppColors.ornateCream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.ornateCream,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: AppColors.ornateGold.withValues(alpha: 0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.ornateGold.withValues(alpha: 0.3)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ornateGreen,
          foregroundColor: AppColors.ornateCream,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ornateGold,
        linearTrackColor: Color(0xFFECE0C2),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFF0E2B8),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.ornateGold.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.ornateDark,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.ornateDark,
          height: 1.35,
        ),
        bodyMedium: TextStyle(color: AppColors.ornateDark, height: 1.65),
        bodySmall: TextStyle(color: Color(0xFF745F42), height: 1.5),
      ),
    );
  }

  static ThemeData get ornateDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF141C1A),
      extensions: const [AppThemeTokens.ornate],
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.ornateGreen,
        brightness: Brightness.dark,
        primary: AppColors.ornateGold,
        secondary: AppColors.ornateGold,
        surface: const Color(0xFF1B2D27),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ornateGreen,
        foregroundColor: AppColors.ornateCream,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.ornateCream,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1F312E),
        elevation: 2,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.ornateGold.withValues(alpha: 0.35)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ornateGold,
          foregroundColor: AppColors.ornateDark,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.ornateGold,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 68,
        backgroundColor: Color(0xFF1B2D27),
        indicatorColor: AppColors.ornateGreen,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.ornateGold.withValues(alpha: 0.28),
        thickness: 1,
        space: 1,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFFF5F0E6),
          height: 1.35,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFFF5F0E6),
          height: 1.35,
        ),
        bodyMedium: TextStyle(color: Color(0xFFF5F0E6), height: 1.6),
        bodySmall: TextStyle(color: Color(0xFFCFD9D2), height: 1.5),
      ),
    );
  }
}

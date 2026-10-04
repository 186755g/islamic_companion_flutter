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

class AppColors {
  static const Color deepGreen = Color(0xFF0B3D2E);
  static const Color mediumGreen = Color(0xFF14543E);
  static const Color darkGreen = Color(0xFF0D2D25);
  static const Color gold = Color(0xFFC9A227);
  static const Color lightGold = Color(0xFFE8D48A);
  static const Color ivory = Color(0xFFFBF7EF);
  static const Color beige = Color(0xFFF4E7D1);
  static const Color warmSand = Color(0xFFF2E6C9);
  static const Color textDark = Color(0xFF1C2A22);
  static const Color textSecondary = Color(0xFF607068);
  static const Color success = Color(0xFF3E8E5A);
  static const Color warning = Color(0xFFD4A23A);
  static const Color error = Color(0xFFB9544C);
  static const Color divider = Color(0xFFE5DDCB);
  static const Color softGreen = Color(0xFFE7F0E8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = white;
  static const Color primary = deepGreen;
  static const Color secondary = gold;
  static const Color background = ivory;
  static const Color textPrimary = textDark;

  static const Color ornateGreen = Color(0xFF113A2F);
  static const Color ornateGold = Color(0xFFC39A42);
  static const Color ornateCream = Color(0xFFF7F1E5);
  static const Color ornateBronze = Color(0xFF8A6536);
  static const Color ornateDark = Color(0xFF1C2C23);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double huge = 32;
}

class AppRadius {
  static const double small = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double xLarge = 28;
  static const double pill = 999;

  static const BorderRadius smallAll = BorderRadius.all(Radius.circular(small));
  static const BorderRadius mediumAll =
      BorderRadius.all(Radius.circular(medium));
  static const BorderRadius largeAll = BorderRadius.all(Radius.circular(large));
  static const BorderRadius xLargeAll =
      BorderRadius.all(Radius.circular(xLarge));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

class AppAccessibility {
  static const double minTouchTarget = 48.0;
  static const double maxTextScale = 1.35;
}

class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.4,
    fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
  );

  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.35,
    fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.45,
    fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.7,
    fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.7,
    fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.6,
    fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.4,
    fontFamilyFallback: ['Noto Sans Arabic', 'Arial', 'sans-serif'],
  );
}

class AppButtonStyles {
  static final ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    ),
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
    textStyle: AppTextStyles.button,
  );

  static final ButtonStyle secondary = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.divider),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.md,
    ),
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.mediumAll),
    textStyle: AppTextStyles.button,
  );
}

class AppCardStyles {
  static const EdgeInsetsGeometry margin = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.xs,
  );

  static final RoundedRectangleBorder shape = const RoundedRectangleBorder(
    borderRadius: AppRadius.largeAll,
    side: BorderSide(color: AppColors.divider, width: 1),
  );

  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x0F0B3D2E),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];
}

class AppCheckboxStyles {
  static final CheckboxThemeData theme = CheckboxThemeData(
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
    side: const BorderSide(color: AppColors.divider),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.white;
    }),
    checkColor: WidgetStateProperty.all(AppColors.white),
  );
}

class AppSwitchStyles {
  static final SwitchThemeData theme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.white;
      }
      return AppColors.white;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.25);
      }
      return AppColors.divider;
    }),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.withValues(alpha: 0.12);
      }
      return AppColors.primary.withValues(alpha: 0.06);
    }),
  );
}

class AppNavigationStyles {
  static NavigationBarThemeData theme({
    required Color background,
    required Color indicator,
    required Color textPrimary,
  }) {
    return NavigationBarThemeData(
      backgroundColor: background,
      indicatorColor: indicator,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      height: 76,
      surfaceTintColor: Colors.transparent,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? textPrimary : textPrimary.withValues(alpha: 0.72),
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: textPrimary,
          height: 1.4,
          fontFamilyFallback: const ['Noto Sans Arabic', 'Arial', 'sans-serif'],
        );
      }),
    );
  }
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
    required this.success,
    required this.warning,
    required this.error,
    required this.divider,
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
  final Color success;
  final Color warning;
  final Color error;
  final Color divider;
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
    surface: AppColors.surface,
    background: AppColors.background,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    divider: AppColors.divider,
    border: AppColors.divider,
    cardShadow: [
      BoxShadow(
        color: Color(0x150B3D2E),
        blurRadius: 12,
        offset: Offset(0, 5),
      ),
    ],
    cardRadius: AppRadius.largeAll,
    buttonRadius: AppRadius.mediumAll,
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
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    divider: Color(0xFFE4D4A8),
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
    Color? success,
    Color? warning,
    Color? error,
    Color? divider,
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
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      divider: divider ?? this.divider,
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
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      border: Color.lerp(border, other.border, t) ?? border,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      cardRadius:
          BorderRadius.lerp(cardRadius, other.cardRadius, t) ?? cardRadius,
      buttonRadius: BorderRadius.lerp(buttonRadius, other.buttonRadius, t) ??
          buttonRadius,
      goldGradient: t < 0.5 ? goldGradient : other.goldGradient,
      ornamentPattern: t < 0.5 ? ornamentPattern : other.ornamentPattern,
      ornamentFrame: t < 0.5 ? ornamentFrame : other.ornamentFrame,
    );
  }
}

class AppTheme {
  static ThemeData _buildTheme({
    required Brightness brightness,
    required AppThemeTokens tokens,
    required Color scaffoldBackground,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color navBackground,
    required Color navIndicator,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color divider,
  }) {
    final textTheme = TextTheme(
      displayLarge: AppTextStyles.display.copyWith(color: textPrimary),
      headlineSmall: AppTextStyles.headline.copyWith(color: textPrimary),
      titleLarge: AppTextStyles.title.copyWith(color: textPrimary),
      titleMedium: AppTextStyles.title.copyWith(color: textPrimary),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: textSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamilyFallback: const ['Noto Sans Arabic', 'Arial', 'sans-serif'],
      scaffoldBackgroundColor: scaffoldBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tokens.primary,
        brightness: brightness,
        primary: tokens.primary,
        secondary: tokens.secondary,
        surface: surface,
      ),
      visualDensity: VisualDensity.standard,
      extensions: [tokens],
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppAccessibility.minTouchTarget, AppAccessibility.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTextStyles.button,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.title.copyWith(color: appBarForeground),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: tokens.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.cardRadius,
          side: BorderSide(color: divider),
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(borderRadius: tokens.buttonRadius),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(48, 48),
        ),
      ),
      checkboxTheme: AppCheckboxStyles.theme,
      switchTheme: AppSwitchStyles.theme,
      navigationBarTheme: AppNavigationStyles.theme(
        background: navBackground,
        indicator: navIndicator,
        textPrimary: textPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.secondary,
        linearTrackColor: divider,
      ),
      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: textPrimary),
    );
  }

  static ThemeData get theme {
    return _buildTheme(
      brightness: Brightness.light,
      tokens: AppThemeTokens.classic,
      scaffoldBackground: AppColors.background,
      appBarBackground: AppColors.primary,
      appBarForeground: AppColors.white,
      navBackground: AppColors.white,
      navIndicator: AppColors.warmSand,
      surface: AppColors.surface,
      textPrimary: AppColors.textPrimary,
      textSecondary: AppColors.textSecondary,
      divider: AppColors.divider,
    );
  }

  static ThemeData get darkTheme {
    const darkBackground = Color(0xFF111B17);
    const darkSurface = Color(0xFF1A2A24);
    const darkText = Color(0xFFF2F6F1);
    const darkSecondaryText = Color(0xFFBACCC1);
    const darkDivider = Color(0xFF2B3C36);

    return _buildTheme(
      brightness: Brightness.dark,
      tokens: AppThemeTokens.classic.copyWith(
        background: darkBackground,
        surface: darkSurface,
        textPrimary: darkText,
        textSecondary: darkSecondaryText,
        divider: darkDivider,
      ),
      scaffoldBackground: darkBackground,
      appBarBackground: AppColors.deepGreen,
      appBarForeground: AppColors.ivory,
      navBackground: darkSurface,
      navIndicator: const Color(0xFF1D3F34),
      surface: darkSurface,
      textPrimary: darkText,
      textSecondary: darkSecondaryText,
      divider: darkDivider,
    );
  }

  static ThemeData get ornateTheme {
    return _buildTheme(
      brightness: Brightness.light,
      tokens: AppThemeTokens.ornate,
      scaffoldBackground: AppColors.ornateCream,
      appBarBackground: AppColors.ornateGreen,
      appBarForeground: AppColors.ornateCream,
      navBackground: AppColors.white,
      navIndicator: const Color(0xFFF0E2B8),
      surface: AppColors.white,
      textPrimary: AppColors.ornateDark,
      textSecondary: const Color(0xFF745F42),
      divider: const Color(0xFFE4D4A8),
    );
  }

  static ThemeData get ornateDarkTheme {
    const darkBackground = Color(0xFF141C1A);
    const darkSurface = Color(0xFF1B2D27);
    const darkText = Color(0xFFF5F0E6);
    const darkSecondaryText = Color(0xFFCFD9D2);

    return _buildTheme(
      brightness: Brightness.dark,
      tokens: AppThemeTokens.ornate.copyWith(
        background: darkBackground,
        surface: darkSurface,
        textPrimary: darkText,
        textSecondary: darkSecondaryText,
        divider: const Color(0xFF2D3A35),
      ),
      scaffoldBackground: darkBackground,
      appBarBackground: AppColors.ornateGreen,
      appBarForeground: AppColors.ornateCream,
      navBackground: darkSurface,
      navIndicator: AppColors.ornateGreen,
      surface: darkSurface,
      textPrimary: darkText,
      textSecondary: darkSecondaryText,
      divider: const Color(0xFF2D3A35),
    );
  }
}

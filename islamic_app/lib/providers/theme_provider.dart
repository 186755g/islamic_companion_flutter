import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _themeType = StorageService.getThemeType();
  }

  AppThemeType _themeType = AppThemeType.classicMinimal;

  AppThemeType get activeTheme => _themeType;

  bool get isClassicMinimal => _themeType == AppThemeType.classicMinimal;

  ThemeData get lightTheme => _themeType == AppThemeType.classicMinimal
      ? AppTheme.theme
      : AppTheme.ornateTheme;

  ThemeData get darkTheme => _themeType == AppThemeType.classicMinimal
      ? AppTheme.darkTheme
      : AppTheme.ornateDarkTheme;

  Future<void> setTheme(AppThemeType themeType) async {
    if (_themeType == themeType) return;
    _themeType = themeType;
    await StorageService.setThemeType(themeType);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final nextTheme = isClassicMinimal
        ? AppThemeType.ornateIslamic
        : AppThemeType.classicMinimal;
    await setTheme(nextTheme);
  }
}

class ThemeManager extends ThemeProvider {}

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/azkar_provider.dart';
import 'providers/points_provider.dart';
import 'providers/prayer_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/hadith_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/stories_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/hadith_widget_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');
  await StorageService.init();
  try {
    await HadithWidgetService.update();
  } catch (error, stackTrace) {
    debugPrint('Hadith widget update failed: $error\n$stackTrace');
  }
  try {
    // Initialization can wait for Android permission dialogs. A short timeout
    // would let the app start with an uninitialized scheduler, so prayer
    // notifications would never be created for that session.
    await NotificationService.init();
  } catch (error, stackTrace) {
    debugPrint('Notification initialization failed: $error\n$stackTrace');
  }
  runApp(const IslamicCompanionApp());
}

class IslamicCompanionApp extends StatelessWidget {
  const IslamicCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AzkarProvider()),
        ChangeNotifierProvider(create: (_) => PointsProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
        ChangeNotifierProvider(create: (_) => HadithProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => StoriesProvider()),
        // يربط AzkarProvider بـ StreakProvider بعد إنشاء الاثنين، بحيث
        // يُسجَّل النشاط اليومي تلقائياً عند إتمام أي ذكر.
        ProxyProvider2<StreakProvider, AzkarProvider, void>(
          update: (ctx, streak, azkar, _) => azkar.streakProvider = streak,
        ),
        ChangeNotifierProxyProvider<PointsProvider, PrayerProvider>(
          create: (ctx) =>
              PrayerProvider(pointsProvider: ctx.read<PointsProvider>()),
          update: (ctx, points, previous) =>
              previous ?? PrayerProvider(pointsProvider: points),
        ),
      ],
      child: ValueListenableBuilder<double>(
        valueListenable: StorageService.fontScaleNotifier,
        builder: (context, fontScale, _) => ValueListenableBuilder<bool>(
          valueListenable: StorageService.darkModeNotifier,
          builder: (context, darkMode, _) => MaterialApp(
            title: 'رفيق المسلم',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
            locale: const Locale('ar'),
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              return MediaQuery(
                data: mediaQuery.copyWith(
                  textScaler: TextScaler.linear(fontScale),
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: child!,
                ),
              );
            },
            home: const HomeScreen(),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/prayer_model.dart';
import '../models/streak_model.dart';
import '../models/quran_progress_model.dart';
import '../theme/app_theme.dart';

/// خدمة التخزين المحلي باستخدام Hive (لا تحتاج اتصال إنترنت).
class StorageService {
  static const String azkarBox = 'azkar_progress_box';
  static const String prayerLogBox = 'prayer_log_box';
  static const String pointsBox = 'points_box';
  static const String settingsBox = 'settings_box';
  static const String streakBox = 'streak_box';
  static const String quranBox = 'quran_box';
  static const String khatmahBox = 'khatmah_box';
  static final ValueNotifier<double> fontScaleNotifier =
      ValueNotifier<double>(1.0);
  static final ValueNotifier<bool> darkModeNotifier =
      ValueNotifier<bool>(false);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(azkarBox);
    await Hive.openBox(prayerLogBox);
    await Hive.openBox(pointsBox);
    await Hive.openBox(settingsBox);
    await Hive.openBox(streakBox);
    await Hive.openBox(quranBox);
    await Hive.openBox(khatmahBox);
    fontScaleNotifier.value = getFontScale();
    darkModeNotifier.value = getDarkMode();
  }

  // ---------- Azkar progress ----------
  static Box get _azkar => Hive.box(azkarBox);

  static int getZikrCount(String id) => (_azkar.get(id) as int?) ?? 0;

  static Future<void> setZikrCount(String id, int count) =>
      _azkar.put(id, count);

  static Future<void> resetAzkarProgress(List<String> ids) async {
    for (final id in ids) {
      await _azkar.put(id, 0);
    }
  }

  // ---------- Prayer log ----------
  static Box get _prayerLog => Hive.box(prayerLogBox);

  static DailyPrayerLog getLogForDate(String dateKey) {
    final raw = _prayerLog.get(dateKey);
    if (raw == null) return DailyPrayerLog(dateKey: dateKey);
    return DailyPrayerLog.fromJson(Map<String, dynamic>.from(raw));
  }

  static Future<void> saveLog(DailyPrayerLog log) =>
      _prayerLog.put(log.dateKey, log.toJson());

  // ---------- Points ----------
  static Box get _points => Hive.box(pointsBox);

  static int getWeeklyPoints(String weekKey) =>
      (_points.get(weekKey) as int?) ?? 0;

  static Future<void> addWeeklyPoints(String weekKey, int delta) async {
    final current = getWeeklyPoints(weekKey);
    await _points.put(weekKey, current + delta);
  }

  static Future<void> setWeeklyPoints(String weekKey, int value) =>
      _points.put(weekKey, value);

  // ---------- Settings ----------
  static Box get _settings => Hive.box(settingsBox);

  static double? getLatitude() => _settings.get('lat') as double?;
  static double? getLongitude() => _settings.get('lng') as double?;

  static Future<void> saveLocation(double lat, double lng) async {
    await _settings.put('lat', lat);
    await _settings.put('lng', lng);
  }

  static String? getCountry() => _settings.get('country') as String?;

  static String? getGovernorate() => _settings.get('governorate') as String?;

  static bool getAdhanEnabled() =>
      (_settings.get('adhan_enabled') as bool?) ?? true;

  static Future<void> setAdhanEnabled(bool enabled) =>
      _settings.put('adhan_enabled', enabled);

  static double getAdhanVolume() =>
      (_settings.get('adhan_volume') as num?)?.toDouble() ?? 1.0;

  static Future<void> setAdhanVolume(double volume) =>
      _settings.put('adhan_volume', volume.clamp(0.0, 1.0));

  static double getFontScale() =>
      (_settings.get('font_scale') as num?)?.toDouble() ?? 1.0;

  static Future<void> setFontScale(double scale) async {
    final safeScale = scale.clamp(0.85, 1.35).toDouble();
    await _settings.put('font_scale', safeScale);
    fontScaleNotifier.value = safeScale;
  }

  static bool getDarkMode() => (_settings.get('dark_mode') as bool?) ?? false;

  static Future<void> setDarkMode(bool enabled) async {
    await _settings.put('dark_mode', enabled);
    darkModeNotifier.value = enabled;
  }

  static AppThemeType getThemeType() {
    final storedValue = _settings.get('theme_type') as String?;
    return AppThemeTypeX.fromStorage(storedValue);
  }

  static Future<void> setThemeType(AppThemeType themeType) async {
    await _settings.put('theme_type', themeType.storageName);
  }

  static String getPrayerCardAnimation() =>
      (_settings.get('prayer_card_animation') as String?) ?? 'slide';

  static Future<void> setPrayerCardAnimation(String animation) =>
      _settings.put('prayer_card_animation', animation);

  static String? getFajrAdhanPath() =>
      _settings.get('fajr_adhan_path') as String?;

  static List<String> getFajrAdhanPaths() {
    final stored = _settings.get('fajr_adhan_paths');
    if (stored is List) return stored.whereType<String>().toList();
    final legacy = getFajrAdhanPath();
    return legacy == null ? [] : [legacy];
  }

  static String? getSelectedFajrAdhanPath() {
    final selected = _settings.get('selected_fajr_adhan_path') as String?;
    return selected ?? getFajrAdhanPath();
  }

  static Future<void> setFajrAdhanPaths(List<String> paths) =>
      _settings.put('fajr_adhan_paths', paths);

  static Future<void> setSelectedFajrAdhanPath(String? path) async {
    if (path == null) {
      await _settings.delete('selected_fajr_adhan_path');
    } else {
      await _settings.put('selected_fajr_adhan_path', path);
    }
  }

  static Future<void> setFajrAdhanPath(String? path) async {
    if (path == null) {
      await _settings.delete('fajr_adhan_path');
    } else {
      await _settings.put('fajr_adhan_path', path);
    }
  }

  static String? getRegularAdhanPath() =>
      _settings.get('regular_adhan_path') as String?;

  static List<String> getRegularAdhanPaths() {
    final stored = _settings.get('regular_adhan_paths');
    if (stored is List) return stored.whereType<String>().toList();
    final legacy = getRegularAdhanPath();
    return legacy == null ? [] : [legacy];
  }

  static String? getSelectedRegularAdhanPath() {
    final selected = _settings.get('selected_regular_adhan_path') as String?;
    return selected ?? getRegularAdhanPath();
  }

  static Future<void> setRegularAdhanPaths(List<String> paths) =>
      _settings.put('regular_adhan_paths', paths);

  static Future<void> setSelectedRegularAdhanPath(String? path) async {
    if (path == null) {
      await _settings.delete('selected_regular_adhan_path');
    } else {
      await _settings.put('selected_regular_adhan_path', path);
    }
  }

  static Future<void> setRegularAdhanPath(String? path) async {
    if (path == null) {
      await _settings.delete('regular_adhan_path');
    } else {
      await _settings.put('regular_adhan_path', path);
    }
  }

  static String? getNotificationSoundPath() =>
      _settings.get('notification_sound_path') as String?;

  static Future<void> setNotificationSoundPath(String? path) async {
    if (path == null) {
      await _settings.delete('notification_sound_path');
    } else {
      await _settings.put('notification_sound_path', path);
    }
  }

  static Future<void> saveSelectedPlace({
    required String country,
    required String governorate,
    required double latitude,
    required double longitude,
  }) async {
    await _settings.put('country', country);
    await _settings.put('governorate', governorate);
    await saveLocation(latitude, longitude);
  }

  static Future<void> clearSelectedPlace() async {
    await _settings.delete('country');
    await _settings.delete('governorate');
  }

  // ---------- Streak ----------
  static Box get _streak => Hive.box(streakBox);

  static StreakModel getStreak() {
    final raw = _streak.get('streak');
    if (raw == null) return StreakModel();
    return StreakModel.fromJson(Map<dynamic, dynamic>.from(raw));
  }

  static Future<void> saveStreak(StreakModel model) =>
      _streak.put('streak', model.toJson());

  // ---------- Quran bookmark ----------
  static Box get _quran => Hive.box(quranBox);

  static QuranBookmark? getBookmark() {
    final raw = _quran.get('last_bookmark');
    if (raw == null) return null;
    return QuranBookmark.fromJson(Map<dynamic, dynamic>.from(raw));
  }

  static Future<void> saveBookmark(QuranBookmark bookmark) =>
      _quran.put('last_bookmark', bookmark.toJson());

  // ---------- Khatmah plans ----------
  static Box get _khatmah => Hive.box(khatmahBox);

  static List<KhatmahPlan> getAllKhatmahPlans() {
    return _khatmah.values
        .map((raw) => KhatmahPlan.fromJson(Map<dynamic, dynamic>.from(raw)))
        .toList();
  }

  static Future<void> saveKhatmahPlan(KhatmahPlan plan) =>
      _khatmah.put(plan.id, plan.toJson());

  static Future<void> deleteKhatmahPlan(String id) => _khatmah.delete(id);
}

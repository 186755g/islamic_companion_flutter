import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/streak_model.dart';
import '../services/storage_service.dart';
import '../services/hadith_widget_service.dart';

class StreakProvider extends ChangeNotifier {
  late StreakModel _streak;
  bool _celebratedToday = false;

  StreakProvider() {
    _streak = StorageService.getStreak();
    _checkForBrokenStreak();
  }

  StreakModel get streak => _streak;
  bool get isActiveToday => _streak.lastActiveDate == _todayKey;
  bool get justCelebrated => _celebratedToday;

  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());
  String get _yesterdayKey =>
      DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

  void _checkForBrokenStreak() {
    if (_streak.lastActiveDate.isEmpty) return;
    if (_streak.lastActiveDate == _todayKey || _streak.lastActiveDate == _yesterdayKey) {
      return;
    }
    _streak.currentStreak = 0;
    StorageService.saveStreak(_streak);
  }

  Future<void> registerActivity() async {
    if (isActiveToday) return;

    if (_streak.lastActiveDate == _yesterdayKey) {
      _streak.currentStreak += 1;
    } else {
      _streak.currentStreak = 1;
    }
    _streak.lastActiveDate = _todayKey;
    _streak.totalActiveDays += 1;
    if (_streak.currentStreak > _streak.longestStreak) {
      _streak.longestStreak = _streak.currentStreak;
    }
    await StorageService.saveStreak(_streak);
    await HadithWidgetService.update();
    _celebratedToday = true;
    notifyListeners();
  }

  void acknowledgeCelebration() {
    _celebratedToday = false;
    notifyListeners();
  }
}

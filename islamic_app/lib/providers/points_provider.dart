import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/prayer_model.dart';
import '../services/storage_service.dart';

class PointsProvider extends ChangeNotifier {
  int _weeklyPoints = 0;
  int get weeklyPoints => _weeklyPoints;
  int get weeklyTarget => PointsConfig.weeklyMinimumTarget;
  double get progressRatio => (_weeklyPoints / weeklyTarget).clamp(0, 1).toDouble();
  bool get isBelowTarget => _weeklyPoints < weeklyTarget;

  PointsProvider() {
    _load();
  }

  String get _weekKey {
    final now = DateTime.now();
    final weekOfYear = _isoWeekNumber(now);
    return '${now.year}-W$weekOfYear';
  }

  int _isoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  void _load() {
    _weeklyPoints = StorageService.getWeeklyPoints(_weekKey);
  }

  Future<void> addPoints(int delta) async {
    _weeklyPoints = (_weeklyPoints + delta).clamp(0, 1 << 30);
    await StorageService.setWeeklyPoints(_weekKey, _weeklyPoints);
    notifyListeners();
  }
}

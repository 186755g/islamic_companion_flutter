import 'package:flutter/foundation.dart';
import '../data/azkar_data.dart';
import '../data/prayer_duas_data.dart';
import '../models/zikr_model.dart';
import '../services/storage_service.dart';
import 'streak_provider.dart';

class AzkarProvider extends ChangeNotifier {
  late List<Zikr> _morning;
  late List<Zikr> _evening;
  late List<Zikr> _prayer;

  /// يُضبط من main.dart بعد إنشاء StreakProvider لتسجيل النشاط اليومي
  /// تلقائياً عند إتمام أي ذكر.
  StreakProvider? streakProvider;

  AzkarProvider() {
    _morning = AzkarData.morningAzkar();
    _evening = AzkarData.eveningAzkar();
    _prayer = PrayerDuasData.all()
        .expand(
          (section) => section.duas.asMap().entries.map(
                (entry) => Zikr(
                  id: '${section.id}_${entry.key}',
                  arabicText: entry.value,
                  source: section.title,
                  targetCount: 1,
                ),
              ),
        )
        .toList();
    _loadProgress();
  }

  List<Zikr> get morning => _morning;
  List<Zikr> get evening => _evening;
  List<Zikr> get prayer => _prayer;

  List<Zikr> byCategory(AzkarCategory c) {
    switch (c) {
      case AzkarCategory.morning:
        return _morning;
      case AzkarCategory.evening:
        return _evening;
      case AzkarCategory.prayer:
        return _prayer;
    }
  }

  void _loadProgress() {
    for (final z in [..._morning, ..._evening]) {
      z.currentCount = StorageService.getZikrCount(z.id);
    }
  }

  Future<void> tapZikr(Zikr zikr) async {
    if (zikr.isCompleted) return;
    zikr.increment();
    await StorageService.setZikrCount(zikr.id, zikr.currentCount);
    if (zikr.isCompleted) {
      streakProvider?.registerActivity();
    }
    notifyListeners();
  }

  double progressFor(AzkarCategory c) {
    final list = byCategory(c);
    if (list.isEmpty) return 0;
    final completed = list.where((z) => z.isCompleted).length;
    return completed / list.length;
  }

  Future<void> resetCategory(AzkarCategory c) async {
    final list = byCategory(c);
    for (final z in list) {
      z.reset();
    }
    await StorageService.resetAzkarProgress(list.map((z) => z.id).toList());
    notifyListeners();
  }
}

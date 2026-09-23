import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../data/hadith_data.dart';
import 'storage_service.dart';

/// Synchronizes the hadith collection with the Android home-screen widget.
class HadithWidgetService {
  static const widgetName = 'HadithWidgetProvider';

  static Future<void> update() async {
    if (!Platform.isAndroid) return;

    final hadiths = HadithData.all();
    await HomeWidget.saveWidgetData<int>('hadith_count', hadiths.length);
    for (var index = 0; index < hadiths.length; index++) {
      final hadith = hadiths[index];
      await HomeWidget.saveWidgetData<String>(
          'hadith_${index}_text', hadith.text);
      await HomeWidget.saveWidgetData<String>(
          'hadith_${index}_source', hadith.source);
      await HomeWidget.saveWidgetData<String>(
          'hadith_${index}_narrator', hadith.narrator);
    }
    final streak = StorageService.getStreak();
    await HomeWidget.saveWidgetData<int>(
        'streak_current', streak.currentStreak);
    await HomeWidget.saveWidgetData<int>(
        'streak_longest', streak.longestStreak);
    await HomeWidget.saveWidgetData<int>(
        'streak_total_days', streak.totalActiveDays);
    await HomeWidget.saveWidgetData<bool>(
        'streak_active_today',
        streak.lastActiveDate ==
            DateTime.now().toIso8601String().substring(0, 10));
    try {
      await HomeWidget.updateWidget(name: widgetName);
    } catch (error, stackTrace) {
      // A widget may not be pinned yet or the launcher may be unavailable.
      // Keep app features working while making the update failure diagnosable.
      debugPrint('Hadith widget update request failed: $error\n$stackTrace');
    }
  }
}

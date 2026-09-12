import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/quran_progress_model.dart';
import '../services/storage_service.dart';

class QuranProvider extends ChangeNotifier {
  QuranBookmark? _bookmark;
  List<KhatmahPlan> _plans = [];

  QuranProvider() {
    _bookmark = StorageService.getBookmark();
    _plans = StorageService.getAllKhatmahPlans();
  }

  QuranBookmark? get bookmark => _bookmark;
  List<KhatmahPlan> get plans => _plans;
  KhatmahPlan? get activePlan {
    final list = _plans.where((p) => p.isActive && !p.isCompleted).toList();
    return list.isEmpty ? null : list.first;
  }

  Future<void> saveLastRead({
    required int page,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    _bookmark = QuranBookmark(
      page: page,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      savedAt: DateTime.now(),
    );
    await StorageService.saveBookmark(_bookmark!);
    notifyListeners();
  }

  Future<KhatmahPlan> createPlan({required String title, required int days}) async {
    final plan = KhatmahPlan(
      id: const Uuid().v4(),
      title: title,
      totalDays: days,
      startDate: DateTime.now(),
    );
    _plans.add(plan);
    await StorageService.saveKhatmahPlan(plan);
    notifyListeners();
    return plan;
  }

  Future<bool> updatePlanProgress(String planId, int completedPage) async {
    final plan = _plans.firstWhere((p) => p.id == planId);
    final wasCompleted = plan.isCompleted;
    plan.lastCompletedPage = completedPage.clamp(0, KhatmahPlan.totalMushafPages);
    await StorageService.saveKhatmahPlan(plan);
    notifyListeners();
    return !wasCompleted && plan.isCompleted;
  }

  Future<void> deletePlan(String id) async {
    _plans.removeWhere((p) => p.id == id);
    await StorageService.deleteKhatmahPlan(id);
    notifyListeners();
  }
}

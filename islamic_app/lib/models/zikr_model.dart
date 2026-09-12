/// نموذج الذِّكر الواحد
class Zikr {
  final String id;
  final String arabicText;
  final String? transliteration;
  final String source;
  final int targetCount;
  int currentCount;

  Zikr({
    required this.id,
    required this.arabicText,
    this.transliteration,
    required this.source,
    required this.targetCount,
    this.currentCount = 0,
  });

  bool get isCompleted => currentCount >= targetCount;

  void increment() {
    if (currentCount < targetCount) currentCount++;
  }

  void reset() => currentCount = 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'currentCount': currentCount,
      };
}

enum AzkarCategory { morning, evening }

/// معلومات أساسية عن سورة (للفهرسة والانتقال السريع)
class SurahInfo {
  final int number;
  final String arabicName;
  final int totalAyahs;
  final int startPage;

  const SurahInfo({
    required this.number,
    required this.arabicName,
    required this.totalAyahs,
    required this.startPage,
  });
}

/// آخر موضع قراءة محفوظ.
class QuranBookmark {
  final int page;
  final int surahNumber;
  final int ayahNumber;
  final DateTime savedAt;

  QuranBookmark(
      {required this.page,
      required this.surahNumber,
      required this.ayahNumber,
      required this.savedAt});

  Map<String, dynamic> toJson() => {
        'page': page,
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'savedAt': savedAt.toIso8601String(),
      };

  factory QuranBookmark.fromJson(Map<dynamic, dynamic> json) => QuranBookmark(
        page: json['page'],
        surahNumber: json['surahNumber'],
        ayahNumber: json['ayahNumber'],
        savedAt: DateTime.parse(json['savedAt']),
      );
}

/// خطة ختمة مخصصة أو محددة مسبقاً.
class KhatmahPlan {
  final String id;
  final String title;
  final int totalDays;
  final DateTime startDate;
  int lastCompletedPage;
  bool isActive;
  final int totalPages;

  static const int defaultTotalPages = 604;

  KhatmahPlan({
    required this.id,
    required this.title,
    required this.totalDays,
    required this.startDate,
    this.lastCompletedPage = 0,
    this.isActive = true,
    this.totalPages = defaultTotalPages,
  });

  double get pagesPerDay => totalPages / totalDays;
  double get progressRatio =>
      (lastCompletedPage / totalPages).clamp(0, 1).toDouble();
  int get progressPercent => (progressRatio * 100).round();
  DateTime get expectedEndDate => startDate.add(Duration(days: totalDays));
  bool get isCompleted => lastCompletedPage >= totalPages;

  int get pagesBehindSchedule {
    final daysElapsed = DateTime.now().difference(startDate).inDays + 1;
    final expectedPage = (daysElapsed * pagesPerDay).round();
    final behind = expectedPage - lastCompletedPage;
    return behind > 0 ? behind : 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalDays': totalDays,
        'startDate': startDate.toIso8601String(),
        'lastCompletedPage': lastCompletedPage,
        'isActive': isActive,
        'totalPages': totalPages,
      };

  factory KhatmahPlan.fromJson(Map<dynamic, dynamic> json) => KhatmahPlan(
        id: json['id'],
        title: json['title'],
        totalDays: json['totalDays'],
        startDate: DateTime.parse(json['startDate']),
        lastCompletedPage: json['lastCompletedPage'] ?? 0,
        isActive: json['isActive'] ?? true,
        totalPages: json['totalPages'] ?? defaultTotalPages,
      );

  static List<int> predefinedDurations() => [30, 60, 90];
}

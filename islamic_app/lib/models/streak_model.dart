/// نموذج نظام الالتزام اليومي (Streak)
class StreakModel {
  int currentStreak;
  int longestStreak;
  String lastActiveDate;
  int totalActiveDays;

  StreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate = '',
    this.totalActiveDays = 0,
  });

  int get lampLevel {
    if (currentStreak <= 0) return 0;
    if (currentStreak < 3) return 1;
    if (currentStreak < 7) return 2;
    return 3;
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDate': lastActiveDate,
        'totalActiveDays': totalActiveDays,
      };

  factory StreakModel.fromJson(Map<dynamic, dynamic> json) => StreakModel(
        currentStreak: json['currentStreak'] ?? 0,
        longestStreak: json['longestStreak'] ?? 0,
        lastActiveDate: json['lastActiveDate'] ?? '',
        totalActiveDays: json['totalActiveDays'] ?? 0,
      );
}

enum StreakActivity { azkar, quran, prayerTracked, hadithRead }

enum FardPrayer { fajr, dhuhr, asr, maghrib, isha }

enum SunnahPrayer {
  fajrBefore,
  dhuhrBefore,
  dhuhrAfter,
  maghribAfter,
  ishaAfter,
}

extension FardPrayerX on FardPrayer {
  String get arabicName {
    switch (this) {
      case FardPrayer.fajr:
        return 'الفجر';
      case FardPrayer.dhuhr:
        return 'الظهر';
      case FardPrayer.asr:
        return 'العصر';
      case FardPrayer.maghrib:
        return 'المغرب';
      case FardPrayer.isha:
        return 'العشاء';
    }
  }
}

extension SunnahPrayerX on SunnahPrayer {
  String get arabicName {
    switch (this) {
      case SunnahPrayer.fajrBefore:
        return 'سنة الفجر (ركعتان قبلية)';
      case SunnahPrayer.dhuhrBefore:
        return 'سنة الظهر القبلية (4 ركعات)';
      case SunnahPrayer.dhuhrAfter:
        return 'سنة الظهر البعدية (ركعتان)';
      case SunnahPrayer.maghribAfter:
        return 'سنة المغرب البعدية (ركعتان)';
      case SunnahPrayer.ishaAfter:
        return 'سنة العشاء البعدية (ركعتان)';
    }
  }

  FardPrayer get relatedFard {
    switch (this) {
      case SunnahPrayer.fajrBefore:
        return FardPrayer.fajr;
      case SunnahPrayer.dhuhrBefore:
      case SunnahPrayer.dhuhrAfter:
        return FardPrayer.dhuhr;
      case SunnahPrayer.maghribAfter:
        return FardPrayer.maghrib;
      case SunnahPrayer.ishaAfter:
        return FardPrayer.isha;
    }
  }
}

class DailyPrayerLog {
  final String dateKey;
  final Map<String, bool> fardStatus;
  final Map<String, bool> sunnahStatus;

  DailyPrayerLog({
    required this.dateKey,
    Map<String, bool>? fardStatus,
    Map<String, bool>? sunnahStatus,
  })  : fardStatus = fardStatus ??
            {for (final f in FardPrayer.values) f.name: false},
        sunnahStatus = sunnahStatus ??
            {for (final s in SunnahPrayer.values) s.name: false};

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'fardStatus': fardStatus,
        'sunnahStatus': sunnahStatus,
      };

  factory DailyPrayerLog.fromJson(Map<String, dynamic> json) => DailyPrayerLog(
        dateKey: json['dateKey'],
        fardStatus: Map<String, bool>.from(json['fardStatus']),
        sunnahStatus: Map<String, bool>.from(json['sunnahStatus']),
      );
}

class PointsConfig {
  static const int fardPoints = 10;
  static const int sunnahPoints = 5;
  static const int weeklyMinimumTarget = 245;
}

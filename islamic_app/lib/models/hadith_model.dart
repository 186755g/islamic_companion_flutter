enum HadithCategory {
  goodManners,
  familyTies,
  neighborRights,
  honesty,
  kindness,
  brotherhood,
  businessEthics,
}

extension HadithCategoryX on HadithCategory {
  String get arabicName {
    switch (this) {
      case HadithCategory.goodManners:
        return 'حسن الخلق';
      case HadithCategory.familyTies:
        return 'صلة الرحم وبر الوالدين';
      case HadithCategory.neighborRights:
        return 'حقوق الجار';
      case HadithCategory.honesty:
        return 'الصدق والأمانة';
      case HadithCategory.kindness:
        return 'الرفق والرحمة';
      case HadithCategory.brotherhood:
        return 'الأخوة والمجتمع';
      case HadithCategory.businessEthics:
        return 'آداب البيع والمعاملات';
    }
  }
}

class HadithModel {
  final String id;
  final String text;
  final String narrator;
  final String source;
  final HadithCategory category;
  final String? briefExplanation;

  const HadithModel({
    required this.id,
    required this.text,
    required this.narrator,
    required this.source,
    required this.category,
    this.briefExplanation,
  });
}

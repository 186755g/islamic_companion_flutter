enum StoryCategory { prophet, companionMale, companionFemale }

class StoryModel {
  final String id;
  final String title;
  final StoryCategory category;
  final String summary;
  final List<String> paragraphs;
  final List<String> sources;
  final String? lessonLearned;

  const StoryModel({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.paragraphs,
    required this.sources,
    this.lessonLearned,
  });
}

extension StoryCategoryX on StoryCategory {
  String get arabicName {
    switch (this) {
      case StoryCategory.prophet:
        return 'قصص الأنبياء';
      case StoryCategory.companionMale:
        return 'الصحابة رضي الله عنهم';
      case StoryCategory.companionFemale:
        return 'الصحابيات رضي الله عنهن';
    }
  }
}

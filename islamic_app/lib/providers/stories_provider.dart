import 'package:flutter/foundation.dart';
import '../data/stories_data.dart';
import '../models/story_model.dart';

class StoriesProvider extends ChangeNotifier {
  StoryCategory? _activeCategory;
  StoryCategory? get activeCategory => _activeCategory;

  List<StoryModel> get filtered =>
      _activeCategory == null ? StoriesData.all() : StoriesData.byCategory(_activeCategory!);

  void setCategory(StoryCategory? c) {
    _activeCategory = c;
    notifyListeners();
  }
}

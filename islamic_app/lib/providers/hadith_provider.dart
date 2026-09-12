import 'package:flutter/foundation.dart';
import '../data/hadith_data.dart';
import '../models/hadith_model.dart';

class HadithProvider extends ChangeNotifier {
  String _query = '';
  HadithCategory? _activeCategory;

  String get query => _query;
  HadithCategory? get activeCategory => _activeCategory;

  HadithModel get hadithOfTheDay => HadithData.hadithOfTheDay();

  List<HadithModel> get filtered {
    var list = _activeCategory == null ? HadithData.all() : HadithData.byCategory(_activeCategory!);
    if (_query.trim().isNotEmpty) {
      list = list
          .where((h) =>
              h.text.contains(_query) ||
              h.narrator.contains(_query) ||
              (h.briefExplanation?.contains(_query) ?? false))
          .toList();
    }
    return list;
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setCategory(HadithCategory? c) {
    _activeCategory = c;
    notifyListeners();
  }
}

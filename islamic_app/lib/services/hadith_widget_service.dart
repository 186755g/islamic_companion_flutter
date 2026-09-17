import 'package:home_widget/home_widget.dart';
import '../data/hadith_data.dart';

/// Synchronizes the hadith collection with the Android home-screen widget.
class HadithWidgetService {
  static const widgetName = 'HadithWidgetProvider';

  static Future<void> update() async {
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
    await HomeWidget.updateWidget(name: widgetName);
  }
}

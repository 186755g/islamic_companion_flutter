import '../models/hadith_model.dart';

/// ⚠️ قائمة تمثيلية ابتدائية — راجعها وأكملها من مرجع موثوق (رياض الصالحين،
/// بلوغ المرام) بإشراف أهل علم قبل الاعتماد عليها في نسخة إنتاجية.
class HadithData {
  static List<HadithModel> all() => [
        const HadithModel(
          id: 'h1',
          text: 'إِنَّ مِنْ أَحَبِّكُمْ إِلَيَّ وَأَقْرَبِكُمْ مِنِّي مَجْلِسًا يَوْمَ الْقِيَامَةِ أَحَاسِنُكُمْ أَخْلَاقًا',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'رواه الترمذي',
          category: HadithCategory.goodManners,
          briefExplanation: 'حسن الخلق من أعظم أسباب القرب من النبي ﷺ يوم القيامة.',
        ),
        const HadithModel(
          id: 'h2',
          text: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلَا يُؤْذِ جَارَهُ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.neighborRights,
          briefExplanation: 'عدم إيذاء الجار من علامات كمال الإيمان.',
        ),
        const HadithModel(
          id: 'h3',
          text: 'لَيْسَ الْوَاصِلُ بِالْمُكَافِئِ، وَلَكِنَّ الْوَاصِلَ الَّذِي إِذَا قُطِعَتْ رَحِمُهُ وَصَلَهَا',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'رواه البخاري',
          category: HadithCategory.familyTies,
          briefExplanation: 'صلة الرحم الحقيقية تكون حتى مع من يقطعها.',
        ),
        const HadithModel(
          id: 'h4',
          text: 'التَّاجِرُ الصَّدُوقُ الْأَمِينُ مَعَ النَّبِيِّينَ وَالصِّدِّيقِينَ وَالشُّهَدَاءِ',
          narrator: 'أبو سعيد الخدري رضي الله عنه',
          source: 'رواه الترمذي',
          category: HadithCategory.businessEthics,
          briefExplanation: 'الصدق والأمانة في التجارة سبب لرفعة المنزلة يوم القيامة.',
        ),
        const HadithModel(
          id: 'h5',
          text: 'الرَّاحِمُونَ يَرْحَمُهُمُ الرَّحْمَنُ، ارْحَمُوا مَنْ فِي الْأَرْضِ يَرْحَمْكُمْ مَنْ فِي السَّمَاءِ',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'رواه أبو داود والترمذي',
          category: HadithCategory.kindness,
          briefExplanation: 'الرحمة بالخلق سبب لنيل رحمة الله تعالى.',
        ),
        const HadithModel(
          id: 'h6',
          text: 'الْمُسْلِمُ أَخُو الْمُسْلِمِ، لَا يَظْلِمُهُ وَلَا يُسْلِمُهُ',
          narrator: 'عبد الله بن عمر رضي الله عنهما',
          source: 'متفق عليه',
          category: HadithCategory.brotherhood,
          briefExplanation: 'الأخوة الإسلامية تقتضي النصرة وعدم الظلم.',
        ),
        const HadithModel(
          id: 'h7',
          text: 'إِيَّاكُمْ وَالْكَذِبَ، فَإِنَّ الْكَذِبَ يَهْدِي إِلَى الْفُجُورِ، وَإِنَّ الْفُجُورَ يَهْدِي إِلَى النَّارِ',
          narrator: 'عبد الله بن مسعود رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.honesty,
          briefExplanation: 'الصدق طريق إلى البر والجنة، والكذب طريق إلى الفجور والنار.',
        ),
      ];

  static List<HadithModel> byCategory(HadithCategory c) =>
      all().where((h) => h.category == c).toList();

  static List<HadithModel> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return all();
    return all()
        .where((h) =>
            h.text.contains(q) ||
            h.narrator.contains(q) ||
            (h.briefExplanation?.contains(q) ?? false))
        .toList();
  }

  static HadithModel hadithOfTheDay() {
    final list = all();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return list[dayOfYear % list.length];
  }
}

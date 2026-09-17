import '../models/hadith_model.dart';

/// أحاديث مختارة من الصحيحين وكتب السنن المشهورة، مع ذكر المصدر لكل حديث.
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
        const HadithModel(
          id: 'h8',
          text: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
          narrator: 'عمر بن الخطاب رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h9',
          text: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h10',
          text: 'لَا تَغْضَبْ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه البخاري',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h11',
          text: 'مَنْ لَا يَرْحَمْ لَا يُرْحَمْ',
          narrator: 'جرير بن عبد الله رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h12',
          text: 'مَنْ غَشَّنَا فَلَيْسَ مِنَّا',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.businessEthics,
        ),
        const HadithModel(
          id: 'h13',
          text: 'الطُّهُورُ شَطْرُ الإِيمَانِ',
          narrator: 'أبو مالك الأشعري رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h14',
          text: 'الصَّلَوَاتُ الخَمْسُ، وَالجُمْعَةُ إِلَى الجُمْعَةِ، وَرَمَضَانُ إِلَى رَمَضَانَ، مُكَفِّرَاتٌ مَا بَيْنَهُنَّ إِذَا اجْتُنِبَتِ الكَبَائِرُ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h15',
          text: 'أَقْرَبُ مَا يَكُونُ العَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ، فَأَكْثِرُوا الدُّعَاءَ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h16',
          text: 'خَيْرُكُمْ مَنْ تَعَلَّمَ القُرْآنَ وَعَلَّمَهُ',
          narrator: 'عثمان بن عفان رضي الله عنه',
          source: 'رواه البخاري',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h17',
          text: 'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ بِهِ طَرِيقًا إِلَى الجَنَّةِ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h18',
          text: 'الدِّينُ النَّصِيحَةُ',
          narrator: 'تميم الداري رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h19',
          text: 'المُسْلِمُ مَنْ سَلِمَ المُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'متفق عليه',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h20',
          text: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
          narrator: 'أنس بن مالك رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h21',
          text: 'مَنْ كَانَ فِي حَاجَةِ أَخِيهِ كَانَ اللَّهُ فِي حَاجَتِهِ',
          narrator: 'عبد الله بن عمر رضي الله عنهما',
          source: 'متفق عليه',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h22',
          text: 'وَاللَّهُ فِي عَوْنِ العَبْدِ مَا كَانَ العَبْدُ فِي عَوْنِ أَخِيهِ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h23',
          text: 'مَنْ لَا يَرْحَمُ النَّاسَ لَا يَرْحَمْهُ اللَّهُ',
          narrator: 'جرير بن عبد الله رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h24',
          text: 'لَيْسَ الشَّدِيدُ بِالصُّرَعَةِ، إِنَّمَا الشَّدِيدُ الَّذِي يَمْلِكُ نَفْسَهُ عِنْدَ الغَضَبِ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h25',
          text: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَاليَوْمِ الآخِرِ فَلْيُكْرِمْ ضَيْفَهُ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.goodManners,
        ),
        const HadithModel(
          id: 'h26',
          text: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَاليَوْمِ الآخِرِ فَلْيُكْرِمْ جَارَهُ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.neighborRights,
        ),
        const HadithModel(
          id: 'h27',
          text: 'مَا زَالَ جِبْرِيلُ يُوصِينِي بِالجَارِ حَتَّى ظَنَنْتُ أَنَّهُ سَيُوَرِّثُهُ',
          narrator: 'عائشة رضي الله عنها',
          source: 'متفق عليه',
          category: HadithCategory.neighborRights,
        ),
        const HadithModel(
          id: 'h28',
          text: 'خَيْرُ الأَصْحَابِ عِنْدَ اللَّهِ خَيْرُهُمْ لِصَاحِبِهِ، وَخَيْرُ الجِيرَانِ عِنْدَ اللَّهِ خَيْرُهُمْ لِجَارِهِ',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'رواه الترمذي',
          category: HadithCategory.neighborRights,
        ),
        const HadithModel(
          id: 'h29',
          text: 'مَنْ أَحَبَّ أَنْ يُبْسَطَ لَهُ فِي رِزْقِهِ، وَأَنْ يُنْسَأَ لَهُ فِي أَثَرِهِ، فَلْيَصِلْ رَحِمَهُ',
          narrator: 'أنس بن مالك رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.familyTies,
        ),
        const HadithModel(
          id: 'h30',
          text: 'لَيْسَ الوَاصِلُ بِالمُكَافِئِ، وَلَكِنَّ الوَاصِلَ الَّذِي إِذَا قُطِعَتْ رَحِمُهُ وَصَلَهَا',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'رواه البخاري',
          category: HadithCategory.familyTies,
        ),
        const HadithModel(
          id: 'h31',
          text: 'رِضَا الرَّبِّ فِي رِضَا الوَالِدِ، وَسَخَطُ الرَّبِّ فِي سَخَطِ الوَالِدِ',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'رواه الترمذي',
          category: HadithCategory.familyTies,
        ),
        const HadithModel(
          id: 'h32',
          text: 'رَغِمَ أَنْفُهُ، ثُمَّ رَغِمَ أَنْفُهُ، ثُمَّ رَغِمَ أَنْفُهُ. قِيلَ: مَنْ؟ قَالَ: مَنْ أَدْرَكَ وَالِدَيْهِ عِنْدَ الكِبَرِ أَحَدَهُمَا أَوْ كِلَيْهِمَا ثُمَّ لَمْ يَدْخُلِ الجَنَّةَ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.familyTies,
        ),
        const HadithModel(
          id: 'h33',
          text: 'عَلَيْكُمْ بِالصِّدْقِ، فَإِنَّ الصِّدْقَ يَهْدِي إِلَى البِرِّ، وَإِنَّ البِرَّ يَهْدِي إِلَى الجَنَّةِ',
          narrator: 'عبد الله بن مسعود رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.honesty,
        ),
        const HadithModel(
          id: 'h34',
          text: 'آيَةُ المُنَافِقِ ثَلَاثٌ: إِذَا حَدَّثَ كَذَبَ، وَإِذَا وَعَدَ أَخْلَفَ، وَإِذَا اؤْتُمِنَ خَانَ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.honesty,
        ),
        const HadithModel(
          id: 'h35',
          text: 'أَدِّ الأَمَانَةَ إِلَى مَنِ ائْتَمَنَكَ، وَلَا تَخُنْ مَنْ خَانَكَ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه أبو داود والترمذي',
          category: HadithCategory.honesty,
        ),
        const HadithModel(
          id: 'h36',
          text: 'مَنْ غَشَّ فَلَيْسَ مِنِّي',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.businessEthics,
        ),
        const HadithModel(
          id: 'h37',
          text: 'رَحِمَ اللَّهُ رَجُلًا سَمْحًا إِذَا بَاعَ، وَإِذَا اشْتَرَى، وَإِذَا اقْتَضَى',
          narrator: 'جابر بن عبد الله رضي الله عنهما',
          source: 'رواه البخاري',
          category: HadithCategory.businessEthics,
        ),
        const HadithModel(
          id: 'h38',
          text: 'مَنْ احْتَكَرَ فَهُوَ خَاطِئٌ',
          narrator: 'معمر بن عبد الله رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.businessEthics,
        ),
        const HadithModel(
          id: 'h39',
          text: 'البَيِّعَانِ بِالخِيَارِ مَا لَمْ يَتَفَرَّقَا، فَإِنْ صَدَقَا وَبَيَّنَا بُورِكَ لَهُمَا فِي بَيْعِهِمَا',
          narrator: 'حكيم بن حزام رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.businessEthics,
        ),
        const HadithModel(
          id: 'h40',
          text: 'إِنَّ اللَّهَ كَتَبَ الإِحْسَانَ عَلَى كُلِّ شَيْءٍ',
          narrator: 'شداد بن أوس رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h41',
          text: 'مَا مِنْ مُسْلِمٍ يَغْرِسُ غَرْسًا، أَوْ يَزْرَعُ زَرْعًا، فَيَأْكُلُ مِنْهُ طَيْرٌ أَوْ إِنْسَانٌ أَوْ بَهِيمَةٌ إِلَّا كَانَ لَهُ بِهِ صَدَقَةٌ',
          narrator: 'أنس بن مالك رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h42',
          text: 'مَنْ لَا يَرْحَمْ لَا يُرْحَمْ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h43',
          text: 'الكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h44',
          text: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ لَكَ صَدَقَةٌ',
          narrator: 'أبو ذر رضي الله عنه',
          source: 'رواه الترمذي',
          category: HadithCategory.kindness,
        ),
        const HadithModel(
          id: 'h45',
          text: 'مَنْ دَلَّ عَلَى خَيْرٍ فَلَهُ مِثْلُ أَجْرِ فَاعِلِهِ',
          narrator: 'أبو مسعود الأنصاري رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h46',
          text: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَاليَوْمِ الآخِرِ فَلْيَصِلْ رَحِمَهُ',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه البخاري',
          category: HadithCategory.familyTies,
        ),
        const HadithModel(
          id: 'h47',
          text: 'لَا تَحَاسَدُوا، وَلَا تَنَاجَشُوا، وَلَا تَبَاغَضُوا، وَكُونُوا عِبَادَ اللَّهِ إِخْوَانًا',
          narrator: 'أبو هريرة رضي الله عنه',
          source: 'رواه مسلم',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h48',
          text: 'المُؤْمِنُ لِلْمُؤْمِنِ كَالبُنْيَانِ يَشُدُّ بَعْضُهُ بَعْضًا',
          narrator: 'أبو موسى الأشعري رضي الله عنه',
          source: 'متفق عليه',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h49',
          text: 'مَثَلُ المُؤْمِنِينَ فِي تَوَادِّهِمْ وَتَرَاحُمِهِمْ وَتَعَاطُفِهِمْ مَثَلُ الجَسَدِ',
          narrator: 'النعمان بن بشير رضي الله عنهما',
          source: 'رواه مسلم',
          category: HadithCategory.brotherhood,
        ),
        const HadithModel(
          id: 'h50',
          text: 'مَنْ صَمَتَ نَجَا',
          narrator: 'عبد الله بن عمرو رضي الله عنهما',
          source: 'رواه الترمذي',
          category: HadithCategory.goodManners,
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

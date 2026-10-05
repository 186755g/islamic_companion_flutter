export const toArabicDigits = (value: number | string) =>
  String(value).replace(/\d/g, (d) => '٠١٢٣٤٥٦٧٨٩'[Number(d)])

export type PrayerTone = 'peach' | 'butter' | 'sky' | 'lilac' | 'mint'

export type Prayer = {
  id: string
  name: string
  time: string
  period: string
  tone: PrayerTone
}

export const PRAYERS: Prayer[] = [
  { id: 'fajr', name: 'الفجر', time: '04:12', period: 'ص', tone: 'lilac' },
  { id: 'dhuhr', name: 'الظهر', time: '12:51', period: 'م', tone: 'butter' },
  { id: 'asr', name: 'العصر', time: '04:28', period: 'م', tone: 'peach' },
  { id: 'maghrib', name: 'المغرب', time: '07:45', period: 'م', tone: 'sky' },
  { id: 'isha', name: 'العشاء', time: '09:12', period: 'م', tone: 'mint' },
]

export const TONE_CLASSES: Record<PrayerTone, string> = {
  peach: 'bg-peach text-peach-foreground',
  butter: 'bg-butter text-butter-foreground',
  sky: 'bg-sky text-sky-foreground',
  lilac: 'bg-lilac text-lilac-foreground',
  mint: 'bg-mint text-mint-foreground',
}

export type SunnahPrayer = { id: string; name: string; rakahs: number }

export const SUNNAH_PRAYERS: SunnahPrayer[] = [
  { id: 'fajr-sunnah', name: 'سنة الفجر', rakahs: 2 },
  { id: 'dhuhr-before', name: 'سنة الظهر القبلية', rakahs: 4 },
  { id: 'dhuhr-after', name: 'سنة الظهر البعدية', rakahs: 2 },
  { id: 'maghrib-sunnah', name: 'سنة المغرب', rakahs: 2 },
  { id: 'isha-sunnah', name: 'سنة العشاء', rakahs: 2 },
  { id: 'witr', name: 'الوتر', rakahs: 1 },
]

export type AdhkarCategory = 'morning' | 'evening' | 'prayer'

export type Dhikr = {
  id: string
  text: string
  source: string
  repeat: number
  virtue?: string
}

export const ADHKAR: Record<AdhkarCategory, Dhikr[]> = {
  morning: [
    {
      id: 'm-kursi',
      text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      source: 'آية الكرسي — سورة البقرة: ٢٥٥',
      repeat: 1,
      virtue: 'من قالها حين يصبح أُجير من الجن حتى يمسي',
    },
    {
      id: 'm-mulk',
      text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      source: 'رواه مسلم',
      repeat: 1,
    },
    {
      id: 'm-bika',
      text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      source: 'رواه الترمذي',
      repeat: 1,
    },
    {
      id: 'm-bismillah',
      text: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      source: 'رواه أبو داود والترمذي',
      repeat: 3,
    },
    {
      id: 'm-subhan',
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      source: 'رواه مسلم',
      repeat: 100,
      virtue: 'حُطّت خطاياه وإن كانت مثل زبد البحر',
    },
  ],
  evening: [
    {
      id: 'e-kursi',
      text: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ وَلَا يَئُودُهُ حِفْظُهُمَا وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      source: 'آية الكرسي — سورة البقرة: ٢٥٥',
      repeat: 1,
    },
    {
      id: 'e-mulk',
      text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      source: 'رواه مسلم',
      repeat: 1,
    },
    {
      id: 'e-bika',
      text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      source: 'رواه الترمذي',
      repeat: 1,
    },
    {
      id: 'e-audhu',
      text: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      source: 'رواه مسلم',
      repeat: 3,
    },
  ],
  prayer: [
    {
      id: 'p-istighfar',
      text: 'أَسْتَغْفِرُ اللَّهَ',
      source: 'رواه مسلم',
      repeat: 3,
    },
    {
      id: 'p-salam',
      text: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      source: 'رواه مسلم',
      repeat: 1,
    },
    { id: 'p-subhan', text: 'سُبْحَانَ اللَّهِ', source: 'رواه مسلم', repeat: 33 },
    { id: 'p-hamd', text: 'الْحَمْدُ لِلَّهِ', source: 'رواه مسلم', repeat: 33 },
    { id: 'p-akbar', text: 'اللَّهُ أَكْبَرُ', source: 'رواه مسلم', repeat: 33 },
  ],
}

export const ADHKAR_TABS: { id: AdhkarCategory; label: string }[] = [
  { id: 'morning', label: 'الصباح' },
  { id: 'evening', label: 'المساء' },
  { id: 'prayer', label: 'الصلاة' },
]

export const QURAN_TOTAL_PAGES = 604

export const POINTS = {
  fard: 10,
  sunnah: 5,
  adhkarSession: 15,
  quranPage: 2,
}

export const JOURNEY_GOAL = 245

export const FONT_SIZES = [
  { label: 'صغير', scale: 0.9 },
  { label: 'متوسط', scale: 1 },
  { label: 'كبير', scale: 1.15 },
  { label: 'كبير جدًا', scale: 1.3 },
]

class EgyptGovernorate {
  final String name;
  final double latitude;
  final double longitude;

  const EgyptGovernorate({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

/// إحداثيات تقريبية لمراكز المحافظات؛ تكفي لحساب المواقيت محليًا دون إنترنت.
const egyptGovernorates = <EgyptGovernorate>[
  EgyptGovernorate(name: 'القاهرة', latitude: 30.0444, longitude: 31.2357),
  EgyptGovernorate(name: 'الجيزة', latitude: 30.0131, longitude: 31.2089),
  EgyptGovernorate(name: 'الإسكندرية', latitude: 31.2001, longitude: 29.9187),
  EgyptGovernorate(name: 'الدقهلية', latitude: 31.0409, longitude: 31.3785),
  EgyptGovernorate(name: 'البحر الأحمر', latitude: 27.2579, longitude: 33.8116),
  EgyptGovernorate(name: 'البحيرة', latitude: 30.8481, longitude: 30.3436),
  EgyptGovernorate(name: 'الفيوم', latitude: 29.3085, longitude: 30.8428),
  EgyptGovernorate(name: 'الغربية', latitude: 30.8754, longitude: 31.0335),
  EgyptGovernorate(name: 'الإسماعيلية', latitude: 30.5965, longitude: 32.2715),
  EgyptGovernorate(name: 'المنوفية', latitude: 30.5972, longitude: 30.9876),
  EgyptGovernorate(name: 'المنيا', latitude: 28.1099, longitude: 30.7503),
  EgyptGovernorate(name: 'القليوبية', latitude: 30.4667, longitude: 31.1833),
  EgyptGovernorate(name: 'الوادي الجديد', latitude: 25.4420, longitude: 30.5586),
  EgyptGovernorate(name: 'السويس', latitude: 29.9668, longitude: 32.5498),
  EgyptGovernorate(name: 'أسوان', latitude: 24.0889, longitude: 32.8998),
  EgyptGovernorate(name: 'أسيوط', latitude: 27.1783, longitude: 31.1859),
  EgyptGovernorate(name: 'بني سويف', latitude: 29.0661, longitude: 31.0994),
  EgyptGovernorate(name: 'بورسعيد', latitude: 31.2653, longitude: 32.3019),
  EgyptGovernorate(name: 'دمياط', latitude: 31.4175, longitude: 31.8144),
  EgyptGovernorate(name: 'جنوب سيناء', latitude: 28.5560, longitude: 33.9388),
  EgyptGovernorate(name: 'كفر الشيخ', latitude: 31.1107, longitude: 30.9388),
  EgyptGovernorate(name: 'مطروح', latitude: 31.3543, longitude: 27.2373),
  EgyptGovernorate(name: 'الأقصر', latitude: 25.6872, longitude: 32.6396),
  EgyptGovernorate(name: 'قنا', latitude: 26.1551, longitude: 32.7160),
  EgyptGovernorate(name: 'شمال سيناء', latitude: 31.1249, longitude: 33.8006),
  EgyptGovernorate(name: 'الشرقية', latitude: 30.7327, longitude: 31.7195),
  EgyptGovernorate(name: 'سوهاج', latitude: 26.5591, longitude: 31.6957),
];

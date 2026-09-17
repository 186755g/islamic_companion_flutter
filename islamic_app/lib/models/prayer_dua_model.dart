/// نموذج مجموعة أدعية لموضع معين من الصلاة (مثل الاستفتاح أو الركوع).
/// كل موضع قد يحتوي عدة صيغ بديلة للدعاء (duas), يختار المصلي منها ما يشاء.
class PrayerDuaSection {
  final String id;
  final String title;
  final List<String> duas;
  final String? note;

  const PrayerDuaSection({
    required this.id,
    required this.title,
    required this.duas,
    this.note,
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/prayer_duas_data.dart';
import '../providers/streak_provider.dart';
import '../theme/app_theme.dart';

/// شاشة مرجعية لأدعية الصلاة (استفتاح، ركوع، سجود، تشهد، قنوت...).
/// هذا قسم للقراءة والحفظ فقط، وليس عدّاد تكرار مثل شاشة الأذكار,
/// لأن هذه الأدعية تُقال أثناء الصلاة نفسها.
class PrayerDuasScreen extends StatefulWidget {
  const PrayerDuasScreen({super.key});

  @override
  State<PrayerDuasScreen> createState() => _PrayerDuasScreenState();
}

class _PrayerDuasScreenState extends State<PrayerDuasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StreakProvider>().registerActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sections = PrayerDuasData.all();
    return Scaffold(
      appBar: AppBar(title: const Text('أذكار الصلاة')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: sections.length,
        itemBuilder: (context, i) {
          final section = sections[i];
          return Card(
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text(
                  section.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepGreen,
                  ),
                ),
                iconColor: AppColors.gold,
                collapsedIconColor: AppColors.gold,
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                children: [
                  ...section.duas.map(
                    (dua) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        dua,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 15.5,
                          height: 1.9,
                        ),
                      ),
                    ),
                  ),
                  if (section.note != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        section.note!,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

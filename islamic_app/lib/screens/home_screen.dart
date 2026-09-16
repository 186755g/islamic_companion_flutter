import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../providers/points_provider.dart';
import '../providers/prayer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/streak_lantern_card.dart';
import '../widgets/hadith_of_the_day_card.dart';
import 'azkar_screen.dart';
import 'progress_screen.dart';
import 'quran_screen.dart';
import 'stories_screen.dart';
import 'hadith_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _PrayerHomeTab(),
      const AzkarScreen(),
      const QuranScreen(),
      const _LibraryTab(),
      const ProgressScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('رفيق المسلم')),
      body: pages[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.lightGold.withValues(alpha: 0.5),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mosque), label: 'الصلاة'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'الأذكار'),
          NavigationDestination(
              icon: Icon(Icons.import_contacts), label: 'القرآن'),
          NavigationDestination(
              icon: Icon(Icons.local_library), label: 'المكتبة'),
          NavigationDestination(
              icon: Icon(Icons.emoji_events), label: 'التقدّم'),
        ],
      ),
    );
  }
}

class _PrayerHomeTab extends StatelessWidget {
  const _PrayerHomeTab();

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final pointsProv = context.watch<PointsProvider>();

    if (prayerProv.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (prayerProv.locationNotice != null) ...[
          _LocationPermissionNotice(prayerProv: prayerProv),
          const SizedBox(height: 12),
        ],
        const StreakLanternCard(),
        const SizedBox(height: 12),
        _WeeklyPointsCard(pointsProv: pointsProv),
        const SizedBox(height: 12),
        const HadithOfTheDayCard(),
        const SizedBox(height: 16),
        _NextPrayerCard(prayerProv: prayerProv),
        const SizedBox(height: 16),
        Text(
            'صلوات اليوم — ${DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now())}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...FardPrayer.values.map((f) => _FardCard(prayer: f)),
      ],
    );
  }
}

class _LocationPermissionNotice extends StatelessWidget {
  final PrayerProvider prayerProv;

  const _LocationPermissionNotice({required this.prayerProv});

  void _showManualLocationDialog(BuildContext context) {
    final latController = TextEditingController(text: '21.4225');
    final lngController = TextEditingController(text: '39.8262');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تحديد الموقع يدويًا'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: latController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'خط العرض',
                    hintText: 'مثال: 21.4225',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lngController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'خط الطول',
                    hintText: 'مثال: 39.8262',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                final lat = double.tryParse(latController.text);
                final lng = double.tryParse(lngController.text);
                if (lat == null || lng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('أدخل خط العرض وخط الطول بشكل صحيح')),
                  );
                  return;
                }

                prayerProv.setManualLocation(lat, lng);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('تطبيق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightGold.withValues(alpha: 0.22),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    color: AppColors.deepGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    prayerProv.locationNotice!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (prayerProv.requestingLocationPermission)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else ...[
                  TextButton.icon(
                    onPressed: prayerProv.useMakkahAsDefault,
                    icon: const Icon(Icons.location_city_outlined),
                    label: const Text('استخدام مكة'),
                  ),
                  TextButton.icon(
                    onPressed: prayerProv.requestLocationPermission,
                    icon: const Icon(Icons.my_location),
                    label: Text(prayerProv.locationPermissionPermanentlyDenied
                        ? 'فتح الإعدادات'
                        : 'السماح بموقع الجهاز'),
                  ),
                  TextButton.icon(
                    onPressed: () => _showManualLocationDialog(context),
                    icon: const Icon(Icons.gps_fixed),
                    label: const Text('تحديد يدوي'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// تبويب "المكتبة" — يجمع مدخلي الأحاديث وقصص الأنبياء والصحابة.
class _LibraryTab extends StatelessWidget {
  const _LibraryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LibraryTile(
          icon: Icons.auto_stories,
          title: 'أحاديث المعاملات والأخلاق',
          subtitle: 'مكتبة أحاديث صحيحة في حسن الخلق والمعاملات، مع بحث وتصنيف',
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const HadithScreen())),
        ),
        const SizedBox(height: 12),
        _LibraryTile(
          icon: Icons.groups,
          title: 'قصص الأنبياء والصحابة',
          subtitle: 'سِيَر موثقة للأنبياء والصحابة الكرام رضوان الله عليهم',
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const StoriesScreen())),
        ),
      ],
    );
  }
}

class _LibraryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _LibraryTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
            backgroundColor: AppColors.deepGreen,
            child: Icon(icon, color: AppColors.gold)),
        title: Text(title,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle,
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}

class _WeeklyPointsCard extends StatelessWidget {
  final PointsProvider pointsProv;
  const _WeeklyPointsCard({required this.pointsProv});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.deepGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('نقاطك هذا الأسبوع',
                style: TextStyle(color: AppColors.lightGold, fontSize: 14)),
            const SizedBox(height: 4),
            Text('${pointsProv.weeklyPoints} / ${pointsProv.weeklyTarget}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pointsProv.progressRatio,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              ),
            ),
            if (pointsProv.isBelowTarget) ...[
              const SizedBox(height: 8),
              const Text('حافظ على استمراريتك للوصول للحد الأدنى الأسبوعي 🌙',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}

class _FardCard extends StatelessWidget {
  final FardPrayer prayer;
  const _FardCard({required this.prayer});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PrayerProvider>();
    final unlocked = prov.isFardUnlocked(prayer);
    final checked = prov.fardChecked(prayer);
    final prayerTime = prov.timeFor(prayer);
    final relatedSunnahs =
        SunnahPrayer.values.where((s) => s.relatedFard == prayer).toList();
    final visual = _PrayerVisual.forPrayer(prayer);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Checkbox(
                  value: checked,
                  onChanged: unlocked ? (_) => prov.toggleFard(prayer) : null,
                  activeColor: AppColors.success,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(prayer.arabicName,
                          textAlign: TextAlign.right,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: unlocked ? null : Colors.grey)),
                      const SizedBox(height: 3),
                      Text(
                        prayerTime == null
                            ? 'الوقت غير متاح'
                            : DateFormat.jm('ar').format(prayerTime),
                        style: TextStyle(
                          color: visual.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: visual.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(visual.icon, color: visual.accent, size: 26),
                  ),
                ),
                if (!unlocked)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(Icons.lock_clock, size: 18, color: Colors.grey),
                  ),
              ],
            ),
            if (relatedSunnahs.isNotEmpty) ...[
              const Divider(height: 12),
              ...relatedSunnahs.map((s) => Row(
                    children: [
                      Checkbox(
                          value: prov.sunnahChecked(s),
                          onChanged:
                              unlocked ? (_) => prov.toggleSunnah(s) : null,
                          activeColor: AppColors.gold),
                      Expanded(
                          child: Text(s.arabicName,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontSize: 13))),
                    ],
                  )),
            ]
          ],
        ),
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  final PrayerProvider prayerProv;
  const _NextPrayerCard({required this.prayerProv});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = FardPrayer.values
        .map((prayer) => (prayer: prayer, time: prayerProv.timeFor(prayer)))
        .where((entry) => entry.time != null && entry.time!.isAfter(now))
        .toList();
    final next = upcoming.isEmpty ? null : upcoming.first;
    final visual = next == null
        ? _PrayerVisual.forPrayer(FardPrayer.fajr)
        : _PrayerVisual.forPrayer(next.prayer);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [visual.background, AppColors.deepGreen],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(visual.icon, color: AppColors.lightGold, size: 42),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('الصلاة القادمة',
                    style: TextStyle(color: AppColors.lightGold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  next == null ? 'الفجر غدًا' : next.prayer.arabicName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  next?.time == null
                      ? 'يتم تحديث المواقيت يوميًا'
                      : DateFormat.jm('ar').format(next!.time!),
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerVisual {
  final IconData icon;
  final Color accent;
  final Color background;

  const _PrayerVisual(this.icon, this.accent, this.background);

  static _PrayerVisual forPrayer(FardPrayer prayer) {
    switch (prayer) {
      case FardPrayer.fajr:
        return const _PrayerVisual(
            Icons.wb_twilight, Color(0xFFB47739), Color(0xFFFFE7C2));
      case FardPrayer.dhuhr:
        return const _PrayerVisual(
            Icons.wb_sunny_outlined, Color(0xFFB78916), Color(0xFFFFF2BC));
      case FardPrayer.asr:
        return const _PrayerVisual(
            Icons.sunny, Color(0xFFB9692F), Color(0xFFFFDFC5));
      case FardPrayer.maghrib:
        return const _PrayerVisual(
            Icons.nights_stay_outlined, Color(0xFF7E5B85), Color(0xFFE8DDF0));
      case FardPrayer.isha:
        return const _PrayerVisual(
            Icons.nightlight_round, Color(0xFF37647A), Color(0xFFDCECF0));
    }
  }
}

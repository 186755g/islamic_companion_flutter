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
        const StreakLanternCard(),
        const SizedBox(height: 12),
        _WeeklyPointsCard(pointsProv: pointsProv),
        const SizedBox(height: 12),
        const HadithOfTheDayCard(),
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
    final relatedSunnahs =
        SunnahPrayer.values.where((s) => s.relatedFard == prayer).toList();

    return Card(
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
                  child: Text(prayer.arabicName,
                      textAlign: TextAlign.right,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: unlocked ? null : Colors.grey)),
                ),
                if (!unlocked)
                  const Icon(Icons.lock_clock, size: 18, color: Colors.grey),
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

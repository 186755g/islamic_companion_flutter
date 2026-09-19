import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../providers/points_provider.dart';
import '../providers/prayer_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/streak_lantern_card.dart';
import '../widgets/hadith_of_the_day_card.dart';
import '../widgets/islamic_ornament.dart';
import 'azkar_screen.dart';
import 'progress_screen.dart';
import 'quran_screen.dart';
import 'stories_screen.dart';
import 'hadith_screen.dart';
import 'settings_screen.dart';

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
      appBar: AppBar(
        title: const Text('رفيق المسلم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'الإعدادات',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: pages[_tabIndex],
      bottomNavigationBar: _BottomNavigation(
        selectedIndex: _tabIndex,
        onSelected: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.mosque_rounded, label: 'الصلاة', effect: _NavEffect.glow),
      (
        icon: Icons.menu_book_rounded,
        label: 'الأذكار',
        effect: _NavEffect.pulse
      ),
      (
        icon: Icons.import_contacts_rounded,
        label: 'القرآن',
        effect: _NavEffect.lift
      ),
      (
        icon: Icons.local_library_rounded,
        label: 'المكتبة',
        effect: _NavEffect.open
      ),
      (
        icon: Icons.emoji_events_rounded,
        label: 'التقدّم',
        effect: _NavEffect.bounce
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 5),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.deepGreen.withValues(alpha: .1),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _AnimatedNavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  effect: items[i].effect,
                  selected: selectedIndex == i,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _NavEffect { glow, pulse, lift, open, bounce }

class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final _NavEffect effect;
  final bool selected;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    required this.effect,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> {
  bool _pressed = false;

  void _handleTap() {
    setState(() => _pressed = true);
    widget.onTap();
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _pressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.selected || _pressed;
    final color = active ? AppColors.deepGreen : Colors.grey.shade600;
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.lightGold.withValues(
              alpha: widget.selected ? .62 : 0,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAnimatedIcon(color),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight:
                      widget.selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(Color color) {
    final icon = Icon(widget.icon, color: color, size: 25);
    switch (widget.effect) {
      case _NavEffect.glow:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: .35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: icon,
        );
      case _NavEffect.pulse:
        return AnimatedScale(
          scale: _pressed ? 1.2 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: icon,
        );
      case _NavEffect.lift:
        return AnimatedSlide(
          offset: _pressed ? const Offset(0, -.16) : Offset.zero,
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          child: icon,
        );
      case _NavEffect.open:
        return AnimatedRotation(
          turns: _pressed ? -.04 : 0,
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          child: icon,
        );
      case _NavEffect.bounce:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _pressed ? -4 : 0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          builder: (context, value, child) =>
              Transform.translate(offset: Offset(0, value), child: child),
          child: icon,
        );
    }
  }
}

class _PrayerHomeTab extends StatefulWidget {
  const _PrayerHomeTab();

  @override
  State<_PrayerHomeTab> createState() => _PrayerHomeTabState();
}

class _PrayerHomeTabState extends State<_PrayerHomeTab> {
  int _selectedPrayerIndex = 0;

  @override
  Widget build(BuildContext context) {
    final prayerProv = context.watch<PrayerProvider>();
    final pointsProv = context.watch<PointsProvider>();

    if (prayerProv.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const IslamicOrnamentDivider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          child: Column(
            children: [
              const HadithOfTheDayCard(),
              const SizedBox(height: 14),
              _PrayerDashboardHero(prayerProv: prayerProv),
              const SizedBox(height: 14),
              if (prayerProv.locationNotice != null) ...[
                _LocationPermissionNotice(prayerProv: prayerProv),
                const SizedBox(height: 14),
              ],
              _NextPrayerCard(prayerProv: prayerProv),
              const SizedBox(height: 14),
              _PrayerTimeline(prayerProv: prayerProv),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'صلوات اليوم',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now()),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
              _PrayerCardPager(
                selectedIndex: _selectedPrayerIndex,
                onIndexChanged: (index) =>
                    setState(() => _selectedPrayerIndex = index),
              ),
              const SizedBox(height: 8),
              const StreakLanternCard(),
              const SizedBox(height: 12),
              _WeeklyPointsCard(pointsProv: pointsProv),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrayerCardPager extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _PrayerCardPager({
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  State<_PrayerCardPager> createState() => _PrayerCardPagerState();
}

class _PrayerCardPagerState extends State<_PrayerCardPager> {
  late String _animationStyle;

  @override
  void initState() {
    super.initState();
    _animationStyle = StorageService.getPrayerCardAnimation();
  }

  Widget _transition(Widget child, Animation<double> animation) {
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    switch (_animationStyle) {
      case 'fade':
        return FadeTransition(opacity: curved, child: child);
      case 'scale':
        return ScaleTransition(
          scale: Tween(begin: .86, end: 1.0).animate(curved),
          child: child,
        );
      case 'rotation':
        return RotationTransition(
          turns: Tween(begin: -.015, end: 0.0).animate(curved),
          child: child,
        );
      case 'slide':
      default:
        return SlideTransition(
          position: Tween(begin: const Offset(.18, 0), end: Offset.zero)
              .animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
    }
  }

  void _move(int delta) {
    final next = widget.selectedIndex + delta;
    if (next < 0 || next >= FardPrayer.values.length) return;
    widget.onIndexChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    _animationStyle = StorageService.getPrayerCardAnimation();
    final prayer = FardPrayer.values[widget.selectedIndex];
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'علّم على الصلاة',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              tooltip: 'الصلاة السابقة',
              onPressed: widget.selectedIndex == 0 ? null : () => _move(-1),
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 520),
                reverseDuration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: _transition,
                child: KeyedSubtree(
                  key: ValueKey(prayer),
                  child: _FardCard(prayer: prayer),
                ),
              ),
            ),
            IconButton(
              tooltip: 'الصلاة التالية',
              onPressed: widget.selectedIndex == FardPrayer.values.length - 1
                  ? null
                  : () => _move(1),
              icon: const Icon(Icons.arrow_back_ios_rounded),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${widget.selectedIndex + 1} من ${FardPrayer.values.length}',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}

class _PrayerDashboardHero extends StatelessWidget {
  final PrayerProvider prayerProv;

  const _PrayerDashboardHero({required this.prayerProv});

  @override
  Widget build(BuildContext context) {
    final completed = FardPrayer.values.where(prayerProv.fardChecked).length;
    final progress = completed / FardPrayer.values.length;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepGreen, Color(0xFF176047)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: .2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DashboardPattern(
                color: AppColors.lightGold.withValues(alpha: .13),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mosque_rounded,
                          color: AppColors.lightGold, size: 27),
                    ),
                    const Spacer(),
                    const Text(
                      'لوحة الصلاة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'بارك الله في يومك',
                  style: TextStyle(color: AppColors.lightGold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed من ${FardPrayer.values.length} صلوات مكتملة',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: .16),
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.lightGold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  progress == 1
                      ? 'أتممت صلوات اليوم، تقبّل الله'
                      : 'استمر، كل صلاة نور',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeline extends StatelessWidget {
  final PrayerProvider prayerProv;

  const _PrayerTimeline({required this.prayerProv});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Icon(Icons.swipe_rounded,
                    size: 16, color: Colors.grey.shade500),
                const Spacer(),
                const Text(
                  'مواقيت اليوم',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: FardPrayer.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prayer = FardPrayer.values[index];
                  final visual = _PrayerVisual.forPrayer(prayer);
                  final checked = prayerProv.fardChecked(prayer);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    width: 74,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: checked
                          ? visual.accent.withValues(alpha: .16)
                          : visual.background.withValues(alpha: .65),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: checked
                            ? visual.accent.withValues(alpha: .5)
                            : visual.accent.withValues(alpha: .18),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(checked ? Icons.check_circle : visual.icon,
                            color: checked ? AppColors.success : visual.accent,
                            size: 22),
                        Text(prayer.arabicName,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          prayerProv.timeFor(prayer) == null
                              ? '--:--'
                              : DateFormat.jm('ar')
                                  .format(prayerProv.timeFor(prayer)!),
                          style: TextStyle(
                              color: visual.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardPattern extends CustomPainter {
  final Color color;

  const _DashboardPattern({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final center = Offset(size.width * .12, size.height * .15);
    for (var radius = 22.0; radius < 130; radius += 22) {
      canvas.drawCircle(center, radius, paint);
    }
    final path = Path();
    for (var x = -size.height; x < size.width; x += 30) {
      path.moveTo(x, size.height);
      path.lineTo(x + size.height, 0);
    }
    canvas.drawPath(path, paint..strokeWidth = .6);
  }

  @override
  bool shouldRepaint(covariant _DashboardPattern oldDelegate) =>
      oldDelegate.color != color;
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.deepGreen, AppColors.mediumGreen],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.deepGreen.withValues(alpha: .16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_library_rounded,
                  color: AppColors.lightGold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المكتبة الإسلامية',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'اقرأ، تأمل، واستلهم من كنوز الهداية',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'استكشف المحتوى',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'مصادر مختارة لرحلة يومية أكثر قربًا وطمأنينة',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        const SizedBox(height: 14),
        _LibraryTile(
          icon: Icons.auto_stories,
          title: 'أحاديث المعاملات والأخلاق',
          subtitle: 'أحاديث مختارة في حسن الخلق والمعاملات، مع البحث والتصنيف.',
          tag: 'أحاديث',
          accent: const Color(0xFFB78916),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const HadithScreen())),
        ),
        const SizedBox(height: 14),
        _LibraryTile(
          icon: Icons.groups,
          title: 'قصص الأنبياء والصحابة',
          subtitle: 'سِيَر وقصص موثقة تحمل دروسًا ملهمة من حياة الصالحين.',
          tag: 'قصص وسِيَر',
          accent: const Color(0xFF557C68),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const StoriesScreen())),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softGreen.withValues(alpha: .72),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: AppColors.deepGreen.withValues(alpha: .08)),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'خصص دقائق قليلة كل يوم للقراءة والتدبر.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.textDark.withValues(alpha: .82),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LibraryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tag;
  final Color accent;
  final VoidCallback onTap;

  const _LibraryTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.tag,
      required this.accent,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.chevron_left_rounded, color: accent, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 29),
              ),
            ],
          ),
        ),
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

class _FardCard extends StatefulWidget {
  final FardPrayer prayer;
  const _FardCard({required this.prayer});

  @override
  State<_FardCard> createState() => _FardCardState();
}

class _FardCardState extends State<_FardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PrayerProvider>();
    final unlocked = prov.isFardUnlocked(widget.prayer);
    final checked = prov.fardChecked(widget.prayer);
    final prayerTime = prov.timeFor(widget.prayer);
    final relatedSunnahs = SunnahPrayer.values
        .where((s) => s.relatedFard == widget.prayer)
        .toList();
    final visual = _PrayerVisual.forPrayer(widget.prayer);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final glow = checked
            ? 0.18 + (_animationController.value * 0.08)
            : 0.06 + (_animationController.value * 0.03);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: visual.accent.withValues(alpha: glow),
                blurRadius: checked ? 16 : 9,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PrayerCardPattern(
                      color: visual.accent.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        visual.background.withValues(alpha: 0.42),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: checked,
                            onChanged: unlocked
                                ? (_) => prov.toggleFard(widget.prayer)
                                : null,
                            activeColor: AppColors.success,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  widget.prayer.arabicName,
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: unlocked ? null : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
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
                          _AnimatedPrayerIcon(
                            visual: visual,
                            enabled: unlocked,
                            glow: glow,
                          ),
                          if (!unlocked)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.lock_clock,
                                  size: 18, color: Colors.grey),
                            ),
                        ],
                      ),
                      if (relatedSunnahs.isNotEmpty) ...[
                        Divider(
                          height: 12,
                          color: visual.accent.withValues(alpha: 0.18),
                        ),
                        ...relatedSunnahs.map(
                          (s) => Row(
                            children: [
                              Checkbox(
                                value: prov.sunnahChecked(s),
                                onChanged: unlocked
                                    ? (_) => prov.toggleSunnah(s)
                                    : null,
                                activeColor: AppColors.gold,
                              ),
                              Expanded(
                                child: Text(
                                  s.arabicName,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedPrayerIcon extends StatelessWidget {
  final _PrayerVisual visual;
  final bool enabled;
  final double glow;

  const _AnimatedPrayerIcon({
    required this.visual,
    required this.enabled,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1 + (glow * 0.08),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: visual.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: visual.accent.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: visual.accent.withValues(alpha: glow),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          visual.icon,
          color: enabled ? visual.accent : Colors.grey,
          size: 27,
        ),
      ),
    );
  }
}

class _PrayerCardPattern extends CustomPainter {
  final Color color;

  const _PrayerCardPattern({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width * 0.12, size.height * 0.15);
    for (var radius = 22.0; radius <= 80; radius += 18) {
      canvas.drawCircle(center, radius, paint);
    }
    final path = Path();
    for (var x = -size.height; x < size.width; x += 34) {
      path.moveTo(x, size.height);
      path.lineTo(x + size.height, 0);
    }
    canvas.drawPath(path, paint..strokeWidth = 0.7);
  }

  @override
  bool shouldRepaint(covariant _PrayerCardPattern oldDelegate) =>
      oldDelegate.color != color;
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

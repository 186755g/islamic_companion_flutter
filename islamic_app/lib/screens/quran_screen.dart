import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/quran_progress_model.dart';
import '../providers/quran_provider.dart';
import '../theme/app_theme.dart';
import 'khatmah_completion_screen.dart';
import 'quran_reader_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuranProvider>();
    final activePlan = provider.activePlan;
    final bookmark = provider.bookmark;
    final readingPage = activePlan?.lastCompletedPage ?? bookmark?.page ?? 0;
    final readingProgress =
        (readingPage / provider.totalPages).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن'),
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.deepGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'quran_create_plan',
        backgroundColor: AppColors.deepGreen,
        foregroundColor: AppColors.white,
        onPressed: () => _showNewPlanSheet(context),
        icon: const Icon(Icons.auto_stories_rounded),
        label: const Text('إنشاء خطة ختمة'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            _QuranHero(
              progress: readingProgress,
              readingPage: readingPage,
              totalPages: provider.totalPages,
              activePlan: activePlan,
            ),
            const SizedBox(height: 16),
            _PrimaryReadAction(
              readingPage: readingPage,
              bookmark: bookmark,
            ),
            const SizedBox(height: 16),
            _LastReadingCard(
              bookmark: bookmark,
              readingPage: readingPage,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الختمة',
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.deepGreen,
                  ),
                ),
                Text(
                  '${provider.plans.length} خطة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (provider.plans.isEmpty)
              _EmptyPlans(onCreate: () => _showNewPlanSheet(context))
            else
              ...provider.plans.map((plan) => _KhatmahPlanCard(plan: plan)),
          ],
        ),
      ),
    );
  }

  void _showNewPlanSheet(BuildContext context) {
    final titleController = TextEditingController();
    var selectedDays = 30;
    var customDays = 30.0;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setState) {
          final days = selectedDays == -1 ? customDays.round() : selectedDays;
          final pagesPerDay = KhatmahPlan.defaultTotalPages / days;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              4,
              18,
              MediaQuery.of(sheetContext).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'أنشئ خطتك الخاصة',
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'حدد عدد الأيام الذي يناسب وقتك اليومي',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      labelText: 'اسم الخطة (اختياري)',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'مدة الختمة',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      ...KhatmahPlan.predefinedDurations().map(
                        (duration) => ChoiceChip(
                          label: Text('$duration يوم'),
                          selected: selectedDays == duration,
                          onSelected: (_) =>
                              setState(() => selectedDays = duration),
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('مخصص'),
                        selected: selectedDays == -1,
                        onSelected: (_) => setState(() => selectedDays = -1),
                      ),
                    ],
                  ),
                  if (selectedDays == -1) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${customDays.round()} يوم',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 365,
                            divisions: 364,
                            value: customDays,
                            label: '${customDays.round()} يوم',
                            onChanged: (value) =>
                                setState(() => customDays = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 9),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: AppColors.softGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.deepGreen,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            'ستقرأ تقريبًا ${pagesPerDay.toStringAsFixed(1)} صفحة يوميًا',
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        final title = titleController.text.trim().isEmpty
                            ? 'ختمة $days يوم'
                            : titleController.text.trim();
                        context
                            .read<QuranProvider>()
                            .createPlan(title: title, days: days);
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('ابدأ الخطة'),
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

class _QuranHero extends StatelessWidget {
  final double progress;
  final int readingPage;
  final int totalPages;
  final KhatmahPlan? activePlan;

  const _QuranHero({
    required this.progress,
    required this.readingPage,
    required this.totalPages,
    required this.activePlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepGreen, Color(0xFF184F3F)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepGreen.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _QuranPattern(
                color: AppColors.lightGold.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                SizedBox(
                  width: 94,
                  height: 94,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: value,
                          strokeWidth: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          valueColor: const AlwaysStoppedAnimation(AppColors.lightGold),
                        ),
                        Text(
                          '${(value * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'تقدم القراءة',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.lightGold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activePlan?.title ?? 'رحلة القرآن',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.title.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'الصفحة الحالية: $readingPage من $totalPages',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryReadAction extends StatelessWidget {
  final int readingPage;
  final QuranBookmark? bookmark;

  const _PrimaryReadAction({
    required this.readingPage,
    required this.bookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hasStarted = readingPage > 0;
    final startPage = hasStarted ? readingPage : 1;

    return FilledButton.icon(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuranReaderScreen(startPage: startPage),
        ),
      ),
      icon: const Icon(Icons.menu_book_rounded),
      label: Text(hasStarted ? 'متابعة القراءة' : 'ابدأ القراءة'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.deepGreen,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }
}

class _LastReadingCard extends StatelessWidget {
  final QuranBookmark? bookmark;
  final int readingPage;

  const _LastReadingCard({
    required this.bookmark,
    required this.readingPage,
  });

  @override
  Widget build(BuildContext context) {
    final lastReadTime = bookmark?.savedAt;
    final lastReadText = lastReadTime == null
        ? 'غير متاح'
        : DateFormat('dd/MM/yyyy • HH:mm', 'ar').format(lastReadTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'آخر قراءة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الصفحة ${readingPage == 0 ? '—' : readingPage}',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.deepGreen,
                ),
              ),
              Text(
                'آخر صفحة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _surahNameFor(bookmark?.surahNumber ?? 0),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'آخر سورة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lastReadText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'آخر قراءة',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _surahNameFor(int surahNumber) {
    const names = [
      'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف',
      'الأنفال', 'التوبة', 'يونس', 'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر',
      'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه', 'الأنبياء', 'الحج', 'المؤمنون',
      'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
      'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص',
      'الزمر', 'غافر', 'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية',
      'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق', 'الذاريات', 'الطور', 'النجم',
      'القمر', 'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
      'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم', 'الملك',
      'القلم', 'الحاقة', 'المعارج', 'نوح', 'المزمل', 'المدثر', 'القيامة',
      'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس', 'التكوير', 'الإنفطار',
      'المطففين', 'الإنشقاق', 'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر',
      'البلد', 'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق', 'القدر',
      'البينة', 'الزلزلة', 'العاديات', 'القارعة', 'التكاثر', 'الأعلي', 'الضحي',
      'الشرح', 'التين', 'المسد', 'الإخلاص', 'الفلق', 'الناس'
    ];
    if (surahNumber <= 0 || surahNumber > names.length) {
      return 'غير محدد';
    }
    return names[surahNumber - 1];
  }
}

class _EmptyPlans extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyPlans({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.warmSand,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 36,
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'ابدأ ختمتك الأولى',
            style: AppTextStyles.title.copyWith(
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'خطة هادئة تناسب وقتك وتُشجعك على الاستمرار مع القرآن الكريم.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إنشاء خطة ختمة'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deepGreen,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhatmahPlanCard extends StatelessWidget {
  final KhatmahPlan plan;

  const _KhatmahPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final accent = plan.isCompleted ? AppColors.gold : AppColors.deepGreen;
    final daysRemaining = plan.totalDays -
        DateTime.now().difference(plan.startDate).inDays;
    final safeRemaining = daysRemaining.clamp(0, plan.totalDays);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (plan.isCompleted)
                const Icon(Icons.emoji_events_rounded, color: AppColors.gold)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'نشطة',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.deepGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  plan.title,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatMini(
                  label: 'نسبة الإنجاز',
                  value: '${plan.progressPercent}%',
                  accent: accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMini(
                  label: 'الورد اليومي',
                  value: '${plan.pagesPerDay.round()} صفحة',
                  accent: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatMini(
                  label: 'الأيام المتبقية',
                  value: '$safeRemaining يوم',
                  accent: AppColors.warning,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatMini(
                  label: 'التقدم',
                  value: '${plan.lastCompletedPage}/${plan.totalPages}',
                  accent: AppColors.deepGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: plan.progressRatio,
              minHeight: 10,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const KhatmahCompletionScreen(),
                ),
              ),
              child: const Text('عرض التفاصيل'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatMini({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranPattern extends CustomPainter {
  final Color color;

  const _QuranPattern({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width * .9, size.height * .12);
    for (var radius = 20.0; radius < 145; radius += 23) {
      canvas.drawCircle(center, radius, paint);
    }
    final path = Path();
    for (var x = -size.height; x < size.width; x += 32) {
      path.moveTo(x, size.height);
      path.lineTo(x + size.height, 0);
    }
    canvas.drawPath(path, paint..strokeWidth = .6);
  }

  @override
  bool shouldRepaint(covariant _QuranPattern oldDelegate) =>
      oldDelegate.color != color;
}

import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('المصحف الشريف')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.deepGreen,
        onPressed: () => _showNewPlanSheet(context),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('خطة ختمة'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
        children: [
          _QuranHero(
            progress: readingProgress,
            readingPage: readingPage,
            totalPages: provider.totalPages,
            activePlan: activePlan,
          ),
          const SizedBox(height: 14),
          _ContinueReadingCard(
            bookmark: bookmark,
            readingPage: readingPage,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text(
                'خطط الختمة',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Spacer(),
              Text(
                '${provider.plans.length} خطط',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'اختر إيقاعًا يناسب يومك، وتابع تقدمك صفحة بعد صفحة',
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (provider.plans.isEmpty)
            _EmptyPlans(onCreate: () => _showNewPlanSheet(context)),
          ...provider.plans.map((plan) => _KhatmahPlanCard(plan: plan)),
        ],
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
                  Text('أنشئ خطتك الخاصة',
                      style: Theme.of(sheetContext).textTheme.headlineSmall),
                  const SizedBox(height: 5),
                  Text('حدد عدد الأيام الذي يناسب وقتك اليومي',
                      style: TextStyle(color: Colors.grey.shade600)),
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
                    child: Text('مدّة الختمة',
                        style: TextStyle(fontWeight: FontWeight.bold)),
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
                        Text('${customDays.round()} يوم',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
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
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppColors.deepGreen),
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
              painter: _QuranPattern(
                color: AppColors.lightGold.withValues(alpha: .14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 20, 18),
            child: Row(
              children: [
                SizedBox(
                  width: 94,
                  height: 94,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) => Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: value,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: .15),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.lightGold,
                          ),
                        ),
                        Text('${(value * 100).round()}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('رحلتك مع القرآن',
                          style: TextStyle(
                              color: AppColors.lightGold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        activePlan?.title ?? 'واصل القراءة بتدبر',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'صفحة $readingPage من $totalPages',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
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

class _ContinueReadingCard extends StatelessWidget {
  final QuranBookmark? bookmark;
  final int readingPage;

  const _ContinueReadingCard({
    required this.bookmark,
    required this.readingPage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuranReaderScreen(startPage: bookmark?.page ?? 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.deepGreen, size: 18),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(readingPage == 0 ? 'ابدأ القراءة' : 'متابعة القراءة',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 3),
                    Text(
                      readingPage == 0
                          ? 'افتح المصحف وابدأ رحلتك'
                          : 'آخر موضع محفوظ — صفحة $readingPage',
                      textAlign: TextAlign.right,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.warmSand,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: AppColors.deepGreen, size: 27),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPlans extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyPlans({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const Icon(Icons.flag_circle_outlined,
                size: 48, color: AppColors.gold),
            const SizedBox(height: 9),
            const Text('لا توجد خطة ختمة بعد',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('أنشئ خطة تناسب وقتك اليومي وابدأ الآن',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            OutlinedButton(
                onPressed: onCreate, child: const Text('إنشاء أول خطة')),
          ],
        ),
      ),
    );
  }
}

class _KhatmahPlanCard extends StatelessWidget {
  final KhatmahPlan plan;

  const _KhatmahPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final accent = plan.isCompleted ? AppColors.gold : AppColors.success;
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: -22,
            top: -22,
            child: Icon(Icons.auto_stories_rounded,
                size: 105, color: accent.withValues(alpha: .07)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    if (plan.isCompleted)
                      const Icon(Icons.emoji_events_rounded,
                          color: AppColors.gold, size: 21),
                    if (!plan.isCompleted && plan.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('نشطة',
                            style: TextStyle(
                                color: AppColors.deepGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ),
                    const Spacer(),
                    Expanded(
                      child: Text(plan.title,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${plan.pagesPerDay.toStringAsFixed(1)} صفحة يوميًا • ${plan.totalDays} يوم • ${plan.totalPages} صفحة',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: plan.progressRatio),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor:
                          AppColors.lightGold.withValues(alpha: .3),
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    if (plan.pagesBehindSchedule > 0 && !plan.isCompleted)
                      Text('متأخر ${plan.pagesBehindSchedule} صفحة',
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 11)),
                    const Spacer(),
                    Text('${plan.progressPercent}% مكتمل',
                        style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
                if (plan.isCompleted) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const KhatmahCompletionScreen()),
                      ),
                      child: const Text('عرض التهنئة 🎉'),
                    ),
                  ),
                ],
              ],
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

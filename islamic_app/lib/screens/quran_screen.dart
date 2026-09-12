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
    final prov = context.watch<QuranProvider>();
    final bookmark = prov.bookmark;

    return Scaffold(
      appBar: AppBar(title: const Text('المصحف الشريف')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        onPressed: () => _showNewPlanSheet(context),
        icon: const Icon(Icons.flag),
        label: const Text('خطة ختمة جديدة'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: AppColors.deepGreen,
            child: ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.white),
              title: Text(
                bookmark == null ? 'ابدأ القراءة من أول المصحف' : 'متابعة القراءة — صفحة ${bookmark.page}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
              subtitle: bookmark != null
                  ? Text('آخر حفظ: سورة رقم ${bookmark.surahNumber}، آية ${bookmark.ayahNumber}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12), textAlign: TextAlign.right)
                  : null,
              trailing: const Icon(Icons.chevron_left, color: Colors.white),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => QuranReaderScreen(startPage: bookmark?.page ?? 1)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('خطط الختمة', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (prov.plans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('لا توجد خطة ختمة بعد — أنشئ واحدة من الزر أدناه',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ),
          ...prov.plans.map((p) => _KhatmahPlanCard(plan: p)),
        ],
      ),
    );
  }

  void _showNewPlanSheet(BuildContext context) {
    final titleController = TextEditingController();
    int? selectedDays = 30;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('خطة ختمة جديدة', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(labelText: 'اسم الخطة (اختياري)'),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  ...KhatmahPlan.predefinedDurations().map((d) => ChoiceChip(
                        label: Text('$d يوماً'),
                        selected: selectedDays == d,
                        onSelected: (_) => setState(() => selectedDays = d),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final days = selectedDays ?? 30;
                  final title = titleController.text.trim().isEmpty ? 'ختمة $days يوماً' : titleController.text.trim();
                  context.read<QuranProvider>().createPlan(title: title, days: days);
                  Navigator.pop(ctx);
                },
                child: const Text('إنشاء الخطة'),
              ),
            ],
          ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                if (plan.isCompleted) const Icon(Icons.emoji_events, color: AppColors.gold, size: 20),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(plan.title, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${plan.pagesPerDay.toStringAsFixed(1)} صفحة/يوم لإتمامها خلال ${plan.totalDays} يوماً',
                textAlign: TextAlign.right, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: plan.progressRatio,
                minHeight: 10,
                backgroundColor: AppColors.lightGold.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation(plan.isCompleted ? AppColors.gold : AppColors.success),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (plan.pagesBehindSchedule > 0 && !plan.isCompleted)
                  Text('متأخر ${plan.pagesBehindSchedule} صفحة', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                Text('${plan.progressPercent}% مكتمل', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            if (plan.isCompleted) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KhatmahCompletionScreen())),
                  child: const Text('عرض شاشة التهنئة 🎉'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_theme.dart';

/// ⚠️ نص المصحف الكامل غير مضمَّن هنا لضخامته (604 صفحة). اربط هذه الشاشة
/// بمصدر بيانات محلي موثوق وزوّد منطق عرض النص الفعلي.
class QuranReaderScreen extends StatefulWidget {
  final int startPage;
  const QuranReaderScreen({super.key, this.startPage = 1});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late int currentPage;
  static const int totalPages = 604;

  @override
  void initState() {
    super.initState();
    currentPage = widget.startPage.clamp(1, totalPages);
  }

  @override
  void dispose() {
    _persistBookmark();
    super.dispose();
  }

  Future<void> _persistBookmark() async {
    await context.read<QuranProvider>().saveLastRead(page: currentPage, surahNumber: 1, ayahNumber: 1);
    await context.read<StreakProvider>().registerActivity();

    final active = context.read<QuranProvider>().activePlan;
    if (active != null && currentPage > active.lastCompletedPage) {
      await context.read<QuranProvider>().updatePlanProgress(active.id, currentPage);
    }
  }

  void _goTo(int page) {
    setState(() => currentPage = page.clamp(1, totalPages));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: Text('صفحة $currentPage من $totalPages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'حفظ العلامة يدوياً',
            onPressed: () async {
              await _persistBookmark();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ موضعك بنجاح ✓')));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, size: 64, color: AppColors.gold),
              const SizedBox(height: 16),
              Text(
                'محتوى الصفحة $currentPage سيُعرض هنا بعد ربط مصدر\nنص المصحف (JSON محلي أو حزمة قرآن موثوقة).',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.8),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: currentPage < totalPages ? () => _goTo(currentPage + 1) : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالية'),
              ),
              TextButton.icon(
                onPressed: currentPage > 1 ? () => _goTo(currentPage - 1) : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('السابقة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

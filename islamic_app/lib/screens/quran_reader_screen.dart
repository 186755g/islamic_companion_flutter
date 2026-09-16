import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../providers/streak_provider.dart';
import '../services/quran_pdf_service.dart';
import '../theme/app_theme.dart';

/// شاشة قراءة المصحف الفعلية من ملف PDF محلي.
class QuranReaderScreen extends StatefulWidget {
  final int startPage;
  const QuranReaderScreen({super.key, this.startPage = 1});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  late final PdfController _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.startPage < 1 ? 1 : widget.startPage;
    _pdfController =
        QuranPdfService.createController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _persistBookmark();
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _persistBookmark() async {
    final quranProvider = context.read<QuranProvider>();
    final streakProvider = context.read<StreakProvider>();
    await quranProvider.saveLastRead(
        page: _currentPage, surahNumber: 0, ayahNumber: 0);
    await streakProvider.registerActivity();
    final active = quranProvider.activePlan;
    if (active != null && _currentPage > active.lastCompletedPage) {
      await quranProvider.updatePlanProgress(active.id, _currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        title: Text(_totalPages == 0
            ? 'جاري تحميل المصحف...'
            : 'صفحة $_currentPage من $_totalPages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'حفظ العلامة يدوياً',
            onPressed: () async {
              await _persistBookmark();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ موضعك بنجاح ✓')));
              }
            },
          ),
        ],
      ),
      body: PdfView(
        controller: _pdfController,
        scrollDirection: Axis.horizontal,
        onDocumentLoaded: (document) =>
            setState(() => _totalPages = document.pagesCount),
        onPageChanged: (page) => setState(() => _currentPage = page),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => _pdfController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالية'),
              ),
              TextButton.icon(
                onPressed: () => _pdfController.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut),
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

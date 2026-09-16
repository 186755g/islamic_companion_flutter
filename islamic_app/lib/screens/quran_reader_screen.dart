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
  PdfController? _pdfController;
  late final QuranProvider _quranProvider;
  late final StreakProvider _streakProvider;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _quranProvider = context.read<QuranProvider>();
    _streakProvider = context.read<StreakProvider>();
    _currentPage = widget.startPage < 1 ? 1 : widget.startPage;
    _loadPdf();
  }

  @override
  void dispose() {
    _persistBookmark();
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final available = await QuranPdfService.isAssetAvailable();
      if (!available) {
        throw StateError('Quran PDF asset is missing');
      }

      final controller =
          QuranPdfService.createController(initialPage: _currentPage);
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _pdfController = controller;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to load Quran PDF: $error\n$stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'تعذر تحميل المصحف، حاول مرة أخرى.';
        });
      }
    }
  }

  Future<void> _persistBookmark() async {
    await _quranProvider.saveLastRead(
        page: _currentPage, surahNumber: 0, ayahNumber: 0);
    await _streakProvider.registerActivity();
    final active = _quranProvider.activePlan;
    if (active != null && _currentPage > active.lastCompletedPage) {
      await _quranProvider.updatePlanProgress(active.id, _currentPage);
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null || _pdfController == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_outlined,
                  size: 56, color: AppColors.gold),
              const SizedBox(height: 16),
              Text(_loadError ?? 'تعذر تحميل المصحف، حاول مرة أخرى.',
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return PdfView(
      controller: _pdfController!,
      scrollDirection: Axis.horizontal,
      onDocumentLoaded: (document) =>
          setState(() => _totalPages = document.pagesCount),
      onPageChanged: (page) => setState(() => _currentPage = page),
    );
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
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _pdfController == null
                    ? null
                    : () => _pdfController!.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالية'),
              ),
              TextButton.icon(
                onPressed: _pdfController == null
                    ? null
                    : () => _pdfController!.previousPage(
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

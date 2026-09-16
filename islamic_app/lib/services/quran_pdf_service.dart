import 'package:pdfx/pdfx.dart';
import 'package:flutter/services.dart';

/// خدمة مسؤولة عن فتح ملف المصحف المرفق كأصل داخل التطبيق عبر مكتبة pdfx.
class QuranPdfService {
  static const String assetPath = 'assets/quran/mushaf.pdf';

  static Future<bool> isAssetAvailable() async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<int> getPageCount() async {
    final document = await PdfDocument.openAsset(assetPath);
    final count = document.pagesCount;
    await document.close();
    return count;
  }

  static PdfController createController({int initialPage = 1}) {
    return PdfController(
      document: PdfDocument.openAsset(assetPath),
      initialPage: initialPage < 1 ? 1 : initialPage,
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// ⚠️ راجع نص الدعاء والفضائل من مرجع موثوق قبل النشر.
class KhatmahCompletionScreen extends StatelessWidget {
  const KhatmahCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepGreen,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            const Icon(Icons.emoji_events, color: AppColors.gold, size: 72),
            const SizedBox(height: 16),
            const Text(
              'بارك الله لك، تمت الختمة بحمد الله',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'من فضائل ختم القرآن',
              child: const Text(
                'القرآن الكريم شفيع لصاحبه يوم القيامة، وقد ثبت في الحديث الصحيح '
                'عن النبي ﷺ الحثّ على قراءته وتدبره. وكان كثير من السلف يجتهدون '
                'في ختمه ويجتمعون عند دعاء الختمة رجاءً لإجابة الدعاء.',
                textAlign: TextAlign.right,
                style: TextStyle(height: 1.9, fontSize: 15),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'دعاء ختم القرآن',
              child: const Text(
                'اللَّهُمَّ ارْحَمْنِي بِالْقُرْآنِ، وَاجْعَلْهُ لِي إِمَامًا وَنُورًا وَهُدًى وَرَحْمَةً، '
                'اللَّهُمَّ ذَكِّرْنِي مِنْهُ مَا نُسِّيتُ، وَعَلِّمْنِي مِنْهُ مَا جَهِلْتُ، '
                'وَارْزُقْنِي تِلَاوَتَهُ آنَاءَ اللَّيْلِ وَأَطْرَافَ النَّهَارِ، وَاجْعَلْهُ لِي حُجَّةً '
                'يَا رَبَّ الْعَالَمِينَ.',
                textAlign: TextAlign.right,
                style: TextStyle(height: 2.0, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.deepGreen),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ابدأ ختمة جديدة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.deepGreen, fontSize: 15)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

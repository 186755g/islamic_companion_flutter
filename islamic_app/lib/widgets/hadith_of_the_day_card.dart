import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/hadith_provider.dart';
import '../theme/app_theme.dart';
import '../screens/hadith_screen.dart';

class HadithOfTheDayCard extends StatelessWidget {
  const HadithOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final hadith = context.watch<HadithProvider>().hadithOfTheDay;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.gold.withValues(alpha: .28)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const HadithScreen())),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_stories, color: AppColors.gold, size: 18),
                  SizedBox(width: 6),
                  Text('حديث اليوم',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepGreen)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hadith.text,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 16, height: 1.85, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Text('${hadith.source} — ${hadith.narrator}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 11, height: 1.4, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

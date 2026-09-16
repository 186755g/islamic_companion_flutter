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
        side: const BorderSide(color: AppColors.gold, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const HadithScreen())),
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, height: 1.7),
              ),
              const SizedBox(height: 6),
              Text('${hadith.source} — ${hadith.narrator}',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_theme.dart';

/// قنديل متوهج يعكس مستوى الالتزام اليومي (streak).
class StreakLanternCard extends StatelessWidget {
  const StreakLanternCard({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StreakProvider>();
    final streak = prov.streak;
    final level = streak.lampLevel;

    final glowColor = switch (level) {
      0 => Colors.grey.shade400,
      1 => AppColors.lightGold,
      2 => AppColors.gold,
      _ => const Color(0xFFFFD76A),
    };

    return Card(
      color: AppColors.deepGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: level / 3),
              duration: const Duration(milliseconds: 700),
              builder: (context, value, child) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withValues(alpha: 0.15 + value * 0.5),
                        blurRadius: 14 + value * 18,
                        spreadRadius: value * 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    level == 0 ? Icons.nights_stay_outlined : Icons.local_fire_department,
                    color: glowColor,
                    size: 36,
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${streak.currentStreak} يوم متتالي',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prov.isActiveToday
                        ? 'أحسنت! نشاطك مسجَّل لليوم ✨'
                        : 'أكمل ذكراً أو صفحة اليوم لإبقاء القنديل مضيئاً',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                  ),
                  if (streak.longestStreak > streak.currentStreak) ...[
                    const SizedBox(height: 2),
                    Text(
                      'أطول سلسلة: ${streak.longestStreak} يوم',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

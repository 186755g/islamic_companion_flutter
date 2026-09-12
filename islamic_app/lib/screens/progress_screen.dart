import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final points = context.watch<PointsProvider>();
    final remaining = (points.weeklyTarget - points.weeklyPoints).clamp(0, 1 << 30);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(points.isBelowTarget ? Icons.trending_up : Icons.emoji_events, size: 48, color: AppColors.gold),
                const SizedBox(height: 12),
                Text('${points.weeklyPoints} نقطة', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text('من أصل ${points.weeklyTarget} نقطة مستهدفة هذا الأسبوع', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: points.progressRatio,
                    minHeight: 12,
                    backgroundColor: AppColors.lightGold.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation(AppColors.deepGreen),
                  ),
                ),
                const SizedBox(height: 12),
                if (points.isBelowTarget)
                  Text('تحتاج $remaining نقطة إضافية للوصول للحد الأدنى الأسبوعي', style: const TextStyle(color: Colors.redAccent))
                else
                  const Text('ما شاء الله! لقد حققت هدفك الأسبوعي 🎉',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('نظام النقاط', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                const _RuleRow(label: 'كل صلاة فريضة', points: '+10'),
                const _RuleRow(label: 'كل سنة راتبة', points: '+5'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final String points;
  const _RuleRow({required this.label, required this.points});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(points, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }
}

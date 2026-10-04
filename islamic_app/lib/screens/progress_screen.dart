import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../providers/points_provider.dart';
import '../providers/prayer_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final points = context.watch<PointsProvider>();
    final streak = context.watch<StreakProvider>().streak;
    final prayer = context.watch<PrayerProvider>();
    final remaining =
        (points.weeklyTarget - points.weeklyPoints).clamp(0, 1 << 30);
    final completedPrayers = FardPrayer.values
            .where(prayer.fardChecked)
            .length +
        SunnahPrayer.values.where(prayer.sunnahChecked).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 600 ? 28.0 : 16.0;
        return ListView(
          padding:
              EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 28),
          children: [
            _ProgressHero(
              weeklyPoints: points.weeklyPoints,
              weeklyTarget: points.weeklyTarget,
              ratio: points.progressRatio,
              activeDays: streak.totalActiveDays,
              currentStreak: streak.currentStreak,
              completedPrayers: completedPrayers,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_month_rounded,
                    label: 'أيام النشاط',
                    value: '${streak.totalActiveDays} يوم',
                    color: AppColors.mediumGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'السلسلة الحالية',
                    value: '${streak.currentStreak} يوم',
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    icon: Icons.done_all_rounded,
                    label: 'الصلوات المكتملة',
                    value: '$completedPrayers',
                    color: AppColors.deepGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _MotivationCard(
              achieved: !points.isBelowTarget,
              remaining: remaining,
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppColors.gold, size: 22),
                        const SizedBox(width: 8),
                        Text('كيف تم احتساب النقاط؟',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _RuleRow(
                      icon: Icons.mosque_rounded,
                      label: 'الفريضة',
                      points: '10 نقاط',
                      value: 'لكل صلاة فريضة مكتملة',
                    ),
                    const _RuleRow(
                      icon: Icons.favorite_rounded,
                      label: 'السنة',
                      points: '5 نقاط',
                      value: 'لكل سنة راتبة مكتملة',
                    ),
                    const _RuleRow(
                      icon: Icons.lightbulb_rounded,
                      label: 'الاستمرارية',
                      points: 'بركة',
                      value: 'استمر، القليل الدائم خير من الكثير المنقطع.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressHero extends StatelessWidget {
  final int weeklyPoints;
  final int weeklyTarget;
  final double ratio;
  final int activeDays;
  final int currentStreak;
  final int completedPrayers;

  const _ProgressHero({
    required this.weeklyPoints,
    required this.weeklyTarget,
    required this.ratio,
    required this.activeDays,
    required this.currentStreak,
    required this.completedPrayers,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = weeklyPoints >= weeklyTarget;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 290),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.deepGreen, AppColors.mediumGreen],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
                child: CustomPaint(painter: _IslamicPatternPainter())),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isComplete ? Icons.emoji_events_rounded : Icons.nights_stay_rounded,
                        color: AppColors.lightGold,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'رحلتك الإيمانية',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return SizedBox(
                        width: 136,
                        height: 136,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: value,
                                strokeWidth: 12,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation(
                                    AppColors.lightGold),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$weeklyPoints',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text('نقاط',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: .8),
                                      fontSize: 11,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isComplete
                        ? 'ما شاء الله، حققت هدفك الأسبوعي'
                        : 'كل خطوة صغيرة تقرّبك من هدفك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isComplete
                          ? AppColors.lightGold
                          : Colors.white.withValues(alpha: .88),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _CompactMetric(
                          icon: Icons.done_all_rounded,
                          label: 'الصلوات',
                          value: '$completedPrayers',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CompactMetric(
                          icon: Icons.local_fire_department_rounded,
                          label: 'السلسلة',
                          value: '$currentStreak',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CompactMetric(
                          icon: Icons.calendar_month_rounded,
                          label: 'نشاط',
                          value: '$activeDays',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CompactMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.lightGold, size: 18),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: .75),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicPatternPainter extends CustomPainter {
  const _IslamicPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const radius = 24.0;
    for (double x = -radius; x < size.width + radius; x += radius * 2) {
      for (double y = -radius; y < size.height + radius; y += radius * 2) {
        final center = Offset(x + (y ~/ (radius * 2)).remainder(2) * radius, y);
        final path = Path();
        for (var i = 0; i < 8; i++) {
          final angle = (math.pi * 2 * i / 8) - math.pi / 8;
          final point =
              center + Offset(math.cos(angle), math.sin(angle)) * radius;
          if (i == 0) {
            path.moveTo(point.dx, point.dy);
          } else {
            path.lineTo(point.dx, point.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  final bool achieved;
  final int remaining;

  const _MotivationCard({required this.achieved, required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: achieved
          ? AppColors.softGreen
          : AppColors.warmSand.withValues(alpha: .5),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(
              achieved ? Icons.check_circle_rounded : Icons.lightbulb_rounded,
              color: achieved ? AppColors.success : AppColors.gold,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                achieved
                    ? 'استمر، القليل الدائم خير من الكثير المنقطع.'
                    : 'باقي $remaining نقطة فقط. استمر، القليل الدائم خير من الكثير المنقطع.',
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: AppColors.textDark, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String points;
  final String value;

  const _RuleRow({
    required this.icon,
    required this.label,
    required this.points,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$label = $points',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: AppColors.deepGreen, size: 20),
        ],
      ),
    );
  }
}

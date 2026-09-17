import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/points_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final points = context.watch<PointsProvider>();
    final streak = context.watch<StreakProvider>().streak;
    final remaining =
        (points.weeklyTarget - points.weeklyPoints).clamp(0, 1 << 30);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _ProgressHero(points: points),
        const SizedBox(height: 18),
        Row(
          children: [
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
                icon: Icons.calendar_month_rounded,
                label: 'أيام النشاط',
                value: '${streak.totalActiveDays} يوم',
                color: AppColors.mediumGreen,
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
                    Text('كيف تجمع النقاط؟',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 10),
                const _RuleRow(
                  icon: Icons.mosque_rounded,
                  label: 'كل صلاة فريضة',
                  points: '+10',
                ),
                const _RuleRow(
                  icon: Icons.favorite_rounded,
                  label: 'كل سنة راتبة',
                  points: '+5',
                ),
                const _RuleRow(
                  icon: Icons.menu_book_rounded,
                  label: 'استمر في وردك اليومي',
                  points: 'بركة',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressHero extends StatelessWidget {
  final PointsProvider points;

  const _ProgressHero({required this.points});

  @override
  Widget build(BuildContext context) {
    final ratio = points.progressRatio;
    final isComplete = !points.isBelowTarget;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 270),
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
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isComplete
                            ? Icons.emoji_events_rounded
                            : Icons.nights_stay_rounded,
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
                  const SizedBox(height: 14),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return SizedBox(
                        width: 142,
                        height: 142,
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
                                Text('${points.weeklyPoints}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Text('من ${points.weeklyTarget}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: .8),
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 13),
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
                ],
              ),
            ),
          ],
        ),
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
                    ? 'استمر على هذا الطريق، ثباتك هو أجمل إنجاز.'
                    : 'باقي $remaining نقطة فقط. اغتنم الصلاة القادمة وواصل التقدم.',
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

  const _RuleRow({
    required this.icon,
    required this.label,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(points,
              style: const TextStyle(
                  color: AppColors.success, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(label),
          const SizedBox(width: 10),
          Icon(icon, color: AppColors.deepGreen, size: 20),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IslamicOrnamentDivider extends StatelessWidget {
  final double height;
  final Color backgroundColor;

  const IslamicOrnamentDivider({
    super.key,
    this.height = 28,
    this.backgroundColor = AppColors.deepGreen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _IslamicOrnamentPainter(
          backgroundColor: backgroundColor,
          accentColor: AppColors.gold,
          secondaryColor: AppColors.lightGold,
        ),
      ),
    );
  }
}

class _IslamicOrnamentPainter extends CustomPainter {
  final Color backgroundColor;
  final Color accentColor;
  final Color secondaryColor;

  const _IslamicOrnamentPainter({
    required this.backgroundColor,
    required this.accentColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    final linePaint = Paint()
      ..color = accentColor.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final fillPaint = Paint()..color = secondaryColor.withValues(alpha: 0.25);
    final centerY = size.height / 2;
    const step = 32.0;

    for (double centerX = 16; centerX < size.width + step; centerX += step) {
      final diamond = Path()
        ..moveTo(centerX, centerY - 9)
        ..lineTo(centerX + 9, centerY)
        ..lineTo(centerX, centerY + 9)
        ..lineTo(centerX - 9, centerY)
        ..close();
      canvas.drawPath(diamond, linePaint);

      final innerDiamond = Path()
        ..moveTo(centerX, centerY - 4)
        ..lineTo(centerX + 4, centerY)
        ..lineTo(centerX, centerY + 4)
        ..lineTo(centerX - 4, centerY)
        ..close();
      canvas.drawPath(innerDiamond, fillPaint);
    }

    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _IslamicOrnamentPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

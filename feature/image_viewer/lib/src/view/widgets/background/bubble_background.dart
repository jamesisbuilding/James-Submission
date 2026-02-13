import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final double offset;
  final List<Color> colors;

  BackgroundPainter({required this.offset, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the gradient background rect first (bottom layer)
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // 2. Draw circles on top – semi-transparent white so they show as glowing orbs
    final circlePaint = Paint()..color = Colors.white.withValues(alpha: 0.25);

    canvas.drawCircle(
      Offset(size.width * 0.3 + offset, size.height * 0.4),
      200,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7 - offset, size.height * 0.6),
      150,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.7 - offset, size.height),
      100,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return offset != oldDelegate.offset ||
        !listEquals(colors, oldDelegate.colors);
  }
}
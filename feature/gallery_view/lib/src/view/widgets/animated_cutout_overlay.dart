import 'package:flutter/material.dart';

class AnimatedCutoutOverlay extends StatelessWidget {
  const AnimatedCutoutOverlay({
    super.key,
    required this.overlayPaintKey,
    required this.child,
    required this.cutoutSize,
    required this.cutoutCenterOffset,
    required this.animationKey,
    this.duration,
    required this.swipeDir,
    required this.opacity,
  });

  final GlobalKey overlayPaintKey;
  final Widget child;
  final Size cutoutSize;
  final Offset cutoutCenterOffset;
  final Key animationKey;
  final Offset swipeDir;
  final Duration? duration;
  final double opacity;

  static const Radius _cutoutRadius = Radius.circular(8);

  @override
  Widget build(BuildContext context) {
    const overlayAnimDuration = Duration(milliseconds: 180);
    return Stack(
      children: [
        child,
        TweenAnimationBuilder<double>(
          key: animationKey,
          duration: duration ?? overlayAnimDuration,
          tween: Tween(begin: 0, end: 1),
          builder: (context, anim, _) {
            final size = _animatedCutoutSize(anim);
            return IgnorePointer(
              child: CustomPaint(
                key: overlayPaintKey,
                painter: _CutoutOverlayPainter(
                  cutoutSize: size,
                  cutoutCenterOffset: cutoutCenterOffset,
                  color: Colors.black.withValues(alpha: opacity),
                  cutoutRadius: _cutoutRadius,
                ),
                child: const SizedBox.expand(),
              ),
            );
          },
        ),
      ],
    );
  }

  Size _animatedCutoutSize(double anim) {
    const scaleAmt = .25;
    final dx = swipeDir.dx.abs();
    final dy = swipeDir.dy.abs();
    final pulse = 1 - (2 * (anim - 0.5)).abs();
    final hasDirection = dx > 0 || dy > 0;
    final horizontalFactor = hasDirection ? dx : 1.0;
    final verticalFactor = hasDirection ? dy : 1.0;

    final width = cutoutSize.width * (1 - scaleAmt * pulse * horizontalFactor);
    final height = cutoutSize.height * (1 - scaleAmt * pulse * verticalFactor);
    return Size(width, height);
  }
}

class _CutoutOverlayPainter extends CustomPainter {
  _CutoutOverlayPainter({
    required this.cutoutSize,
    required this.cutoutCenterOffset,
    required this.color,
    required this.cutoutRadius,
  });

  final Size cutoutSize;
  final Offset cutoutCenterOffset;
  final Color color;
  final Radius cutoutRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final holeW = cutoutSize.width.clamp(0.0, size.width).toDouble();
    final holeH = cutoutSize.height.clamp(0.0, size.height).toDouble();

    final centerX = (size.width / 2) + cutoutCenterOffset.dx;
    final centerY = (size.height / 2) + cutoutCenterOffset.dy;
    final padX = (centerX - (holeW / 2))
        .clamp(0.0, size.width - holeW)
        .toDouble();
    final padY = (centerY - (holeH / 2))
        .clamp(0.0, size.height - holeH)
        .toDouble();

    final overlay = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addRRect(
        RRect.fromLTRBR(padX, padY, padX + holeW, padY + holeH, cutoutRadius),
      );
    final shaded = Path.combine(PathOperation.difference, overlay, hole);
    canvas.drawPath(shaded, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CutoutOverlayPainter oldDelegate) {
    return oldDelegate.cutoutSize != cutoutSize ||
        oldDelegate.cutoutCenterOffset != cutoutCenterOffset ||
        oldDelegate.color != color ||
        oldDelegate.cutoutRadius != cutoutRadius;
  }
}

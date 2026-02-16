import 'dart:ui';

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';

/// Time-based reveal: wraps [child] with [DelayedDisplay] for content that fits viewport.
Widget wrapTimeReveal(Widget child, int delayMs) {
  return DelayedDisplay(
    delay: Duration(milliseconds: delayMs),
    slidingBeginOffset: const Offset(0, 0.05),
    child: child,
  );
}

/// Animated blue reveal bar that only plays the tween animation when revealed is true.
class _RevealBarAnimation extends StatelessWidget {
  final bool revealed;
  final Color color;
  const _RevealBarAnimation({required this.revealed, required this.color});

  @override
  Widget build(BuildContext context) {
    if (!revealed) {
      // When not revealed, show nothing or hide the bar
      return const SizedBox.shrink();
    }
    return Transform.translate(
      offset: Offset(0, 0),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value, // Animates width from 0 to 1
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    // Add a backdrop filter (blur) and shadow to the reveal bar background.
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
                        blurRadius: 12.0,
                        spreadRadius: 1.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                    color: color.withValues(alpha: 0.2)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Scroll-based reveal: shows [child] when [blockIndex] <= [maxRevealedIndex].
Widget wrapScrollReveal({
  required Widget child,
  required int blockIndex,
  required int maxRevealedIndex,
  required bool showReveal,
  required Color revealColor,
}) {
  final revealed = blockIndex <= maxRevealedIndex;
  return IntrinsicHeight(
    child: IntrinsicWidth(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // if (showReveal)
            // _RevealBarAnimation(revealed: revealed, color: revealColor),
          AnimatedOpacity(
            opacity: revealed ? 1 : 0,
            duration: const Duration(milliseconds: 1000),
            child: AnimatedSlide(
              offset: revealed ? Offset.zero : const Offset(0, 0.1),
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 250),
              child: child,
            ),
          ),
        ],
      ),
    ),
  );
}

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

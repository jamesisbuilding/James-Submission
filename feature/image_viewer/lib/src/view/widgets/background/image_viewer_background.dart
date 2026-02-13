import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_viewer/src/view/widgets/background/liquid_background.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.imageColors,
    this.colorsListenable,
    this.fallbackColors = const [
      Color(0xFF6B4E9D),
      Color(0xFF4A47A3),
      Color(0xFF1E88E5),
    ],
  }) : assert(
         (imageColors != null) != (colorsListenable != null),
         'Provide exactly one of imageColors or colorsListenable',
       );

  final List<Color>? imageColors;
  final ValueListenable<List<Color>>? colorsListenable;
  final List<Color> fallbackColors;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.colorsListenable != null
            ? LiquidBackground(colorsListenable: widget.colorsListenable)
            : LiquidBackground(
                colors: widget.imageColors ?? widget.fallbackColors,
              ),
        _buildFrostOverlay(),
      ],
    );
  }

  Widget _buildFrostOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SizedBox.expand(
          child: Container(
            color: Theme.of(
              context,
            ).colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

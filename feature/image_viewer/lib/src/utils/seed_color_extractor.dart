import 'package:flutter/material.dart';

/// Extracts corner/edge colors from an image for background seeding.
/// Returns a non-null list; filters out any null color results.
List<Color> extractSeedColorsFromImage(dynamic img) {
  final w = img.width as int?;
  final h = img.height as int?;
  if (w == null || h == null || w <= 0 || h <= 0) {
    return _defaultThemePalette();
  }

  final pixelColorAt = img.pixelColorAt;
  if (pixelColorAt == null) {
    return _defaultThemePalette();
  }

  final colors = <Color>[];
  for (final (x, y) in [
    (0, 0), 
    (w ~/ 2, 0), 
    (0, h ~/ 2), 
    (w - 1, h - 1)
  ]) {
    final c = pixelColorAt(x, y) as Color?;
    if (c != null) colors.add(c);
  }

  // If no valid colors extracted, return a fallback theme palette.
  if (colors.isEmpty) {
    return _defaultThemePalette();
  }

  return colors;
}

/// Return theme's default color palette
List<Color> _defaultThemePalette() {
  // Replace with your theme palette if needed
  return const [
    Color(0xFF212121), // dark grey
    Color(0xFF424242), // grey
    Color(0xFF616161), // mid grey
    Color(0xFF90CAF9), // blueish
    Color(0xFFE57373), // reddish
  ];
}

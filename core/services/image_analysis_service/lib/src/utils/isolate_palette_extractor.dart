import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Default palette when extraction fails.
const _fallbackArgb = [
  0xFF6B4E9D,
  0xFF4A47A3,
  0xFF1E88E5,
];

/// Extracts up to 5 dominant colors from image bytes.
/// Runs in isolate - no Flutter bindings. Returns ARGB ints for [Color.value].
List<int> extractPaletteFromBytes(Uint8List bytes) {
  try {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return List.of(_fallbackArgb);

    final small = img.copyResize(decoded, width: 64);
    final counts = <int, int>{};

    for (var y = 0; y < small.height; y++) {
      for (var x = 0; x < small.width; x++) {
        final p = small.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        if (p.a < 128) continue;
        final key = (r ~/ 32) << 16 | (g ~/ 32) << 8 | (b ~/ 32);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    if (counts.isEmpty) return List.of(_fallbackArgb);

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(5).map((e) {
      final r = ((e.key >> 16) & 0xFF) * 32 + 16;
      final g = ((e.key >> 8) & 0xFF) * 32 + 16;
      final b = (e.key & 0xFF) * 32 + 16;
      return 0xFF000000 | (r.clamp(0, 255) << 16) | (g.clamp(0, 255) << 8) | b.clamp(0, 255);
    }).toList();
  } catch (_) {
    return List.of(_fallbackArgb);
  }
}


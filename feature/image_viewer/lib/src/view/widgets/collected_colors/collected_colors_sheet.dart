import 'dart:ui';

import 'package:flutter/material.dart';

import '../notch.dart';

/// Glassmorphic bottom sheet showing collected colour palettes.
class CollectedColorsSheet extends StatelessWidget {
  const CollectedColorsSheet({super.key, required this.collected});

  final Map<String, List<Color>> collected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final fillColor = isLight
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.6);
    final textColor = isLight ? Colors.black87 : Colors.white;

    final entries = collected.entries.toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Center(child: DraggableNotch()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    'my colours',
                    style: TextStyle(
                      fontFamily: 'YesevaOne',
                      package: 'design_system',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Flexible(
                  child: entries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No colours collected yet',
                            style: TextStyle(
                              fontFamily: 'Raleway',
                              package: 'design_system',
                              fontSize: 14,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: entry.value
                                    .take(5)
                                    .map((c) => _PaletteCircle(color: c))
                                    .toList(),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteCircle extends StatelessWidget {
  const _PaletteCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            width: 0.25,
          ),
        ),
      ),
    );
  }
}

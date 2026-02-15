import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:image_viewer/image_viewer.dart';

import 'collected_colors_sheet.dart';

/// 12×12 circle size matching collapsed palette in expanded view.
const _circleSize = 12.0;

/// Horizontal offset between circle centers for overlap.
const _overlapOffset = 6.0;

/// Three small overlapping circles in top-left. Tapping opens the collected colours sheet.
class CollectedColorsButton extends StatelessWidget {
  const CollectedColorsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectedColorsCubit, Map<String, List<Color>>>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, collected) {
        if (collected.isEmpty) return const SizedBox.shrink();

        final palettes = collected.entries.toList();
        final displayColors = palettes.isNotEmpty
            ? palettes.last.value.take(3).toList()
            : <Color>[];

        while (displayColors.length < 3) {
          displayColors.add(
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          );
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _showCollectedColorsSheet(context, collected);
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: _circleSize + _overlapOffset * 2,
            height: _circleSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < 3; i++)
                  Positioned(
                    left: i * _overlapOffset,
                    top: 0,
                    child: _ColorCircle(color: displayColors[i]),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCollectedColorsSheet(
    BuildContext context,
    Map<String, List<Color>> collected,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CollectedColorsSheet(collected: collected),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  const _ColorCircle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: _circleSize,
      height: _circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          width: 0.5,
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black26),
        ],
      ),
    );
  }
}

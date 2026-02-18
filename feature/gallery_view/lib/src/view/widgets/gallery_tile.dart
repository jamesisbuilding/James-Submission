import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:design_system/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class GalleryTile extends StatelessWidget {
  const GalleryTile({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.imgUrl,
    required this.palette,
    required this.isPaletteCollected,
    required this.imgSize,
    required this.heroTag,
    required this.selectionScaleCycle,
    required this.selectionDuration,
    required this.scaleDuration,
    required this.selectedImageScale,
    required this.selectedTileKey,
    required this.onTap,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int index;
  final int selectedIndex;
  final String imgUrl;
  final List<Color> palette;
  final bool isPaletteCollected;
  final Size imgSize;
  final String? heroTag;
  final int selectionScaleCycle;
  final Duration selectionDuration;
  final Duration scaleDuration;
  final double selectedImageScale;
  final GlobalKey selectedTileKey;
  final ValueChanged<int> onTap;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return Semantics(
      focused: isSelected,
      image: true,
      liveRegion: isSelected,
      label: isSelected ? 'Selected photo ${index + 1}' : 'Photo ${index + 1}',
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: TextButton(
        onPressed: () => onTap(index),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: (isSelected && heroTag != null && imgUrl.isNotEmpty)
            ? Hero(tag: heroTag!, child: _buildTileContent(context, isSelected))
            : _buildTileContent(context, isSelected),
      ),
    );
  }

  Widget _buildTileContent(BuildContext context, bool isSelected) {
    final shouldScale = isSelected && imgUrl.isNotEmpty;
    return ClipRRect(
      key: isSelected ? selectedTileKey : null,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(
              shouldScale
                  ? 'selected_scale_${selectionScaleCycle}_$index'
                  : 'unselected_scale_$index',
            ),
            duration: scaleDuration,
            curve: Curves.easeOut,
            tween: Tween(begin: 1, end: shouldScale ? selectedImageScale : 1),
            builder: (_, value, child) =>
                Transform.scale(scale: value, child: child),
            child: imgUrl.isEmpty
                ? ColoredBox(
                    color: Colors.white.withValues(alpha: 0.5),
                    child: Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontFamily: FontFamily.raleway,
                                package: 'design_system',
                              ),
                          children: [
                            TextSpan(
                              text: '???\n',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontFamily: FontFamily.raleway,
                                    package: 'design_system',
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextSpan(
                              text: 'image ${index + 1}'.toLowerCase(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontFamily: FontFamily.raleway,
                                    package: 'design_system',
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : CachedImage(url: imgUrl, fit: BoxFit.cover),
          ),
          if (imgUrl.isNotEmpty && palette.isNotEmpty)
            Positioned(
              bottom: 8,
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: DecoratedBox(
                      key: const ValueKey('gallery_palette_container'),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: isPaletteCollected ? 0.45 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: isPaletteCollected
                              ? palette
                                    .take(5)
                                    .map(
                                      (color) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        child: DecoratedBox(
                                          key: ValueKey(
                                            'gallery_palette_swatch_collected_${color.value}',
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: color,
                                            border: Border.all(
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: const SizedBox(
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(growable: false)
                              : List.generate(
                                  5,
                                  (index) => Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    child: DecoratedBox(
                                      key: ValueKey(
                                        'gallery_palette_swatch_placeholder_$index',
                                      ),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: const SizedBox(
                                        width: 12,
                                        height: 12,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          AnimatedOpacity(
            duration: selectionDuration,
            opacity: isSelected ? 0 : .5,
            child: ColoredBox(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.1),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: selectionDuration,
                curve: Curves.easeOut,
                opacity: isSelected ? 1 : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: imgSize.width, height: imgSize.height),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_viewer/src/cubit/cubit.dart';

const _swatchSize = 12.0;
const _borderWidth = 1.0;

/// Floating color swatches from collected palettes.
/// Renders between [AnimatedBackground] and carousel. 12x12, 1px white border.
/// Swatches fade in and out at random positions.
class FloatingCollectedColors extends StatefulWidget {
  const FloatingCollectedColors({super.key});

  @override
  State<FloatingCollectedColors> createState() => _FloatingCollectedColorsState();
}

class _FloatingCollectedColorsState extends State<FloatingCollectedColors>
    with TickerProviderStateMixin {
  late Ticker _ticker;
  final List<_SwatchState> _swatches = [];
  final Random _random = Random(42);
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (!mounted || _lastSize.width <= 0 || _lastSize.height <= 0) return;
    final dt = elapsed.inMilliseconds / 1000.0;
    for (final s in _swatches) {
      s.phase += dt / s.cycleDuration;
      if (s.phase >= 1) {
        s.phase = 0;
        s.x = _random.nextDouble() * (_lastSize.width - _swatchSize);
        s.y = _random.nextDouble() * (_lastSize.height - _swatchSize);
      }
    }
    setState(() {});
  }

  void _syncSwatchesFromPalettes(
    List<({String imageUid, List<Color> colors})> palettes,
    Size size,
  ) {
    final allColors = <Color>[];
    for (final p in palettes) {
      for (final c in p.colors) {
        allColors.add(c);
      }
    }

    while (_swatches.length < allColors.length) {
      _swatches.add(_SwatchState(
        color: allColors[_swatches.length],
        x: _random.nextDouble() * (size.width - _swatchSize),
        y: _random.nextDouble() * (size.height - _swatchSize),
        phase: _random.nextDouble(),
        cycleDuration: 2.5 + _random.nextDouble() * 3,
      ));
    }
    while (_swatches.length > allColors.length) {
      _swatches.removeLast();
    }
    for (var i = 0; i < _swatches.length && i < allColors.length; i++) {
      _swatches[i].color = allColors[i];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectedColorsCubit, Map<String, List<Color>>>(
      builder: (context, state) {
        final palettes = state.entries
            .map((e) => (imageUid: e.key, colors: e.value))
            .toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            if (size.width > 0 && size.height > 0) {
              _lastSize = size;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                final before = _swatches.length;
                _syncSwatchesFromPalettes(palettes, size);
                if (_swatches.length != before && mounted) setState(() {});
              });
            }

            if (_swatches.isEmpty) {
              return const SizedBox.shrink();
            }

            return IgnorePointer(
              child: RepaintBoundary(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final s in _swatches)
                      Positioned(
                        left: s.x,
                        top: s.y,
                        child: _ColorSwatch(
                          color: s.color,
                          opacity: sin(s.phase * pi),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SwatchState {
  _SwatchState({
    required this.color,
    required this.x,
    required this.y,
    required this.phase,
    required this.cycleDuration,
  });

  Color color;
  double x;
  double y;
  double phase;
  final double cycleDuration;
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: _swatchSize,
        height: _swatchSize,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: _borderWidth),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

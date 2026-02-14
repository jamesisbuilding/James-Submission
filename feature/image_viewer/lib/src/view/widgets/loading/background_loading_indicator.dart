import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_viewer/image_viewer.dart';

class BackgroundLoadingIndicator extends StatelessWidget {
  const BackgroundLoadingIndicator({
    super.key,
    required this.visibleWhen,
    this.buildWhen,
  });

  /// Determines when the indicator is visible from bloc state.
  final bool Function(ImageViewerState state) visibleWhen;

  /// When to rebuild. Defaults to when [visibleWhen] result changes.
  final bool Function(ImageViewerState previous, ImageViewerState current)?
      buildWhen;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageViewerBloc, ImageViewerState>(
      buildWhen: buildWhen ??
          (prev, curr) => visibleWhen(prev) != visibleWhen(curr),
      builder: (context, state) {
        final visible = visibleWhen(state);
        return SafeArea(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: visible ? 1 : 0,
            child: SpinKitFadingCube(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              size: 16,
            ),
          ),
        );
      },
    );
  }
}

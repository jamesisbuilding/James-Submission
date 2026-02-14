import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_viewer/image_viewer.dart';

class BackgroundLoadingIndicator extends StatelessWidget {
  const BackgroundLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ImageViewerBloc, ImageViewerState>(
        buildWhen: (previous, current) =>
            previous.loadingType != current.loadingType &&
            (previous.loadingType == ViewerLoadingType.background ||
                current.loadingType == ViewerLoadingType.background),
        builder: (context, state) {
          return Opacity(
            opacity: state.loadingType == ViewerLoadingType.background ? 1 : 0,
            child: SpinKitFadingCube(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
              size: 16,
            ),
          );
        },
      ),
    );
  }
}

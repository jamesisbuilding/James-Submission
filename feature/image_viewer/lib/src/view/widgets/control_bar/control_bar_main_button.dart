import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_viewer/image_viewer.dart';

class ControlBarMainButton extends StatelessWidget {
  final Function onAnotherTap;
  final MainButtonMode mode;
  final Function(bool) onPlayTapped;
  const ControlBarMainButton({
    super.key,
    required this.onAnotherTap,
    required this.mode,
    required this.onPlayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<ImageViewerBloc, ImageViewerState>(
        buildWhen: (prev, curr) {
          return prev.selectedImage?.uid != curr.selectedImage?.uid ||
              curr.loadingType != prev.loadingType;
        },
        builder: (context, state) {
          final isLightMode = Theme.of(context).brightness == Brightness.light;
          Color? bgColor;
          Color? fgColor;

          final lightest = state.selectedImage?.lightestColor;
          final darkest = state.selectedImage?.darkestColor;
          bgColor = isLightMode ? lightest : darkest;
          fgColor = isLightMode ? darkest : lightest;

          return BlocBuilder<TtsCubit, TtsState>(
            builder: (context, ttsState) => MainButton(
              label: 'another',
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              onTap: () => onAnotherTap(),
              mode: state.loadingType == ViewerLoadingType.manual
                  ? MainButtonMode.audio
                  : mode,
              onPlayTapped: (playing) => onPlayTapped(playing),
              isPlaying: ttsState.isPlaying,
              isLoading:
                  state.loadingType == ViewerLoadingType.manual ||
                  ttsState.isLoading,
            ),
          );
        },
      ),
    );
  }
}

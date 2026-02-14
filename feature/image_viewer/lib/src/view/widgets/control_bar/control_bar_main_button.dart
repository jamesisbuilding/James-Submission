import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/image_viewer.dart';

class ControlBarMainButton extends StatefulWidget {
  const ControlBarMainButton({
    super.key,
    required this.onAnotherTap,
    required this.mode,
    required this.onPlayTapped,
    this.displayImageForColor,
    this.controlBarExpanded = false,
    required this.carouselExpanded,
  });

  final VoidCallback onAnotherTap;
  final ImageModel? displayImageForColor;
  final MainButtonMode mode;
  final Function(bool) onPlayTapped;
  final bool controlBarExpanded;
  final bool carouselExpanded;

  @override
  State<ControlBarMainButton> createState() => _ControlBarMainButtonState();
}

class _ControlBarMainButtonState extends State<ControlBarMainButton> {
  @override
  void didUpdateWidget(covariant ControlBarMainButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carouselExpanded != widget.carouselExpanded) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<ImageViewerBloc, ImageViewerState>(
        buildWhen: (prev, curr) =>
            prev.selectedImage?.uid != curr.selectedImage?.uid ||
            curr.loadingType != prev.loadingType ||
            (curr.fetchedImages.isNotEmpty != prev.fetchedImages.isNotEmpty) ||
            (curr.fetchedImages.isNotEmpty &&
                (prev.fetchedImages.isEmpty ||
                    prev.fetchedImages.first.uid !=
                        curr.fetchedImages.first.uid)),
        builder: (context, state) {
          final isLightMode = Theme.of(context).brightness == Brightness.light;
          final theme = Theme.of(context);

          final imageForColors =
              widget.displayImageForColor ??
              state.selectedImage ??
              state.visibleImages.lastOrNull;
          Color? bgColor;
          Color? fgColor;
          if (imageForColors != null) {
            final lightest = imageForColors.lightestColor;
            final darkest = imageForColors.darkestColor;
            bgColor = isLightMode ? lightest : darkest;
            fgColor = isLightMode ? darkest : lightest;
          }
          bgColor ??= theme.colorScheme.surface;
          fgColor ??=
              theme.textTheme.labelLarge?.color ?? theme.colorScheme.onSurface;

          final nextImageForBackground = widget.carouselExpanded
              ? state.selectedImage
              : (state.fetchedImages.isNotEmpty
                    ? state.fetchedImages.first
                    : state.selectedImage);
          final backgroundImageUrl = nextImageForBackground?.url;

          return BlocBuilder<TtsCubit, TtsState>(
            builder: (context, ttsState) => MainButton(
              label: 'another',
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              backgroundImageUrl: backgroundImageUrl,
              onTap: () => widget.onAnotherTap(),
              mode: state.loadingType == ViewerLoadingType.manual
                  ? MainButtonMode.audio
                  : widget.mode,
              onPlayTapped: (playing) => widget.onPlayTapped(playing),
              isPlaying: ttsState.isPlaying,
              isLoading:
                  (state.loadingType == ViewerLoadingType.manual &&
                      !widget.carouselExpanded) ||
                  ttsState.isLoading,
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/src/view/pages/image_viewer_main_view.dart';
import 'package:image_viewer/src/view/pages/video_view.dart';

const _fadeDuration = Duration(milliseconds: 600);

/// Orchestrates the image viewer flow: intro video first, then image viewer.
/// Image viewer preloads in the background whilst the video plays.
class ImageViewerFlow extends StatefulWidget {
  const ImageViewerFlow({
    super.key,
    required this.onThemeToggle,
    this.onShareTap,
  });

  final VoidCallback onThemeToggle;
  final void Function(ImageModel?)? onShareTap;

  @override
  State<ImageViewerFlow> createState() => _ImageViewerFlowState();
}

class _ImageViewerFlowState extends State<ImageViewerFlow> {
  bool _videoComplete = false;

  void _onVideoComplete() {
    setState(() => _videoComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Bottom layer: image viewer preloads whilst video plays
        Positioned.fill(
          child: ImageViewerScreen(
            onThemeToggle: widget.onThemeToggle,
            onShareTap: widget.onShareTap,
          ),
        ),
        
        Transform.scale(
          scale: 1.15,
          child: Transform.translate(
            offset: Offset(0, -33),
            child: IgnorePointer(
              ignoring: _videoComplete,
              child: AnimatedOpacity(
                opacity: _videoComplete ? 0 : 1,
                duration: _fadeDuration,
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: VideoView(
                      onVideoComplete: _onVideoComplete,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

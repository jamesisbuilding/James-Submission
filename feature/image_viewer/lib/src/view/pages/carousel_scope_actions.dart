part of 'image_viewer_main_view.dart';

extension _CarouselControllerScopeActions on CarouselControllerScopeState {
  void _openGalleryFromVisibleImages() {
    final state = context.read<ImageViewerBloc>().state;
    final visibleImages = state.visibleImages
        .where((image) => image.url.isNotEmpty)
        .toList(growable: false);
    if (visibleImages.isEmpty) return;

    final selectedId = state.selectedImage?.uid;
    final selectedIndex = selectedId == null
        ? 0
        : visibleImages.indexWhere((image) => image.uid == selectedId);
    final collectedImageUids = context
        .read<CollectedColorsCubit>()
        .state
        .keys
        .toSet();
    widget.onOpenGalleryRoute?.call(
      context,
      imageUrls: visibleImages.map((i) => i.url).toList(growable: false),
      imageUids: visibleImages.map((i) => i.uid).toList(growable: false),
      imagePalettes: visibleImages
          .map((i) => List<Color>.of(i.colorPalette, growable: false))
          .toList(growable: false),
      imageCollectedStates: visibleImages
          .map((i) => collectedImageUids.contains(i.uid))
          .toList(growable: false),
      initialIndex: selectedIndex >= 0 ? selectedIndex : 0,
    );
  }

  void nextPage() {
    widget.onNextPage();
  }

  Future<Uint8List?> _captureCarouselScreenshot() async {
    final boundary =
        _screenshotKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null || !mounted) return null;
    final image = await boundary.toImage(
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }

  Future<void> _onShareTap(ImageModel? image) async {
    if (image == null) return;
    if (!mounted) return;
    Uint8List? screenshotBytes;
    if (widget.expandedView) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        screenshotBytes = await _captureCarouselScreenshot();
        if (!mounted) return;
        widget.onShareTap?.call(image, screenshotBytes: screenshotBytes);
      });
    } else {
      widget.onShareTap?.call(image, screenshotBytes: null);
    }
  }
}

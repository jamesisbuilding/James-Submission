import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:image_viewer/src/utils/image_provider_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/view/widgets/alerts/custom_dialog.dart';
import 'package:image_viewer/src/view/widgets/background/image_viewer_background.dart';
import 'package:image_viewer/src/view/widgets/control_bar/control_bar.dart';
import 'package:image_viewer/src/view/widgets/image_carousel.dart';
import 'package:image_viewer/src/view/widgets/loading/background_loading_indicator.dart';

part 'carousel_scope.dart';

const _slotCount = 5;
const _minColorsForShader = 4;
const _fallbackPalette = [
  Color(0xFF6B4E9D),
  Color(0xFF4A47A3),
  Color(0xFF1E88E5),
];

List<Color> _ensureMinColors(List<Color> colors) {
  if (colors.length >= _minColorsForShader) return colors;
  if (colors.isEmpty) return _ensureMinColors(List.of(_fallbackPalette));
  final out = List<Color>.from(colors);
  while (out.length < _minColorsForShader) {
    out.add(out[out.length % colors.length]);
  }
  return out;
}

/// Produces 5 colors by picking from each image per slot. ratio[i] = image index.
List<Color> _computeBlendedColors(List<ImageModel> images, List<int> ratio) {
  if (images.isEmpty) return _ensureMinColors(List.of(_fallbackPalette));
  final result = <Color>[];
  for (var i = 0; i < _slotCount; i++) {
    final imageIndex = (i < ratio.length ? ratio[i] : 0).clamp(
      0,
      images.length - 1,
    );
    final palette = images[imageIndex].colorPalette;
    final colorIndex = palette.isEmpty ? 0 : i % palette.length;
    result.add(
      palette.isEmpty
          ? _fallbackPalette[colorIndex % _fallbackPalette.length]
          : palette[colorIndex],
    );
  }
  return result;
}

/// Expects [BlocProvider<ImageViewerBloc>] from an ancestor (e.g. app router).
class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({
    super.key,
    required this.onThemeToggle,
    this.onShareTap,
  });

  final VoidCallback onThemeToggle;
  final void Function(ImageModel?, {Uint8List? screenshotBytes})? onShareTap;

  @override
  Widget build(BuildContext context) {
    return _ImageViewerContent(
      onThemeToggle: onThemeToggle,
      onShareTap: onShareTap,
    );
  }
}

class _ImageViewerContent extends StatefulWidget {
  const _ImageViewerContent({required this.onThemeToggle, this.onShareTap});

  final VoidCallback onThemeToggle;
  final void Function(ImageModel?, {Uint8List? screenshotBytes})? onShareTap;

  @override
  State<_ImageViewerContent> createState() => _ImageViewerContentState();
}

class _ImageViewerContentState extends State<_ImageViewerContent> {
  late final ValueNotifier<List<Color>> _blendedColorsNotifier;
  List<ImageModel>? _lastImages;
  ImageModel? _lastSelectedImage;
  ImageModel? _displayImageForColor;
  bool _expandedView = false;

  @override
  void initState() {
    super.initState();
    _blendedColorsNotifier = ValueNotifier<List<Color>>(
      _ensureMinColors(List.of(_fallbackPalette)),
    );
  }

  Future<void> _precacheThenUpdateDisplayImage(ImageModel image) async {
    final provider = imageProviderForImage(image);
    if (provider == null) {
      if (mounted) setState(() => _displayImageForColor = image);
      return;
    }
    try {
      await precacheImage(provider, context);
    } catch (_) {
      // Fallback: update anyway to avoid being stuck
    }
    if (!mounted) return;
    final bloc = context.read<ImageViewerBloc>();
    if (bloc.state.selectedImage?.uid == image.uid) {
      setState(() => _displayImageForColor = image);
    }
  }

  @override
  void dispose() {
    _blendedColorsNotifier.dispose();
    super.dispose();
  }

  void _onVisibleRatioChange(List<ImageModel> images, List<int> ratio) {
    _blendedColorsNotifier.value = _computeBlendedColors(images, ratio);
  }

  void _onPageChange(List<ImageModel> images, int page) {
    if (page >= images.length) return;
    final image = images[page];
    _blendedColorsNotifier.value = image.colorPalette.isNotEmpty
        ? _ensureMinColors(List.of(image.colorPalette))
        : _computeBlendedColors(images, List.filled(_slotCount, page));
    final bloc = context.read<ImageViewerBloc>();
    bloc.add(UpdateSelectedImage(image: image));

    // Stop TTS when switching images so highlight matches the visible content
    context.read<TtsCubit>().stop();

    // Prefetch when nearing end (2 pages from last); skip if already loading
    if (page == images.length - 2 &&
        bloc.state.loadingType == ViewerLoadingType.none) {
      bloc.add(const ImageViewerFetchRequested());
    }
  }

  _toggleExpandedView({required bool expanded}) {
    if (!expanded) {
      context.read<TtsCubit>().stop();
    }
    setState(() {
      _expandedView = expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: BlocConsumer<ImageViewerBloc, ImageViewerState>(
              buildWhen: (prev, curr) {
                return prev.visibleImages.length != curr.visibleImages.length ||
                    prev.selectedImage != curr.selectedImage ||
                    prev.errorType != curr.errorType;
              },
              listenWhen: (prev, curr) =>
                  prev.errorType != curr.errorType &&
                  curr.errorType != ViewerErrorType.none,
              listener: (context, state) {
                final hasNoVisibleImages = state.visibleImages.isEmpty;
                showCustomDialog(
                  context: context,
                  message: state.errorType.message,
                  onDismiss: () {
                    context.read<ImageViewerBloc>().add(const ErrorDismissed());
                    if (hasNoVisibleImages) {
                      context.read<ImageViewerBloc>().add(
                            const ImageViewerFetchRequested(
                              loadingType: ViewerLoadingType.manual,
                            ),
                          );
                    }
                  },
                );
              },
              builder: (context, state) {
                final isLoaded = state.visibleImages.isNotEmpty;
                final isLoading = state.loadingType != ViewerLoadingType.none;

                if (isLoaded) {
                  _lastImages = state.visibleImages;
                  _lastSelectedImage = state.selectedImage;
                  final newSelected = state.selectedImage;
                  if (newSelected != null &&
                      newSelected.uid != _displayImageForColor?.uid) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _precacheThenUpdateDisplayImage(newSelected);
                    });
                  }
                }

                final images = isLoaded
                    ? state.visibleImages
                    : (isLoading ? _lastImages : null);
                final selectedImage = isLoaded
                    ? state.selectedImage
                    : _lastSelectedImage;
                final canShowContent =
                    images != null &&
                    images.isNotEmpty &&
                    selectedImage != null &&
                    selectedImage.url.isNotEmpty;

                return CarouselControllerScope(
                  images: images,
                  selectedImage: selectedImage,
                  displayImageForColor: _displayImageForColor ?? selectedImage,
                  canShowContent: canShowContent,
                  blendedColorsNotifier: _blendedColorsNotifier,
                  isLoaded: isLoaded,
                  onVisibleRatioChange: _onVisibleRatioChange,
                  onPageChange: _onPageChange,
                  expandedView: _expandedView,
                  onExpanded: (expanded) =>
                      _toggleExpandedView(expanded: expanded),
                  onThemeToggle: widget.onThemeToggle,
                  onNextPage: () =>
                      context.read<ImageViewerBloc>().add(AnotherImageEvent()),
                  onShareTap: widget.onShareTap,
                );
              },
            ),
          ),
          if (kDebugMode) _BlocStateOverlay(),
        ],
      ),
    );
  }
}

/// Debug overlay showing current [ImageViewerBloc] state.
class _BlocStateOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: BlocBuilder<ImageViewerBloc, ImageViewerState>(
        buildWhen: (prev, curr) => true,
        builder: (context, state) {
          return Material(
            color: Colors.transparent,

            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('loading: ${state.loadingType.name}'),
                    Text('visible: ${state.visibleImages.length}'),
                    Text('fetched: ${state.fetchedImages.length}'),
                    Text(
                      'selected: ${state.selectedImage?.uid ?? "null"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('error: ${state.errorType.name}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

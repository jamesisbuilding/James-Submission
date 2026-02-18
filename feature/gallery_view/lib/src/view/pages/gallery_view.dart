import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_view/src/view/widgets/animated_cutout_overlay.dart';
import 'package:gallery_view/src/view/widgets/gallery_tile.dart';

/// Displays a swipe/keyboard navigable square image grid with a focused cutout.
class PhotoGallery extends StatefulWidget {
  const PhotoGallery({
    super.key,
    required this.imageUrls,
    required this.imageUids,
    required this.imagePalettes,
    required this.imageCollectedStates,
    this.initialIndex = 0,
    this.gridSize = 4,
    this.imageSize,
    this.gridSpacing = 12,
    this.onImageActivated,
    this.onSelectedIndexChanged,
  }) : assert(
         imageUrls.length == imageUids.length,
         'imageUrls and imageUids must have same length',
       ),
       assert(
         imageUrls.length == imagePalettes.length,
         'imageUrls and imagePalettes must have same length',
       ),
       assert(
         imageUrls.length == imageCollectedStates.length,
         'imageUrls and imageCollectedStates must have same length',
       );

  final List<String> imageUrls;
  final List<String> imageUids;
  final List<List<Color>> imagePalettes;
  final List<bool> imageCollectedStates;
  final int initialIndex;
  final int gridSize;
  final Size? imageSize;
  final double gridSpacing;
  final ValueChanged<int>? onImageActivated;
  final ValueChanged<int>? onSelectedIndexChanged;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  /// Flattened selected index in the square grid.
  late int _selectedIndex;

  /// Render list used by the grid (may repeat inputs if there are fewer URLs).
  late List<String> _gridImages;
  late List<String> _gridImageUids;
  late List<List<Color>> _gridImagePalettes;
  late List<bool> _gridImageCollectedStates;

  /// Latest move direction used to animate cutout axis.
  Offset _lastSwipeDir = Offset.zero;

  /// Runtime alignment delta between selected tile center and overlay center.
  Offset _cutoutCenterOffset = Offset.zero;

  /// Increments to force selected-tile scale animation restart each change.
  int _selectionScaleCycle = 0;

  /// Controls whether the next index change should skip movement tween.
  bool _skipNextOffsetTween = false;

  /// Duration for grid translation when moving selection.
  static const _swipeDuration = Duration(milliseconds: 180);

  /// Duration for per-tile scale/border/dim transitions.
  /// Set to zero so selected tile updates instantly.
  static const _selectionDuration = Duration.zero;

  /// Duration for selected image scale animation.
  static const _scaleDuration = Duration(milliseconds: 1500);

  /// Selected tile scale multiplier.
  static const _selectedImageScale = 1.2;

  /// Focus node to capture keyboard arrow events.
  final FocusNode _keyboardFocusNode = FocusNode();

  /// Key assigned to selected tile to measure its screen position.
  final GlobalKey _selectedTileKey = GlobalKey();

  /// Key assigned to overlay paint box to measure its screen position.
  final GlobalKey _overlayPaintKey = GlobalKey();

  /// Number of cells in a square grid.
  int get _imgCount => pow(widget.gridSize, 2).round();

  @override
  void initState() {
    super.initState();
    // Clamp incoming index so initial selection is always valid.
    _selectedIndex = widget.initialIndex.clamp(0, _imgCount - 1);
    // Build initial list that exactly fills the grid.
    _gridImages = _fillGridImages(widget.imageUrls, _imgCount);
    _gridImageUids = _fillGridImages(widget.imageUids, _imgCount);
    _gridImagePalettes = _fillGridPalettes(widget.imagePalettes, _imgCount);
    _gridImageCollectedStates = _fillGridBooleans(
      widget.imageCollectedStates,
      _imgCount,
    );
  }

  @override
  void didUpdateWidget(covariant PhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild grid if source images or grid dimensions changed.
    if (oldWidget.imageUrls != widget.imageUrls ||
        oldWidget.imageUids != widget.imageUids ||
        oldWidget.imagePalettes != widget.imagePalettes ||
        oldWidget.imageCollectedStates != widget.imageCollectedStates ||
        oldWidget.gridSize != widget.gridSize) {
      _gridImages = _fillGridImages(widget.imageUrls, _imgCount);
      _gridImageUids = _fillGridImages(widget.imageUids, _imgCount);
      _gridImagePalettes = _fillGridPalettes(widget.imagePalettes, _imgCount);
      _gridImageCollectedStates = _fillGridBooleans(
        widget.imageCollectedStates,
        _imgCount,
      );
      // Keep selection in-bounds after shape changes.
      _selectedIndex = _selectedIndex.clamp(0, _imgCount - 1);
    }
  }

  @override
  void dispose() {
    // Release focus resources.
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  /// Ensures we always have exactly [count] URLs to render.
  /// If there are fewer URLs, we repeat them to fill all slots.
  List<String> _fillGridImages(List<String> source, int count) {
    if (source.isEmpty) return <String>[];
    if (source.length >= count)
      return source.take(count).toList(growable: false);

    final filled = List<String>.of(source, growable: true);
    while (filled.length < count) {
      if (filled.length >= source.length) {
        filled.addAll(List.generate(count - filled.length, (index) => ''));
      } else {
        filled.addAll(source);
      }
    }
    return filled.take(count).toList(growable: false);
  }

  List<List<Color>> _fillGridPalettes(List<List<Color>> source, int count) {
    if (source.isEmpty) {
      return List<List<Color>>.generate(
        count,
        (_) => const <Color>[],
        growable: false,
      );
    }
    if (source.length >= count) {
      return source
          .take(count)
          .map((palette) => List<Color>.of(palette, growable: false))
          .toList(growable: false);
    }

    final filled = source
        .map((palette) => List<Color>.of(palette, growable: false))
        .toList(growable: true);
    while (filled.length < count) {
      if (filled.length >= source.length) {
        filled.addAll(
          List<List<Color>>.generate(
            count - filled.length,
            (_) => const <Color>[],
            growable: false,
          ),
        );
      } else {
        filled.addAll(
          source.map((palette) => List<Color>.of(palette, growable: false)),
        );
      }
    }
    return filled.take(count).toList(growable: false);
  }

  List<bool> _fillGridBooleans(List<bool> source, int count) {
    if (source.isEmpty) {
      return List<bool>.filled(count, false, growable: false);
    }
    if (source.length >= count) {
      return source.take(count).toList(growable: false);
    }

    final filled = List<bool>.of(source, growable: true);
    while (filled.length < count) {
      if (filled.length >= source.length) {
        filled.addAll(List<bool>.filled(count - filled.length, false));
      } else {
        filled.addAll(source);
      }
    }
    return filled.take(count).toList(growable: false);
  }

  /// Computes the translation that keeps current selected cell near center.
  Offset _calculateCurrentOffset(double spacing, Size size) {
    // Works for both odd and even grid sizes; for even grids this avoids a
    // half-tile bias that pushes selected items off true center.
    final halfCount = (widget.gridSize - 1) / 2;
    final paddedImageSize = Size(size.width + spacing, size.height + spacing);
    final originOffset = Offset(
      halfCount * paddedImageSize.width,
      halfCount * paddedImageSize.height,
    );
    final col = _selectedIndex % widget.gridSize;
    final row = (_selectedIndex / widget.gridSize).floor();
    final indexedOffset = Offset(
      -paddedImageSize.width * col,
      -paddedImageSize.height * row,
    );
    return originOffset + indexedOffset;
  }

  /// Converts index delta into a coarse direction vector for animation shaping.
  Offset _directionFromIndexDelta({required int from, required int to}) {
    if (to == from) return Offset.zero;
    final delta = to - from;
    if (delta.abs() >= widget.gridSize) {
      return Offset(0, delta.isNegative ? -1 : 1);
    }
    return Offset(delta.isNegative ? -1 : 1, 0);
  }

  void _setIndex(
    int value, {
    bool skipAnimation = false,
    Offset? transitionDirection,
  }) {
    // Guard invalid and no-op updates.
    if (value < 0 || value >= _imgCount) return;
    if (value == _selectedIndex) return;
    final inferredDirection = _directionFromIndexDelta(
      from: _selectedIndex,
      to: value,
    );
    _lastSwipeDir = transitionDirection ?? inferredDirection;
    _skipNextOffsetTween = skipAnimation;
    // Commit selection.
    setState(() {
      _selectedIndex = value;
      _selectionScaleCycle++;
    });
    debugPrint('Selected changed link: ${_gridImages[value]}');
    // Provide tactile feedback for every real image change.
    HapticFeedback.lightImpact();
    // Re-measure cutout alignment after frame is laid out.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncCutoutCenterOffset(),
    );
    widget.onSelectedIndexChanged?.call(value);
  }

  /// Measures selected tile and overlay centers, then stores the delta.
  /// Painter reads this to align the cutout with the selected image.
  void _syncCutoutCenterOffset() {
    final selectedContext = _selectedTileKey.currentContext;
    final overlayContext = _overlayPaintKey.currentContext;
    if (selectedContext == null || overlayContext == null || !mounted) return;

    final selectedBox = selectedContext.findRenderObject() as RenderBox?;
    final overlayBox = overlayContext.findRenderObject() as RenderBox?;
    if (selectedBox == null || overlayBox == null) return;

    final selectedCenterGlobal = selectedBox.localToGlobal(
      selectedBox.size.center(Offset.zero),
    );
    final overlayTopLeftGlobal = overlayBox.localToGlobal(Offset.zero);
    final overlayCenterGlobal =
        overlayTopLeftGlobal + overlayBox.size.center(Offset.zero);
    final nextOffset = selectedCenterGlobal - overlayCenterGlobal;

    // Ignore tiny floating-point noise.
    if ((nextOffset - _cutoutCenterOffset).distance > 0.5) {
      setState(() => _cutoutCenterOffset = nextOffset);
    }
  }

  /// Handles keyboard arrow navigation across the grid.
  bool _handleKeyDown(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;
    final keyActions = <LogicalKeyboardKey, int>{
      LogicalKeyboardKey.arrowUp: -widget.gridSize,
      LogicalKeyboardKey.arrowDown: widget.gridSize,
      LogicalKeyboardKey.arrowRight: 1,
      LogicalKeyboardKey.arrowLeft: -1,
    };

    final action = keyActions[key];
    if (action == null) return false;

    final current = _selectedIndex;
    final next = current + action;
    final isRightEdge = current % widget.gridSize == widget.gridSize - 1;
    final isLeftEdge = current % widget.gridSize == 0;
    final outOfBounds = next < 0 || next >= _imgCount;
    // Block wrap-around and out-of-range navigation.
    if ((isRightEdge && key == LogicalKeyboardKey.arrowRight) ||
        (isLeftEdge && key == LogicalKeyboardKey.arrowLeft) ||
        outOfBounds) {
      return false;
    }

    _setIndex(next);
    return true;
  }

  /// Handles swipe direction and maps it to next selected index.
  void _handleSwipe(Offset dragDelta) {
    var nextIndex = _selectedIndex;

    // Vertical swipe moves full rows; horizontal moves one column.
    if (dragDelta.dy.abs() > dragDelta.dx.abs()) {
      nextIndex += widget.gridSize * (dragDelta.dy > 0 ? -1 : 1);
      _lastSwipeDir = Offset(0, dragDelta.dy.sign);
    } else {
      nextIndex += (dragDelta.dx > 0 ? -1 : 1);
      _lastSwipeDir = Offset(dragDelta.dx.sign, 0);
    }

    // Keep movement inside bounds and prevent row wrapping.
    if (nextIndex < 0 || nextIndex >= _imgCount) return;
    if (_lastSwipeDir.dx < 0 && nextIndex % widget.gridSize == 0) return;
    if (_lastSwipeDir.dx > 0 &&
        nextIndex % widget.gridSize == widget.gridSize - 1)
      return;
    _setIndex(nextIndex, transitionDirection: _lastSwipeDir);
  }

  /// Tap selected tile => activate callback, otherwise just select it.
  void _handleImageTapped(int index) {
    if (_selectedIndex == index) {
      widget.onImageActivated?.call(index);
      return;
    }
    _setIndex(index);
  }

  Future<bool> _maybeCloseGallery() async {
    Navigator.of(context).pop(_selectedIndex);
    return true;
  }

  String? _heroTagForIndex(int index) {
    final uid = _gridImageUids[index];
    if (uid.isEmpty) return null;
    return 'gallery_hero_$uid';
  }

  @override
  Widget build(BuildContext context) {
    // While there are no image URLs, show loading indicator.
    if (_gridImages.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final media = MediaQuery.of(context);

    // Base tile sizing derives from viewport proportions.
    final baseSize = Size(media.size.width * 0.75, media.size.height * 0.75);
    // Caller can override tile size; we force square cells.
    final desiredSize = widget.imageSize ?? baseSize;
    final tileSide = min(desiredSize.width, desiredSize.height);
    final imgSize = Size.square(tileSide);

    // Grid tween offset for selection transitions.
    var gridOffset = _calculateCurrentOffset(widget.gridSpacing, imgSize);
    final offsetTweenDuration = _skipNextOffsetTween
        ? Duration.zero
        : _swipeDuration;
    // Cutout starts same size as selected tile.
    final overlayCutoutSize = imgSize;
    // Keep overlay hole aligned with selected tile center.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _syncCutoutCenterOffset(),
    );

    // Current visual tuning nudges entire gallery upward.
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _maybeCloseGallery();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Focus(
              focusNode: _keyboardFocusNode,
              autofocus: true,
              onKeyEvent: (_, event) => _handleKeyDown(event)
                  ? KeyEventResult.handled
                  : KeyEventResult.ignored,
              child: AnimatedCutoutOverlay(
                overlayPaintKey: _overlayPaintKey,
                animationKey: ValueKey(_selectedIndex),
                cutoutSize: overlayCutoutSize,
                cutoutCenterOffset: _cutoutCenterOffset,
                swipeDir: _lastSwipeDir,
                duration: offsetTweenDuration,
                opacity: .5,
                // OverflowBox permits grid to draw outside parent constraints.
                child: OverflowBox(
                  maxWidth:
                      widget.gridSize * imgSize.width +
                      widget.gridSpacing * (widget.gridSize),
                  maxHeight:
                      widget.gridSize * imgSize.height +
                      widget.gridSpacing * (widget.gridSize) +
                      200,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    // Swipe velocity drives index movement.
                    onPanEnd: (details) =>
                        _handleSwipe(details.velocity.pixelsPerSecond),
                    child: TweenAnimationBuilder<Offset>(
                      tween: Tween(begin: gridOffset, end: gridOffset),
                      duration: offsetTweenDuration,
                      curve: Curves.easeOut,
                      builder: (_, value, child) =>
                          // Translate entire grid toward selected tile.
                          Transform.translate(offset: value, child: child),
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: widget.gridSize,
                        childAspectRatio: 1,
                        mainAxisSpacing: widget.gridSpacing,
                        crossAxisSpacing: widget.gridSpacing,
                        children: List.generate(
                          _imgCount,
                          (i) => GalleryTile(
                            index: i,
                            selectedIndex: _selectedIndex,
                            imgUrl: _gridImages[i],
                            palette: _gridImagePalettes[i],
                            isPaletteCollected: _gridImageCollectedStates[i],
                            imgSize: imgSize,
                            heroTag: _heroTagForIndex(i),
                            selectionScaleCycle: _selectionScaleCycle,
                            selectionDuration: _selectionDuration,
                            scaleDuration: _scaleDuration,
                            selectedImageScale: _selectedImageScale,
                            selectedTileKey: _selectedTileKey,
                            onTap: _handleImageTapped,
                            onIncrease: () => _setIndex(_selectedIndex + 1),
                            onDecrease: () => _setIndex(_selectedIndex - 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              left: 24,
              child: CustomIconButton(
                onTap: _maybeCloseGallery,
                icon: Assets.icons.carousel.designImage(
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

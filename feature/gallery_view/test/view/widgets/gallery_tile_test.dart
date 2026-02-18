import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery_view/src/view/widgets/gallery_tile.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  GalleryTile buildTile({
    required bool isPaletteCollected,
    required String imgUrl,
    List<Color> palette = const [Colors.red, Colors.green, Colors.blue],
  }) {
    return GalleryTile(
      index: 0,
      selectedIndex: 0,
      imgUrl: imgUrl,
      palette: palette,
      isPaletteCollected: isPaletteCollected,
      imgSize: const Size.square(120),
      heroTag: null,
      selectionScaleCycle: 0,
      selectionDuration: Duration.zero,
      scaleDuration: Duration.zero,
      selectedImageScale: 1.2,
      selectedTileKey: GlobalKey(),
      onTap: (_) {},
      onIncrease: () {},
      onDecrease: () {},
    );
  }

  group('GalleryTile palette strip', () {
    testWidgets('shows collected swatches when collected', (tester) async {
      await tester.pumpWidget(
        wrap(buildTile(isPaletteCollected: true, imgUrl: 'https://a.jpg')),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const ValueKey('gallery_palette_container')), findsOneWidget);
      expect(
        find.byKey(ValueKey('gallery_palette_swatch_collected_${Colors.red.value}')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('gallery_palette_swatch_placeholder_0')),
        findsNothing,
      );
    });

    testWidgets('shows empty placeholders when not collected', (tester) async {
      await tester.pumpWidget(
        wrap(buildTile(isPaletteCollected: false, imgUrl: 'https://a.jpg')),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const ValueKey('gallery_palette_container')), findsOneWidget);
      expect(
        find.byKey(ValueKey('gallery_palette_swatch_collected_${Colors.red.value}')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('gallery_palette_swatch_placeholder_0')),
        findsOneWidget,
      );
    });

    testWidgets('hides palette strip when image url empty', (tester) async {
      await tester.pumpWidget(
        wrap(buildTile(isPaletteCollected: true, imgUrl: '')),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const ValueKey('gallery_palette_container')), findsNothing);
    });
  });
}

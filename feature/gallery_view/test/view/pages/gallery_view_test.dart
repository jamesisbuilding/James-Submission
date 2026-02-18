import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gallery_view/gallery_view.dart';

void main() {
  group('PhotoGallery', () {
    test('asserts when urls and uids lengths differ', () {
      expect(
        () => PhotoGallery(
          imageUrls: const ['a'],
          imageUids: const ['uid-a', 'uid-b'],
          imagePalettes: const [<Color>[]],
          imageCollectedStates: const [false],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('calls onSelectedIndexChanged when selecting new tile', (
      tester,
    ) async {
      int? selectedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoGallery(
            imageUrls: const ['https://a.jpg', 'https://b.jpg'],
            imageUids: const ['uid-a', 'uid-b'],
            imagePalettes: const [<Color>[], <Color>[]],
            imageCollectedStates: const [false, false],
            gridSize: 2,
            imageSize: const Size.square(120),
            initialIndex: 0,
            onSelectedIndexChanged: (value) => selectedIndex = value,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump(const Duration(milliseconds: 200));

      expect(selectedIndex, 1);
    });

    testWidgets('calls onImageActivated when tapping selected tile', (
      tester,
    ) async {
      int? activatedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoGallery(
            imageUrls: const ['https://a.jpg', 'https://b.jpg'],
            imageUids: const ['uid-a', 'uid-b'],
            imagePalettes: const [<Color>[], <Color>[]],
            imageCollectedStates: const [false, false],
            gridSize: 2,
            imageSize: const Size.square(120),
            initialIndex: 0,
            onImageActivated: (value) => activatedIndex = value,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final tiles = find.byType(TextButton);
      expect(tiles, findsNWidgets(4));
      await tester.tap(tiles.first);
      await tester.pump(const Duration(milliseconds: 200));

      expect(activatedIndex, 0);
    });
  });
}

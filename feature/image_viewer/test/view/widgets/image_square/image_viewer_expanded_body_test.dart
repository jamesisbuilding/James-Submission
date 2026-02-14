import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/cubit/cubit.dart';
import 'package:image_viewer/src/view/widgets/image_square/image_viewer.dart'
    as iv;
import 'package:image_viewer/src/view/widgets/image_square/image_viewer_body.dart';

import '../../../cubit/fakes/fake_tts_service.dart';
import '../../../data/fakes/fake_image_analysis_service.dart';

void main() {
  late TtsCubit ttsCubit;
  late FakeTtsService fakeTtsService;
  late CollectedColorsCubit collectedColorsCubit;
  late FavouritesCubit favouritesCubit;

  setUp(() {
    fakeTtsService = FakeTtsService();
    ttsCubit = TtsCubit(ttsService: fakeTtsService);
    collectedColorsCubit = CollectedColorsCubit();
    favouritesCubit = FavouritesCubit();
  });

  tearDown(() {
    ttsCubit.close();
    collectedColorsCubit.close();
    favouritesCubit.close();
    fakeTtsService.dispose();
  });

  ImageModel imageWithText(String uid, String title, String description) =>
      ImageModel(
        uid: uid,
        title: title,
        description: description,
        isFavourite: false,
        url: 'https://example.com/$uid',
        colorPalette: const [Color(0xFF000000)],
        localPath: '',
        pixelSignature: 'sig_$uid',
      );

  Widget buildTestHarness({required Widget child}) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TtsCubit>.value(value: ttsCubit),
          BlocProvider<CollectedColorsCubit>.value(value: collectedColorsCubit),
          BlocProvider<FavouritesCubit>.value(value: favouritesCubit),
        ],
        child: Scaffold(body: child),
      ),
    );
  }

  /// Collects all TextSpans with non-empty text from a RichText.
  List<TextSpan> collectWordSpans(InlineSpan root) {
    final spans = <TextSpan>[];
    void visit(InlineSpan span) {
      if (span is TextSpan) {
        if (span.text != null &&
            span.text!.isNotEmpty &&
            span.text != ' ' &&
            span.text != '"') {
          spans.add(span);
        }
        for (final c in span.children ?? <InlineSpan>[]) {
          visit(c);
        }
      }
    }

    visit(root);
    return spans;
  }

  group('ImageViewer expanded body', () {
    testWidgets('body only appears when expanded', (tester) async {
      final image = testImage('uid1', 'sig1');
      await tester.pumpWidget(
        buildTestHarness(
          child: iv.ImageViewer(
            image: image,
            selected: true,
            disabled: false,
            expanded: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ImageViewerBody), findsNothing);

      await tester.pumpWidget(
        buildTestHarness(
          child: iv.ImageViewer(
            image: image,
            selected: true,
            disabled: false,
            expanded: true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ImageViewerBody), findsOneWidget);
    });

    testWidgets('when currentWord is injected, one word span gets highlight '
        'style', (tester) async {
      final image =
          imageWithText('uid1', 'First Second Third', 'Alpha Beta');

      await tester.pumpWidget(
        buildTestHarness(
          child: ImageViewerBody(
            image: image,
            currentWord: (word: 'Second', isTitle: true, wordIndex: 1),
            visible: true,
            onColorsExpanded: (_) {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      expect(richTexts.length, greaterThanOrEqualTo(1));

      final titleRichText = richTexts.first;
      final wordSpans = collectWordSpans(titleRichText.text);
      expect(wordSpans.map((s) => s.text), containsAll(['First', 'Second', 'Third']));

      final highlightedSpans =
          wordSpans.where((s) => s.style?.backgroundColor != null).toList();
      expect(highlightedSpans.length, 1);
      expect(highlightedSpans.single.text, 'Second');
    });

    testWidgets('title vs description index mapping displays expected '
        'highlighted token', (tester) async {
      final image =
          imageWithText('uid1', 'Title A B', 'Desc X Y Z');
      await tester.pumpWidget(
        buildTestHarness(
          child: ImageViewerBody(
            image: image,
            currentWord: (word: 'A', isTitle: true, wordIndex: 1),
            visible: true,
            onColorsExpanded: (_) {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      var richTexts = tester.widgetList<RichText>(find.byType(RichText));
      var titleSpans = collectWordSpans(richTexts.first.text);
      var highlighted = titleSpans.where((s) => s.style?.backgroundColor != null);
      expect(highlighted.length, 1);
      expect(highlighted.single.text, 'A');

      await tester.pumpWidget(
        buildTestHarness(
          child: ImageViewerBody(
            image: image,
            currentWord: (word: 'X', isTitle: false, wordIndex: 1),
            visible: true,
            onColorsExpanded: (_) {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final descRichTexts =
          tester.widgetList<RichText>(find.byType(RichText)).toList();
      final descRichText =
          descRichTexts.length >= 2 ? descRichTexts[1] : descRichTexts.first;
      final descSpans = collectWordSpans(descRichText.text);
      final descHighlighted =
          descSpans.where((s) => s.style?.backgroundColor != null);
      expect(descHighlighted.length, 1);
      expect(descHighlighted.single.text, 'X');
    });
  });
}

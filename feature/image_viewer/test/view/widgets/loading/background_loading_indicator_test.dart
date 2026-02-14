import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/view/widgets/loading/background_loading_indicator.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/image_viewer_bloc_test_utils.dart';
import '../../../data/fakes/fake_image_analysis_service.dart';

void main() {
  late ImageViewerBloc imageViewerBloc;
  late MockImageRepository mockRepo;

  setUp(() {
    mockRepo = MockImageRepository();
    when(() => mockRepo.runImageRetrieval(
          count: any(named: 'count'),
          existingImages: any(named: 'existingImages'),
        )).thenAnswer((_) => Stream.empty());
    imageViewerBloc = ImageViewerBloc(imageRepository: mockRepo);
  });

  tearDown(() => imageViewerBloc.close());

  Widget buildTestHarness({
    required bool Function(ImageViewerState) visibleWhen,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: BlocProvider<ImageViewerBloc>.value(
        value: imageViewerBloc,
        child: Scaffold(
          body: BackgroundLoadingIndicator(visibleWhen: visibleWhen),
        ),
      ),
    );
  }

  double opacityOf(WidgetTester tester) {
    final animatedOpacity = tester.widget<AnimatedOpacity>(
      find.descendant(
        of: find.byType(BackgroundLoadingIndicator),
        matching: find.byType(AnimatedOpacity),
      ).first,
    );
    return animatedOpacity.opacity;
  }

  group('BackgroundLoadingIndicator visibility', () {
    testWidgets('carousel logic: visible when visibleImages.isEmpty',
        (tester) async {
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [],
        fetchedImages: [],
        selectedImage: null,
        loadingType: ViewerLoadingType.manual,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          visibleWhen: (state) => state.visibleImages.isEmpty,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 1.0);
    });

    testWidgets('carousel logic: not visible when visibleImages is non-empty',
        (tester) async {
      final image = testImage('uid1', 'sig1');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [image],
        fetchedImages: [],
        selectedImage: image,
        loadingType: ViewerLoadingType.none,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          visibleWhen: (state) => state.visibleImages.isEmpty,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 0.0);
    });

    testWidgets('carousel logic: not visible when expanded even if no images',
        (tester) async {
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [],
        fetchedImages: [],
        selectedImage: null,
        loadingType: ViewerLoadingType.manual,
      ));

      const expandedView = true;
      await tester.pumpWidget(
        buildTestHarness(
          visibleWhen: (state) =>
              state.visibleImages.isEmpty && !expandedView,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 0.0);
    });

    testWidgets('carousel logic: visible when loading and not expanded',
        (tester) async {
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [],
        fetchedImages: [],
        selectedImage: null,
        loadingType: ViewerLoadingType.background,
      ));

      const expandedView = false;
      await tester.pumpWidget(
        buildTestHarness(
          visibleWhen: (state) =>
              state.visibleImages.isEmpty && !expandedView,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 1.0);
    });

    testWidgets('control bar logic: visible when background loading and has images',
        (tester) async {
      final image = testImage('uid1', 'sig1');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [image],
        fetchedImages: [],
        selectedImage: image,
        loadingType: ViewerLoadingType.background,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          visibleWhen: (state) =>
              state.loadingType == ViewerLoadingType.background &&
              state.visibleImages.isNotEmpty,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 1.0);
    });

    testWidgets('control bar logic: not visible when manual loading',
        (tester) async {
      final image = testImage('uid1', 'sig1');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [image],
        fetchedImages: [],
        selectedImage: image,
        loadingType: ViewerLoadingType.manual,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          visibleWhen: (state) =>
              state.loadingType == ViewerLoadingType.background &&
              state.visibleImages.isNotEmpty,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 0.0);
    });

    testWidgets('control bar logic: not visible when no visible images',
        (tester) async {
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [],
        fetchedImages: [],
        selectedImage: null,
        loadingType: ViewerLoadingType.background,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          visibleWhen: (state) =>
              state.loadingType == ViewerLoadingType.background &&
              state.visibleImages.isNotEmpty,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(opacityOf(tester), 0.0);
    });
  });
}

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/view/widgets/control_bar/control_bar_main_button.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/image_viewer_bloc_test_utils.dart';
import '../../../cubit/fakes/fake_tts_service.dart';
import '../../../data/fakes/fake_image_analysis_service.dart';

void main() {
  late ImageViewerBloc imageViewerBloc;
  late TtsCubit ttsCubit;
  late FakeTtsService fakeTtsService;
  late MockImageRepository mockRepo;

  setUp(() {
    mockRepo = MockImageRepository();
    when(() => mockRepo.runImageRetrieval(
          count: any(named: 'count'),
          existingImages: any(named: 'existingImages'),
        )).thenAnswer((_) => Stream.empty());
    imageViewerBloc = ImageViewerBloc(imageRepository: mockRepo);
    fakeTtsService = FakeTtsService();
    ttsCubit = TtsCubit(ttsService: fakeTtsService);
  });

  tearDown(() {
    imageViewerBloc.close();
    ttsCubit.close();
    fakeTtsService.dispose();
  });

  Widget buildTestHarness({
    required Widget child,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ImageViewerBloc>.value(value: imageViewerBloc),
          BlocProvider<TtsCubit>.value(value: ttsCubit),
        ],
        child: Scaffold(body: child),
      ),
    );
  }

  group('ControlBarMainButton states', () {
    testWidgets('collapsed with prefetched: background shows fetchedImages.first',
        (tester) async {
      final selected = testImage('uid1', 'sig1');
      final prefetched = testImage('uid2', 'sig2');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [selected],
        fetchedImages: [prefetched],
        selectedImage: selected,
        loadingType: ViewerLoadingType.none,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          child: ControlBarMainButton(
            onAnotherTap: () {},
            mode: MainButtonMode.another,
            onPlayTapped: (_) {},
            carouselExpanded: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final mainButton = tester.widget<MainButton>(find.byType(MainButton));
      expect(mainButton.backgroundImageUrl, prefetched.url);
      expect(mainButton.mode, MainButtonMode.another);
      expect(mainButton.isLoading, false);
    });

    testWidgets('collapsed with no prefetched: background shows selectedImage',
        (tester) async {
      final selected = testImage('uid1', 'sig1');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [selected],
        fetchedImages: [],
        selectedImage: selected,
        loadingType: ViewerLoadingType.none,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          child: ControlBarMainButton(
            onAnotherTap: () {},
            mode: MainButtonMode.another,
            onPlayTapped: (_) {},
            carouselExpanded: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final mainButton = tester.widget<MainButton>(find.byType(MainButton));
      expect(mainButton.backgroundImageUrl, selected.url);
      expect(mainButton.mode, MainButtonMode.another);
      expect(mainButton.isLoading, false);
    });

    testWidgets('expanded: background shows selectedImage', (tester) async {
      final selected = testImage('uid1', 'sig1');
      final prefetched = testImage('uid2', 'sig2');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [selected],
        fetchedImages: [prefetched],
        selectedImage: selected,
        loadingType: ViewerLoadingType.none,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          child: ControlBarMainButton(
            onAnotherTap: () {},
            mode: MainButtonMode.audio,
            onPlayTapped: (_) {},
            carouselExpanded: true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final mainButton = tester.widget<MainButton>(find.byType(MainButton));
      expect(mainButton.backgroundImageUrl, selected.url);
      expect(mainButton.mode, MainButtonMode.audio);
    });

    testWidgets('manual loading collapsed: mode audio, isLoading true',
        (tester) async {
      final selected = testImage('uid1', 'sig1');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [selected],
        fetchedImages: [],
        selectedImage: selected,
        loadingType: ViewerLoadingType.manual,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          child: ControlBarMainButton(
            onAnotherTap: () {},
            mode: MainButtonMode.another,
            onPlayTapped: (_) {},
            carouselExpanded: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final mainButton = tester.widget<MainButton>(find.byType(MainButton));
      expect(mainButton.mode, MainButtonMode.audio);
      expect(mainButton.isLoading, true);
    });

    testWidgets('background loading collapsed: no loading shown', (tester) async {
      final selected = testImage('uid1', 'sig1');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [selected],
        fetchedImages: [],
        selectedImage: selected,
        loadingType: ViewerLoadingType.background,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          child: ControlBarMainButton(
            onAnotherTap: () {},
            mode: MainButtonMode.another,
            onPlayTapped: (_) {},
            carouselExpanded: false,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final mainButton = tester.widget<MainButton>(find.byType(MainButton));
      expect(mainButton.mode, MainButtonMode.another);
      expect(mainButton.isLoading, false);
    });

    testWidgets('displayImageForColor overrides colors', (tester) async {
      final selected = testImage('uid1', 'sig1');
      final displayForColor = testImage('uid2', 'sig2');
      imageViewerBloc.emit(ImageViewerState(
        visibleImages: [selected],
        fetchedImages: [],
        selectedImage: selected,
        loadingType: ViewerLoadingType.none,
      ));

      await tester.pumpWidget(
        buildTestHarness(
          child: ControlBarMainButton(
            onAnotherTap: () {},
            mode: MainButtonMode.another,
            onPlayTapped: (_) {},
            carouselExpanded: false,
            displayImageForColor: displayForColor,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final mainButton = tester.widget<MainButton>(find.byType(MainButton));
      expect(mainButton.backgroundColor, isNotNull);
      expect(mainButton.foregroundColor, isNotNull);
    });
  });
}


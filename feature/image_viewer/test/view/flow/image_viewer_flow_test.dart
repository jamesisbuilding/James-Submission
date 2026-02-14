import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/data/datasources/image_remote_datasource.dart';
import 'package:image_viewer/src/data/repositories/image_repository_impl.dart';
import 'package:image_viewer/src/domain/repositories/image_repository.dart';
import 'package:tts_service/tts_service.dart';

import '../../cubit/fakes/fake_tts_service.dart';
import '../../data/fakes/fake_image_analysis_service.dart';
import '../../data/fakes/fake_image_remote_datasource.dart';

const _testOverlayKey = Key('test_overlay');
const _bottomLayerKey = Key('test_bottom_layer');

void main() {
  late GetIt testGetIt;
  late FakeImageRemoteDatasource fakeDatasource;
  late FakeImageAnalysisService fakeAnalysisService;
  late FakeTtsService fakeTtsService;

  setUp(() {
    testGetIt = GetIt.asNewInstance();
    fakeDatasource = FakeImageRemoteDatasource(
      urlsToReturn: ['https://test.com/1', 'https://test.com/2', 'https://test.com/3'],
    );
    fakeAnalysisService = FakeImageAnalysisService(
      resultsToReturn: [
        Success(testImage('uid1', 'sig1')),
        Success(testImage('uid2', 'sig2')),
        Success(testImage('uid3', 'sig3')),
      ],
    );
    fakeTtsService = FakeTtsService();

    testGetIt.registerSingleton<ImageRemoteDatasource>(fakeDatasource);
    testGetIt.registerSingleton<ImageAnalysisService>(fakeAnalysisService);
    testGetIt.registerSingleton<AbstractTtsService>(fakeTtsService);
    testGetIt.registerLazySingleton<ImageRepository>(
      () => ImageRepositoryImpl(
        remoteDatasource: testGetIt<ImageRemoteDatasource>(),
        imageAnalysisService: testGetIt<ImageAnalysisService>(),
      ),
    );
    testGetIt.registerFactory<ImageViewerBloc>(
      () => ImageViewerBloc(imageRepository: testGetIt<ImageRepository>()),
    );
    testGetIt.registerFactory<TtsCubit>(
      () => TtsCubit(ttsService: testGetIt<AbstractTtsService>()),
    );
    testGetIt.registerFactory<FavouritesCubit>(() => FavouritesCubit());
    testGetIt.registerFactory<CollectedColorsCubit>(() => CollectedColorsCubit());
  });

  tearDown(() async {
    await testGetIt.reset();
    fakeTtsService.dispose();
  });

  Widget buildTestFlow({Widget Function(VoidCallback onVideoComplete)? overlayBuilder}) {
    return MaterialApp(
      home: ImageViewerFlow(
        getIt: testGetIt,
        onThemeToggle: () {},
        bottomLayer: ColoredBox(
          key: _bottomLayerKey,
          color: Colors.grey,
          child: const SizedBox.expand(),
        ),
        overlayBuilder: overlayBuilder ??
            (onComplete) => GestureDetector(
                  key: _testOverlayKey,
                  onTap: onComplete,
                  behavior: HitTestBehavior.opaque,
                  child: ColoredBox(
                    color: Colors.black,
                    child: const SizedBox.expand(),
                  ),
                ),
      ),
    );
  }

  group('ImageViewerFlow overlay transition', () {
    testWidgets('VideoView initially visible, blocks pointer', (tester) async {
      await tester.pumpWidget(buildTestFlow());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byKey(_testOverlayKey), findsOneWidget);

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(Transform),
          matching: find.byType(AnimatedOpacity),
        ).first,
      );
      expect(animatedOpacity.opacity, 1.0);

      final ignorePointer = tester.widget<IgnorePointer>(
        find.ancestor(
          of: find.byKey(_testOverlayKey),
          matching: find.byType(IgnorePointer),
        ).first,
      );
      expect(ignorePointer.ignoring, false);
    });

    testWidgets('after onVideoComplete, opacity animates to 0 and pointer is released',
        (tester) async {
      await tester.pumpWidget(buildTestFlow());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.byKey(_testOverlayKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.descendant(
          of: find.byType(Transform),
          matching: find.byType(AnimatedOpacity),
        ).first,
      );
      expect(animatedOpacity.opacity, 0.0);

      final ignorePointer = tester.widget<IgnorePointer>(
        find.ancestor(
          of: find.byKey(_testOverlayKey),
          matching: find.byType(IgnorePointer),
        ).first,
      );
      expect(ignorePointer.ignoring, true);
    });

    testWidgets('ImageViewerScreen is present underneath throughout', (tester) async {
      await tester.pumpWidget(buildTestFlow());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byKey(_bottomLayerKey), findsOneWidget);

      await tester.tap(find.byKey(_testOverlayKey));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));

      expect(find.byKey(_bottomLayerKey), findsOneWidget);
    });
  });
}

ImageModel testImage(String uid, String pixelSignature) => ImageModel(
      uid: uid,
      title: 't',
      description: 'd',
      isFavourite: false,
      url: 'https://example.com/$uid',
      colorPalette: const [Color(0xFF000000)],
      localPath: '',
      pixelSignature: pixelSignature,
    );

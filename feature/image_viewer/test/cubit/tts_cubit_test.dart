import 'dart:async' show unawaited;

import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:tts_service/tts_service.dart';

import 'fakes/fake_tts_service.dart';

void main() {
  late FakeTtsService fakeTtsService;
  late TtsCubit cubit;

  setUp(() {
    fakeTtsService = FakeTtsService();
    cubit = TtsCubit(ttsService: fakeTtsService);
  });

  tearDown(() {
    cubit.close();
    fakeTtsService.dispose();
  });

  group('TtsCubit transitions', () {
    test('play() emits loading -> playing', () async {
      final states = <TtsState>[];
      final sub = cubit.stream.listen(states.add);

      unawaited(cubit.play('Title', 'Description'));

      await Future<void>.delayed(Duration.zero);

      expect(states.length, greaterThanOrEqualTo(1));
      expect(states.first.isLoading, true);

      await Future<void>.delayed(Duration(milliseconds: 50));

      sub.cancel();

      final playingState = states.lastWhere(
        (s) => s.isPlaying,
        orElse: () => states.last,
      );
      expect(playingState.isLoading, false);
      expect(playingState.isPlaying, true);
    });

    test('onPlaybackComplete clears isPlaying/currentWord', () async {
      fakeTtsService.completeImmediately = false;

      final states = <TtsState>[];
      final sub = cubit.stream.listen(states.add);

      unawaited(cubit.play('Title', 'Description'));
      await Future<void>.delayed(Duration(milliseconds: 50));

      fakeTtsService.emitWord((word: 'hello', isTitle: true, wordIndex: 0));
      await Future<void>.delayed(Duration.zero);

      fakeTtsService.triggerPlaybackComplete();
      await Future<void>.delayed(Duration.zero);

      sub.cancel();

      final clearedState = states.last;
      expect(clearedState.isPlaying, false);
      expect(clearedState.currentWord, isNull);
    });

    test('stop() always clears state', () async {
      fakeTtsService.completeImmediately = false;

      unawaited(cubit.play('Title', 'Description'));
      await Future<void>.delayed(Duration(milliseconds: 50));

      await cubit.stop();

      expect(cubit.state.isLoading, false);
      expect(cubit.state.isPlaying, false);
      expect(cubit.state.currentWord, isNull);
    });

    test('exception in TTS service resets state and rethrows', () async {
      fakeTtsService.shouldThrow = true;

      await expectLater(
        cubit.play('Title', 'Description'),
        throwsA(isA<Exception>()),
      );

      expect(cubit.state.isLoading, false);
      expect(cubit.state.isPlaying, false);
      expect(cubit.state.currentWord, isNull);
    });
  });
}

import 'dart:async';

import 'package:tts_service/tts_service.dart';

/// Fake TTS service for testing TtsCubit.
/// Allows controlling when playback completes and simulating errors.
class FakeTtsService implements AbstractTtsService {
  FakeTtsService({
    this.shouldThrow = false,
    this.completeImmediately = false,
  });

  bool shouldThrow;
  bool completeImmediately;

  final _currentWordController = StreamController<TtsCurrentWord>.broadcast();
  @override
  Stream<TtsCurrentWord> get currentWordStream => _currentWordController.stream;

  @override
  bool isSpeaking = false;

  void Function()? _onPlaybackComplete;

  void Function()? get storedOnPlaybackComplete => _onPlaybackComplete;

  /// Triggers the stored onPlaybackComplete callback (simulates audio finishing).
  void triggerPlaybackComplete() {
    _onPlaybackComplete?.call();
    _onPlaybackComplete = null;
  }

  /// Emits a word to currentWordStream for testing word highlighting.
  void emitWord(TtsCurrentWord word) {
    _currentWordController.add(word);
  }

  @override
  Future<void> playTextToSpeech(
    String title,
    String description, {
    void Function()? onPlaybackComplete,
  }) async {
    _onPlaybackComplete = onPlaybackComplete;
    if (shouldThrow) {
      throw Exception('TTS service error');
    }
    if (completeImmediately) {
      onPlaybackComplete?.call();
    }
  }

  @override
  Future<void> stop() async {}

  void dispose() {
    _currentWordController.close();
  }
}

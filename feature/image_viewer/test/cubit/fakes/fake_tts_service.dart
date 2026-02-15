import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tts_service/tts_service.dart';

/// Fake TTS service for testing TtsCubit.
/// Allows controlling when playback completes and simulating errors.
class FakeTtsService implements AbstractTtsService {
  FakeTtsService({
    this.shouldThrow = false,
    this.completeImmediately = false,
    this.delayPlayReturn = false,
  });

  bool shouldThrow;
  bool completeImmediately;

  /// When true, playTextToSpeech blocks until [completePlayReturn] is called
  /// or [cancelWhen] completes (for cancel-during-load tests).
  bool delayPlayReturn;

  Completer<void>? _playReturnCompleter;

  /// Unblocks playTextToSpeech when [delayPlayReturn] is true.
  void completePlayReturn() {
    _playReturnCompleter?.complete();
    _playReturnCompleter = null;
  }

  final _currentWordController = StreamController<TtsCurrentWord>.broadcast();
  @override
  Stream<TtsCurrentWord> get currentWordStream => _currentWordController.stream;

  @override
  bool isSpeaking = false;

  VoidCallback? _onPlaybackComplete;

  VoidCallback? get storedOnPlaybackComplete => _onPlaybackComplete;

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
    VoidCallback? onPlaybackComplete,
    Future<void>? cancelWhen,
    bool Function()? isCancelled,
  }) async {
    _onPlaybackComplete = onPlaybackComplete;
    if (shouldThrow) {
      throw Exception('TTS service error');
    }
    if (delayPlayReturn) {
      _playReturnCompleter = Completer<void>();
      final futures = [_playReturnCompleter!.future];
      if (cancelWhen != null) futures.add(cancelWhen);
      await Future.any(futures);
      if (isCancelled?.call() ?? false) return;
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

import 'package:flutter/foundation.dart';
import 'package:tts_service/src/models/tts_current_word.dart';

/// Abstract interface for text-to-speech playback.
/// Allows dependency injection and testing.
abstract class AbstractTtsService {
  /// Plays [title] and [description] as speech. Returns when playback has started.
  /// [onPlaybackComplete] is called when audio finishes naturally (not on stop).
  /// When [cancelWhen] completes, the API request is aborted. [isCancelled] is checked
  /// before loading/playing—when it returns true, the operation aborts.
  Future<void> playTextToSpeech(
    String title,
    String description, {
    VoidCallback? onPlaybackComplete,
    Future<void>? cancelWhen,
    bool Function()? isCancelled,
  });

  Future<void> stop();

  bool get isSpeaking;

  /// Emits (word index, word) as playback progresses.
  /// Only emits when the current word changes. Broadcast stream.
  Stream<TtsCurrentWord> get currentWordStream;
}

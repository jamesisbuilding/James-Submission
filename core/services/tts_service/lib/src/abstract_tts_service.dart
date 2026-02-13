import 'package:tts_service/src/models/tts_current_word.dart';

/// Abstract interface for text-to-speech playback.
/// Allows dependency injection and testing.
abstract class AbstractTtsService {
  /// Plays [title] and [description] as speech. Returns when playback has started.
  /// [onPlaybackComplete] is called when audio finishes naturally (not on stop).
  Future<void> playTextToSpeech(
    String title,
    String description, {
    void Function()? onPlaybackComplete,
  });

  Future<void> stop();

  bool get isSpeaking;

  /// Emits (word index, word) as playback progresses.
  /// Only emits when the current word changes. Broadcast stream.
  Stream<TtsCurrentWord> get currentWordStream;
}

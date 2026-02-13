/// Abstract interface for text-to-speech playback.
/// Allows dependency injection and testing.
abstract class AbstractTtsService {
  /// Plays [text] as speech. Returns when playback has started.
  /// [onPlaybackComplete] is called when audio finishes naturally (not on stop).
  Future<void> playTextToSpeech(
    String text, {
    void Function()? onPlaybackComplete,
  });

  Future<void> stop();

  bool get isSpeaking;
}

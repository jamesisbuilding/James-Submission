import 'package:equatable/equatable.dart';
import 'package:tts_service/tts_service.dart';

/// TTS playback state for the image viewer audio button.
class TtsState extends Equatable {
  const TtsState({
    this.isLoading = false,
    this.isPlaying = false,
    this.currentWord,
  });

  final bool isLoading;
  final bool isPlaying;
  final TtsCurrentWord? currentWord;

  @override
  List<Object?> get props => [isLoading, isPlaying, currentWord];

  TtsState copyWith({
    bool? isLoading,
    bool? isPlaying,
    TtsCurrentWord? currentWord,
    bool nullifyCurrentWord = false,
  }) =>
      TtsState(
        isLoading: isLoading ?? this.isLoading,
        isPlaying: isPlaying ?? this.isPlaying,
        currentWord:
            nullifyCurrentWord ? null : (currentWord ?? this.currentWord),
      );
}

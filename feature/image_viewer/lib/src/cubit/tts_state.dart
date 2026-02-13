import 'package:equatable/equatable.dart';

/// TTS playback state for the image viewer audio button.
class TtsState extends Equatable {
  const TtsState({
    this.isLoading = false,
    this.isPlaying = false,
  });

  final bool isLoading;
  final bool isPlaying;

  @override
  List<Object?> get props => [isLoading, isPlaying];

  TtsState copyWith({bool? isLoading, bool? isPlaying}) =>
      TtsState(
        isLoading: isLoading ?? this.isLoading,
        isPlaying: isPlaying ?? this.isPlaying,
      );
}

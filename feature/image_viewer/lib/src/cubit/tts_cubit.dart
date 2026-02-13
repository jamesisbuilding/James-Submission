import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tts_service/tts_service.dart';

import 'tts_state.dart';

/// Manages TTS playback state for the image viewer audio button.
/// Separate from [ImageViewerBloc] for single responsibility.
class TtsCubit extends Cubit<TtsState> {
  TtsCubit({required AbstractTtsService ttsService})
      : _ttsService = ttsService,
        super(const TtsState());

  final AbstractTtsService _ttsService;

  Future<void> play(String text) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _ttsService.playTextToSpeech(
        text,
        onPlaybackComplete: () {
          if (!isClosed) {
            emit(state.copyWith(isLoading: false, isPlaying: false));
          }
        },
      );
      emit(state.copyWith(isLoading: false, isPlaying: true));
    } catch (_) {
      emit(state.copyWith(isLoading: false, isPlaying: false));
      rethrow;
    }
  }

  Future<void> stop() async {
    await _ttsService.stop();
    emit(state.copyWith(isLoading: false, isPlaying: false));
  }
}

import 'dart:async';

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
  StreamSubscription<TtsCurrentWord>? _wordSubscription;

  Future<void> play(String title, String description) async {
    _wordSubscription?.cancel();
    _wordSubscription = null;
    emit(state.copyWith(isLoading: true, nullifyCurrentWord: true));

    await _ttsService.stop();

    _wordSubscription = _ttsService.currentWordStream.listen((w) {
      if (!isClosed) emit(state.copyWith(currentWord: w));
    });
    try {
      await _ttsService.playTextToSpeech(
        title,
        description,
        onPlaybackComplete: () {
          if (!isClosed) {
            _wordSubscription?.cancel();
            _wordSubscription = null;
            emit(state.copyWith(
              isLoading: false,
              isPlaying: false,
              nullifyCurrentWord: true,
            ));
          }
        },
      );
      emit(state.copyWith(isLoading: false, isPlaying: true));
    } catch (_) {
      _wordSubscription?.cancel();
      _wordSubscription = null;
      emit(state.copyWith(
        isLoading: false,
        isPlaying: false,
        nullifyCurrentWord: true,
      ));
      rethrow;
    }
  }

  Future<void> stop() async {
    _wordSubscription?.cancel();
    _wordSubscription = null;
    emit(state.copyWith(
      isLoading: false,
      isPlaying: false,
      nullifyCurrentWord: true,
    ));
    await _ttsService.stop();
  }
}

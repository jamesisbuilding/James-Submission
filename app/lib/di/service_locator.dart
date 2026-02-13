import 'package:aurora_test/env/env.dart';
import 'package:aurora_test/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:share_service/share_service.dart';
import 'package:tts_service/tts_service.dart';

final GetIt _sl = GetIt.instance;

GetIt get serviceLocator => _sl;

/// Initializes all dependencies. Call before [runApp].
Future<void> configureDependencies() async {
  // Image analysis: switch pipelineType between gemini and chatGpt
  registerImageAnalysisModule(
    _sl,
    pipelineType: ImageAnalysisPipelineType.chatGpt, // or .gemini
    openaiApiKey: Env.openaiApiKey,
  );
  // Initialize pipeline (OpenAI client etc) before first use
  await _sl.get<AbstractImageAnalysisPipeline>().initialize();

  // TTS – key from app/.env
  _sl.registerLazySingleton<AbstractTtsService>(
    () => TtsAudioGenerationService(apiKey: Env.elevenLabsApiKey),
  );

  // Share
  _sl.registerLazySingleton<AbstractShareService>(
    () => ShareServiceImpl(),
  );

  // Image viewer: feature owns its blocs; app has no knowledge of them
  registerImageViewerModule(_sl);

  _sl.registerLazySingleton<ThemeNotifier>(
    () => ThemeNotifier(initialMode: ThemeMode.dark),
  );
}

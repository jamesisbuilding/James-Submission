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
/// Override pipeline via dart-define: flutter run -d IMAGE_ANALYSIS_PIPELINE=gemini
Future<void> configureDependencies() async {
  final pipelineEnv = String.fromEnvironment('IMAGE_ANALYSIS_PIPELINE', defaultValue: 'chatGpt');
  final pipelineType = switch (pipelineEnv.toLowerCase()) {
    'gemini' => ImageAnalysisPipelineType.gemini,
    _ => ImageAnalysisPipelineType.chatGpt,
  };
  registerImageAnalysisModule(
    _sl,
    pipelineType: pipelineType,
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

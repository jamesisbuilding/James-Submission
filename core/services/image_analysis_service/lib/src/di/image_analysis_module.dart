import 'package:get_it/get_it.dart';
import 'package:image_analysis_service/image_analysis_service.dart';

/// Pipeline backend for image captioning.
enum ImageAnalysisPipelineType {
  gemini,
  chatGpt,
}

/// Registers image analysis services with [GetIt].
/// Call from app's service locator setup.
/// Switch [pipelineType] to choose Gemini or ChatGPT.
void registerImageAnalysisModule(
  GetIt getIt, {
  ImageAnalysisPipelineType pipelineType = ImageAnalysisPipelineType.chatGpt,
  String? openaiApiKey,
  AbstractImageAnalysisPipeline? pipeline,
}) {
  getIt.registerLazySingleton<AbstractImageAnalysisPipeline>(
    () {
      if (pipeline != null) return pipeline;
      return switch (pipelineType) {
        ImageAnalysisPipelineType.gemini => GeminiImageAnalysisPipeline(),
        ImageAnalysisPipelineType.chatGpt => ChatGptImageAnalysisPipeline(
            apiKey: openaiApiKey?.trim().isNotEmpty == true
                ? openaiApiKey!.trim()
                : null,
          ),
      };
    },
  );

  getIt.registerLazySingleton<ImageAnalysisService>(
    () => ImageAnalysisService(pipeline: getIt<AbstractImageAnalysisPipeline>()),
  );
}

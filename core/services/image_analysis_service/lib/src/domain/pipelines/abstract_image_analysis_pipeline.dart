import 'dart:typed_data';

import 'package:image_analysis_service/src/domain/models/image_caption_result.dart';

/// Abstract contract for AI-powered image captioning (title + description).
/// Implement with [GeminiImageAnalysisPipeline] or [ChatGptImageAnalysisPipeline].
abstract interface class AbstractImageAnalysisPipeline {
  /// Optional setup (e.g. API keys, client init). Call before first [analyzeImage].
  Future<void> initialize();

  /// Analyzes the image and returns a structured title and description.
  /// [imagePath] is used for MIME type detection; [imageBytes] are the raw bytes.
  Future<ImageCaptionResult> analyzeImage({
    required String imagePath,
    required Uint8List imageBytes,
  });
}

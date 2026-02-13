import 'package:image_analysis_service/image_analysis_service.dart';

/// Repository contract for fetching images.
abstract interface class ImageRepository {
  /// Streams images as they arrive. Yields each successful image;
  /// completes when [count] reached or retries exhausted.
  /// Throws if no images after retries.
  /// [existingImages] are used for duplicate URL and pixel-hash checks.
  Stream<ImageModel> runImageRetrieval({
    int count = 1,
    List<ImageModel> existingImages = const [],
  });
}

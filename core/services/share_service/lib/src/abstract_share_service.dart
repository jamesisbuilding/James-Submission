/// Abstract interface for sharing content.
/// Allows dependency injection and testing.
abstract class AbstractShareService {
  /// Shares an image with a description and app tagline.
  ///
  /// Prefers [imagePath] if the file exists; otherwise uses [imageBytes].
  /// [description] and [title] are combined with the tagline "I sent this from Imgo!".
  Future<void> shareImageWithDescription({
    required String description,
    String? title,
    String? imagePath,
    List<int>? imageBytes,
  });
}

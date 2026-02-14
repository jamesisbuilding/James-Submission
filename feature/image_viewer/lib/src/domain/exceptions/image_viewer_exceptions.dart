/// Thrown when too many sequential duplicates prevent fetching more images.
class NoMoreImagesException implements Exception {
  NoMoreImagesException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'NoMoreImagesException';
}

/// Thrown when all image fetch attempts fail after retries.
class ImageFetchFailedException implements Exception {
  ImageFetchFailedException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'ImageFetchFailedException';
}

/// Thrown when too many sequential duplicates prevent fetching more images.
class NoMoreImagesException implements Exception {
  NoMoreImagesException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'NoMoreImagesException';
}

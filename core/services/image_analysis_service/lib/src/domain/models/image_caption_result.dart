/// Result of AI-generated image captioning (title + description).
class ImageCaptionResult {
  const ImageCaptionResult({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  Map<String, dynamic> toMap() => {'title': title, 'description': description};
}

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_analysis_service/image_analysis_service.dart';

typedef ImageViewerShareTapCallback =
    void Function(ImageModel? image, {Uint8List? screenshotBytes});

typedef OpenGalleryRouteCallback =
    Future<int?> Function(
      BuildContext context, {
      required List<String> imageUrls,
      required List<String> imageUids,
      required List<List<Color>> imagePalettes,
      required List<bool> imageCollectedStates,
      required int initialIndex,
    });

class ImageViewerAppServices {
  const ImageViewerAppServices({
    required this.onThemeToggle,
    this.onShareTap,
    this.onOpenGalleryRoute,
  });

  final VoidCallback onThemeToggle;
  final ImageViewerShareTapCallback? onShareTap;
  final OpenGalleryRouteCallback? onOpenGalleryRoute;
}

void registerImageViewerAppServices(
  GetIt getIt, {
  required VoidCallback onThemeToggle,
  ImageViewerShareTapCallback? onShareTap,
  OpenGalleryRouteCallback? onOpenGalleryRoute,
}) {
  if (getIt.isRegistered<ImageViewerAppServices>()) {
    getIt.unregister<ImageViewerAppServices>();
  }
  getIt.registerLazySingleton<ImageViewerAppServices>(
    () => ImageViewerAppServices(
      onThemeToggle: onThemeToggle,
      onShareTap: onShareTap,
      onOpenGalleryRoute: onOpenGalleryRoute,
    ),
  );
}

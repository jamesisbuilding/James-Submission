import 'package:aurora_test/di/service_locator.dart';
import 'package:aurora_test/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:gallery_view/gallery_view.dart';
import 'package:go_router/go_router.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:share_service/share_service.dart';

/// App-level route paths.
abstract final class AppRoutes {
  static const String imageViewer = '/image-viewer';
  static const String gallery = '/gallery';
}

class _GalleryRouteArgs {
  const _GalleryRouteArgs({
    required this.imageUrls,
    required this.imageUids,
    required this.imagePalettes,
    required this.imageCollectedStates,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final List<String> imageUids;
  final List<List<Color>> imagePalettes;
  final List<bool> imageCollectedStates;
  final int initialIndex;
}

/// GoRouter configuration for app-level imperative navigation.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.imageViewer,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) => child,
      routes: [
        GoRoute(
          path: AppRoutes.imageViewer,
          builder: (context, state) {
            registerImageViewerAppServices(
              serviceLocator,
              onThemeToggle: serviceLocator.get<ThemeNotifier>().toggle,
              onOpenGalleryRoute: (
                context, {
                required imageUrls,
                required imageUids,
                required imagePalettes,
                required imageCollectedStates,
                required initialIndex,
              }) {
                return context.push<int>(
                  AppRoutes.gallery,
                  extra: _GalleryRouteArgs(
                    imageUrls: imageUrls,
                    imageUids: imageUids,
                    imagePalettes: imagePalettes,
                    imageCollectedStates: imageCollectedStates,
                    initialIndex: initialIndex,
                  ),
                );
              },
              onShareTap: (image, {screenshotBytes}) {
                if (image == null) return;
                final isScreenshot = screenshotBytes != null;
                serviceLocator
                    .get<AbstractShareService>()
                    .shareImageWithDescription(
                      description: isScreenshot ? '' : image.description,
                      title: isScreenshot ? null : image.title,
                      imagePath: screenshotBytes != null
                          ? null
                          : (image.localPath.isNotEmpty ? image.localPath : null),
                      imageBytes: screenshotBytes != null
                          ? screenshotBytes.toList()
                          : image.byteList?.toList(),
                      imageMimeType: screenshotBytes != null ? 'image/png' : null,
                    );
              },
            );
            return ImageViewerFlow(getIt: serviceLocator);
          },
        ),
        GoRoute(
          path: AppRoutes.gallery,
          pageBuilder: (context, state) {
            final args = state.extra as _GalleryRouteArgs?;
            if (args == null) {
              return const MaterialPage<void>(
                child: Scaffold(
                  body: Center(child: Text('Missing gallery route args')),
                ),
              );
            }
            return CustomTransitionPage<void>(
              key: state.pageKey,
              transitionDuration: const Duration(milliseconds: 300),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              child: PhotoGallery(
                imageUrls: args.imageUrls,
                imageUids: args.imageUids,
                imagePalettes: args.imagePalettes,
                imageCollectedStates: args.imageCollectedStates,
                initialIndex: args.initialIndex,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: child,
              ),
            );
          },
        ),
      ],
    ),
  ],
);

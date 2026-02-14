import 'package:aurora_test/di/service_locator.dart';
import 'package:aurora_test/theme/theme_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:share_service/share_service.dart';

/// App-level route paths.
abstract final class AppRoutes {
  static const String imageViewer = '/image-viewer';
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
            final onThemeToggle =
                serviceLocator.get<ThemeNotifier>().toggle;
            return ImageViewerFlow(
              getIt: serviceLocator,
              onThemeToggle: onThemeToggle,
              onShareTap: (image, {screenshotBytes}) {
                if (image != null) {
                  final isScreenshot = screenshotBytes != null;
                  serviceLocator
                      .get<AbstractShareService>()
                      .shareImageWithDescription(
                        description:
                            isScreenshot ? '' : image.description,
                        title: isScreenshot ? null : image.title,
                        imagePath: screenshotBytes != null
                            ? null
                            : (image.localPath.isNotEmpty
                                ? image.localPath
                                : null),
                        imageBytes: screenshotBytes != null
                            ? screenshotBytes.toList()
                            : image.byteList?.toList(),
                        imageMimeType: screenshotBytes != null
                            ? 'image/png'
                            : null,
                      );
                }
              },
            );
          },
        ),
      ],
    ),
  ],
);

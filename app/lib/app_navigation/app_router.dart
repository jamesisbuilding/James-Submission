import 'package:aurora_test/di/service_locator.dart';
import 'package:aurora_test/theme/theme_notifier.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) =>
                      serviceLocator.get<ImageViewerBloc>()
                        ..add(const ImageViewerFetchRequested()),
                ),
                BlocProvider(
                  create: (_) => serviceLocator.get<TtsCubit>(),
                ),
                BlocProvider(
                  create: (_) => serviceLocator.get<FavouritesCubit>(),
                ),
              ],
              child: ImageViewerFlow(
                onThemeToggle: onThemeToggle,
                onShareTap: (image) {
                  if (image != null) {
                    serviceLocator
                        .get<AbstractShareService>()
                        .shareImageWithDescription(
                          description: image.description,
                          title: image.title,
                          imagePath: image.localPath.isNotEmpty
                              ? image.localPath
                              : null,
                          imageBytes: image.byteList?.toList(),
                        );
                  }
                },
              ),
            );
          },
        ),
      ],
    ),
  ],
);

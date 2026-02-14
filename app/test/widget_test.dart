import 'package:aurora_test/di/service_locator.dart';
import 'package:aurora_test/theme/theme_notifier.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Smoke test for app DI and theme. Avoids full MyApp/ImageViewerFlow so we don't
/// pull in video_player (no platform impl in test env).
void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await configureDependencies();
  });

  testWidgets('DI smoke test – ThemeNotifier and themes build', (WidgetTester tester) async {
    final themeNotifier = serviceLocator.get<ThemeNotifier>();
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: themeNotifier,
        builder: (context, _) => MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: const Scaffold(body: Center(child: Text('IMGO'))),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('IMGO'), findsOneWidget);
  });
}

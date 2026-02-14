import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/src/view/widgets/alerts/custom_dialog.dart';

void main() {
  testWidgets('showCustomDialog shows dialog and onDismiss is called on tap',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(() => tester.view.resetPhysicalSize());
    var dismissed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                showCustomDialog(
                  context: context,
                  message: 'Test message',
                  onDismiss: () => dismissed = true,
                );
              },
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('Test message'), findsOneWidget);

    final okayButton = find.text('OK');
    expect(okayButton, findsOneWidget);
    await tester.tap(okayButton);
    await tester.pumpAndSettle();

    expect(dismissed, true);
  });
}

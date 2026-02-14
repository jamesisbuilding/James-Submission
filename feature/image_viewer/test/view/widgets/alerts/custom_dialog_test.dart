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
                  icon: const Icon(Icons.warning),
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
    expect(find.byType(AlertDialog), findsOneWidget);

    final okayButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(MainButton),
    );
    expect(okayButton, findsOneWidget);
    final center = tester.getCenter(okayButton);
    await tester.tapAt(center);
    await tester.pumpAndSettle();

    expect(dismissed, true);
  });
}

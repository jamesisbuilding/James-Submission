import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/src/view/widgets/collected_colors/collected_colors_sheet.dart';
import 'package:image_viewer/src/view/widgets/notch.dart';

void main() {
  Widget buildTestHarness({required Map<String, List<Color>> collected}) {
    return MaterialApp(
      theme: lightTheme,
      home: Scaffold(
        body: CollectedColorsSheet(collected: collected),
      ),
    );
  }

  group('CollectedColorsSheet', () {
    testWidgets('shows my colours title', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(collected: {'uid1': [Colors.red, Colors.blue]}),
      );
      await tester.pumpAndSettle();

      expect(find.text('my colours'), findsOneWidget);
    });

    testWidgets('shows DraggableNotch at top', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(collected: {'uid1': [Colors.red]}),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DraggableNotch), findsOneWidget);
    });

    testWidgets('shows empty state when no colours collected', (tester) async {
      await tester.pumpWidget(buildTestHarness(collected: {}));
      await tester.pumpAndSettle();

      expect(find.text('No colours collected yet'), findsOneWidget);
    });

    testWidgets('shows empty state when collected has no entries', (tester) async {
      await tester.pumpWidget(buildTestHarness(collected: {}));
      await tester.pumpAndSettle();

      expect(find.text('No colours collected yet'), findsOneWidget);
    });

    testWidgets('shows palette rows when colours collected', (tester) async {
      final collected = {
        'uid1': [Colors.red, Colors.blue, Colors.green],
        'uid2': [Colors.yellow, Colors.orange],
      };
      await tester.pumpWidget(buildTestHarness(collected: collected));
      await tester.pumpAndSettle();

      expect(find.text('No colours collected yet'), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/view/widgets/collected_colors/collected_colors_button.dart';
import 'package:image_viewer/src/view/widgets/collected_colors/collected_colors_sheet.dart';

void main() {
  late CollectedColorsCubit collectedColorsCubit;

  setUp(() {
    collectedColorsCubit = CollectedColorsCubit();
  });

  tearDown(() => collectedColorsCubit.close());

  Widget buildTestHarness({required Widget child}) {
    return MaterialApp(
      theme: lightTheme,
      home: BlocProvider<CollectedColorsCubit>.value(
        value: collectedColorsCubit,
        child: Scaffold(body: child),
      ),
    );
  }

  group('CollectedColorsButton', () {
    testWidgets('is hidden when collected is empty', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(child: const CollectedColorsButton()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsNothing);
      expect(find.byType(CollectedColorsButton), findsOneWidget);
    });

    testWidgets('is visible when collected has colors', (tester) async {
      collectedColorsCubit.add('uid1', [Colors.red, Colors.blue, Colors.green]);
      await tester.pumpWidget(
        buildTestHarness(child: const CollectedColorsButton()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(CollectedColorsButton), findsOneWidget);
    });

    testWidgets('tap opens collected colours sheet', (tester) async {
      collectedColorsCubit.add('uid1', [Colors.red, Colors.blue]);
      await tester.pumpWidget(
        buildTestHarness(child: const CollectedColorsButton()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(CollectedColorsSheet), findsOneWidget);
    });

    testWidgets('becomes visible when colors added after empty', (tester) async {
      await tester.pumpWidget(
        buildTestHarness(child: const CollectedColorsButton()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GestureDetector), findsNothing);

      collectedColorsCubit.add('uid1', [Colors.red]);
      await tester.pumpAndSettle();
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });
}

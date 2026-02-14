import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/src/view/widgets/gyro/gyro_parallax_card.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() {
  group('GyroParallaxCard', () {
    testWidgets('renders child when disabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GyroParallaxCard(
              enabled: false,
              child: SizedBox(key: Key('child'), height: 100, width: 100),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('renders child when enabled without gyro stream (non-mobile)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GyroParallaxCard(
              enabled: true,
              child: SizedBox(key: Key('child'), height: 100, width: 100),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);
    });

    testWidgets('applies Transform when enabled with gyro stream',
        (WidgetTester tester) async {
      final controller = StreamController<GyroscopeEvent>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GyroParallaxCard(
              enabled: true,
              gyroscopeStream: controller.stream,
              child: const SizedBox(
                key: Key('child'),
                height: 100,
                width: 100,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('child')), findsOneWidget);
      final gyroTransform = find.descendant(
        of: find.byType(GyroParallaxCard),
        matching: find.byType(Transform),
      );
      expect(gyroTransform, findsOneWidget);

      controller.add(GyroscopeEvent(0.1, 0.1, 0, DateTime.now()));
      await tester.pump();
      expect(gyroTransform, findsOneWidget);

      await controller.close();
    });

    testWidgets('stops applying Transform when disabled mid-stream',
        (WidgetTester tester) async {
      final controller = StreamController<GyroscopeEvent>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GyroParallaxCard(
              enabled: true,
              gyroscopeStream: controller.stream,
              child: const SizedBox(key: Key('child'), height: 100, width: 100),
            ),
          ),
        ),
      );

      controller.add(GyroscopeEvent(0.5, 0.5, 0, DateTime.now()));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(GyroParallaxCard),
          matching: find.byType(Transform),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GyroParallaxCard(
              enabled: false,
              gyroscopeStream: controller.stream,
              child: const SizedBox(key: Key('child'), height: 100, width: 100),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(GyroParallaxCard),
          matching: find.byType(Transform),
        ),
        findsNothing,
      );
      expect(find.byKey(const Key('child')), findsOneWidget);

      await controller.close();
    });

    testWidgets('disposes without error', (WidgetTester tester) async {
      final controller = StreamController<GyroscopeEvent>.broadcast();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GyroParallaxCard(
              enabled: true,
              gyroscopeStream: controller.stream,
              child: const SizedBox(height: 100, width: 100),
            ),
          ),
        ),
      );

      controller.add(GyroscopeEvent(0.1, 0.1, 0, DateTime.now()));
      await tester.pump();

      await tester.pumpWidget(const SizedBox());
      await controller.close();
    });
  });
}

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/view/widgets/control_bar/favourite_button.dart';

import '../../../data/fakes/fake_image_analysis_service.dart';

void main() {
  late FavouritesCubit favouritesCubit;

  setUp(() {
    favouritesCubit = FavouritesCubit();
  });

  tearDown(() => favouritesCubit.close());

  Widget buildTestHarness({
    required Widget child,
  }) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: BlocProvider<FavouritesCubit>.value(
        value: favouritesCubit,
        child: Scaffold(
          body: child,
        ),
      ),
    );
  }

  ImageModel image(String uid) => testImage(uid, 'sig_$uid');

  group('FavouriteStarButton', () {
    testWidgets('tapping star toggles state', (tester) async {
      final img = image('uid1');
      await tester.pumpWidget(
        buildTestHarness(
          child: FavouriteStarButton(selectedImage: img),
        ),
      );
      await tester.pumpAndSettle();

      expect(favouritesCubit.state, isEmpty);

      await tester.tap(find.byType(CustomIconButton));
      await tester.pumpAndSettle();

      expect(favouritesCubit.state, contains('uid1'));

      await tester.tap(find.byType(CustomIconButton));
      await tester.pumpAndSettle();

      expect(favouritesCubit.state, isEmpty);
    });

    testWidgets('icon color changes for selected UID when favourited', (tester) async {
      final img = image('uid1');
      await tester.pumpWidget(
        buildTestHarness(
          child: FavouriteStarButton(selectedImage: img),
        ),
      );
      await tester.pumpAndSettle();

      expect(favouritesCubit.state.contains('uid1'), false);

      await tester.tap(find.byType(CustomIconButton));
      await tester.pumpAndSettle();

      expect(favouritesCubit.state.contains('uid1'), true);
      expect(favouritesCubit.isFavourite('uid1'), true);
    });

    testWidgets('unrelated UID toggle does not rebuild target star', (tester) async {
      final imgA = image('uidA');
      final imgB = image('uidB');
      final buildCountA = ValueNotifier<int>(0);
      final buildCountB = ValueNotifier<int>(0);

      await tester.pumpWidget(
        buildTestHarness(
          child: Row(
            children: [
              FavouriteStarButton(
                selectedImage: imgA,
                debugBuildCount: buildCountA,
              ),
              FavouriteStarButton(
                selectedImage: imgB,
                debugBuildCount: buildCountB,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(buildCountA.value, 1);
      expect(buildCountB.value, 1);

      await tester.tap(find.byType(CustomIconButton).last);
      await tester.pumpAndSettle();

      expect(buildCountA.value, 1);
      expect(buildCountB.value, 2);
    });
  });
}

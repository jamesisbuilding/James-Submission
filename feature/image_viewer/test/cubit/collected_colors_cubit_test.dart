import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/src/cubit/cubit.dart';

void main() {
  late CollectedColorsCubit cubit;

  setUp(() {
    cubit = CollectedColorsCubit();
  });

  tearDown(() => cubit.close());

  group('CollectedColorsCubit', () {
    test('add adds palette for non-empty imageUid', () {
      const uid = 'img1';
      final colors = [Colors.red, Colors.blue];

      cubit.add(uid, colors);

      expect(cubit.state[uid], colors);
      expect(cubit.isCollected(uid), true);
    });

    test('add does nothing when imageUid is empty', () {
      cubit.add('', [Colors.red]);

      expect(cubit.state, isEmpty);
    });

    test('isCollected returns false for unknown UID', () {
      expect(cubit.isCollected('unknown'), false);
    });

    test('collectedPalettes returns entries as records', () {
      cubit.add('uid1', [Colors.red]);
      cubit.add('uid2', [Colors.blue, Colors.green]);

      final palettes = cubit.collectedPalettes;

      expect(palettes.length, 2);
      expect(palettes.any((p) => p.imageUid == 'uid1' && p.colors.length == 1), true);
      expect(palettes.any((p) => p.imageUid == 'uid2' && p.colors.length == 2), true);
    });

    test('add overwrites existing palette for same UID', () {
      cubit.add('uid1', [Colors.red]);
      cubit.add('uid1', [Colors.green, Colors.blue]);

      expect(cubit.state['uid1'], [Colors.green, Colors.blue]);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/src/domain/exceptions/image_viewer_exceptions.dart';

void main() {
  group('ImageFetchFailedException', () {
    test('toString returns default when message is null', () {
      final e = ImageFetchFailedException();
      expect(e.toString(), 'ImageFetchFailedException');
    });

    test('toString returns custom message when provided', () {
      final e = ImageFetchFailedException('All analyses failed');
      expect(e.message, 'All analyses failed');
    });
  });

  group('NoMoreImagesException', () {
    test('toString returns default when message is null', () {
      final e = NoMoreImagesException();
      expect(e.toString(), 'NoMoreImagesException');
    });

    test('toString returns custom message when provided', () {
      final e = NoMoreImagesException('Custom message');
      expect(e.toString(), 'Custom message');
    });

    test('message field is accessible', () {
      final e = NoMoreImagesException();
      expect(e.message, isNull);
      final e2 = NoMoreImagesException('custom');
      expect(e2.message, 'custom');
    });
  });
}

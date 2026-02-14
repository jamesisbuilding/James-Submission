import 'package:flutter_test/flutter_test.dart';
import 'package:share_service/share_service.dart';

void main() {
  group('ShareServiceImpl share text', () {
    test('screenshot mode: empty description and null title yields only tagline',
        () {
      final text = buildShareText(title: null, description: '');
      expect(text, 'I sent this from Imgo!');
    });

    test('collapsed mode: title and description are included with tagline', () {
      final text = buildShareText(
        title: 'Sunset Beach',
        description: 'A peaceful evening by the water.',
      );
      expect(
        text,
        'Sunset Beach\n\nA peaceful evening by the water.\n\nI sent this from Imgo!',
      );
    });

    test('title only yields title and tagline', () {
      final text = buildShareText(title: 'Mountain View', description: '');
      expect(text, 'Mountain View\n\nI sent this from Imgo!');
    });

    test('description only yields description and tagline', () {
      final text = buildShareText(
        title: null,
        description: 'Golden hour over the valley.',
      );
      expect(text, 'Golden hour over the valley.\n\nI sent this from Imgo!');
    });
  });
}

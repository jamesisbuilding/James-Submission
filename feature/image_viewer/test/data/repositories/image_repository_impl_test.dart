import 'package:flutter_test/flutter_test.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/image_viewer.dart';
import 'package:image_viewer/src/domain/exceptions/image_viewer_exceptions.dart';

import '../fakes/fake_image_analysis_service.dart';
import '../fakes/fake_image_remote_datasource.dart';

void main() {
  late FakeImageRemoteDatasource fakeDatasource;
  late FakeImageAnalysisService fakeAnalysisService;
  late ImageRepositoryImpl repository;

  setUp(() {
    fakeDatasource = FakeImageRemoteDatasource();
    fakeAnalysisService = FakeImageAnalysisService();
    repository = ImageRepositoryImpl(
      remoteDatasource: fakeDatasource,
      imageAnalysisService: fakeAnalysisService,
    );
  });

  group('ImageRepositoryImpl dedupe/backoff', () {
    test('URL dedupe (rawUrls.toSet()) works', () async {
      fakeDatasource.reset(
        urlsToReturn: [
          'https://a.com/1',
          'https://a.com/1',
          'https://b.com/2',
          'https://c.com/3',
        ],
      );
      fakeAnalysisService.reset(
        resultsToReturn: [
          Success(testImage('uid1', 'sig1')),
          Success(testImage('uid2', 'sig2')),
          Success(testImage('uid3', 'sig3')),
        ],
      );

      final stream = repository.runImageRetrieval(count: 3, existingImages: []);
      final images = await stream.toList();

      expect(images.length, 3);
      expect(fakeDatasource.callCount, 4);
      expect(fakeAnalysisService.callCount, 3);
    });

    test('duplicate result increments sequential duplicate counter and throws at threshold',
        () async {
      fakeDatasource.reset(
        urlsToReturn: ['https://a.com/1', 'https://b.com/2', 'https://c.com/3'],
      );
      fakeAnalysisService.reset(
        resultsToReturn: [
          Failure('duplicate', type: FailureType.duplicate),
          Failure('duplicate', type: FailureType.duplicate),
          Failure('duplicate', type: FailureType.duplicate),
        ],
      );

      final stream = repository.runImageRetrieval(count: 1, existingImages: []);

      expect(
        () => stream.toList(),
        throwsA(isA<NoMoreImagesException>()),
      );
    });

    test('non-duplicate results decrement remainingToFetch and stream yields expected count',
        () async {
      fakeDatasource.reset(
        urlsToReturn: ['https://a.com/1', 'https://b.com/2', 'https://c.com/3'],
      );
      fakeAnalysisService.reset(
        resultsToReturn: [
          Success(testImage('uid1', 'sig1')),
          Success(testImage('uid2', 'sig2')),
          Success(testImage('uid3', 'sig3')),
        ],
      );

      final stream = repository.runImageRetrieval(count: 3, existingImages: []);
      final images = await stream.toList();

      expect(images.length, 3);
      expect(images.map((e) => e.uid).toList(), ['uid1', 'uid2', 'uid3']);
    });

    test('backoff retries stop once target count is reached', () async {
      fakeDatasource.reset(
        urlsToReturn: ['https://a.com/1', 'https://b.com/2'],
      );
      fakeAnalysisService.reset(
        resultsToReturn: [
          Success(testImage('uid1', 'sig1')),
          Success(testImage('uid2', 'sig2')),
        ],
      );

      final stream = repository.runImageRetrieval(count: 2, existingImages: []);
      await stream.toList();

      expect(fakeDatasource.callCount, 2);
      expect(fakeAnalysisService.callCount, 2);
    });

    test('throws when all attempts fail', () async {
      const rounds = 4;
      fakeDatasource.reset(
        urlsToReturn: List.generate(rounds, (i) => 'https://a.com/$i'),
      );
      fakeAnalysisService.reset(
        resultsToReturn: List.generate(
          rounds,
          (_) => Failure('fetch failed', type: FailureType.other),
        ),
      );

      final stream = repository.runImageRetrieval(count: 1, existingImages: []);

      expect(
        () => stream.toList(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('All image analyses failed'),
        )),
      );
    });

    test('Success model with duplicate pixel signature increments sequential counter and throws at threshold',
        () async {
      const sameSig = 'duplicate_sig';
      fakeDatasource.reset(
        urlsToReturn: [
          'https://a.com/1',
          'https://b.com/2',
          'https://c.com/3',
          'https://d.com/4',
          'https://e.com/5',
        ],
      );
      fakeAnalysisService.reset(
        resultsToReturn: [
          Success(testImage('uid1', sameSig)),
          Success(testImage('uid2', sameSig)),
          Success(testImage('uid3', sameSig)),
          Success(testImage('uid4', sameSig)),
          Success(testImage('uid5', sameSig)),
        ],
      );

      final stream = repository.runImageRetrieval(count: 3, existingImages: []);

      expect(
        () => stream.toList(),
        throwsA(isA<NoMoreImagesException>().having(
          (e) => e.message,
          'message',
          contains('Too many sequential duplicates'),
        )),
      );
    });
  });
}

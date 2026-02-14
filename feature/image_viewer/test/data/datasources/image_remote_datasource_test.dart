import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_viewer/src/data/datasources/image_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
  });

  group('ImageRemoteDatasourceImpl', () {
    test('getRandomImageUrl returns url from response', () async {
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/image/'),
          data: {'url': 'https://example.com/image.jpg'},
          statusCode: 200,
        ),
      );

      final ds = ImageRemoteDatasourceImpl(dio: mockDio);
      final url = await ds.getRandomImageUrl();

      expect(url, 'https://example.com/image.jpg');
    });

    test('getRandomImageUrl throws when data is null', () async {
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/image/'),
          data: null,
          statusCode: 200,
        ),
      );

      final ds = ImageRemoteDatasourceImpl(dio: mockDio);

      expect(
        ds.getRandomImageUrl(),
        throwsA(isA<DioException>().having(
          (e) => e.error,
          'error',
          'Empty response',
        )),
      );
    });

    test('getRandomImageUrl throws when url is missing', () async {
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/image/'),
          data: <String, dynamic>{},
          statusCode: 200,
        ),
      );

      final ds = ImageRemoteDatasourceImpl(dio: mockDio);

      expect(
        ds.getRandomImageUrl(),
        throwsA(isA<DioException>().having(
          (e) => e.error,
          'error',
          'Missing or empty url in response',
        )),
      );
    });

    test('getRandomImageUrl throws when url is empty', () async {
      when(() => mockDio.get<Map<String, dynamic>>(any())).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          requestOptions: RequestOptions(path: '/image/'),
          data: {'url': ''},
          statusCode: 200,
        ),
      );

      final ds = ImageRemoteDatasourceImpl(dio: mockDio);

      expect(
        ds.getRandomImageUrl(),
        throwsA(isA<DioException>()),
      );
    });
  });
}

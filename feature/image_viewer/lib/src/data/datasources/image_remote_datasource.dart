import 'package:dio/dio.dart';

const _baseUrl = 'https://november7-730026606190.europe-west1.run.app';

/// Remote data source for image API.
abstract interface class ImageRemoteDatasource {
  /// Fetches a random image URL from the API.
  Future<String> getRandomImageUrl();
}

/// Dio-based implementation of [ImageRemoteDatasource].
class ImageRemoteDatasourceImpl implements ImageRemoteDatasource {
  ImageRemoteDatasourceImpl({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  final Dio _dio;

  @override
  Future<String> getRandomImageUrl() async {
    final response = await _dio.get<Map<String, dynamic>>('/image/');
    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Empty response',
      );
    }
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: 'Missing or empty url in response',
      );
    }
    return url;
  }
}

import 'package:image_viewer/src/data/datasources/image_remote_datasource.dart';

/// Fake datasource that returns URLs from a queue.
/// Use [urlsToReturn] to control exactly which URLs are returned per call.
class FakeImageRemoteDatasource implements ImageRemoteDatasource {
  FakeImageRemoteDatasource({List<String>? urlsToReturn})
      : _urlQueue = List.from(urlsToReturn ?? []);

  final List<String> _urlQueue;
  int _callCount = 0;

  int get callCount => _callCount;

  @override
  Future<String> getRandomImageUrl() async {
    if (_urlQueue.isEmpty) {
      throw StateError('FakeImageRemoteDatasource: no URLs left in queue');
    }
    _callCount++;
    return _urlQueue.removeAt(0);
  }

  /// Resets call count and optionally replaces the URL queue.
  void reset({List<String>? urlsToReturn}) {
    _callCount = 0;
    if (urlsToReturn != null) {
      _urlQueue.clear();
      _urlQueue.addAll(urlsToReturn);
    }
  }
}

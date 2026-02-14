import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_analysis_service/image_analysis_service.dart';

/// Fake analysis service that returns results from a queue.
/// Use [resultsToReturn] to control Success/Failure per call.
class FakeImageAnalysisService implements ImageAnalysisService {
  FakeImageAnalysisService({List<Result<ImageModel>>? resultsToReturn})
      : _resultQueue = List.from(resultsToReturn ?? []);

  final List<Result<ImageModel>> _resultQueue;
  int _callCount = 0;

  int get callCount => _callCount;

  @override
  Future<Result<ImageModel>> runImageAnalysisService({
    required String imageURL,
    List<ImageModel> existingImages = const [],
  }) async {
    if (_resultQueue.isEmpty) {
      throw StateError(
        'FakeImageAnalysisService: no results left in queue (call $_callCount for url $imageURL)',
      );
    }
    _callCount++;
    return _resultQueue.removeAt(0);
  }

  /// Resets call count and optionally replaces the result queue.
  void reset({List<Result<ImageModel>>? resultsToReturn}) {
    _callCount = 0;
    if (resultsToReturn != null) {
      _resultQueue.clear();
      _resultQueue.addAll(resultsToReturn);
    }
  }

  @override
  Future<List<Color>> runColorAnalysis({required Uint8List imageBytes}) async =>
      [Colors.transparent];

  @override
  Future<void> wipeViewerCache() async {}
}

ImageModel testImage(String uid, String pixelSignature) => ImageModel(
      uid: uid,
      title: 't',
      description: 'd',
      isFavourite: false,
      url: 'https://example.com/$uid',
      colorPalette: const [Color(0xFF000000)],
      localPath: '',
      pixelSignature: pixelSignature,
    );

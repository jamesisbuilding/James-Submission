import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_analysis_service/image_analysis_service.dart';

import 'package:image_viewer/src/data/datasources/image_remote_datasource.dart';
import 'package:image_viewer/src/domain/exceptions/image_viewer_exceptions.dart';
import 'package:image_viewer/src/domain/repositories/image_repository.dart';

/// Release-safe: only logs in debug/profile.
void _log(String message) {
  if (kDebugMode) debugPrint('[ImageRepo] $message');
}

const _maxRetriesPerSlot = 3;
const _initialBackoffMs = 500;
const _maxSequentialDuplicates = 3;
const _requestTimeout = Duration(seconds: 10);

class ImageRepositoryImpl implements ImageRepository {
  ImageRepositoryImpl({
    required ImageRemoteDatasource remoteDatasource,
    required ImageAnalysisService imageAnalysisService,
  }) : _remoteDatasource = remoteDatasource,
       _imageAnalysisService = imageAnalysisService;

  final ImageRemoteDatasource _remoteDatasource;
  final ImageAnalysisService _imageAnalysisService;

  /// Global set of pixel signatures seen across all fetches. Prevents duplicates
  /// even when [existingImages] passed to [runImageRetrieval] is stale.
  final Set<String> _seenSignatures = {};

  @override
  Stream<ImageModel> runImageRetrieval({
    int count = 1,
    List<ImageModel> existingImages = const [],
  }) async* {
    _log('runImageRetrieval count=$count existing=${existingImages.length} seen=${_seenSignatures.length}');

    _seenSignatures.addAll(
      existingImages
          .map((e) => e.pixelSignature)
          .where((s) => s.isNotEmpty),
    );

    var currentPool = List<ImageModel>.from(existingImages);

    int remainingToFetch = count;
    int backoffMs = _initialBackoffMs;
    int sequentialDuplicates = 0;

    for (
      var round = 0;
      round <= _maxRetriesPerSlot && remainingToFetch > 0;
      round++
    ) {
      // Print state params each round for debugging
      debugPrint(
        '[ImageRepo] Round $round: remainingToFetch=$remainingToFetch, backoffMs=$backoffMs, sequentialDuplicates=$sequentialDuplicates, '
        'currentPool.length=${currentPool.length}, _seenSignatures.length=${_seenSignatures.length}'
      );

      // Fetch URLs based on what's still missing
      final rawUrls = await Future.wait<String>(
        List.generate(
          remainingToFetch,
          (_) => _remoteDatasource.getRandomImageUrl(),
        ),
      );
      debugPrint('[ImageRepo] Round $round: requested $remainingToFetch url(s), got rawUrls=$rawUrls');

      // Dedupe: API can return the same URL multiple times in parallel requests
      final urls = rawUrls.toSet().toList();
      if (urls.length < rawUrls.length) {
        debugPrint(
          '[ImageRepo] Deduped ${rawUrls.length - urls.length} duplicate URL(s)',
        );
      }

      for (final url in urls) {
        // Sequential processing: currentPool must be updated after each
        // success so the analysis service can detect duplicates within batch.
        final Result<ImageModel> result = await _imageAnalysisService
            .runImageAnalysisService(
              imageURL: url,
              existingImages: currentPool,
            )
            .timeout(_requestTimeout);

        final ImageModel? model = switch (result) {
          Success(:final value) => value,
          Failure(:final type) => () {
            if (type == FailureType.duplicate) {
              sequentialDuplicates++;
              if (sequentialDuplicates >= _maxSequentialDuplicates) {
              
                throw NoMoreImagesException(
                  'Too many sequential duplicates '
                  '${sequentialDuplicates}/$_maxSequentialDuplicates',
                );
              }
            } else {
              sequentialDuplicates = 0;
            }
            return null;
          }(),
        };

        if (model != null) {
          if (model.pixelSignature.isEmpty || _seenSignatures.contains(model.pixelSignature)) {
            if (model.pixelSignature.isNotEmpty) {
              sequentialDuplicates++;
              if (sequentialDuplicates >= _maxSequentialDuplicates) {
                throw NoMoreImagesException(
                  'Too many sequential duplicates '
                  '${sequentialDuplicates}/$_maxSequentialDuplicates',
                );
              }
            }
            continue;
          }

          sequentialDuplicates = 0;
          _seenSignatures.add(model.pixelSignature);
          currentPool.add(model);
          remainingToFetch--;
          yield model;

          if (remainingToFetch <= 0) break;
        }
      }

      if (remainingToFetch <= 0) break;

      if (round < _maxRetriesPerSlot) {
        _log('Retrying in ${backoffMs}ms');
        await Future.delayed(Duration(milliseconds: backoffMs));
        backoffMs *= 2;
      }
    }

    if (currentPool.length <= existingImages.length) {
      throw ImageFetchFailedException('All image analyses failed after retries');
    }
  }
}

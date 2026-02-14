import 'dart:async' show TimeoutException;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_analysis_service/image_analysis_service.dart';
import 'package:image_viewer/src/domain/exceptions/image_viewer_exceptions.dart';
import 'package:image_viewer/src/domain/repositories/image_repository.dart';

import 'image_viewer_event.dart';
import 'image_viewer_state.dart';

part 'bloc_handlers.dart';

class ImageViewerBloc extends Bloc<ImageViewerEvent, ImageViewerState> {
  ImageViewerBloc({required ImageRepository imageRepository})
    : _imageRepository = imageRepository,
      super(ImageViewerState.empty()) {
    on<ImageViewerFetchRequested>(_onFetchRequested);
    on<UpdateSelectedImage>(_updateSelectedImage);
    on<AnotherImageEvent>(_anotherImageEvent);
    on<ErrorDismissed>(_onErrorDismissed);
    on<CarouselControllerRegistered>(_onCarouselControllerRegistered);
    on<CarouselControllerUnregistered>(_onCarouselControllerUnregistered);
  }

  final ImageRepository _imageRepository;

  /// Signatures that are already accepted into bloc state.
  final Set<String> _acceptedSignatures = <String>{};

  /// Signatures currently being processed by active fetch handlers.
  final Set<String> _inFlightSignatures = <String>{};

  void seedAcceptedSignatures(Iterable<String> signatures) {
    _acceptedSignatures.addAll(signatures.where((s) => s.isNotEmpty));
  }

  /// Reserves [signature] for this handler instance if not already seen.
  /// Returns false when the signature is already accepted/in-flight.
  bool tryReserveSignature(String signature) {
    if (signature.isEmpty) return false;
    if (_acceptedSignatures.contains(signature) ||
        _inFlightSignatures.contains(signature)) {
      return false;
    }
    _inFlightSignatures.add(signature);
    return true;
  }

  /// Promotes an in-flight signature to accepted once emit is successful.
  void acceptReservedSignature(String signature) {
    if (signature.isEmpty) return;
    _inFlightSignatures.remove(signature);
    _acceptedSignatures.add(signature);
  }

  /// Releases an in-flight reservation when image is discarded.
  void releaseReservedSignature(String signature) {
    if (signature.isEmpty) return;
    _inFlightSignatures.remove(signature);
  }
}

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
    on<ImageFavourited>(_onImageFavourited);
    on<ErrorDismissed>(_onErrorDismissed);
    on<CarouselControllerRegistered>(_onCarouselControllerRegistered);
    on<CarouselControllerUnregistered>(_onCarouselControllerUnregistered);
  }

  final ImageRepository _imageRepository;
}

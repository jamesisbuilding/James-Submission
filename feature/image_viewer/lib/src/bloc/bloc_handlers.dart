part of 'image_viewer_bloc.dart';

extension ImageBlocHandlers on ImageViewerBloc {
  Future<void> _onFetchRequested(
    ImageViewerFetchRequested event,
    Emitter<ImageViewerState> emit,
  ) async {
    final bool isFirstLoad = state.visibleImages.isEmpty;

    bool isFirstArrivalFromStream = true;

    emit(state.copyWith(loadingType: event.loadingType));

    try {
      seedAcceptedSignatures([
        ...state.visibleImages.map((e) => e.pixelSignature),
        ...state.fetchedImages.map((e) => e.pixelSignature),
      ]);

      final existingSignatures = {
        ...state.visibleImages
            .map((e) => e.pixelSignature)
            .where((s) => s.isNotEmpty),
        ...state.fetchedImages
            .map((e) => e.pixelSignature)
            .where((s) => s.isNotEmpty),
      };

      await for (final image in _imageRepository.runImageRetrieval(
        count: event.count,
        existingImages: [...state.visibleImages, ...state.fetchedImages],
      )) {
        final sig = image.pixelSignature;
        if (sig.isEmpty || existingSignatures.contains(sig)) {
          if (sig.isNotEmpty) {
            debugPrint('[Bloc] Skipping duplicate pixelSignature: $sig');
          }
          continue;
        }
        if (!tryReserveSignature(sig)) {
          debugPrint('[Bloc] Skipping reserved/accepted pixelSignature: $sig');
          continue;
        }
        existingSignatures.add(sig);

        // CASE 1: Initial Start (No existing images)
        if (isFirstLoad && isFirstArrivalFromStream) {
          emit(
            state.copyWith(
              visibleImages: [image],
              selectedImage: image,
              loadingType: ViewerLoadingType.background,
            ),
          );
        } else if (state.loadingType == ViewerLoadingType.manual &&
            _isOnLastPage(state) &&
            isFirstArrivalFromStream) {
          final updatedVisible = [...state.visibleImages, image];
          emit(
            state.copyWith(
              visibleImages: updatedVisible,
              selectedImage: image,
              loadingType: ViewerLoadingType.none,
            ),
          );
          _navigateCarousel(target: updatedVisible.length - 1);
        } else {
          emit(state.copyWith(fetchedImages: [...state.fetchedImages, image]));
        }

        acceptReservedSignature(sig);
        isFirstArrivalFromStream = false;
      }

      // Final cleanup: Stream is finished
      emit(state.copyWith(loadingType: ViewerLoadingType.none));
    } on NoMoreImagesException {
      // Use current state: loadingType may have changed during the stream
      // (e.g. first image arrival switched manual→background), so we only
      // surface errors when the user is still actively waiting (manual).
      final isManualAtCatch = state.loadingType == ViewerLoadingType.manual;
      emit(
        state.copyWith(
          loadingType: ViewerLoadingType.none,
          errorType: isManualAtCatch ? ViewerErrorType.noMoreImages : null,
        ),
      );
    } on TimeoutException {
      final isManualAtCatch = state.loadingType == ViewerLoadingType.manual;
      if (isManualAtCatch) {
        emit(
          state.copyWith(
            errorType: ViewerErrorType.fetchTimeout,
            loadingType: ViewerLoadingType.none,
          ),
        );
      }
    } catch (e) {
      final isManualAtCatch = state.loadingType == ViewerLoadingType.manual;
      if (isManualAtCatch) {
        emit(
          state.copyWith(
            errorType: ViewerErrorType.unableToFetchImage,
            loadingType: ViewerLoadingType.none,
          ),
        );
      }
    } finally {
      _inFlightSignatures.clear();
    }
  }

  void _anotherImageEvent(event, emit) {
    if (state.fetchedImages.isNotEmpty) {
      List<ImageModel> currentlyVisible = List.from(state.visibleImages);
      currentlyVisible.add(state.fetchedImages.first);
      List<ImageModel> fetchedImages = List.from(state.fetchedImages);
      fetchedImages.removeAt(0);

      emit(
        state.copyWith(
          visibleImages: currentlyVisible,
          fetchedImages: fetchedImages,
        ),
      );

      _navigateCarousel();
    } else {
      if (state.loadingType == ViewerLoadingType.none) {
        add(
          const ImageViewerFetchRequested(
            count: 3,
            loadingType: ViewerLoadingType.manual,
          ),
        );
      } else if (state.loadingType == ViewerLoadingType.background) {
        emit(state.copyWith(loadingType: ViewerLoadingType.manual));
      }
    }
  }

  // --- Helper Methods ---

  void _navigateCarousel({int? target}) {
    final ctrl = state.carouselController;
    if (ctrl != null && ctrl.hasClients) {
      final targetPage = target ?? state.visibleImages.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ctrl.hasClients) {
          ctrl.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  bool _isOnLastPage(ImageViewerState s) =>
      s.visibleImages.isNotEmpty && s.selectedImage == s.visibleImages.last;

  void _onErrorDismissed(ErrorDismissed event, Emitter<ImageViewerState> emit) {
    emit(state.copyWith(errorType: ViewerErrorType.none));
  }

  void _onCarouselControllerRegistered(
    CarouselControllerRegistered event,
    Emitter<ImageViewerState> emit,
  ) {
    emit(state.copyWith(carouselController: event.controller));
  }

  void _onCarouselControllerUnregistered(
    CarouselControllerUnregistered event,
    Emitter<ImageViewerState> emit,
  ) {
    emit(state.copyWith(clearCarouselController: true));
  }

  void _updateSelectedImage(
    UpdateSelectedImage event,
    Emitter<ImageViewerState> emit,
  ) {
    emit(state.copyWith(selectedImage: event.image));
  }
}

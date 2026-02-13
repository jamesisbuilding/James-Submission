import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks favourited image UIDs. Isolated from [ImageViewerBloc] so favouriting
/// triggers minimal rebuilds (only the star widget), not the full control bar.
class FavouritesCubit extends Cubit<Set<String>> {
  FavouritesCubit() : super({});

  void toggle(String uid) {
    final next = Set<String>.from(state);
    if (next.contains(uid)) {
      next.remove(uid);
    } else {
      next.add(uid);
    }
    emit(next);
  }

  bool isFavourite(String uid) => state.contains(uid);
}

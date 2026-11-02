import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../state/library_state.dart';

final libraryViewModelProvider =
    NotifierProvider<LibraryViewModel, LibraryState>(LibraryViewModel.new);

class LibraryViewModel extends Notifier<LibraryState> {
  @override
  LibraryState build() => LibraryState(ref.watch(favoritesViewModelProvider));
  void remove(int movieId) =>
      ref.read(favoritesViewModelProvider.notifier).removeFavorite(movieId);
  Future<void> retryRead() =>
      ref.read(favoritesViewModelProvider.notifier).retryRead();
}

import 'package:catalog_feature/catalog_feature.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.debouncing = false,
    this.listing = const MovieListingState(),
  });
  final String query;
  final bool debouncing;
  final MovieListingState listing;
}

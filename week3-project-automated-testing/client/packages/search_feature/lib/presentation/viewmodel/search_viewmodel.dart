import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../state/search_state.dart';

final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(
  SearchViewModel.new,
);

class SearchViewModel extends Notifier<SearchState> {
  late MovieListingSession _session;
  Timer? _debounce;
  bool _alive = true;
  @override
  SearchState build() {
    _session = MovieListingSession(
      clock: ref.read(clockProvider),
      onChanged: (listing) => state = SearchState(
        query: state.query,
        listing: listing,
        debouncing: state.debouncing,
      ),
    );
    ref.onDispose(() {
      _alive = false;
      _debounce?.cancel();
      _session.dispose();
    });
    return const SearchState();
  }

  void edit(String query) {
    _debounce?.cancel();
    _session.invalidatePending();
    state = SearchState(
      query: query,
      listing: state.listing,
      debouncing: normalizeQuery(query).isNotEmpty,
    );
    if (normalizeQuery(query).isEmpty) {
      _session.clear();
      return;
    }
    _debounce = ref.read(scheduleProvider)(
      const Duration(milliseconds: 350),
      () {
        _debounce = null;
        _run();
      },
    );
  }

  Future<void> submit() {
    _debounce?.cancel();
    _debounce = null;
    state = SearchState(query: state.query, listing: state.listing);
    final query = normalizeQuery(state.query);
    if (query.isEmpty) {
      clear();
      return Future.value();
    }
    if (state.listing.requested?.query == query &&
        (state.listing.loading ||
            state.listing.error == null &&
                state.listing.displayed?.query == query))
      return Future.value();
    return _run();
  }

  Future<void> _run() {
    if (!_alive) return Future.value();
    final query = normalizeQuery(state.query);
    if (query.isEmpty) {
      clear();
      return Future.value();
    }
    state = SearchState(query: state.query, listing: state.listing);
    final repo = ref.read(movieRepositoryProvider);
    return _session.load(
      RequestKey(
        mode: ref.read(catalogModeProvider),
        operation: 'search',
        query: query,
        region: 'US',
      ),
      (page, options) => repo.searchMovies(query, page, options: options),
      label: 'Results for “$query”',
    );
  }

  void clear() {
    _debounce?.cancel();
    _debounce = null;
    _session.clear();
    state = const SearchState();
  }

  Future<void> retry() => _session.retry();
  Future<void> loadMore() => _session.loadMore();
}

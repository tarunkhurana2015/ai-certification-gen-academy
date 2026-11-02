import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../state/home_state.dart';
import 'home_sources.dart';

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  HomeViewModel.new,
);

class HomeViewModel extends Notifier<HomeState> {
  final _sessions = <String, MovieListingSession>{};
  int? _seed;
  FavoriteMovieSnapshot? _seedSnapshot;
  bool _initialized = false, _alive = true;
  @override
  HomeState build() {
    final clock = ref.read(clockProvider);
    for (final source in homeSources) {
      _sessions[source] = MovieListingSession(
        clock: clock,
        onChanged: (listing) {
          state = HomeState(
            sections: Map.unmodifiable({...state.sections, source: listing}),
          );
        },
      );
    }
    ref.onDispose(() {
      _alive = false;
      for (final session in _sessions.values) {
        session.dispose();
      }
    });
    ref.listen(favoritesViewModelProvider, (_, next) {
      if (next.ready)
        _recommend(next.entries.isEmpty ? null : next.entries.first.movie);
    });
    Future.microtask(() {
      if (!_alive) return;
      for (final source in homeSources.where((s) => s != 'recommended')) {
        _load(source);
      }
      final favorites = ref.read(favoritesViewModelProvider);
      _recommend(
        favorites.ready && favorites.entries.isNotEmpty
            ? favorites.entries.first.movie
            : null,
      );
    });
    return HomeState(
      sections: {
        for (final source in homeSources) source: const MovieListingState(),
      },
    );
  }

  Future<void> _load(String source, {int? seed, String? label}) =>
      _sessions[source]!.load(
        RequestKey(
          mode: ref.read(catalogModeProvider),
          operation: source == 'recommended'
              ? (seed == null ? 'popular' : 'recommendations')
              : source,
          seedMovieId: seed,
          region: 'US',
        ),
        homeFetcher(ref.read(discoveryRepositoryProvider), source, seed: seed),
        label: label ?? homeTitle(source),
      );
  Future<void> _recommend(FavoriteMovieSnapshot? seed) async {
    if (_initialized && _seed == seed?.movieId) return;
    _initialized = true;
    _seed = seed?.movieId;
    _seedSnapshot = seed;
    final id = _seed;
    await _load(
      'recommended',
      seed: id,
      label: seed == null
          ? 'General picks · Popular movies'
          : 'Because you favorited ${seed.title}',
    );
    await _fallbackIfEmpty(id, seed?.title);
  }

  Future<void> _fallbackIfEmpty(int? id, String? title) async {
    if (!_alive || _seed != id) return;
    final result = _sessions['recommended']!.state;
    if (id != null &&
        result.requested?.seedMovieId == id &&
        result.error == null &&
        !result.loading &&
        result.items.isEmpty &&
        !result.canLoadMore) {
      await _load(
        'recommended',
        label: 'General picks · No recommendations available for $title',
      );
    }
  }

  Future<void> retry(String source) async {
    final seed = _seedSnapshot;
    await _sessions[source]!.retry();
    if (source == 'recommended')
      await _fallbackIfEmpty(seed?.movieId, seed?.title);
  }

  Future<void> refresh() async {
    await Future.wait([for (final source in _sessions.keys) retry(source)]);
  }
}

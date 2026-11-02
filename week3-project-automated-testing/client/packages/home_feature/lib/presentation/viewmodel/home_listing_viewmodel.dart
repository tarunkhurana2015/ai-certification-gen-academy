import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'home_sources.dart';

typedef HomeListingIdentity = ({
  String entry,
  String source,
  int? seed,
  String label,
});
final homeListingProvider = NotifierProvider.autoDispose
    .family<HomeListingViewModel, MovieListingState, HomeListingIdentity>(
      HomeListingViewModel.new,
    );

class HomeListingViewModel extends Notifier<MovieListingState> {
  HomeListingViewModel(this.identity);
  final HomeListingIdentity identity;
  late MovieListingSession _session;
  bool _alive = true;
  @override
  MovieListingState build() {
    _session = MovieListingSession(
      clock: ref.read(clockProvider),
      onChanged: (next) => state = next,
    );
    ref.onDispose(() {
      _alive = false;
      _session.dispose();
    });
    final mode = ref.read(catalogModeProvider);
    final repo = ref.read(discoveryRepositoryProvider);
    Future.microtask(() async {
      await _session.load(
        RequestKey(
          mode: mode,
          operation: identity.source,
          seedMovieId: identity.seed,
          region: 'US',
        ),
        homeFetcher(repo, identity.source, seed: identity.seed),
        label: identity.label,
      );
      await _fallbackIfEmpty();
    });
    return const MovieListingState();
  }

  Future<void> _fallbackIfEmpty() async {
    if (!_alive || identity.source != 'recommended' || identity.seed == null)
      return;
    final result = _session.state;
    if (result.requested?.seedMovieId != identity.seed ||
        result.error != null ||
        result.continuationError != null ||
        result.loading ||
        result.items.isNotEmpty ||
        result.canLoadMore)
      return;
    await _session.load(
      RequestKey(
        mode: ref.read(catalogModeProvider),
        operation: 'popular',
        region: 'US',
      ),
      homeFetcher(ref.read(discoveryRepositoryProvider), 'recommended'),
      label: 'General picks · No recommendations available · ${identity.label}',
    );
  }

  Future<void> retry() async {
    await _session.retry();
    await _fallbackIfEmpty();
  }

  Future<void> loadMore() async {
    await _session.loadMore();
    await _fallbackIfEmpty();
  }
}

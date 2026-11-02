import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../state/browse_state.dart';

final browseViewModelProvider = NotifierProvider<BrowseViewModel, BrowseState>(
  BrowseViewModel.new,
);

class BrowseViewModel extends Notifier<BrowseState> {
  late MovieListingSession _session;
  @override
  BrowseState build() {
    _session = MovieListingSession(
      clock: ref.read(clockProvider),
      onChanged: (listing) =>
          state = BrowseState(category: state.category, listing: listing),
    );
    ref.onDispose(_session.dispose);
    Future.microtask(() => select(BrowseCategory.nowPlaying));
    return const BrowseState();
  }

  Future<void> select(BrowseCategory category) {
    state = BrowseState(category: category, listing: state.listing);
    final repo = ref.read(discoveryRepositoryProvider);
    return _session.load(
      RequestKey(
        mode: ref.read(catalogModeProvider),
        operation: category.apiName,
        category: category.apiName,
        region: 'US',
      ),
      (page, options) => switch (category) {
        BrowseCategory.nowPlaying => repo.getNowPlaying(page, options: options),
        BrowseCategory.upcoming => repo.getUpcoming(page, options: options),
        BrowseCategory.popular => repo.getPopular(page, options: options),
        BrowseCategory.topRated => repo.getTopRated(page, options: options),
      },
      label: category.label,
    );
  }

  Future<void> retry() => _session.retry();
  Future<void> loadMore() => _session.loadMore();
}

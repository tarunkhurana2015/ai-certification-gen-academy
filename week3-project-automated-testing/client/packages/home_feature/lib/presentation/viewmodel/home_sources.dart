import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';

const homeSources = [
  'recommended',
  'trending',
  'now_playing',
  'top_rated',
  'upcoming',
];
String homeTitle(String source) => switch (source) {
  'recommended' => 'Recommended for you',
  'trending' => 'Trending',
  'now_playing' => 'Now Playing',
  'top_rated' => 'Top Rated',
  'upcoming' => 'Upcoming',
  _ => 'Movies',
};
MoviePageFetcher homeFetcher(
  DiscoveryRepository repo,
  String source, {
  int? seed,
}) => (page, options) async {
  if (source == 'trending') {
    return switch (await repo.getTrending(options: options)) {
      Success<TrendingSelection>(:final data) => Outcome.success(
        PageResult(
          items: data.items,
          page: 1,
          totalPages: data.items.isEmpty ? 0 : 1,
          totalResults: data.items.length,
          requestKey: data.requestKey,
        ),
      ),
      Failed<TrendingSelection>(:final error) => Outcome.failure(error),
      Cancelled<TrendingSelection>() => const Outcome.cancelled(),
    };
  }
  return switch (source) {
    'recommended' when seed != null => repo.getRecommendations(
      seed,
      page,
      options: options,
    ),
    'now_playing' => repo.getNowPlaying(page, options: options),
    'top_rated' => repo.getTopRated(page, options: options),
    'upcoming' => repo.getUpcoming(page, options: options),
    _ => repo.getPopular(page, options: options),
  };
};

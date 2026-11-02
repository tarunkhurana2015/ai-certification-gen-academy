import 'package:catalog_feature/catalog_feature.dart';

enum BrowseCategory { nowPlaying, upcoming, popular, topRated }

extension BrowseCategoryLabel on BrowseCategory {
  String get label => switch (this) {
    BrowseCategory.nowPlaying => 'Now Playing',
    BrowseCategory.upcoming => 'Upcoming',
    BrowseCategory.popular => 'Popular',
    BrowseCategory.topRated => 'Top Rated',
  };
  String get apiName => switch (this) {
    BrowseCategory.nowPlaying => 'now_playing',
    BrowseCategory.upcoming => 'upcoming',
    BrowseCategory.popular => 'popular',
    BrowseCategory.topRated => 'top_rated',
  };
}

class BrowseState {
  const BrowseState({
    this.category = BrowseCategory.nowPlaying,
    this.listing = const MovieListingState(),
  });
  final BrowseCategory category;
  final MovieListingState listing;
}

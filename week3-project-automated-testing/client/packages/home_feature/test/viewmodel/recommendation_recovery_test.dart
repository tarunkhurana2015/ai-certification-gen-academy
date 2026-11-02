import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:home_feature/presentation/viewmodel/home_viewmodel.dart';
import 'package:home_feature/presentation/viewmodel/home_listing_viewmodel.dart';
import 'home_viewmodel_test.dart' show Discovery, Favorites;

void main() {
  test('seeded shelf Retry applies the exhausted empty fallback', () async {
    final data = Discovery();
    final c = ProviderContainer(
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(data),
        favoritesRepositoryProvider.overrideWithValue(Favorites()),
      ],
    );
    addTearDown(c.dispose);
    c.read(homeViewModelProvider);
    await Future<void>.delayed(Duration.zero);
    data.seeded[22] = Future.value(
      Outcome.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: 'recommendations',
          occurredAtUtc: DateTime.utc(2026),
        ),
      ),
    );
    c
        .read(favoritesViewModelProvider.notifier)
        .addFavorite(const MovieSummary(id: 22, title: 'Seed'));
    await Future<void>.delayed(Duration.zero);
    expect(
      c.read(homeViewModelProvider).sections['recommended']!.error,
      isNotNull,
    );
    data.seeded[22] = Future.value(
      const Outcome.success(
        PageResult(
          items: [],
          page: 1,
          totalPages: 0,
          totalResults: 0,
          requestKey: RequestKey(
            mode: 'fixture',
            operation: 'recommendations',
            seedMovieId: 22,
            page: 1,
          ),
        ),
      ),
    );
    await c.read(homeViewModelProvider.notifier).retry('recommended');
    expect(
      c.read(homeViewModelProvider).sections['recommended']!.displayedLabel,
      contains('General picks'),
    );
  });
  test(
    'See all falls back only after all filtered seeded pages are exhausted',
    () async {
      final data = EmptySeed();
      final c = ProviderContainer(
        overrides: [discoveryRepositoryProvider.overrideWithValue(data)],
      );
      addTearDown(c.dispose);
      const identity = (
        entry: 'test',
        source: 'recommended',
        seed: 22,
        label: 'Because you favorited Seed',
      );
      final subscription = c.listen(homeListingProvider(identity), (_, _) {});
      addTearDown(subscription.close);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(homeListingProvider(identity)).canLoadMore, true);
      await c.read(homeListingProvider(identity).notifier).loadMore();
      expect(
        c.read(homeListingProvider(identity)).displayedLabel,
        contains('General picks'),
      );
      expect(c.read(homeListingProvider(identity)).items, isNotEmpty);
      expect(data.seedPages, [1, 2]);
    },
  );
}

class EmptySeed extends Discovery {
  final seedPages = <int>[];
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRecommendations(
    int id,
    int p, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) async {
    seedPages.add(p);
    return Outcome.success(
      PageResult(
        items: [],
        page: p,
        totalPages: 2,
        totalResults: 2,
        requestKey: RequestKey(
          mode: 'fixture',
          operation: 'recommendations',
          seedMovieId: id,
          page: p,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:home_feature/presentation/viewmodel/home_viewmodel.dart';

class Discovery extends Fake implements DiscoveryRepository {
  bool failUpcoming = false;
  int popularCalls = 0;
  final seeded = <int, Future<Outcome<PageResult<MovieSummary>>>>{};
  final movies = List.generate(
    12,
    (i) => MovieSummary(id: i + 1, title: 'Film ${i + 1}'),
  );
  Future<Outcome<PageResult<MovieSummary>>> page(
    String source,
    int page,
  ) async => Outcome.success(
    PageResult(
      items: movies,
      page: page,
      totalPages: 1,
      totalResults: 12,
      requestKey: RequestKey(mode: 'fixture', operation: source),
    ),
  );
  @override
  Future<Outcome<TrendingSelection>> getTrending({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) async => Outcome.success(
    TrendingSelection(
      items: movies,
      requestKey: const RequestKey(mode: 'fixture', operation: 'trending'),
    ),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getPopular(
    int p, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    popularCalls++;
    return page('popular', p);
  }

  @override
  Future<Outcome<PageResult<MovieSummary>>> getNowPlaying(
    int p, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => page('now_playing', p);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getTopRated(
    int p, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => page('top_rated', p);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getUpcoming(
    int p, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) async => failUpcoming
      ? Outcome.failure(
          AppFailure(
            kind: FailureKind.network,
            operation: 'upcoming',
            occurredAtUtc: DateTime.utc(2026),
          ),
        )
      : await page('upcoming', p);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRecommendations(
    int id,
    int p, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => seeded[id] ?? page('recommendations', p);
}

class Favorites extends Fake implements FavoritesRepository {
  @override
  Future<Outcome<FavoritesBaseline>> readBaseline() async =>
      const Outcome.success(FavoritesBaseline(entries: [], lastAddedOrder: 0));
  @override
  Future<Outcome<PersistenceAck>> apply(FavoriteWriteCommand c) async =>
      Outcome.success(
        PersistenceAck(
          intentRevision: c.intentRevision,
          movieId: c.movieId,
          storedEntry: c.desiredEntry,
          committedAtUtc: DateTime.utc(2026),
        ),
      );
}

void main() {
  ProviderContainer make(Discovery data) => ProviderContainer(
    overrides: [
      discoveryRepositoryProvider.overrideWithValue(data),
      favoritesRepositoryProvider.overrideWithValue(Favorites()),
    ],
  );
  test('MOV-HOME-001 limits featured to five and shelves to ten', () async {
    final c = make(Discovery());
    addTearDown(c.dispose);
    c.read(homeViewModelProvider);
    await Future<void>.delayed(Duration.zero);
    final state = c.read(homeViewModelProvider);
    expect(state.featured.length, 5);
    expect(state.sections.length, 5);
    expect(state.shelf('trending').length, 10);
  });
  test('MOV-HOME-003 MOV-HOME-004 favorites reseed recommendations', () async {
    final c = make(Discovery());
    addTearDown(c.dispose);
    c.read(homeViewModelProvider);
    await Future<void>.delayed(Duration.zero);
    expect(
      c.read(homeViewModelProvider).sections['recommended']!.displayedLabel,
      contains('General picks'),
    );
    c
        .read(favoritesViewModelProvider.notifier)
        .addFavorite(const MovieSummary(id: 22, title: 'Northbound'));
    await Future<void>.delayed(Duration.zero);
    expect(
      c.read(homeViewModelProvider).sections['recommended']!.displayedLabel,
      contains('Northbound'),
    );
  });
  test('MOV-HOME-006 a failed shelf leaves other shelves usable', () async {
    final c = make(Discovery()..failUpcoming = true);
    addTearDown(c.dispose);
    c.read(homeViewModelProvider);
    await Future<void>.delayed(Duration.zero);
    final state = c.read(homeViewModelProvider);
    expect(state.sections['upcoming']!.error, isNotNull);
    expect(state.sections['trending']!.items, isNotEmpty);
  });
  test(
    'MOV-HOME-005 exhausted empty recommendations explicitly fall back to Popular',
    () async {
      final data = Discovery();
      final c = make(data);
      addTearDown(c.dispose);
      c.read(homeViewModelProvider);
      await Future<void>.delayed(Duration.zero);
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
            ),
          ),
        ),
      );
      c
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(const MovieSummary(id: 22, title: 'Empty seed'));
      await Future<void>.delayed(Duration.zero);
      final state = c.read(homeViewModelProvider).sections['recommended']!;
      expect(state.displayedLabel, contains('General picks'));
      expect(state.displayed!.operation, 'popular');
      expect(data.popularCalls, 2);
    },
  );
  test(
    'filtered-empty recommendations with another page keep their seeded identity',
    () async {
      final data = Discovery();
      final c = make(data);
      addTearDown(c.dispose);
      c.read(homeViewModelProvider);
      await Future<void>.delayed(Duration.zero);
      data.seeded[22] = Future.value(
        const Outcome.success(
          PageResult(
            items: [],
            page: 1,
            totalPages: 2,
            totalResults: 2,
            requestKey: RequestKey(
              mode: 'fixture',
              operation: 'recommendations',
              seedMovieId: 22,
            ),
          ),
        ),
      );
      c
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(const MovieSummary(id: 22, title: 'More to find'));
      await Future<void>.delayed(Duration.zero);
      final state = c.read(homeViewModelProvider).sections['recommended']!;
      expect(state.canLoadMore, true);
      expect(state.displayedLabel, contains('More to find'));
      expect(data.popularCalls, 1);
    },
  );
  for (final oldFailure in [false, true]) {
    test(
      'MOV-HOME-008 old seed ${oldFailure ? 'failure' : 'success'} cannot replace a new seed',
      () async {
        final data = Discovery();
        final old = Completer<Outcome<PageResult<MovieSummary>>>();
        data.seeded[22] = old.future;
        final c = make(data);
        addTearDown(c.dispose);
        c.read(homeViewModelProvider);
        await Future<void>.delayed(Duration.zero);
        final vm = c.read(favoritesViewModelProvider.notifier);
        vm.addFavorite(const MovieSummary(id: 22, title: 'Old seed'));
        await Future<void>.delayed(Duration.zero);
        vm.addFavorite(const MovieSummary(id: 23, title: 'New seed'));
        await Future<void>.delayed(Duration.zero);
        old.complete(
          oldFailure
              ? Outcome.failure(
                  AppFailure(
                    kind: FailureKind.network,
                    operation: 'recommendations',
                    occurredAtUtc: DateTime.utc(2026),
                  ),
                )
              : await data.page('recommendations', 1),
        );
        await Future<void>.delayed(Duration.zero);
        final state = c.read(homeViewModelProvider).sections['recommended']!;
        expect(state.displayedLabel, contains('New seed'));
        expect(state.error, isNull);
      },
    );
  }
  test(
    'MOV-HOME-007 an exhausted empty general fallback never invents recommendations',
    () async {
      final data = Discovery()..movies.clear();
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
            ),
          ),
        ),
      );
      final c = make(data);
      addTearDown(c.dispose);
      c.read(homeViewModelProvider);
      await Future<void>.delayed(Duration.zero);
      c
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(const MovieSummary(id: 22, title: 'Empty seed'));
      await Future<void>.delayed(Duration.zero);
      final state = c.read(homeViewModelProvider).sections['recommended']!;
      expect(state.items, isEmpty);
      expect(state.error, isNull);
      expect(state.canLoadMore, false);
      expect(state.displayedLabel, contains('General picks'));
      expect(state.displayed!.operation, 'popular');
    },
  );
}

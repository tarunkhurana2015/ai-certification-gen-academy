import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';

class PendingMovies implements MovieRepository {
  final List<Completer<Outcome<MovieDetails>>> reads = [];
  @override
  Future<Outcome<MovieDetails>> getMovie(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    final c = Completer<Outcome<MovieDetails>>();
    reads.add(c);
    return c.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Unexpected repository call');
}

MovieDetails movie(int id, String title) => MovieDetails(
  movie: MovieSummary(id: id, title: title),
);
AppFailure failure() => AppFailure(
  kind: FailureKind.network,
  operation: 'movie',
  occurredAtUtc: DateTime.utc(2026),
);

class RelatedMovies extends Fake implements MovieRepository {
  int responsePage = 2;
  bool throws = false;
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRelatedMovies(
    int id,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) async {
    if (page > 1 && throws) throw StateError('Transport failure');
    final actual = page == 1 ? 1 : responsePage;
    return Outcome.success(
      PageResult(
        items: [MovieSummary(id: actual, title: 'Page $actual')],
        page: actual,
        totalPages: 3,
        totalResults: 3,
        requestKey: options.requestKey!,
      ),
    );
  }
}

Future<void> flushCatalog() => Future<void>.delayed(Duration.zero);
void main() {
  test(
    'related continuation rejects wrong pages and recovers thrown requests',
    () async {
      final repo = RelatedMovies();
      final c = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: [movieRepositoryProvider.overrideWithValue(repo)],
      );
      const identity = (
        branch: 'home',
        entry: 'related',
        id: 900001,
        kind: CatalogKind.related,
      );
      c.listen(catalogPageProvider(identity), (_, _) {});
      await flushCatalog();
      repo.responsePage = 1;
      await c.read(catalogPageProvider(identity).notifier).loadMore();
      expect(
        c.read(catalogPageProvider(identity)).continuationError!.kind,
        FailureKind.invalidData,
      );
      repo.throws = true;
      await c.read(catalogPageProvider(identity).notifier).loadMore();
      expect(c.read(catalogPageProvider(identity)).loadingMore, false);
      repo.throws = false;
      repo.responsePage = 2;
      await c.read(catalogPageProvider(identity).notifier).loadMore();
      expect(
        (c.read(catalogPageProvider(identity)).data
                as CatalogValue<PageResult<MovieSummary>>)
            .value
            .page,
        2,
      );
    },
  );
  test(
    'MOV-DETAIL-004 old page failure cannot replace a different pushed movie',
    () async {
      final repository = PendingMovies();
      final container = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: [movieRepositoryProvider.overrideWithValue(repository)],
      );
      const old = (
        branch: 'home',
        entry: 'entry1',
        id: 900001,
        kind: CatalogKind.movie,
      );
      const current = (
        branch: 'home',
        entry: 'entry2',
        id: 900002,
        kind: CatalogKind.movie,
      );
      container.listen(catalogPageProvider(old), (_, _) {});
      container.listen(catalogPageProvider(current), (_, _) {});
      await flushCatalog();
      repository.reads[1].complete(
        Outcome.success(movie(900002, 'Afterlight')),
      );
      await flushCatalog();
      repository.reads[0].complete(Outcome.failure(failure()));
      await flushCatalog();
      final state = container.read(catalogPageProvider(current));
      expect(
        (state.data as CatalogValue<MovieDetails>).value.movie.title,
        'Afterlight',
      );
      expect(state.error, isNull);
    },
  );
  test(
    'refresh failure preserves the successfully displayed movie identity',
    () async {
      final repository = PendingMovies();
      final container = ProviderContainer.test(
        retry: (_, _) => null,
        overrides: [movieRepositoryProvider.overrideWithValue(repository)],
      );
      const identity = (
        branch: 'home',
        entry: 'entry',
        id: 900001,
        kind: CatalogKind.movie,
      );
      container.listen(catalogPageProvider(identity), (_, _) {});
      await flushCatalog();
      repository.reads[0].complete(
        Outcome.success(movie(900001, 'Northbound')),
      );
      await flushCatalog();
      final refresh = container
          .read(catalogPageProvider(identity).notifier)
          .load(refresh: true);
      repository.reads[1].complete(Outcome.failure(failure()));
      await refresh;
      final state = container.read(catalogPageProvider(identity));
      expect(state.displayed!.entityId, 900001);
      expect(state.error, isNotNull);
      expect(
        (state.data as CatalogValue<MovieDetails>).value.movie.title,
        'Northbound',
      );
    },
  );
  test('a malformed route identity never performs a provider read', () async {
    final repository = PendingMovies();
    final container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [movieRepositoryProvider.overrideWithValue(repository)],
    );
    const identity = (
      branch: 'home',
      entry: 'invalid',
      id: 0,
      kind: CatalogKind.movie,
    );
    container.listen(catalogPageProvider(identity), (_, _) {});
    await flushCatalog();
    expect(repository.reads, isEmpty);
    expect(
      container.read(catalogPageProvider(identity)).error!.kind,
      FailureKind.invalidRequest,
    );
  });
}

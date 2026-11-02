import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/src/tmdb/tmdb_catalog.dart';
import 'support/tmdb_harness.dart';

void main() {
  test(
    'regional feeds preserve order and exclude explicitly adult titles',
    () async {
      final adapter = JsonAdapter();
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      for (final category in [
        'now_playing',
        'upcoming',
        'popular',
        'top_rated',
      ]) {
        adapter.responses['/3/movie/$category'] = rawPage([
          rawMovie(1),
          rawMovie(2, adult: true),
          rawMovie(3),
        ]);
      }
      final pages = await Future.wait([
        catalog.getNowPlaying(1),
        catalog.getUpcoming(1),
        catalog.getPopular(1),
        catalog.getTopRated(1),
      ]);
      for (final page in pages) {
        expect(page.dataOrNull!.items.map((m) => m.id), [1, 3]);
      }
      for (final request in adapter.requests) {
        expect(request.uri.queryParameters['region'], 'US');
        expect(request.uri.queryParameters['page'], '1');
        expect(request.uri.queryParameters.containsKey('include_adult'), false);
      }
    },
  );
  test(
    'Trending is the available weekly selection without unsupported paging or region',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/trending/movie/week'] = rawPage([
          rawMovie(1),
        ], totalPages: 50);
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = await TmdbCatalog(client).getTrending();
      expect(result.dataOrNull!.canContinue, false);
      expect(adapter.requests.single.uri.queryParameters, {
        'language': 'en-US',
      });
    },
  );
  test(
    'malformed paging is a failure while a filtered empty page still continues',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/movie/popular'] = rawPage([
          rawMovie(1, adult: true),
        ], totalPages: 2);
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      final result = (await catalog.getPopular(1)).dataOrNull!;
      expect(result.items, isEmpty);
      expect(result.totalPages, 2);
      adapter.responses['/3/movie/popular'] = {
        'page': 2,
        'total_pages': 3,
        'total_results': 1,
        'results': [],
      };
      expect(
        (await catalog.getPopular(
          1,
          options: const CatalogReadOptions(policy: ReadPolicy.refresh),
        )).failureOrNull!.kind,
        FailureKind.invalidData,
      );
    },
  );
}

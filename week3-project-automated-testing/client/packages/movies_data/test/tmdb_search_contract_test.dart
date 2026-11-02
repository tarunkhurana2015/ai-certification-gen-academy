import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/src/tmdb/tmdb_catalog.dart';
import 'support/tmdb_harness.dart';

void main() {
  test(
    'Search trims only outside whitespace, excludes adult and rejects empty locally',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/search/movie'] = rawPage([rawMovie(1)]);
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      expect(
        (await catalog.searchMovies('  A  Movie  ', 1)).dataOrNull,
        isNotNull,
      );
      expect(adapter.requests.single.uri.queryParameters['query'], 'A  Movie');
      expect(
        adapter.requests.single.uri.queryParameters['include_adult'],
        'false',
      );
      expect(
        (await catalog.searchMovies('   ', 1)).failureOrNull!.kind,
        FailureKind.invalidRequest,
      );
      expect(adapter.requests.length, 1);
    },
  );
  test(
    'optional invalid dates and rating stay unknown and title falls back',
    () async {
      final movie = rawMovie(1, title: ' ')
        ..['release_date'] = '2026-02-31'
        ..['vote_count'] = 0;
      final adapter = JsonAdapter()
        ..responses['/3/search/movie'] = rawPage([movie]);
      final client = testClient(adapter);
      addTearDown(client.close);
      final value = (await TmdbCatalog(
        client,
      ).searchMovies('A', 1)).dataOrNull!.items.single;
      expect(value.title, 'Original title');
      expect(value.releaseDate, isNull);
      expect(value.rating, isNull);
    },
  );
}

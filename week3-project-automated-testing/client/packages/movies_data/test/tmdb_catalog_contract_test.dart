import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/src/tmdb/tmdb_catalog.dart';
import 'support/tmdb_harness.dart';

void main() {
  test(
    'movie identity and adult policy are enforced on direct details',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/movie/1'] = rawMovie(1, adult: true);
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      expect(
        (await catalog.getMovie(1)).failureOrNull!.kind,
        FailureKind.contentUnavailable,
      );
      adapter.responses['/3/movie/1'] = rawMovie(2);
      expect(
        (await catalog.getMovie(1)).failureOrNull!.kind,
        FailureKind.invalidData,
      );
    },
  );
  test(
    'collection name/title variations preserve release order and eligibility',
    () async {
      final first = rawMovie(1)..remove('title');
      first['name'] = 'Collection movie';
      final adapter = JsonAdapter()
        ..responses['/3/collection/10'] = {
          'id': 10,
          'name': 'Collection',
          'parts': [rawMovie(2, adult: true), first],
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = (await TmdbCatalog(client).getCollection(10)).dataOrNull!;
      expect(result.movies.single.title, 'Collection movie');
    },
  );
  test(
    'supported trailers prefer official and never turn a teaser into a trailer',
    () async {
      Map<String, Object?> video(
        String id, {
        bool official = false,
        String type = 'Trailer',
      }) => {
        'id': id,
        'name': 'Trailer',
        'key': 'AbCdEfGh123',
        'site': 'YouTube',
        'type': type,
        'official': official,
      };
      final adapter = JsonAdapter()
        ..responses['/3/movie/1/videos'] = {
          'id': 1,
          'results': [
            video('teaser', type: 'Teaser'),
            video('unofficial'),
            video('official', official: true),
          ],
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = (await TmdbCatalog(client).getTrailers(1)).dataOrNull!;
      expect(result.map((v) => v.id), ['official', 'unofficial']);
      expect(
        result.first.url.toString(),
        'https://www.youtube.com/watch?v=AbCdEfGh123',
      );
    },
  );
}

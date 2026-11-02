import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/src/tmdb/tmdb_catalog.dart';
import 'support/tmdb_harness.dart';

void main() {
  test(
    'complete filmography combines roles, excludes adult and sorts future/date/unknown',
    () async {
      final first = rawMovie(1)
        ..['credit_id'] = 'cast1'
        ..['character'] = 'Alex';
      final crew = rawMovie(1)
        ..['credit_id'] = 'crew1'
        ..['job'] = 'Director';
      final future = rawMovie(2)..['release_date'] = '2027-01-01';
      final unknown = rawMovie(3)..['release_date'] = '';
      final adapter = JsonAdapter()
        ..responses['/3/person/7/movie_credits'] = {
          'id': 7,
          'cast': [first, first, future, unknown, rawMovie(4, adult: true)],
          'crew': [crew],
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = (await TmdbPersonRepository(
        TmdbCatalog(client),
      ).getFilmography(7)).dataOrNull!;
      expect(result.entries.map((e) => e.movie.id), [2, 1, 3]);
      expect(result.entries[1].roles.length, 2);
      expect(
        adapter.requests.single.uri.queryParameters.containsKey('page'),
        false,
      );
    },
  );
  test(
    'overlapping movie/person IDs use distinct image endpoints and caches',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/movie/7/images'] = {
          'id': 7,
          'backdrops': [],
          'posters': [],
        }
        ..responses['/3/person/7/images'] = {'id': 7, 'profiles': []};
      final client = testClient(adapter);
      addTearDown(client.close);
      final movies = TmdbCatalog(client);
      final people = TmdbPersonRepository(movies);
      expect(
        (await movies.getImages(7)).dataOrNull!.ownerKind,
        OwnerKind.movie,
      );
      expect(
        (await people.getImages(7)).dataOrNull!.ownerKind,
        OwnerKind.person,
      );
      expect(adapter.requests.last.uri.queryParameters, isEmpty);
    },
  );
  test(
    'cast keeps distinct credits, deduplicates identical IDs and sorts supplied order',
    () async {
      Map<String, Object?> credit(String id, int order) => {
        'id': 7,
        'name': 'Person',
        'credit_id': id,
        'character': id,
        'order': order,
      };
      final adapter = JsonAdapter()
        ..responses['/3/movie/1/credits'] = {
          'id': 1,
          'cast': [credit('second', 2), credit('first', 1), credit('first', 1)],
          'crew': [],
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = (await TmdbCatalog(client).getCredits(1)).dataOrNull!;
      expect(result.cast.map((c) => c.creditId), ['first', 'second']);
    },
  );
}

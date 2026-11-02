import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';
import 'support/tmdb_harness.dart';

void main() {
  test(
    'cached genre and trailer selections cannot be mutated by another consumer',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/genre/movie/list'] = {
          'genres': [
            {'id': 18, 'name': 'Drama'},
          ],
        }
        ..responses['/3/movie/1/videos'] = {
          'id': 1,
          'results': [
            {
              'id': 't',
              'name': 'Trailer',
              'site': 'YouTube',
              'type': 'Trailer',
              'key': 'AbCdEfGh123',
            },
          ],
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      final genres = (await catalog.getGenres()).dataOrNull!;
      expect(() => genres.clear(), throwsUnsupportedError);
      final trailers = (await catalog.getTrailers(1)).dataOrNull!;
      expect(() => trailers.clear(), throwsUnsupportedError);
      expect((await catalog.getGenres()).dataOrNull!.single.name, 'Drama');
      expect((await catalog.getTrailers(1)).dataOrNull!.single.id, 't');
    },
  );
  test(
    'rich movie/person metadata remains typed and optional resources stay independent',
    () async {
      final adapter = JsonAdapter();
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      adapter.responses['/3/movie/1'] = {
        ...rawMovie(1),
        'runtime': 119,
        'status': 'Released',
        'tagline': 'A journey',
        'genres': [
          {'id': 18, 'name': 'Drama'},
        ],
        'belongs_to_collection': {'id': 10, 'name': 'Collection'},
      };
      adapter.responses['/3/person/7'] = {
        'id': 7,
        'name': 'Maya Reed',
        'known_for_department': 'Acting',
        'biography': 'A public biography.\n\nA second paragraph.',
        'birthday': '1990-10-03',
        'deathday': '',
        'place_of_birth': 'A town',
        'also_known_as': ['M. Reed'],
        'profile_path': '/maya.jpg',
      };
      final movie = (await catalog.getMovie(1)).dataOrNull!;
      expect(movie.runtimeMinutes, 119);
      expect(movie.genres.single.name, 'Drama');
      expect(movie.collection!.id, 10);
      expect(movie.status, 'Released');
      final person = (await TmdbPersonRepository(
        catalog,
      ).getPerson(7)).dataOrNull!;
      expect(person.birthday!.iso, '1990-10-03');
      expect(person.deathday, isNull);
      expect(person.alsoKnownAs, ['M. Reed']);
      expect(person.biography, contains('\n\n'));
    },
  );
  test(
    'genres and release-window provenance map without inventing dates',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/genre/movie/list'] = {
          'genres': [
            {'id': 18, 'name': 'Drama'},
            {'id': 878, 'name': 'Science fiction'},
          ],
        };
      adapter.responses['/3/movie/now_playing'] = {
        ...rawPage([rawMovie(1)]),
        'dates': {'minimum': '2026-01-01', 'maximum': '2026-01-31'},
      };
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      expect((await catalog.getGenres()).dataOrNull!.map((g) => g.id), [
        18,
        878,
      ]);
      final result = (await catalog.getNowPlaying(1)).dataOrNull!;
      expect(result.releaseWindow!.minimum.iso, '2026-01-01');
      expect(result.items.single.releaseDate!.iso, '2026-01-09');
    },
  );
  test(
    'movie/person galleries deduplicate paths and ignore arbitrary image URLs',
    () async {
      Map<String, Object?> image(String path, int width, int height) => {
        'file_path': path,
        'width': width,
        'height': height,
        'iso_639_1': 'en',
      };
      final adapter = JsonAdapter()
        ..responses['/3/movie/1/images'] = {
          'id': 1,
          'backdrops': [image('/b.jpg', 1280, 720), image('/b.jpg', 1280, 720)],
          'posters': [
            image('https://evil.test/p.jpg', 500, 750),
            image('/p.jpg', 500, 750),
          ],
        }
        ..responses['/3/person/7/images'] = {
          'id': 7,
          'profiles': [image('/maya.jpg', 342, 513)],
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      expect(
        (await catalog.getImages(1)).dataOrNull!.images.map((i) => i.filePath),
        ['/b.jpg', '/p.jpg'],
      );
      expect(
        (await TmdbPersonRepository(
          catalog,
        ).getImages(7)).dataOrNull!.images.single.kind,
        ImageKind.profile,
      );
    },
  );
  test(
    'reviews preserve literal text, reviewer scale, UTC timestamps and provider cursor',
    () async {
      final review = {
        'id': 'r1',
        'author': 'Reviewer',
        'content': '<b>Literal supplied text</b>\n\nLong content.',
        'author_details': {'rating': 8.5},
        'created_at': '2026-01-01T10:00:00Z',
        'updated_at': '2026-01-01T12:00:00+02:00',
      };
      final adapter = JsonAdapter()
        ..responses['/3/movie/1/reviews'] = {
          'id': 1,
          ...rawPage([review, review]),
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = (await TmdbCatalog(client).getReviews(1, 1)).dataOrNull!;
      expect(result.items.length, 1);
      expect(result.items.single.content, review['content']);
      expect(result.items.single.authorRating, 8.5);
      expect(
        result.items.single.createdAtUtc,
        result.items.single.updatedAtUtc,
      );
      expect(result.requestKey.entityId, 1);
    },
  );
  test(
    'recommendation/similar endpoints remove their seed without changing provider pagination',
    () async {
      final adapter = JsonAdapter();
      for (final endpoint in ['recommendations', 'similar']) {
        adapter.responses['/3/movie/1/$endpoint'] = rawPage([
          rawMovie(1),
          rawMovie(2, adult: true),
          rawMovie(3),
        ], totalPages: 2);
      }
      final client = testClient(adapter);
      addTearDown(client.close);
      final catalog = TmdbCatalog(client);
      for (final result in [
        await catalog.getRecommendations(1, 1),
        await catalog.getRelatedMovies(1, 1),
      ]) {
        expect(result.dataOrNull!.items.map((m) => m.id), [3]);
        expect(result.dataOrNull!.totalPages, 2);
      }
      expect(
        (await catalog.getPopular(0)).failureOrNull!.kind,
        FailureKind.invalidRequest,
      );
      expect(
        (await catalog.getPopular(501)).failureOrNull!.kind,
        FailureKind.invalidRequest,
      );
    },
  );
  test(
    'crew credits keep distinct jobs and a stable department/name order',
    () async {
      Map<String, Object?> crew(
        int id,
        String name,
        String department,
        String job,
      ) => {'id': id, 'name': name, 'department': department, 'job': job};
      final adapter = JsonAdapter()
        ..responses['/3/movie/1/credits'] = {
          'id': 1,
          'cast': [],
          'crew': [
            crew(7, 'Zed', 'Sound', 'Composer'),
            crew(8, 'Al', 'Directing', 'Director'),
            crew(7, 'Zed', 'Sound', 'Composer'),
            crew(7, 'Zed', 'Sound', 'Editor'),
          ],
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = (await TmdbCatalog(client).getCredits(1)).dataOrNull!;
      expect(result.crew.length, 3);
      expect(result.crew.first.person.name, 'Al');
      expect(result.crew.last.job, 'Editor');
    },
  );
  test(
    'missing live configuration fails every contract without synthetic content',
    () async {
      final catalog = UnavailableCatalog();
      final results = await Future.wait<Outcome<Object>>([
        catalog.getNowPlaying(1),
        catalog.getUpcoming(1),
        catalog.getPopular(1),
        catalog.getTopRated(1),
        catalog.getTrending(),
        catalog.getRecommendations(1, 1),
        catalog.getGenres(),
        catalog.searchMovies('A', 1),
        catalog.getMovie(1),
        catalog.getCredits(1),
        catalog.getImages(1),
        catalog.getReviews(1, 1),
        catalog.getTrailers(1),
        catalog.getRelatedMovies(1, 1),
        catalog.getCollection(1),
        catalog.getPerson(1),
        catalog.getFilmography(1),
        catalog.getConfiguration(),
      ]);
      expect(results.length, 18);
      for (final result in results) {
        expect(result.failureOrNull!.kind, FailureKind.configuration);
        expect(result.failureOrNull!.retryAllowed, false);
        expect(result.dataOrNull, isNull);
      }
    },
  );
}

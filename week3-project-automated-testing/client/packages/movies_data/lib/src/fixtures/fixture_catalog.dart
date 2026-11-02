import 'package:movies_core/movies_core.dart';

/// Deliberate synthetic catalog; never selected as a live-error fallback.
class FixtureCatalog
    implements
        DiscoveryRepository,
        MovieRepository,
        PersonRepository,
        ArtworkConfigurationRepository {
  FixtureCatalog() {
    const titles = [
      'Northbound',
      'Afterlight',
      'Afterlight Again',
      'Quiet Harbor',
      'Ember',
      'Paper Moons',
      'The Last Signal',
      'Ocean After Dark',
      'Violet City',
      'The Long Way Home',
      'A World Between',
      'Solstice',
    ];
    const dates = [
      '2026-01-09',
      '2025-10-10',
      '2026-06-12',
      '2024-05-04',
      '2025-11-22',
      '2026-01-02',
      '2026-03-20',
      '2025-08-08',
      '2026-01-16',
      '2025-06-14',
      '2026-04-03',
      '2026-01-11',
    ];
    const stories = [
      'When a quiet traveler returns to the mountain town she once left behind, an unexpected friendship changes the direction of her journey.',
      'An unexpected meeting under the last light of summer draws two strangers into a story of memory, distance, and second chances.',
      'Years after their first encounter, old friends return to a changing city and discover that some stories are only beginning.',
      'At the edge of a small coastal town, a lighthouse keeper learns to listen to the stories carried in with the tide.',
      'A young artist follows a spark of inspiration through one unforgettable night in a city that never quite sleeps.',
      'A handwritten letter sends a curious photographer across a landscape of half-remembered dreams.',
      'A mysterious transmission reaches a remote observatory, leaving its smallest team with a very large question.',
      'Beyond the harbor lights, a marine researcher discovers a connection that challenges everything she thought she knew.',
      'Three lives cross beneath the neon glow of an unfamiliar city, each searching for a place to belong.',
      'An ordinary road trip becomes a journey through the people and places that make a home.',
      'Two neighbors separated by a busy city find an unlikely shared language in the stories they tell.',
      'During the shortest days of winter, a family gathers to celebrate the things that keep them close.',
    ];
    for (var i = 0; i < titles.length; i++) {
      final id = 900001 + i;
      movies[id] = MovieSummary(
        id: id,
        title: titles[i],
        originalTitle: titles[i],
        overview: stories[i],
        posterPath: i == 3 ? null : 'fixture:${titles[i]}',
        backdropPath: i == 3 ? null : 'fixture:${titles[i]}',
        releaseDate: CalendarDate.fromIso(dates[i]),
        rating: i == 3
            ? null
            : TmdbRating(
                average: i == 0 ? 7.8 : 7.1 + (i % 6) * 0.3,
                voteCount: i == 0 ? 1250 : 420 + i * 157,
              ),
        genreIds: [18, if (i == 6) 878],
        originalLanguage: 'en',
        adult: false,
        popularity: 100 - i.toDouble(),
      );
    }
  }
  final Map<int, MovieSummary> movies = {};
  static const maya = PersonSummary(
    id: 910001,
    name: 'Maya Reed',
    profilePath: 'fixture:Maya Reed',
    knownForDepartment: 'Acting',
  );
  static const ellis = PersonSummary(
    id: 910002,
    name: 'Ellis Stone',
    profilePath: 'fixture:Ellis Stone',
    knownForDepartment: 'Acting',
  );
  static const director = PersonSummary(
    id: 910003,
    name: 'Jamie Vale',
    profilePath: 'fixture:Jamie Vale',
    knownForDepartment: 'Directing',
  );
  static const collection = CollectionRef(
    id: 920001,
    name: 'Afterlight Collection',
    backdropPath: 'fixture:Afterlight',
    posterPath: 'fixture:Afterlight',
  );
  RequestKey _key(String operation, {int? id, int? page, String? query}) =>
      RequestKey(
        mode: 'fixture',
        operation: operation,
        entityId: id,
        page: page,
        query: query,
      );
  Outcome<T> _missing<T>(String operation) => Outcome.failure(
    AppFailure(
      kind: FailureKind.notFound,
      operation: operation,
      occurredAtUtc: DateTime.utc(2026, 1, 15),
      retryAllowed: false,
    ),
  );
  Future<Outcome<T>> _read<T>(
    CatalogReadOptions options,
    Outcome<T> Function() value,
  ) async => options.cancellation?.isCancelled == true
      ? const Outcome.cancelled()
      : value();
  PageResult<MovieSummary> _page(
    Iterable<MovieSummary> values,
    int page,
    String source, {
    int? seed,
    String? query,
  }) {
    if (page < 1 || page > 500) throw const FormatException('Invalid page');
    final all = values.toList();
    return PageResult(
      items: all.skip((page - 1) * 4).take(4).toList(),
      page: page,
      totalPages: (all.length / 4).ceil(),
      totalResults: all.length,
      requestKey: _key(source, id: seed, page: page, query: query),
    );
  }

  @override
  Future<Outcome<PageResult<MovieSummary>>> getNowPlaying(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => Outcome.success(
      _page(
        movies.values.where(
          (m) =>
              m.releaseDate!.iso.startsWith('2026-01') &&
              m.releaseDate!.day <= 15,
        ),
        page,
        'now_playing',
      ),
    ),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getUpcoming(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => Outcome.success(
      _page(
        movies.values.where(
          (m) => m.releaseDate!.iso.compareTo('2026-01-15') > 0,
        ),
        page,
        'upcoming',
      ),
    ),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getPopular(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => Outcome.success(_page(movies.values, page, 'popular')),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getTopRated(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(options, () {
    final values = movies.values.toList()
      ..sort(
        (a, b) => (b.rating?.average ?? 0).compareTo(a.rating?.average ?? 0),
      );
    return Outcome.success(_page(values, page, 'top_rated'));
  });
  @override
  Future<Outcome<TrendingSelection>> getTrending({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => Outcome.success(
      TrendingSelection(
        items: movies.values.toList(),
        requestKey: _key('trending'),
      ),
    ),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRecommendations(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => movies.containsKey(movieId)
        ? Outcome.success(
            _page(
              movieId == 900004
                  ? []
                  : movies.values.where((m) => m.id != movieId),
              page,
              'recommendations',
              seed: movieId,
            ),
          )
        : _missing('recommendations'),
  );
  @override
  Future<Outcome<List<Genre>>> getGenres({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => const Outcome.success([
      Genre(id: 18, name: 'Drama'),
      Genre(id: 878, name: 'Science fiction'),
    ]),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> searchMovies(
    String query,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => normalizeQuery(query).isEmpty
        ? Outcome.failure(
            AppFailure(
              kind: FailureKind.invalidRequest,
              operation: 'search',
              occurredAtUtc: DateTime.utc(2026, 1, 15),
              retryAllowed: false,
            ),
          )
        : Outcome.success(
            _page(
              movies.values.where(
                (m) =>
                    m.title.toLowerCase().contains(query.trim().toLowerCase()),
              ),
              page,
              'search',
              query: query.trim(),
            ),
          ),
  );
  @override
  Future<Outcome<MovieDetails>> getMovie(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(options, () {
    final movie = movies[movieId];
    if (movie == null) return _missing('movie');
    return Outcome.success(
      MovieDetails(
        movie: movie,
        genres: const [Genre(id: 18, name: 'Drama')],
        runtimeMinutes: movieId == 900004 ? null : 108 + (movieId % 13),
        status: movie.releaseDate!.iso.compareTo('2026-01-15') > 0
            ? 'Upcoming'
            : 'Released',
        collection: [900002, 900003].contains(movieId) ? collection : null,
      ),
    );
  });
  @override
  Future<Outcome<MovieCredits>> getCredits(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => movies.containsKey(movieId)
        ? Outcome.success(
            MovieCredits(
              movieId: movieId,
              cast: [
                const CastCredit(
                  person: maya,
                  character: 'Alex',
                  creditId: 'fixture-cast-001',
                  order: 0,
                ),
                const CastCredit(
                  person: ellis,
                  character: 'Sam',
                  creditId: 'fixture-cast-002',
                  order: 1,
                ),
              ],
              crew: [
                const CrewCredit(
                  person: director,
                  department: 'Directing',
                  job: 'Director',
                  creditId: 'fixture-crew-001',
                ),
              ],
            ),
          )
        : _missing('credits'),
  );
  @override
  Future<Outcome<PersonDetails>> getPerson(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => [910001, 910002, 910003].contains(personId)
        ? Outcome.success(
            PersonDetails(
              person: personId == 910001
                  ? maya
                  : personId == 910002
                  ? ellis
                  : director,
              biography:
                  '${personId == 910001
                      ? 'Maya Reed'
                      : personId == 910002
                      ? 'Ellis Stone'
                      : 'Jamie Vale'} is a fictional film professional in the Movies demonstration catalog. Their work connects intimate character stories with journeys through unfamiliar places.\n\nExplore the filmography to discover related stories and the people who made them.',
              placeOfBirth: 'Demo catalog',
            ),
          )
        : _missing('person'),
  );
  @override
  Future<Outcome<PersonFilmography>> getFilmography(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(options, () {
    if (![910001, 910002, 910003].contains(personId))
      return _missing('filmography');
    final values = movies.values.toList()
      ..sort((a, b) => b.releaseDate!.compareTo(a.releaseDate!));
    return Outcome.success(
      PersonFilmography(
        personId: personId,
        entries: [
          for (final m in values)
            FilmographyEntry(
              movie: m,
              roles: [
                CreditRole(
                  kind: personId == 910003 ? CreditKind.crew : CreditKind.cast,
                  character: personId == 910003 ? null : 'Alex',
                  job: personId == 910003 ? 'Director' : null,
                  creditId: 'fixture-$personId-${m.id}',
                ),
              ],
            ),
        ],
      ),
    );
  });
  @override
  Future<Outcome<ImageGallery>> getImages(
    int id, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(options, () {
    final person = id >= 910001 && id <= 910003;
    if (!person && !movies.containsKey(id)) return _missing('images');
    return Outcome.success(
      ImageGallery(
        ownerKind: person ? OwnerKind.person : OwnerKind.movie,
        ownerId: id,
        images: id == 900004
            ? []
            : [
                ImageAsset(
                  filePath:
                      'fixture:${person ? 'Portrait' : movies[id]!.title}',
                  kind: person ? ImageKind.profile : ImageKind.backdrop,
                  width: person ? 500 : 1280,
                  height: person ? 750 : 720,
                ),
              ],
      ),
    );
  });
  @override
  Future<Outcome<PageResult<MovieReview>>> getReviews(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => movies.containsKey(movieId)
        ? Outcome.success(
            PageResult(
              items: movieId == 900004
                  ? []
                  : [
                      MovieReview(
                        id: 'fixture-review-$movieId',
                        author: 'Demo reviewer',
                        content:
                            'A thoughtful, beautifully paced story about finding connection in unexpected places. This review is fictional demonstration content.',
                        authorRating: 8,
                        createdAtUtc: DateTime.utc(2026, 1, 10),
                      ),
                    ],
              page: page,
              totalPages: movieId == 900004 ? 0 : 1,
              totalResults: movieId == 900004 ? 0 : 1,
              requestKey: _key('reviews', id: movieId, page: page),
            ),
          )
        : _missing('reviews'),
  );
  @override
  Future<Outcome<List<TrailerLink>>> getTrailers(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => movies.containsKey(movieId)
        ? Outcome.success(
            movieId == 900004
                ? []
                : [
                    TrailerLink(
                      id: 'fixture-video-$movieId',
                      movieId: movieId,
                      name: 'Trailer',
                      youtubeKey: 'AbCdEfGh123',
                      url: Uri.https('www.youtube.com', '/watch', {
                        'v': 'AbCdEfGh123',
                      }),
                      official: true,
                    ),
                  ],
          )
        : _missing('videos'),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRelatedMovies(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => movies.containsKey(movieId)
        ? Outcome.success(
            _page(
              movies.values.where((m) => m.id != movieId),
              page,
              'related',
              seed: movieId,
            ),
          )
        : _missing('related'),
  );
  @override
  Future<Outcome<MovieCollection>> getCollection(
    int collectionId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => collectionId == 920001
        ? Outcome.success(
            MovieCollection(
              collection: collection,
              movies: [movies[900002]!, movies[900003]!],
              overview:
                  'Two connected stories about finding one another again.',
            ),
          )
        : _missing('collection'),
  );
  @override
  Future<Outcome<ImageConfiguration>> getConfiguration({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _read(
    options,
    () => Outcome.success(
      ImageConfiguration(
        secureBaseUrl: Uri.https('example.invalid', '/fixture/'),
        posterSizes: const ['w500'],
        backdropSizes: const ['w1280'],
        profileSizes: const ['w342'],
      ),
    ),
  );
}

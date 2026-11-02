import 'package:movies_core/movies_core.dart';
import 'dto/tmdb_dtos.dart';
import 'artwork_urls.dart';
import 'tmdb_client.dart';

class TmdbCatalog
    implements
        DiscoveryRepository,
        MovieRepository,
        ArtworkConfigurationRepository {
  TmdbCatalog(this.client);
  final TmdbClient client;
  static const _language = {'language': 'en-US'};
  RequestKey _key(
    String op, {
    int? id,
    int? page,
    String? query,
    bool regional = false,
    int? seed,
  }) => RequestKey(
    mode: 'live',
    operation: op,
    entityId: id,
    page: page,
    query: query,
    seedMovieId: seed,
    region: regional ? 'US' : null,
    filters: const {'adultPolicy': 'excludeFlagged-v1'},
  );
  Future<Outcome<T>> _invalid<T>(String op) => Future.value(
    Outcome.failure(
      AppFailure(
        kind: FailureKind.invalidRequest,
        operation: op,
        occurredAtUtc: client.clock.utcNow(),
        retryAllowed: false,
      ),
    ),
  );
  void _identity(Map<String, dynamic> json, int id) {
    if (positiveInteger(json['id']) != id)
      throw const FormatException('Resource identity mismatch');
  }

  Future<Outcome<PageResult<MovieSummary>>> _feed(
    String category,
    int page,
    CatalogReadOptions options,
  ) => _moviesPage('/movie/$category', category, page, options, regional: true);
  Future<Outcome<PageResult<MovieSummary>>> _moviesPage(
    String path,
    String operation,
    int page,
    CatalogReadOptions options, {
    int? id,
    String? query,
    bool regional = false,
    int? seed,
  }) {
    if (page < 1 || page > 500 || id != null && id <= 0)
      return _invalid(operation);
    final key = _key(
      operation,
      id: id,
      page: page,
      query: query,
      regional: regional,
      seed: seed,
    );
    return client.read(
      path,
      query: {
        ..._language,
        'page': '$page',
        if (regional) 'region': 'US',
        if (query != null) 'query': query,
        if (query != null) 'include_adult': 'false',
      },
      key: key,
      options: options,
      map: (json) => _page(json, page, key, seed: seed),
    );
  }

  PageResult<MovieSummary> _page(
    Map<String, dynamic> json,
    int page,
    RequestKey key, {
    int? seed,
  }) {
    final dto = TmdbPageDto.fromJson(json);
    _pageMetadata(dto, page);
    final seen = <int>{};
    final movies = <MovieSummary>[];
    for (final raw in dto.results) {
      if (raw['adult'] == true) continue;
      final movie = _movie(TmdbMovieDto.fromJson(raw));
      if (movie.id != seed && seen.add(movie.id)) movies.add(movie);
    }
    final minimum = _date(dto.dates?['minimum'] as String?);
    final maximum = _date(dto.dates?['maximum'] as String?);
    return PageResult(
      items: movies,
      page: dto.page,
      totalPages: dto.totalPages,
      totalResults: dto.totalResults,
      requestKey: key,
      releaseWindow:
          minimum != null && maximum != null && minimum.compareTo(maximum) <= 0
          ? ReleaseWindow(minimum: minimum, maximum: maximum)
          : null,
    );
  }

  void _pageMetadata(TmdbPageDto dto, int expected) {
    if (dto.page != expected ||
        dto.totalPages == 0 && (dto.page != 1 || dto.results.isNotEmpty) ||
        dto.totalPages > 0 && dto.page > dto.totalPages ||
        dto.totalResults == 0 && dto.results.isNotEmpty)
      throw const FormatException('Invalid paging');
  }

  @override
  Future<Outcome<PageResult<MovieSummary>>> getNowPlaying(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _feed('now_playing', page, options);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getUpcoming(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _feed('upcoming', page, options);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getPopular(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _feed('popular', page, options);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getTopRated(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _feed('top_rated', page, options);
  @override
  Future<Outcome<TrendingSelection>> getTrending({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    final key = _key('trending');
    return client.read(
      '/trending/movie/week',
      query: _language,
      key: key,
      options: options,
      map: (json) {
        final result = _page(json, 1, key);
        return TrendingSelection(
          items: result.items,
          requestKey: key,
          providerPage: result.page,
          providerTotalPages: result.totalPages,
          providerTotalResults: result.totalResults,
        );
      },
    );
  }

  @override
  Future<Outcome<PageResult<MovieSummary>>> getRecommendations(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _moviesPage(
    '/movie/$movieId/recommendations',
    'recommendations',
    page,
    options,
    id: movieId,
    seed: movieId,
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRelatedMovies(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _moviesPage(
    '/movie/$movieId/similar',
    'related',
    page,
    options,
    id: movieId,
    seed: movieId,
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> searchMovies(
    String query,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    final normalized = normalizeQuery(query);
    if (normalized.isEmpty) return _invalid('search');
    return _moviesPage(
      '/search/movie',
      'search',
      page,
      options,
      query: normalized,
      regional: true,
    );
  }

  @override
  Future<Outcome<List<Genre>>> getGenres({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => client.read(
    '/genre/movie/list',
    query: _language,
    key: _key('genres'),
    ttl: const Duration(hours: 24),
    options: options,
    map: (json) => List<Genre>.unmodifiable(
      jsonRows(json['genres'])
          .map(TmdbGenreDto.fromJson)
          .map((g) => Genre(id: g.id, name: _required(g.name))),
    ),
  );
  @override
  Future<Outcome<MovieDetails>> getMovie(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    if (movieId <= 0) return _invalid('movie');
    return client.read(
      '/movie/$movieId',
      query: _language,
      key: _key('movie', id: movieId),
      options: options,
      ttl: const Duration(minutes: 15),
      map: (json) {
        _identity(json, movieId);
        final dto = TmdbMovieDto.fromJson(json);
        if (dto.adult == true)
          throw const TmdbMappingFailure(FailureKind.contentUnavailable);
        return MovieDetails(
          movie: _movie(dto),
          genres: dto.genres
              .map((g) => Genre(id: g.id, name: _required(g.name)))
              .toList(),
          runtimeMinutes: dto.runtime != null && dto.runtime! > 0
              ? dto.runtime
              : null,
          status: _text(dto.status),
          tagline: _text(dto.tagline),
          collection: dto.belongsToCollection == null
              ? null
              : _collectionRef(
                  TmdbCollectionDto.fromJson(dto.belongsToCollection!),
                ),
        );
      },
    );
  }

  @override
  Future<Outcome<MovieCredits>> getCredits(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    if (movieId <= 0) return _invalid('cast');
    return client.read(
      '/movie/$movieId/credits',
      query: _language,
      key: _key('cast', id: movieId),
      ttl: const Duration(minutes: 15),
      options: options,
      map: (json) {
        _identity(json, movieId);
        final seen = <String>{};
        final cast = <({CastCredit value, int position})>[];
        final crew = <({CrewCredit value, int position})>[];
        var position = 0;
        for (final raw in jsonRows(json['cast'])) {
          final dto = TmdbPersonDto.fromJson(raw);
          final key =
              _text(dto.creditId) ?? 'cast|${dto.id}|${dto.character ?? ''}';
          if (seen.add(key))
            cast.add((
              value: CastCredit(
                person: _person(dto),
                creditId: _text(dto.creditId),
                character: _text(dto.character),
                order: dto.order,
              ),
              position: position,
            ));
          position++;
        }
        position = 0;
        for (final raw in jsonRows(json['crew'])) {
          final dto = TmdbPersonDto.fromJson(raw);
          final key =
              _text(dto.creditId) ??
              'crew|${dto.id}|${dto.department ?? ''}|${dto.job ?? ''}';
          if (seen.add(key))
            crew.add((
              value: CrewCredit(
                person: _person(dto),
                creditId: _text(dto.creditId),
                department: _text(dto.department),
                job: _text(dto.job),
              ),
              position: position,
            ));
          position++;
        }
        cast.sort((a, b) {
          final order = (a.value.order ?? 0x7fffffff).compareTo(
            b.value.order ?? 0x7fffffff,
          );
          return order != 0 ? order : a.position.compareTo(b.position);
        });
        crew.sort((a, b) {
          for (final pair in [
            (a.value.department ?? '', b.value.department ?? ''),
            (a.value.job ?? '', b.value.job ?? ''),
            (a.value.person.name, b.value.person.name),
          ]) {
            final order = pair.$1.compareTo(pair.$2);
            if (order != 0) return order;
          }
          return a.position.compareTo(b.position);
        });
        return MovieCredits(
          movieId: movieId,
          cast: cast.map((e) => e.value).toList(),
          crew: crew.map((e) => e.value).toList(),
        );
      },
    );
  }

  @override
  Future<Outcome<MovieCollection>> getCollection(
    int collectionId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    if (collectionId <= 0) return _invalid('collection');
    return client.read(
      '/collection/$collectionId',
      query: _language,
      key: _key('collection', id: collectionId),
      options: options,
      ttl: const Duration(minutes: 15),
      map: (json) {
        _identity(json, collectionId);
        final dto = TmdbCollectionDto.fromJson(json);
        if (dto.parts == null)
          throw const FormatException('Missing collection parts');
        final seen = <int>{};
        final movies = [
          for (final raw in dto.parts!)
            if (raw['adult'] != true) _movie(TmdbMovieDto.fromJson(raw)),
        ].where((m) => seen.add(m.id)).toList();
        movies.sort((a, b) => _releaseOrder(a, b, descending: false));
        return MovieCollection(
          collection: _collectionRef(dto),
          movies: movies,
          overview: _text(dto.overview),
        );
      },
    );
  }

  @override
  Future<Outcome<ImageGallery>> getImages(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _images(movieId, false, options);
  Future<Outcome<ImageGallery>> getPersonImages(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _images(personId, true, options);
  Future<Outcome<ImageGallery>> _images(
    int id,
    bool person,
    CatalogReadOptions options,
  ) {
    if (id <= 0) return _invalid('images');
    return client.read(
      '/${person ? 'person' : 'movie'}/$id/images',
      query: person
          ? const {}
          : const {..._language, 'include_image_language': 'en,null'},
      key: _key(person ? 'personImages' : 'movieImages', id: id),
      options: options,
      ttl: const Duration(minutes: 15),
      map: (json) {
        _identity(json, id);
        final seen = <String>{};
        final images = <ImageAsset>[];
        for (final kind
            in person
                ? [ImageKind.profile]
                : [ImageKind.backdrop, ImageKind.poster]) {
          final field = switch (kind) {
            ImageKind.profile => 'profiles',
            ImageKind.backdrop => 'backdrops',
            ImageKind.poster => 'posters',
          };
          for (final raw in jsonRows(json[field])) {
            final dto = TmdbImageDto.fromJson(raw);
            final path = validatedImagePath(dto.filePath);
            if (path != null && seen.add(path))
              images.add(
                ImageAsset(
                  filePath: path,
                  kind: kind,
                  width: dto.width,
                  height: dto.height,
                  aspectRatio: dto.aspectRatio,
                  language: _text(dto.language),
                ),
              );
          }
        }
        return ImageGallery(
          ownerKind: person ? OwnerKind.person : OwnerKind.movie,
          ownerId: id,
          images: images,
        );
      },
    );
  }

  @override
  Future<Outcome<PageResult<MovieReview>>> getReviews(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    if (movieId <= 0 || page < 1 || page > 500) return _invalid('reviews');
    final key = _key('reviews', id: movieId, page: page);
    return client.read(
      '/movie/$movieId/reviews',
      query: {..._language, 'page': '$page'},
      key: key,
      options: options,
      map: (json) {
        if (json.containsKey('id')) _identity(json, movieId);
        final dto = TmdbPageDto.fromJson(json);
        _pageMetadata(dto, page);
        final seen = <String>{};
        final items = <MovieReview>[];
        for (final raw in dto.results) {
          final value = TmdbReviewDto.fromJson(raw);
          final id = _required(value.id);
          if (!seen.add(id)) continue;
          final rating = value.authorDetails?['rating'];
          items.add(
            MovieReview(
              id: id,
              author: _required(value.author),
              content: value.content,
              authorRating:
                  rating is num &&
                      rating.isFinite &&
                      rating >= 0 &&
                      rating <= 10
                  ? rating.toDouble()
                  : null,
              createdAtUtc: _instant(value.createdAt),
              updatedAtUtc: _instant(value.updatedAt),
            ),
          );
        }
        return PageResult(
          items: items,
          page: dto.page,
          totalPages: dto.totalPages,
          totalResults: dto.totalResults,
          requestKey: key,
        );
      },
    );
  }

  @override
  Future<Outcome<List<TrailerLink>>> getTrailers(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    if (movieId <= 0) return _invalid('trailers');
    return client.read(
      '/movie/$movieId/videos',
      query: _language,
      key: _key('trailers', id: movieId),
      options: options,
      ttl: const Duration(minutes: 15),
      map: (json) {
        _identity(json, movieId);
        final seen = <String>{};
        final links = <TrailerLink>[];
        for (final raw in jsonRows(json['results'])) {
          final dto = TmdbVideoDto.fromJson(raw);
          final id = _text(dto.id);
          final key = dto.key;
          if (dto.site != 'YouTube' ||
              dto.type != 'Trailer' ||
              key == null ||
              !RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(key) ||
              id == null ||
              !seen.add(id))
            continue;
          links.add(
            TrailerLink(
              id: id,
              movieId: movieId,
              name: _text(dto.name) ?? 'Trailer',
              youtubeKey: key,
              url: Uri.https('www.youtube.com', '/watch', {'v': key}),
              official: dto.official,
              publishedAtUtc: _instant(dto.publishedAt),
            ),
          );
        }
        links.sort((a, b) {
          if (a.official != b.official) return a.official ? -1 : 1;
          final date = _nullableDateOrder(a.publishedAtUtc, b.publishedAtUtc);
          return date != 0 ? date : a.id.compareTo(b.id);
        });
        return List<TrailerLink>.unmodifiable(links);
      },
    );
  }

  Future<Outcome<PersonDetails>> getPerson(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    if (personId <= 0) return _invalid('person');
    return client.read(
      '/person/$personId',
      query: _language,
      key: _key('person', id: personId),
      options: options,
      ttl: const Duration(minutes: 15),
      map: (json) {
        _identity(json, personId);
        final dto = TmdbPersonDto.fromJson(json);
        return PersonDetails(
          person: _person(dto),
          biography: _text(dto.biography),
          birthday: _date(dto.birthday),
          deathday: _date(dto.deathday),
          placeOfBirth: _text(dto.placeOfBirth),
          alsoKnownAs: dto.alsoKnownAs.map(_text).whereType<String>().toList(),
        );
      },
    );
  }

  Future<Outcome<PersonFilmography>> getFilmography(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) {
    if (personId <= 0) return _invalid('filmography');
    return client.read(
      '/person/$personId/movie_credits',
      query: _language,
      key: _key('filmography', id: personId),
      options: options,
      ttl: const Duration(minutes: 15),
      map: (json) {
        _identity(json, personId);
        final entries = <int, FilmographyEntry>{};
        final seen = <String>{};
        for (final kind in CreditKind.values) {
          for (final raw in jsonRows(
            json[kind == CreditKind.cast ? 'cast' : 'crew'],
          )) {
            if (raw['adult'] == true) continue;
            final dto = TmdbMovieDto.fromJson(raw);
            final movie = _movie(dto);
            final role = CreditRole(
              kind: kind,
              creditId: _text(dto.creditId),
              character: _text(dto.character),
              department: _text(dto.department),
              job: _text(dto.job),
            );
            final roleKey =
                _text(dto.creditId) ??
                '${movie.id}|${kind.name}|${role.character ?? ''}|${role.department ?? ''}|${role.job ?? ''}';
            if (!seen.add(roleKey)) continue;
            final old = entries[movie.id];
            entries[movie.id] = FilmographyEntry(
              movie: old?.movie ?? movie,
              roles: [...?old?.roles, role],
            );
          }
        }
        final values = entries.values.toList()
          ..sort((a, b) => _releaseOrder(a.movie, b.movie, descending: true));
        return PersonFilmography(personId: personId, entries: values);
      },
    );
  }

  @override
  Future<Outcome<ImageConfiguration>> getConfiguration({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => client.read(
    '/configuration',
    key: _key('configuration'),
    options: options,
    ttl: const Duration(hours: 24),
    map: (json) {
      final dto = TmdbImageConfigurationDto.fromJson(
        json['images'] as Map<String, dynamic>,
      );
      final base = Uri.parse(dto.secureBaseUrl);
      if (base.scheme != 'https' ||
          base.host != 'image.tmdb.org' ||
          base.path != '/t/p/' ||
          base.userInfo.isNotEmpty ||
          base.hasQuery ||
          base.hasFragment ||
          base.port != 443)
        throw const FormatException('Invalid image base');
      List<String> sizes(List<String> values) {
        final result = values
            .where((v) => RegExp(r'^(?:[wh][1-9][0-9]*|original)$').hasMatch(v))
            .toSet()
            .toList();
        if (result.isEmpty) throw const FormatException('Missing image sizes');
        return result;
      }

      return ImageConfiguration(
        secureBaseUrl: base,
        posterSizes: sizes(dto.posterSizes),
        backdropSizes: sizes(dto.backdropSizes),
        profileSizes: sizes(dto.profileSizes),
      );
    },
  );
}

class TmdbPersonRepository implements PersonRepository {
  TmdbPersonRepository(this.catalog);
  final TmdbCatalog catalog;
  @override
  Future<Outcome<PersonDetails>> getPerson(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => catalog.getPerson(personId, options: options);
  @override
  Future<Outcome<PersonFilmography>> getFilmography(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => catalog.getFilmography(personId, options: options);
  @override
  Future<Outcome<ImageGallery>> getImages(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => catalog.getPersonImages(personId, options: options);
}

String? _text(String? value) =>
    value == null || value.trim().isEmpty ? null : value.trim();
String _required(String? value) =>
    _text(value) ?? (throw const FormatException('Required text is absent'));
CalendarDate? _date(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return CalendarDate.fromIso(value);
  } catch (_) {
    return null;
  }
}

DateTime? _instant(String? value) =>
    value == null ? null : DateTime.tryParse(value)?.toUtc();
MovieSummary _movie(TmdbMovieDto dto) => MovieSummary(
  id: dto.id,
  title: _required(
    _text(dto.title) ??
        _text(dto.name) ??
        _text(dto.originalTitle) ??
        _text(dto.originalName),
  ),
  originalTitle: _text(dto.originalTitle) ?? _text(dto.originalName),
  overview: _text(dto.overview),
  posterPath: validatedImagePath(dto.posterPath),
  backdropPath: validatedImagePath(dto.backdropPath),
  releaseDate: _date(dto.releaseDate),
  genreIds: dto.genreIds,
  rating:
      dto.voteAverage != null &&
          dto.voteAverage!.isFinite &&
          dto.voteAverage! >= 0 &&
          dto.voteAverage! <= 10 &&
          dto.voteCount != null &&
          dto.voteCount! > 0
      ? TmdbRating(average: dto.voteAverage!, voteCount: dto.voteCount!)
      : null,
  originalLanguage: _text(dto.originalLanguage),
  popularity: dto.popularity?.isFinite == true ? dto.popularity : null,
  adult: dto.adult,
);
PersonSummary _person(TmdbPersonDto dto) => PersonSummary(
  id: dto.id,
  name: _required(dto.name),
  profilePath: validatedImagePath(dto.profilePath),
  knownForDepartment: _text(dto.knownForDepartment),
);
CollectionRef _collectionRef(TmdbCollectionDto dto) => CollectionRef(
  id: dto.id,
  name: _required(_text(dto.name) ?? _text(dto.title)),
  posterPath: validatedImagePath(dto.posterPath),
  backdropPath: validatedImagePath(dto.backdropPath),
);
int _releaseOrder(MovieSummary a, MovieSummary b, {required bool descending}) {
  if (a.releaseDate == null && b.releaseDate != null) return 1;
  if (a.releaseDate != null && b.releaseDate == null) return -1;
  if (a.releaseDate != null && b.releaseDate != null) {
    final order =
        a.releaseDate!.compareTo(b.releaseDate!) * (descending ? -1 : 1);
    if (order != 0) return order;
  }
  final title = a.title.compareTo(b.title);
  return title != 0 ? title : a.id.compareTo(b.id);
}

int _nullableDateOrder(DateTime? a, DateTime? b) {
  if (a == null) return b == null ? 0 : 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

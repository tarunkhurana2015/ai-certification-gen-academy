import 'package:movies_core/movies_core.dart';

class UnavailableCatalog
    implements
        DiscoveryRepository,
        MovieRepository,
        PersonRepository,
        ArtworkConfigurationRepository {
  UnavailableCatalog({Clock? clock}) : clock = clock ?? SystemClock();
  final Clock clock;
  Future<Outcome<T>> _fail<T>() async => Outcome.failure(
    AppFailure(
      kind: FailureKind.configuration,
      operation: 'catalog',
      occurredAtUtc: clock.utcNow(),
      retryAllowed: false,
    ),
  );
  @override
  Future<Outcome<PageResult<MovieSummary>>> getNowPlaying(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieSummary>>();
  @override
  Future<Outcome<PageResult<MovieSummary>>> getUpcoming(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieSummary>>();
  @override
  Future<Outcome<PageResult<MovieSummary>>> getPopular(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieSummary>>();
  @override
  Future<Outcome<PageResult<MovieSummary>>> getTopRated(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieSummary>>();
  @override
  Future<Outcome<TrendingSelection>> getTrending({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<TrendingSelection>();
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRecommendations(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieSummary>>();
  @override
  Future<Outcome<List<Genre>>> getGenres({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<List<Genre>>();
  @override
  Future<Outcome<PageResult<MovieSummary>>> searchMovies(
    String query,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieSummary>>();
  @override
  Future<Outcome<MovieDetails>> getMovie(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<MovieDetails>();
  @override
  Future<Outcome<MovieCredits>> getCredits(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<MovieCredits>();
  @override
  Future<Outcome<ImageGallery>> getImages(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<ImageGallery>();
  @override
  Future<Outcome<PageResult<MovieReview>>> getReviews(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieReview>>();
  @override
  Future<Outcome<List<TrailerLink>>> getTrailers(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<List<TrailerLink>>();
  @override
  Future<Outcome<PageResult<MovieSummary>>> getRelatedMovies(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PageResult<MovieSummary>>();
  @override
  Future<Outcome<MovieCollection>> getCollection(
    int collectionId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<MovieCollection>();
  @override
  Future<Outcome<PersonDetails>> getPerson(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PersonDetails>();
  @override
  Future<Outcome<PersonFilmography>> getFilmography(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<PersonFilmography>();
  @override
  Future<Outcome<ImageConfiguration>> getConfiguration({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => _fail<ImageConfiguration>();
}

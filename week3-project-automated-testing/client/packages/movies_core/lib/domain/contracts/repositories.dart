import '../models/catalog_models.dart';
import '../models/person_models.dart';
import '../models/media_models.dart';
import '../models/favorite_models.dart';
import '../request/request_models.dart';
import 'runtime.dart';

abstract interface class DiscoveryRepository {
  Future<Outcome<PageResult<MovieSummary>>> getNowPlaying(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<PageResult<MovieSummary>>> getUpcoming(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<PageResult<MovieSummary>>> getPopular(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<PageResult<MovieSummary>>> getTopRated(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<TrendingSelection>> getTrending({
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<PageResult<MovieSummary>>> getRecommendations(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<List<Genre>>> getGenres({
    CatalogReadOptions options = const CatalogReadOptions(),
  });
}

abstract interface class MovieRepository {
  Future<Outcome<PageResult<MovieSummary>>> searchMovies(
    String query,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<MovieDetails>> getMovie(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<MovieCredits>> getCredits(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<ImageGallery>> getImages(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<PageResult<MovieReview>>> getReviews(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<List<TrailerLink>>> getTrailers(
    int movieId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<PageResult<MovieSummary>>> getRelatedMovies(
    int movieId,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<MovieCollection>> getCollection(
    int collectionId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
}

abstract interface class PersonRepository {
  Future<Outcome<PersonDetails>> getPerson(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<PersonFilmography>> getFilmography(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
  Future<Outcome<ImageGallery>> getImages(
    int personId, {
    CatalogReadOptions options = const CatalogReadOptions(),
  });
}

abstract interface class ArtworkConfigurationRepository {
  Future<Outcome<ImageConfiguration>> getConfiguration({
    CatalogReadOptions options = const CatalogReadOptions(),
  });
}

abstract interface class FavoritesRepository {
  Future<Outcome<FavoritesBaseline>> readBaseline();
  Future<Outcome<PersistenceAck>> apply(FavoriteWriteCommand command);
}

abstract interface class ExternalLinkGateway {
  Future<Outcome<bool>> openTrailer(TrailerLink trailer);
  Future<Outcome<bool>> openAttributionLink(Uri destination);
}

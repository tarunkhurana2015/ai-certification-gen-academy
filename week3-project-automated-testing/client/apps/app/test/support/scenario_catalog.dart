import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';

/// Controlled futures through the same typed contracts; never makes HTTP calls.
class ScenarioCatalog extends FixtureCatalog {
  Future<Outcome<TrendingSelection>> Function(CatalogReadOptions)? trending;
  Future<Outcome<PageResult<MovieSummary>>> Function(int, CatalogReadOptions)?
  popular;
  Future<Outcome<PageResult<MovieSummary>>> Function(int, CatalogReadOptions)?
  upcoming;
  Future<Outcome<PageResult<MovieSummary>>> Function(
    String,
    int,
    CatalogReadOptions,
  )?
  search;
  Future<Outcome<MovieDetails>> Function(int, CatalogReadOptions)? movie;
  Future<Outcome<MovieCredits>> Function(int, CatalogReadOptions)? credits;
  Future<Outcome<PersonFilmography>> Function(int, CatalogReadOptions)?
  filmography;
  Future<Outcome<PageResult<MovieReview>>> Function(
    int,
    int,
    CatalogReadOptions,
  )?
  reviews;
  @override
  Future<Outcome<TrendingSelection>> getTrending({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => trending?.call(options) ?? super.getTrending(options: options);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getPopular(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) =>
      popular?.call(page, options) ?? super.getPopular(page, options: options);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getUpcoming(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) =>
      upcoming?.call(page, options) ??
      super.getUpcoming(page, options: options);
  @override
  Future<Outcome<PageResult<MovieSummary>>> searchMovies(
    String query,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) =>
      search?.call(query, page, options) ??
      super.searchMovies(query, page, options: options);
  @override
  Future<Outcome<MovieDetails>> getMovie(
    int id, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => movie?.call(id, options) ?? super.getMovie(id, options: options);
  @override
  Future<Outcome<MovieCredits>> getCredits(
    int id, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => credits?.call(id, options) ?? super.getCredits(id, options: options);
  @override
  Future<Outcome<PersonFilmography>> getFilmography(
    int id, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) =>
      filmography?.call(id, options) ??
      super.getFilmography(id, options: options);
  @override
  Future<Outcome<PageResult<MovieReview>>> getReviews(
    int id,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) =>
      reviews?.call(id, page, options) ??
      super.getReviews(id, page, options: options);
}

AppFailure networkFailure(String operation) => AppFailure(
  kind: FailureKind.network,
  operation: operation,
  occurredAtUtc: DateTime.utc(2026),
);

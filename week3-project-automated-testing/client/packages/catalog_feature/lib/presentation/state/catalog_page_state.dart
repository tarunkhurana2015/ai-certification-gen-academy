import 'package:movies_core/movies_core.dart';

enum CatalogKind {
  movie,
  cast,
  person,
  filmography,
  collection,
  related,
  movieImages,
  personImages,
  reviews,
  trailers,
}

typedef CatalogIdentity = ({
  String branch,
  String entry,
  int id,
  CatalogKind kind,
});

sealed class CatalogPayload {
  const CatalogPayload();
}

final class CatalogValue<T> extends CatalogPayload {
  const CatalogValue(this.value);
  final T value;
}

class CatalogPageState {
  const CatalogPageState({
    this.data,
    this.requested,
    this.displayed,
    this.loading = true,
    this.error,
    this.loadingMore = false,
    this.continuationError,
  });
  final CatalogPayload? data;
  final RequestKey? requested, displayed;
  final bool loading, loadingMore;
  final AppFailure? error, continuationError;
  bool get canLoadMore => switch (data) {
    CatalogValue<PageResult<MovieSummary>>(:final value) =>
      value.page < value.totalPages && value.page < 500,
    CatalogValue<PageResult<MovieReview>>(:final value) =>
      value.page < value.totalPages && value.page < 500,
    _ => false,
  };
}

String catalogBase(CatalogIdentity identity) {
  final root = 'movies.${identity.branch}';
  final id = identity.id;
  return switch (identity.kind) {
    CatalogKind.movie => '$root.movie.$id',
    CatalogKind.cast => '$root.movie.$id.cast',
    CatalogKind.person => '$root.person.$id',
    CatalogKind.filmography => '$root.person.$id.filmography',
    CatalogKind.collection => '$root.collection.$id',
    CatalogKind.related => '$root.movie.$id.related',
    CatalogKind.movieImages => '$root.movie.$id.images',
    CatalogKind.personImages => '$root.person.$id.images',
    CatalogKind.reviews => '$root.movie.$id.reviews',
    CatalogKind.trailers => '$root.movie.$id.trailers',
  };
}

String failureMessage(AppFailure error) => switch (error.kind) {
  FailureKind.configuration || FailureKind.authentication =>
    'The catalog is unavailable right now. Your saved Library is still available.',
  FailureKind.notFound => 'This information is no longer available.',
  FailureKind.contentUnavailable =>
    'This title is not available in this catalog.',
  FailureKind.rateLimited =>
    'The catalog is busy. Please try again after a short wait.',
  FailureKind.timeout => 'Loading took too long. Please try again.',
  FailureKind.invalidData =>
    'This information could not be read. Please try again.',
  _ => 'This information could not be loaded. Please try again.',
};

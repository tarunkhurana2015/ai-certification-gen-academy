import '../models/json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/catalog_models.dart';
part 'request_models.freezed.dart';
part 'request_models.g.dart';

enum FailureKind {
  configuration,
  authentication,
  network,
  timeout,
  rateLimited,
  notFound,
  invalidRequest,
  server,
  invalidData,
  contentUnavailable,
  storageRead,
  storageWrite,
  storageMigration,
  externalLink,
}

@freezed
abstract class RequestKey with _$RequestKey {
  const RequestKey._();
  @JsonSerializable(explicitToJson: true)
  const factory RequestKey({
    required String mode,
    required String operation,
    int? entityId,
    String? query,
    String? category,
    int? seedMovieId,
    @Default('en-US') String language,
    String? region,
    @Default({}) Map<String, String> filters,
    int? page,
  }) = _RequestKey;
  factory RequestKey.fromJson(Map<String, dynamic> json) =>
      _$RequestKeyFromJson(json);
}

@freezed
abstract class ReleaseWindow with _$ReleaseWindow {
  const ReleaseWindow._();
  @JsonSerializable(explicitToJson: true)
  const factory ReleaseWindow({
    required CalendarDate minimum,
    required CalendarDate maximum,
  }) = _ReleaseWindow;
  factory ReleaseWindow.fromJson(Map<String, dynamic> json) =>
      _$ReleaseWindowFromJson(json);
}

@freezed
abstract class AppFailure with _$AppFailure {
  const AppFailure._();
  @JsonSerializable(explicitToJson: true)
  const factory AppFailure({
    required FailureKind kind,
    required String operation,
    @UtcDateTimeConverter() required DateTime occurredAtUtc,
    @Default(true) bool retryAllowed,
    RequestKey? requestKey,
    @UtcDateTimeConverter() DateTime? retryNotBeforeUtc,
    int? httpStatus,
    int? providerCode,
    int? intentRevision,
  }) = _AppFailure;
  factory AppFailure.fromJson(Map<String, dynamic> json) =>
      _$AppFailureFromJson(json);
}

@Freezed(genericArgumentFactories: true)
abstract class PageResult<T> with _$PageResult<T> {
  const PageResult._();
  @JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
  const factory PageResult({
    required List<T> items,
    required int page,
    required int totalPages,
    required int totalResults,
    required RequestKey requestKey,
    ReleaseWindow? releaseWindow,
  }) = _PageResult<T>;
  factory PageResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PageResultFromJson(json, fromJsonT);
}

@freezed
abstract class TrendingSelection with _$TrendingSelection {
  const TrendingSelection._();
  @JsonSerializable(explicitToJson: true)
  const factory TrendingSelection({
    required List<MovieSummary> items,
    required RequestKey requestKey,
    @Default('week') String timeWindow,
    int? providerPage,
    int? providerTotalPages,
    int? providerTotalResults,
  }) = _TrendingSelection;
  factory TrendingSelection.fromJson(Map<String, dynamic> json) =>
      _$TrendingSelectionFromJson(json);
  bool get canContinue => false;
}

@freezed
abstract class RecommendationSource with _$RecommendationSource {
  const RecommendationSource._();
  @JsonSerializable(explicitToJson: true)
  const factory RecommendationSource({
    required String kind,
    int? seedMovieId,
    String? seedTitle,
  }) = _RecommendationSource;
  factory RecommendationSource.fromJson(Map<String, dynamic> json) =>
      _$RecommendationSourceFromJson(json);
}

@Freezed(genericArgumentFactories: true, unionKey: 'type')
sealed class Outcome<T> with _$Outcome<T> {
  const Outcome._();
  @JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
  const factory Outcome.success(T data) = Success<T>;
  @JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
  const factory Outcome.failure(AppFailure error) = Failed<T>;
  @JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
  const factory Outcome.cancelled() = Cancelled<T>;
  factory Outcome.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$OutcomeFromJson(json, fromJsonT);
  T? get dataOrNull => switch (this) {
    Success<T>(:final data) => data,
    _ => null,
  };
  AppFailure? get failureOrNull => switch (this) {
    Failed<T>(:final error) => error,
    _ => null,
  };
}

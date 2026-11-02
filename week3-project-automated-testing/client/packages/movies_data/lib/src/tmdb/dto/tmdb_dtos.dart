import 'package:freezed_annotation/freezed_annotation.dart';
part 'tmdb_dtos.freezed.dart';
part 'tmdb_dtos.g.dart';

int positiveInteger(Object? value) {
  final result = optionalInteger(value);
  if (result == null || result <= 0)
    throw const FormatException('Expected positive integer');
  return result;
}

int nonnegativeInteger(Object? value) {
  final result = optionalInteger(value);
  if (result == null || result < 0)
    throw const FormatException('Expected nonnegative integer');
  return result;
}

int? optionalInteger(Object? value) =>
    value is num && value.isFinite && value == value.roundToDouble()
    ? value.toInt()
    : null;
List<int> genreIdsFromJson(Object? value) =>
    value == null ? const [] : (value as List).map(positiveInteger).toList();
List<Map<String, dynamic>> jsonRows(Object? value) {
  if (value is! List) throw const FormatException('Expected array');
  return value.map((row) {
    if (row is! Map<String, dynamic>)
      throw const FormatException('Expected object');
    return row;
  }).toList();
}

@freezed
abstract class TmdbPageDto with _$TmdbPageDto {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    checked: true,
    explicitToJson: true,
  )
  const factory TmdbPageDto({
    @JsonKey(fromJson: positiveInteger) required int page,
    @JsonKey(fromJson: nonnegativeInteger) required int totalPages,
    @JsonKey(fromJson: nonnegativeInteger) required int totalResults,
    @JsonKey(fromJson: jsonRows) required List<Map<String, dynamic>> results,
    Map<String, dynamic>? dates,
  }) = _TmdbPageDto;
  factory TmdbPageDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbPageDtoFromJson(json);
}

/// Shared provider movie fields; credit extensions are consumed only by the
/// complete movie-credit endpoint. Provider JSON stays inside the data package.
@freezed
abstract class TmdbMovieDto with _$TmdbMovieDto {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    checked: true,
    explicitToJson: true,
  )
  const factory TmdbMovieDto({
    @JsonKey(fromJson: positiveInteger) required int id,
    String? title,
    String? name,
    String? originalTitle,
    String? originalName,
    String? overview,
    String? posterPath,
    String? backdropPath,
    String? releaseDate,
    double? voteAverage,
    @JsonKey(fromJson: optionalInteger) int? voteCount,
    @JsonKey(fromJson: genreIdsFromJson) @Default([]) List<int> genreIds,
    String? originalLanguage,
    double? popularity,
    bool? adult,
    @JsonKey(fromJson: optionalInteger) int? runtime,
    String? status,
    String? tagline,
    Map<String, dynamic>? belongsToCollection,
    @Default([]) List<TmdbGenreDto> genres,
    String? creditId,
    String? character,
    String? department,
    String? job,
  }) = _TmdbMovieDto;
  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbMovieDtoFromJson(json);
}

@freezed
abstract class TmdbGenreDto with _$TmdbGenreDto {
  @JsonSerializable(checked: true)
  const factory TmdbGenreDto({
    @JsonKey(fromJson: positiveInteger) required int id,
    required String name,
  }) = _TmdbGenreDto;
  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbGenreDtoFromJson(json);
}

@freezed
abstract class TmdbPersonDto with _$TmdbPersonDto {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    checked: true,
    explicitToJson: true,
  )
  const factory TmdbPersonDto({
    @JsonKey(fromJson: positiveInteger) required int id,
    required String name,
    String? profilePath,
    String? knownForDepartment,
    String? biography,
    String? birthday,
    String? deathday,
    String? placeOfBirth,
    @Default([]) List<String> alsoKnownAs,
    String? creditId,
    String? character,
    String? department,
    String? job,
    @JsonKey(fromJson: optionalInteger) int? order,
  }) = _TmdbPersonDto;
  factory TmdbPersonDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbPersonDtoFromJson(json);
}

@freezed
abstract class TmdbCollectionDto with _$TmdbCollectionDto {
  @JsonSerializable(
    fieldRename: FieldRename.snake,
    checked: true,
    explicitToJson: true,
  )
  const factory TmdbCollectionDto({
    @JsonKey(fromJson: positiveInteger) required int id,
    String? name,
    String? title,
    String? overview,
    String? posterPath,
    String? backdropPath,
    List<Map<String, dynamic>>? parts,
  }) = _TmdbCollectionDto;
  factory TmdbCollectionDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbCollectionDtoFromJson(json);
}

@freezed
abstract class TmdbImageDto with _$TmdbImageDto {
  @JsonSerializable(fieldRename: FieldRename.snake, checked: true)
  const factory TmdbImageDto({
    required String filePath,
    @JsonKey(fromJson: positiveInteger) required int width,
    @JsonKey(fromJson: positiveInteger) required int height,
    double? aspectRatio,
    @JsonKey(name: 'iso_639_1') String? language,
  }) = _TmdbImageDto;
  factory TmdbImageDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbImageDtoFromJson(json);
}

@freezed
abstract class TmdbVideoDto with _$TmdbVideoDto {
  @JsonSerializable(fieldRename: FieldRename.snake, checked: true)
  const factory TmdbVideoDto({
    String? id,
    String? name,
    String? key,
    String? site,
    String? type,
    @Default(false) bool official,
    String? publishedAt,
  }) = _TmdbVideoDto;
  factory TmdbVideoDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbVideoDtoFromJson(json);
}

@freezed
abstract class TmdbReviewDto with _$TmdbReviewDto {
  @JsonSerializable(fieldRename: FieldRename.snake, checked: true)
  const factory TmdbReviewDto({
    required String id,
    required String author,
    required String content,
    Map<String, dynamic>? authorDetails,
    String? createdAt,
    String? updatedAt,
  }) = _TmdbReviewDto;
  factory TmdbReviewDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbReviewDtoFromJson(json);
}

@freezed
abstract class TmdbImageConfigurationDto with _$TmdbImageConfigurationDto {
  @JsonSerializable(fieldRename: FieldRename.snake, checked: true)
  const factory TmdbImageConfigurationDto({
    required String secureBaseUrl,
    required List<String> posterSizes,
    required List<String> backdropSizes,
    required List<String> profileSizes,
  }) = _TmdbImageConfigurationDto;
  factory TmdbImageConfigurationDto.fromJson(Map<String, dynamic> json) =>
      _$TmdbImageConfigurationDtoFromJson(json);
}

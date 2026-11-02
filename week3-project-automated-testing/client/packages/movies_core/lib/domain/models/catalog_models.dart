import 'package:freezed_annotation/freezed_annotation.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

@freezed
abstract class CalendarDate with _$CalendarDate {
  const CalendarDate._();
  @JsonSerializable(explicitToJson: true)
  const factory CalendarDate({
    required int year,
    required int month,
    required int day,
  }) = _CalendarDate;
  factory CalendarDate.fromJson(Map<String, dynamic> json) =>
      _$CalendarDateFromJson(json);

  static CalendarDate fromIso(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) throw const FormatException('Invalid calendar date');
    final y = int.parse(match[1]!),
        m = int.parse(match[2]!),
        d = int.parse(match[3]!);
    final date = DateTime.utc(y, m, d);
    if (date.year != y || date.month != m || date.day != d)
      throw const FormatException('Invalid calendar date');
    return CalendarDate(year: y, month: m, day: d);
  }

  String get iso =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  int compareTo(CalendarDate other) => iso.compareTo(other.iso);
}

@freezed
abstract class TmdbRating with _$TmdbRating {
  const TmdbRating._();
  @JsonSerializable(explicitToJson: true)
  const factory TmdbRating({required double average, required int voteCount}) =
      _TmdbRating;
  factory TmdbRating.fromJson(Map<String, dynamic> json) =>
      _$TmdbRatingFromJson(json);
}

@freezed
abstract class Genre with _$Genre {
  const Genre._();
  @JsonSerializable(explicitToJson: true)
  const factory Genre({required int id, required String name}) = _Genre;
  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
}

@freezed
abstract class MovieSummary with _$MovieSummary {
  const MovieSummary._();
  @JsonSerializable(explicitToJson: true)
  const factory MovieSummary({
    required int id,
    required String title,
    @Default([]) List<int> genreIds,
    String? originalTitle,
    String? overview,
    String? posterPath,
    String? backdropPath,
    CalendarDate? releaseDate,
    TmdbRating? rating,
    String? originalLanguage,
    double? popularity,
    bool? adult,
  }) = _MovieSummary;
  factory MovieSummary.fromJson(Map<String, dynamic> json) =>
      _$MovieSummaryFromJson(json);
}

@freezed
abstract class CollectionRef with _$CollectionRef {
  const CollectionRef._();
  @JsonSerializable(explicitToJson: true)
  const factory CollectionRef({
    required int id,
    required String name,
    String? posterPath,
    String? backdropPath,
  }) = _CollectionRef;
  factory CollectionRef.fromJson(Map<String, dynamic> json) =>
      _$CollectionRefFromJson(json);
}

@freezed
abstract class MovieDetails with _$MovieDetails {
  const MovieDetails._();
  @JsonSerializable(explicitToJson: true)
  const factory MovieDetails({
    required MovieSummary movie,
    @Default([]) List<Genre> genres,
    int? runtimeMinutes,
    String? status,
    String? tagline,
    CollectionRef? collection,
  }) = _MovieDetails;
  factory MovieDetails.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailsFromJson(json);
}

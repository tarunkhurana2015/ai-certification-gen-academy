import 'package:freezed_annotation/freezed_annotation.dart';
import 'catalog_models.dart';
part 'person_models.freezed.dart';
part 'person_models.g.dart';

enum CreditKind { cast, crew }

@freezed
abstract class PersonSummary with _$PersonSummary {
  const PersonSummary._();
  @JsonSerializable(explicitToJson: true)
  const factory PersonSummary({
    required int id,
    required String name,
    String? profilePath,
    String? knownForDepartment,
  }) = _PersonSummary;
  factory PersonSummary.fromJson(Map<String, dynamic> json) =>
      _$PersonSummaryFromJson(json);
}

@freezed
abstract class PersonDetails with _$PersonDetails {
  const PersonDetails._();
  @JsonSerializable(explicitToJson: true)
  const factory PersonDetails({
    required PersonSummary person,
    @Default([]) List<String> alsoKnownAs,
    String? biography,
    CalendarDate? birthday,
    CalendarDate? deathday,
    String? placeOfBirth,
  }) = _PersonDetails;
  factory PersonDetails.fromJson(Map<String, dynamic> json) =>
      _$PersonDetailsFromJson(json);
}

@freezed
abstract class CastCredit with _$CastCredit {
  const CastCredit._();
  @JsonSerializable(explicitToJson: true)
  const factory CastCredit({
    required PersonSummary person,
    String? creditId,
    String? character,
    int? order,
  }) = _CastCredit;
  factory CastCredit.fromJson(Map<String, dynamic> json) =>
      _$CastCreditFromJson(json);
}

@freezed
abstract class CrewCredit with _$CrewCredit {
  const CrewCredit._();
  @JsonSerializable(explicitToJson: true)
  const factory CrewCredit({
    required PersonSummary person,
    String? creditId,
    String? department,
    String? job,
  }) = _CrewCredit;
  factory CrewCredit.fromJson(Map<String, dynamic> json) =>
      _$CrewCreditFromJson(json);
}

@freezed
abstract class MovieCredits with _$MovieCredits {
  const MovieCredits._();
  @JsonSerializable(explicitToJson: true)
  const factory MovieCredits({
    required int movieId,
    @Default([]) List<CastCredit> cast,
    @Default([]) List<CrewCredit> crew,
  }) = _MovieCredits;
  factory MovieCredits.fromJson(Map<String, dynamic> json) =>
      _$MovieCreditsFromJson(json);
}

@freezed
abstract class CreditRole with _$CreditRole {
  const CreditRole._();
  @JsonSerializable(explicitToJson: true)
  const factory CreditRole({
    required CreditKind kind,
    String? creditId,
    String? character,
    String? department,
    String? job,
  }) = _CreditRole;
  factory CreditRole.fromJson(Map<String, dynamic> json) =>
      _$CreditRoleFromJson(json);
}

@freezed
abstract class FilmographyEntry with _$FilmographyEntry {
  const FilmographyEntry._();
  @JsonSerializable(explicitToJson: true)
  const factory FilmographyEntry({
    required MovieSummary movie,
    @Default([]) List<CreditRole> roles,
  }) = _FilmographyEntry;
  factory FilmographyEntry.fromJson(Map<String, dynamic> json) =>
      _$FilmographyEntryFromJson(json);
}

@freezed
abstract class PersonFilmography with _$PersonFilmography {
  const PersonFilmography._();
  @JsonSerializable(explicitToJson: true)
  const factory PersonFilmography({
    required int personId,
    @Default([]) List<FilmographyEntry> entries,
  }) = _PersonFilmography;
  factory PersonFilmography.fromJson(Map<String, dynamic> json) =>
      _$PersonFilmographyFromJson(json);
}

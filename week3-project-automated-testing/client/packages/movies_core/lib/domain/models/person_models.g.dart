// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PersonSummary _$PersonSummaryFromJson(Map<String, dynamic> json) =>
    _PersonSummary(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profilePath: json['profilePath'] as String?,
      knownForDepartment: json['knownForDepartment'] as String?,
    );

Map<String, dynamic> _$PersonSummaryToJson(_PersonSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profilePath': instance.profilePath,
      'knownForDepartment': instance.knownForDepartment,
    };

_PersonDetails _$PersonDetailsFromJson(Map<String, dynamic> json) =>
    _PersonDetails(
      person: PersonSummary.fromJson(json['person'] as Map<String, dynamic>),
      alsoKnownAs:
          (json['alsoKnownAs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      biography: json['biography'] as String?,
      birthday: json['birthday'] == null
          ? null
          : CalendarDate.fromJson(json['birthday'] as Map<String, dynamic>),
      deathday: json['deathday'] == null
          ? null
          : CalendarDate.fromJson(json['deathday'] as Map<String, dynamic>),
      placeOfBirth: json['placeOfBirth'] as String?,
    );

Map<String, dynamic> _$PersonDetailsToJson(_PersonDetails instance) =>
    <String, dynamic>{
      'person': instance.person.toJson(),
      'alsoKnownAs': instance.alsoKnownAs,
      'biography': instance.biography,
      'birthday': instance.birthday?.toJson(),
      'deathday': instance.deathday?.toJson(),
      'placeOfBirth': instance.placeOfBirth,
    };

_CastCredit _$CastCreditFromJson(Map<String, dynamic> json) => _CastCredit(
  person: PersonSummary.fromJson(json['person'] as Map<String, dynamic>),
  creditId: json['creditId'] as String?,
  character: json['character'] as String?,
  order: (json['order'] as num?)?.toInt(),
);

Map<String, dynamic> _$CastCreditToJson(_CastCredit instance) =>
    <String, dynamic>{
      'person': instance.person.toJson(),
      'creditId': instance.creditId,
      'character': instance.character,
      'order': instance.order,
    };

_CrewCredit _$CrewCreditFromJson(Map<String, dynamic> json) => _CrewCredit(
  person: PersonSummary.fromJson(json['person'] as Map<String, dynamic>),
  creditId: json['creditId'] as String?,
  department: json['department'] as String?,
  job: json['job'] as String?,
);

Map<String, dynamic> _$CrewCreditToJson(_CrewCredit instance) =>
    <String, dynamic>{
      'person': instance.person.toJson(),
      'creditId': instance.creditId,
      'department': instance.department,
      'job': instance.job,
    };

_MovieCredits _$MovieCreditsFromJson(Map<String, dynamic> json) =>
    _MovieCredits(
      movieId: (json['movieId'] as num).toInt(),
      cast:
          (json['cast'] as List<dynamic>?)
              ?.map((e) => CastCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      crew:
          (json['crew'] as List<dynamic>?)
              ?.map((e) => CrewCredit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$MovieCreditsToJson(_MovieCredits instance) =>
    <String, dynamic>{
      'movieId': instance.movieId,
      'cast': instance.cast.map((e) => e.toJson()).toList(),
      'crew': instance.crew.map((e) => e.toJson()).toList(),
    };

_CreditRole _$CreditRoleFromJson(Map<String, dynamic> json) => _CreditRole(
  kind: $enumDecode(_$CreditKindEnumMap, json['kind']),
  creditId: json['creditId'] as String?,
  character: json['character'] as String?,
  department: json['department'] as String?,
  job: json['job'] as String?,
);

Map<String, dynamic> _$CreditRoleToJson(_CreditRole instance) =>
    <String, dynamic>{
      'kind': _$CreditKindEnumMap[instance.kind]!,
      'creditId': instance.creditId,
      'character': instance.character,
      'department': instance.department,
      'job': instance.job,
    };

const _$CreditKindEnumMap = {CreditKind.cast: 'cast', CreditKind.crew: 'crew'};

_FilmographyEntry _$FilmographyEntryFromJson(Map<String, dynamic> json) =>
    _FilmographyEntry(
      movie: MovieSummary.fromJson(json['movie'] as Map<String, dynamic>),
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => CreditRole.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$FilmographyEntryToJson(_FilmographyEntry instance) =>
    <String, dynamic>{
      'movie': instance.movie.toJson(),
      'roles': instance.roles.map((e) => e.toJson()).toList(),
    };

_PersonFilmography _$PersonFilmographyFromJson(Map<String, dynamic> json) =>
    _PersonFilmography(
      personId: (json['personId'] as num).toInt(),
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => FilmographyEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PersonFilmographyToJson(_PersonFilmography instance) =>
    <String, dynamic>{
      'personId': instance.personId,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };

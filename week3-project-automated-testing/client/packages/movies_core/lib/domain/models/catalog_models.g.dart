// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarDate _$CalendarDateFromJson(Map<String, dynamic> json) =>
    _CalendarDate(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      day: (json['day'] as num).toInt(),
    );

Map<String, dynamic> _$CalendarDateToJson(_CalendarDate instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
    };

_TmdbRating _$TmdbRatingFromJson(Map<String, dynamic> json) => _TmdbRating(
  average: (json['average'] as num).toDouble(),
  voteCount: (json['voteCount'] as num).toInt(),
);

Map<String, dynamic> _$TmdbRatingToJson(_TmdbRating instance) =>
    <String, dynamic>{
      'average': instance.average,
      'voteCount': instance.voteCount,
    };

_Genre _$GenreFromJson(Map<String, dynamic> json) =>
    _Genre(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$GenreToJson(_Genre instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

_MovieSummary _$MovieSummaryFromJson(Map<String, dynamic> json) =>
    _MovieSummary(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      genreIds:
          (json['genreIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      originalTitle: json['originalTitle'] as String?,
      overview: json['overview'] as String?,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      releaseDate: json['releaseDate'] == null
          ? null
          : CalendarDate.fromJson(json['releaseDate'] as Map<String, dynamic>),
      rating: json['rating'] == null
          ? null
          : TmdbRating.fromJson(json['rating'] as Map<String, dynamic>),
      originalLanguage: json['originalLanguage'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      adult: json['adult'] as bool?,
    );

Map<String, dynamic> _$MovieSummaryToJson(_MovieSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'genreIds': instance.genreIds,
      'originalTitle': instance.originalTitle,
      'overview': instance.overview,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
      'releaseDate': instance.releaseDate?.toJson(),
      'rating': instance.rating?.toJson(),
      'originalLanguage': instance.originalLanguage,
      'popularity': instance.popularity,
      'adult': instance.adult,
    };

_CollectionRef _$CollectionRefFromJson(Map<String, dynamic> json) =>
    _CollectionRef(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
    );

Map<String, dynamic> _$CollectionRefToJson(_CollectionRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
    };

_MovieDetails _$MovieDetailsFromJson(Map<String, dynamic> json) =>
    _MovieDetails(
      movie: MovieSummary.fromJson(json['movie'] as Map<String, dynamic>),
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      runtimeMinutes: (json['runtimeMinutes'] as num?)?.toInt(),
      status: json['status'] as String?,
      tagline: json['tagline'] as String?,
      collection: json['collection'] == null
          ? null
          : CollectionRef.fromJson(json['collection'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieDetailsToJson(_MovieDetails instance) =>
    <String, dynamic>{
      'movie': instance.movie.toJson(),
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'runtimeMinutes': instance.runtimeMinutes,
      'status': instance.status,
      'tagline': instance.tagline,
      'collection': instance.collection?.toJson(),
    };

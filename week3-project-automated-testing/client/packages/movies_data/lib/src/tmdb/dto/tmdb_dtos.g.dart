// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tmdb_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TmdbPageDto _$TmdbPageDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_TmdbPageDto',
  json,
  ($checkedConvert) {
    final val = _TmdbPageDto(
      page: $checkedConvert('page', (v) => positiveInteger(v)),
      totalPages: $checkedConvert('total_pages', (v) => nonnegativeInteger(v)),
      totalResults: $checkedConvert(
        'total_results',
        (v) => nonnegativeInteger(v),
      ),
      results: $checkedConvert('results', (v) => jsonRows(v)),
      dates: $checkedConvert('dates', (v) => v as Map<String, dynamic>?),
    );
    return val;
  },
  fieldKeyMap: const {
    'totalPages': 'total_pages',
    'totalResults': 'total_results',
  },
);

Map<String, dynamic> _$TmdbPageDtoToJson(_TmdbPageDto instance) =>
    <String, dynamic>{
      'page': instance.page,
      'total_pages': instance.totalPages,
      'total_results': instance.totalResults,
      'results': instance.results,
      'dates': instance.dates,
    };

_TmdbMovieDto _$TmdbMovieDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_TmdbMovieDto',
  json,
  ($checkedConvert) {
    final val = _TmdbMovieDto(
      id: $checkedConvert('id', (v) => positiveInteger(v)),
      title: $checkedConvert('title', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String?),
      originalTitle: $checkedConvert('original_title', (v) => v as String?),
      originalName: $checkedConvert('original_name', (v) => v as String?),
      overview: $checkedConvert('overview', (v) => v as String?),
      posterPath: $checkedConvert('poster_path', (v) => v as String?),
      backdropPath: $checkedConvert('backdrop_path', (v) => v as String?),
      releaseDate: $checkedConvert('release_date', (v) => v as String?),
      voteAverage: $checkedConvert(
        'vote_average',
        (v) => (v as num?)?.toDouble(),
      ),
      voteCount: $checkedConvert('vote_count', (v) => optionalInteger(v)),
      genreIds: $checkedConvert(
        'genre_ids',
        (v) => v == null ? const [] : genreIdsFromJson(v),
      ),
      originalLanguage: $checkedConvert(
        'original_language',
        (v) => v as String?,
      ),
      popularity: $checkedConvert('popularity', (v) => (v as num?)?.toDouble()),
      adult: $checkedConvert('adult', (v) => v as bool?),
      runtime: $checkedConvert('runtime', (v) => optionalInteger(v)),
      status: $checkedConvert('status', (v) => v as String?),
      tagline: $checkedConvert('tagline', (v) => v as String?),
      belongsToCollection: $checkedConvert(
        'belongs_to_collection',
        (v) => v as Map<String, dynamic>?,
      ),
      genres: $checkedConvert(
        'genres',
        (v) =>
            (v as List<dynamic>?)
                ?.map((e) => TmdbGenreDto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      ),
      creditId: $checkedConvert('credit_id', (v) => v as String?),
      character: $checkedConvert('character', (v) => v as String?),
      department: $checkedConvert('department', (v) => v as String?),
      job: $checkedConvert('job', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'originalTitle': 'original_title',
    'originalName': 'original_name',
    'posterPath': 'poster_path',
    'backdropPath': 'backdrop_path',
    'releaseDate': 'release_date',
    'voteAverage': 'vote_average',
    'voteCount': 'vote_count',
    'genreIds': 'genre_ids',
    'originalLanguage': 'original_language',
    'belongsToCollection': 'belongs_to_collection',
    'creditId': 'credit_id',
  },
);

Map<String, dynamic> _$TmdbMovieDtoToJson(_TmdbMovieDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'name': instance.name,
      'original_title': instance.originalTitle,
      'original_name': instance.originalName,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'release_date': instance.releaseDate,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'genre_ids': instance.genreIds,
      'original_language': instance.originalLanguage,
      'popularity': instance.popularity,
      'adult': instance.adult,
      'runtime': instance.runtime,
      'status': instance.status,
      'tagline': instance.tagline,
      'belongs_to_collection': instance.belongsToCollection,
      'genres': instance.genres.map((e) => e.toJson()).toList(),
      'credit_id': instance.creditId,
      'character': instance.character,
      'department': instance.department,
      'job': instance.job,
    };

_TmdbGenreDto _$TmdbGenreDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TmdbGenreDto', json, ($checkedConvert) {
      final val = _TmdbGenreDto(
        id: $checkedConvert('id', (v) => positiveInteger(v)),
        name: $checkedConvert('name', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TmdbGenreDtoToJson(_TmdbGenreDto instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_TmdbPersonDto _$TmdbPersonDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_TmdbPersonDto',
      json,
      ($checkedConvert) {
        final val = _TmdbPersonDto(
          id: $checkedConvert('id', (v) => positiveInteger(v)),
          name: $checkedConvert('name', (v) => v as String),
          profilePath: $checkedConvert('profile_path', (v) => v as String?),
          knownForDepartment: $checkedConvert(
            'known_for_department',
            (v) => v as String?,
          ),
          biography: $checkedConvert('biography', (v) => v as String?),
          birthday: $checkedConvert('birthday', (v) => v as String?),
          deathday: $checkedConvert('deathday', (v) => v as String?),
          placeOfBirth: $checkedConvert('place_of_birth', (v) => v as String?),
          alsoKnownAs: $checkedConvert(
            'also_known_as',
            (v) =>
                (v as List<dynamic>?)?.map((e) => e as String).toList() ??
                const [],
          ),
          creditId: $checkedConvert('credit_id', (v) => v as String?),
          character: $checkedConvert('character', (v) => v as String?),
          department: $checkedConvert('department', (v) => v as String?),
          job: $checkedConvert('job', (v) => v as String?),
          order: $checkedConvert('order', (v) => optionalInteger(v)),
        );
        return val;
      },
      fieldKeyMap: const {
        'profilePath': 'profile_path',
        'knownForDepartment': 'known_for_department',
        'placeOfBirth': 'place_of_birth',
        'alsoKnownAs': 'also_known_as',
        'creditId': 'credit_id',
      },
    );

Map<String, dynamic> _$TmdbPersonDtoToJson(_TmdbPersonDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profile_path': instance.profilePath,
      'known_for_department': instance.knownForDepartment,
      'biography': instance.biography,
      'birthday': instance.birthday,
      'deathday': instance.deathday,
      'place_of_birth': instance.placeOfBirth,
      'also_known_as': instance.alsoKnownAs,
      'credit_id': instance.creditId,
      'character': instance.character,
      'department': instance.department,
      'job': instance.job,
      'order': instance.order,
    };

_TmdbCollectionDto _$TmdbCollectionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_TmdbCollectionDto',
      json,
      ($checkedConvert) {
        final val = _TmdbCollectionDto(
          id: $checkedConvert('id', (v) => positiveInteger(v)),
          name: $checkedConvert('name', (v) => v as String?),
          title: $checkedConvert('title', (v) => v as String?),
          overview: $checkedConvert('overview', (v) => v as String?),
          posterPath: $checkedConvert('poster_path', (v) => v as String?),
          backdropPath: $checkedConvert('backdrop_path', (v) => v as String?),
          parts: $checkedConvert(
            'parts',
            (v) => (v as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'posterPath': 'poster_path',
        'backdropPath': 'backdrop_path',
      },
    );

Map<String, dynamic> _$TmdbCollectionDtoToJson(_TmdbCollectionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'title': instance.title,
      'overview': instance.overview,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'parts': instance.parts,
    };

_TmdbImageDto _$TmdbImageDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_TmdbImageDto',
      json,
      ($checkedConvert) {
        final val = _TmdbImageDto(
          filePath: $checkedConvert('file_path', (v) => v as String),
          width: $checkedConvert('width', (v) => positiveInteger(v)),
          height: $checkedConvert('height', (v) => positiveInteger(v)),
          aspectRatio: $checkedConvert(
            'aspect_ratio',
            (v) => (v as num?)?.toDouble(),
          ),
          language: $checkedConvert('iso_639_1', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'filePath': 'file_path',
        'aspectRatio': 'aspect_ratio',
        'language': 'iso_639_1',
      },
    );

Map<String, dynamic> _$TmdbImageDtoToJson(_TmdbImageDto instance) =>
    <String, dynamic>{
      'file_path': instance.filePath,
      'width': instance.width,
      'height': instance.height,
      'aspect_ratio': instance.aspectRatio,
      'iso_639_1': instance.language,
    };

_TmdbVideoDto _$TmdbVideoDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TmdbVideoDto', json, ($checkedConvert) {
      final val = _TmdbVideoDto(
        id: $checkedConvert('id', (v) => v as String?),
        name: $checkedConvert('name', (v) => v as String?),
        key: $checkedConvert('key', (v) => v as String?),
        site: $checkedConvert('site', (v) => v as String?),
        type: $checkedConvert('type', (v) => v as String?),
        official: $checkedConvert('official', (v) => v as bool? ?? false),
        publishedAt: $checkedConvert('published_at', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'publishedAt': 'published_at'});

Map<String, dynamic> _$TmdbVideoDtoToJson(_TmdbVideoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'key': instance.key,
      'site': instance.site,
      'type': instance.type,
      'official': instance.official,
      'published_at': instance.publishedAt,
    };

_TmdbReviewDto _$TmdbReviewDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_TmdbReviewDto',
      json,
      ($checkedConvert) {
        final val = _TmdbReviewDto(
          id: $checkedConvert('id', (v) => v as String),
          author: $checkedConvert('author', (v) => v as String),
          content: $checkedConvert('content', (v) => v as String),
          authorDetails: $checkedConvert(
            'author_details',
            (v) => v as Map<String, dynamic>?,
          ),
          createdAt: $checkedConvert('created_at', (v) => v as String?),
          updatedAt: $checkedConvert('updated_at', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'authorDetails': 'author_details',
        'createdAt': 'created_at',
        'updatedAt': 'updated_at',
      },
    );

Map<String, dynamic> _$TmdbReviewDtoToJson(_TmdbReviewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'content': instance.content,
      'author_details': instance.authorDetails,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_TmdbImageConfigurationDto _$TmdbImageConfigurationDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_TmdbImageConfigurationDto',
  json,
  ($checkedConvert) {
    final val = _TmdbImageConfigurationDto(
      secureBaseUrl: $checkedConvert('secure_base_url', (v) => v as String),
      posterSizes: $checkedConvert(
        'poster_sizes',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      backdropSizes: $checkedConvert(
        'backdrop_sizes',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      profileSizes: $checkedConvert(
        'profile_sizes',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'secureBaseUrl': 'secure_base_url',
    'posterSizes': 'poster_sizes',
    'backdropSizes': 'backdrop_sizes',
    'profileSizes': 'profile_sizes',
  },
);

Map<String, dynamic> _$TmdbImageConfigurationDtoToJson(
  _TmdbImageConfigurationDto instance,
) => <String, dynamic>{
  'secure_base_url': instance.secureBaseUrl,
  'poster_sizes': instance.posterSizes,
  'backdrop_sizes': instance.backdropSizes,
  'profile_sizes': instance.profileSizes,
};

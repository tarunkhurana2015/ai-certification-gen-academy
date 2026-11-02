// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageAsset _$ImageAssetFromJson(Map<String, dynamic> json) => _ImageAsset(
  filePath: json['filePath'] as String,
  kind: $enumDecode(_$ImageKindEnumMap, json['kind']),
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  language: json['language'] as String?,
  aspectRatio: (json['aspectRatio'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ImageAssetToJson(_ImageAsset instance) =>
    <String, dynamic>{
      'filePath': instance.filePath,
      'kind': _$ImageKindEnumMap[instance.kind]!,
      'width': instance.width,
      'height': instance.height,
      'language': instance.language,
      'aspectRatio': instance.aspectRatio,
    };

const _$ImageKindEnumMap = {
  ImageKind.poster: 'poster',
  ImageKind.backdrop: 'backdrop',
  ImageKind.profile: 'profile',
};

_ImageGallery _$ImageGalleryFromJson(Map<String, dynamic> json) =>
    _ImageGallery(
      ownerKind: $enumDecode(_$OwnerKindEnumMap, json['ownerKind']),
      ownerId: (json['ownerId'] as num).toInt(),
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ImageAsset.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ImageGalleryToJson(_ImageGallery instance) =>
    <String, dynamic>{
      'ownerKind': _$OwnerKindEnumMap[instance.ownerKind]!,
      'ownerId': instance.ownerId,
      'images': instance.images.map((e) => e.toJson()).toList(),
    };

const _$OwnerKindEnumMap = {
  OwnerKind.movie: 'movie',
  OwnerKind.person: 'person',
};

_MovieReview _$MovieReviewFromJson(Map<String, dynamic> json) => _MovieReview(
  id: json['id'] as String,
  author: json['author'] as String,
  content: json['content'] as String,
  authorRating: (json['authorRating'] as num?)?.toDouble(),
  createdAtUtc: _$JsonConverterFromJson<String, DateTime>(
    json['createdAtUtc'],
    const UtcDateTimeConverter().fromJson,
  ),
  updatedAtUtc: _$JsonConverterFromJson<String, DateTime>(
    json['updatedAtUtc'],
    const UtcDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$MovieReviewToJson(_MovieReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author': instance.author,
      'content': instance.content,
      'authorRating': instance.authorRating,
      'createdAtUtc': _$JsonConverterToJson<String, DateTime>(
        instance.createdAtUtc,
        const UtcDateTimeConverter().toJson,
      ),
      'updatedAtUtc': _$JsonConverterToJson<String, DateTime>(
        instance.updatedAtUtc,
        const UtcDateTimeConverter().toJson,
      ),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_TrailerLink _$TrailerLinkFromJson(Map<String, dynamic> json) => _TrailerLink(
  id: json['id'] as String,
  movieId: (json['movieId'] as num).toInt(),
  name: json['name'] as String,
  youtubeKey: json['youtubeKey'] as String,
  url: const SecureUriConverter().fromJson(json['url'] as String),
  official: json['official'] as bool? ?? false,
  publishedAtUtc: _$JsonConverterFromJson<String, DateTime>(
    json['publishedAtUtc'],
    const UtcDateTimeConverter().fromJson,
  ),
);

Map<String, dynamic> _$TrailerLinkToJson(_TrailerLink instance) =>
    <String, dynamic>{
      'id': instance.id,
      'movieId': instance.movieId,
      'name': instance.name,
      'youtubeKey': instance.youtubeKey,
      'url': const SecureUriConverter().toJson(instance.url),
      'official': instance.official,
      'publishedAtUtc': _$JsonConverterToJson<String, DateTime>(
        instance.publishedAtUtc,
        const UtcDateTimeConverter().toJson,
      ),
    };

_MovieCollection _$MovieCollectionFromJson(Map<String, dynamic> json) =>
    _MovieCollection(
      collection: CollectionRef.fromJson(
        json['collection'] as Map<String, dynamic>,
      ),
      movies:
          (json['movies'] as List<dynamic>?)
              ?.map((e) => MovieSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      overview: json['overview'] as String?,
    );

Map<String, dynamic> _$MovieCollectionToJson(_MovieCollection instance) =>
    <String, dynamic>{
      'collection': instance.collection.toJson(),
      'movies': instance.movies.map((e) => e.toJson()).toList(),
      'overview': instance.overview,
    };

_ImageConfiguration _$ImageConfigurationFromJson(Map<String, dynamic> json) =>
    _ImageConfiguration(
      secureBaseUrl: const SecureUriConverter().fromJson(
        json['secureBaseUrl'] as String,
      ),
      posterSizes: (json['posterSizes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      backdropSizes: (json['backdropSizes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      profileSizes: (json['profileSizes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ImageConfigurationToJson(
  _ImageConfiguration instance,
) => <String, dynamic>{
  'secureBaseUrl': const SecureUriConverter().toJson(instance.secureBaseUrl),
  'posterSizes': instance.posterSizes,
  'backdropSizes': instance.backdropSizes,
  'profileSizes': instance.profileSizes,
};

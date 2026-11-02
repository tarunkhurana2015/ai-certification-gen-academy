// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FavoriteMovieSnapshot _$FavoriteMovieSnapshotFromJson(
  Map<String, dynamic> json,
) => _FavoriteMovieSnapshot(
  movieId: (json['movieId'] as num).toInt(),
  title: json['title'] as String,
  originalTitle: json['originalTitle'] as String?,
  posterPath: json['posterPath'] as String?,
  backdropPath: json['backdropPath'] as String?,
  releaseDate: json['releaseDate'] == null
      ? null
      : CalendarDate.fromJson(json['releaseDate'] as Map<String, dynamic>),
  rating: json['rating'] == null
      ? null
      : TmdbRating.fromJson(json['rating'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FavoriteMovieSnapshotToJson(
  _FavoriteMovieSnapshot instance,
) => <String, dynamic>{
  'movieId': instance.movieId,
  'title': instance.title,
  'originalTitle': instance.originalTitle,
  'posterPath': instance.posterPath,
  'backdropPath': instance.backdropPath,
  'releaseDate': instance.releaseDate?.toJson(),
  'rating': instance.rating?.toJson(),
};

_FavoriteEntry _$FavoriteEntryFromJson(Map<String, dynamic> json) =>
    _FavoriteEntry(
      movie: FavoriteMovieSnapshot.fromJson(
        json['movie'] as Map<String, dynamic>,
      ),
      addedOrder: (json['addedOrder'] as num).toInt(),
      addedAtUtc: const UtcDateTimeConverter().fromJson(
        json['addedAtUtc'] as String,
      ),
    );

Map<String, dynamic> _$FavoriteEntryToJson(_FavoriteEntry instance) =>
    <String, dynamic>{
      'movie': instance.movie.toJson(),
      'addedOrder': instance.addedOrder,
      'addedAtUtc': const UtcDateTimeConverter().toJson(instance.addedAtUtc),
    };

_FavoritesBaseline _$FavoritesBaselineFromJson(Map<String, dynamic> json) =>
    _FavoritesBaseline(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => FavoriteEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastAddedOrder: (json['lastAddedOrder'] as num).toInt(),
    );

Map<String, dynamic> _$FavoritesBaselineToJson(_FavoritesBaseline instance) =>
    <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'lastAddedOrder': instance.lastAddedOrder,
    };

_FavoriteWriteCommand _$FavoriteWriteCommandFromJson(
  Map<String, dynamic> json,
) => _FavoriteWriteCommand(
  intentRevision: (json['intentRevision'] as num).toInt(),
  movieId: (json['movieId'] as num).toInt(),
  desiredEntry: json['desiredEntry'] == null
      ? null
      : FavoriteEntry.fromJson(json['desiredEntry'] as Map<String, dynamic>),
);

Map<String, dynamic> _$FavoriteWriteCommandToJson(
  _FavoriteWriteCommand instance,
) => <String, dynamic>{
  'intentRevision': instance.intentRevision,
  'movieId': instance.movieId,
  'desiredEntry': instance.desiredEntry?.toJson(),
};

_PersistenceAck _$PersistenceAckFromJson(Map<String, dynamic> json) =>
    _PersistenceAck(
      intentRevision: (json['intentRevision'] as num).toInt(),
      movieId: (json['movieId'] as num).toInt(),
      committedAtUtc: const UtcDateTimeConverter().fromJson(
        json['committedAtUtc'] as String,
      ),
      storedEntry: json['storedEntry'] == null
          ? null
          : FavoriteEntry.fromJson(json['storedEntry'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PersistenceAckToJson(_PersistenceAck instance) =>
    <String, dynamic>{
      'intentRevision': instance.intentRevision,
      'movieId': instance.movieId,
      'committedAtUtc': const UtcDateTimeConverter().toJson(
        instance.committedAtUtc,
      ),
      'storedEntry': instance.storedEntry?.toJson(),
    };

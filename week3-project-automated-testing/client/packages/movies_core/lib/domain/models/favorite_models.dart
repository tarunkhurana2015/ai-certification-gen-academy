import 'json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'catalog_models.dart';
part 'favorite_models.freezed.dart';
part 'favorite_models.g.dart';

@freezed
abstract class FavoriteMovieSnapshot with _$FavoriteMovieSnapshot {
  const FavoriteMovieSnapshot._();
  @JsonSerializable(explicitToJson: true)
  const factory FavoriteMovieSnapshot({
    required int movieId,
    required String title,
    String? originalTitle,
    String? posterPath,
    String? backdropPath,
    CalendarDate? releaseDate,
    TmdbRating? rating,
  }) = _FavoriteMovieSnapshot;
  factory FavoriteMovieSnapshot.fromJson(Map<String, dynamic> json) =>
      _$FavoriteMovieSnapshotFromJson(json);
}

@freezed
abstract class FavoriteEntry with _$FavoriteEntry {
  const FavoriteEntry._();
  @JsonSerializable(explicitToJson: true)
  const factory FavoriteEntry({
    required FavoriteMovieSnapshot movie,
    required int addedOrder,
    @UtcDateTimeConverter() required DateTime addedAtUtc,
  }) = _FavoriteEntry;
  factory FavoriteEntry.fromJson(Map<String, dynamic> json) =>
      _$FavoriteEntryFromJson(json);
}

@freezed
abstract class FavoritesBaseline with _$FavoritesBaseline {
  const FavoritesBaseline._();
  @JsonSerializable(explicitToJson: true)
  const factory FavoritesBaseline({
    required List<FavoriteEntry> entries,
    required int lastAddedOrder,
  }) = _FavoritesBaseline;
  factory FavoritesBaseline.fromJson(Map<String, dynamic> json) =>
      _$FavoritesBaselineFromJson(json);
}

@freezed
abstract class FavoriteWriteCommand with _$FavoriteWriteCommand {
  const FavoriteWriteCommand._();
  @JsonSerializable(explicitToJson: true)
  const factory FavoriteWriteCommand({
    required int intentRevision,
    required int movieId,
    FavoriteEntry? desiredEntry,
  }) = _FavoriteWriteCommand;
  factory FavoriteWriteCommand.fromJson(Map<String, dynamic> json) =>
      _$FavoriteWriteCommandFromJson(json);
}

@freezed
abstract class PersistenceAck with _$PersistenceAck {
  const PersistenceAck._();
  @JsonSerializable(explicitToJson: true)
  const factory PersistenceAck({
    required int intentRevision,
    required int movieId,
    @UtcDateTimeConverter() required DateTime committedAtUtc,
    FavoriteEntry? storedEntry,
  }) = _PersistenceAck;
  factory PersistenceAck.fromJson(Map<String, dynamic> json) =>
      _$PersistenceAckFromJson(json);
}

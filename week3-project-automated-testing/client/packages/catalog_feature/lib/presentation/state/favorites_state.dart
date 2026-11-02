import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:movies_core/movies_core.dart';
part 'favorites_state.freezed.dart';
part 'favorites_state.g.dart';

@freezed
abstract class UndoOffer with _$UndoOffer {
  const UndoOffer._();
  @JsonSerializable(explicitToJson: true)
  const factory UndoOffer({
    required String token,
    required FavoriteEntry entry,
    required int removalRevision,
    required int deadlineMs,
  }) = _UndoOffer;
  factory UndoOffer.fromJson(Map<String, dynamic> json) =>
      _$UndoOfferFromJson(json);
}

@freezed
abstract class FavoritesState with _$FavoritesState {
  const FavoritesState._();
  @JsonSerializable(explicitToJson: true)
  const factory FavoritesState({
    @Default(false) bool ready,
    @Default(true) bool loading,
    @Default([]) List<FavoriteEntry> entries,
    @Default([]) List<FavoriteWriteCommand> pending,
    @Default({}) Map<int, AppFailure> writeFailures,
    AppFailure? readFailure,
    UndoOffer? undo,
  }) = _FavoritesState;
  factory FavoritesState.fromJson(Map<String, dynamic> json) =>
      _$FavoritesStateFromJson(json);
  bool contains(int movieId) => entries.any((e) => e.movie.movieId == movieId);
}

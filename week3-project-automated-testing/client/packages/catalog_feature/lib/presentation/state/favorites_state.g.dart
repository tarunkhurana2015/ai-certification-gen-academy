// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UndoOffer _$UndoOfferFromJson(Map<String, dynamic> json) => _UndoOffer(
  token: json['token'] as String,
  entry: FavoriteEntry.fromJson(json['entry'] as Map<String, dynamic>),
  removalRevision: (json['removalRevision'] as num).toInt(),
  deadlineMs: (json['deadlineMs'] as num).toInt(),
);

Map<String, dynamic> _$UndoOfferToJson(_UndoOffer instance) =>
    <String, dynamic>{
      'token': instance.token,
      'entry': instance.entry.toJson(),
      'removalRevision': instance.removalRevision,
      'deadlineMs': instance.deadlineMs,
    };

_FavoritesState _$FavoritesStateFromJson(Map<String, dynamic> json) =>
    _FavoritesState(
      ready: json['ready'] as bool? ?? false,
      loading: json['loading'] as bool? ?? true,
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => FavoriteEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      pending:
          (json['pending'] as List<dynamic>?)
              ?.map(
                (e) => FavoriteWriteCommand.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      writeFailures:
          (json['writeFailures'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              int.parse(k),
              AppFailure.fromJson(e as Map<String, dynamic>),
            ),
          ) ??
          const {},
      readFailure: json['readFailure'] == null
          ? null
          : AppFailure.fromJson(json['readFailure'] as Map<String, dynamic>),
      undo: json['undo'] == null
          ? null
          : UndoOffer.fromJson(json['undo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FavoritesStateToJson(_FavoritesState instance) =>
    <String, dynamic>{
      'ready': instance.ready,
      'loading': instance.loading,
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'pending': instance.pending.map((e) => e.toJson()).toList(),
      'writeFailures': instance.writeFailures.map(
        (k, e) => MapEntry(k.toString(), e.toJson()),
      ),
      'readFailure': instance.readFailure?.toJson(),
      'undo': instance.undo?.toJson(),
    };

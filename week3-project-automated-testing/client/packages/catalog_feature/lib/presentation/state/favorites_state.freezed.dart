// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorites_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UndoOffer {

 String get token; FavoriteEntry get entry; int get removalRevision; int get deadlineMs;
/// Create a copy of UndoOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UndoOfferCopyWith<UndoOffer> get copyWith => _$UndoOfferCopyWithImpl<UndoOffer>(this as UndoOffer, _$identity);

  /// Serializes this UndoOffer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UndoOffer&&(identical(other.token, token) || other.token == token)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.removalRevision, removalRevision) || other.removalRevision == removalRevision)&&(identical(other.deadlineMs, deadlineMs) || other.deadlineMs == deadlineMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,entry,removalRevision,deadlineMs);

@override
String toString() {
  return 'UndoOffer(token: $token, entry: $entry, removalRevision: $removalRevision, deadlineMs: $deadlineMs)';
}


}

/// @nodoc
abstract mixin class $UndoOfferCopyWith<$Res>  {
  factory $UndoOfferCopyWith(UndoOffer value, $Res Function(UndoOffer) _then) = _$UndoOfferCopyWithImpl;
@useResult
$Res call({
 String token, FavoriteEntry entry, int removalRevision, int deadlineMs
});


$FavoriteEntryCopyWith<$Res> get entry;

}
/// @nodoc
class _$UndoOfferCopyWithImpl<$Res>
    implements $UndoOfferCopyWith<$Res> {
  _$UndoOfferCopyWithImpl(this._self, this._then);

  final UndoOffer _self;
  final $Res Function(UndoOffer) _then;

/// Create a copy of UndoOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? entry = null,Object? removalRevision = null,Object? deadlineMs = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FavoriteEntry,removalRevision: null == removalRevision ? _self.removalRevision : removalRevision // ignore: cast_nullable_to_non_nullable
as int,deadlineMs: null == deadlineMs ? _self.deadlineMs : deadlineMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of UndoOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<$Res> get entry {
  
  return $FavoriteEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [UndoOffer].
extension UndoOfferPatterns on UndoOffer {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UndoOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UndoOffer() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UndoOffer value)  $default,){
final _that = this;
switch (_that) {
case _UndoOffer():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UndoOffer value)?  $default,){
final _that = this;
switch (_that) {
case _UndoOffer() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token,  FavoriteEntry entry,  int removalRevision,  int deadlineMs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UndoOffer() when $default != null:
return $default(_that.token,_that.entry,_that.removalRevision,_that.deadlineMs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token,  FavoriteEntry entry,  int removalRevision,  int deadlineMs)  $default,) {final _that = this;
switch (_that) {
case _UndoOffer():
return $default(_that.token,_that.entry,_that.removalRevision,_that.deadlineMs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token,  FavoriteEntry entry,  int removalRevision,  int deadlineMs)?  $default,) {final _that = this;
switch (_that) {
case _UndoOffer() when $default != null:
return $default(_that.token,_that.entry,_that.removalRevision,_that.deadlineMs);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _UndoOffer extends UndoOffer {
  const _UndoOffer({required this.token, required this.entry, required this.removalRevision, required this.deadlineMs}): super._();
  factory _UndoOffer.fromJson(Map<String, dynamic> json) => _$UndoOfferFromJson(json);

@override final  String token;
@override final  FavoriteEntry entry;
@override final  int removalRevision;
@override final  int deadlineMs;

/// Create a copy of UndoOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UndoOfferCopyWith<_UndoOffer> get copyWith => __$UndoOfferCopyWithImpl<_UndoOffer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UndoOfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UndoOffer&&(identical(other.token, token) || other.token == token)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.removalRevision, removalRevision) || other.removalRevision == removalRevision)&&(identical(other.deadlineMs, deadlineMs) || other.deadlineMs == deadlineMs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,entry,removalRevision,deadlineMs);

@override
String toString() {
  return 'UndoOffer(token: $token, entry: $entry, removalRevision: $removalRevision, deadlineMs: $deadlineMs)';
}


}

/// @nodoc
abstract mixin class _$UndoOfferCopyWith<$Res> implements $UndoOfferCopyWith<$Res> {
  factory _$UndoOfferCopyWith(_UndoOffer value, $Res Function(_UndoOffer) _then) = __$UndoOfferCopyWithImpl;
@override @useResult
$Res call({
 String token, FavoriteEntry entry, int removalRevision, int deadlineMs
});


@override $FavoriteEntryCopyWith<$Res> get entry;

}
/// @nodoc
class __$UndoOfferCopyWithImpl<$Res>
    implements _$UndoOfferCopyWith<$Res> {
  __$UndoOfferCopyWithImpl(this._self, this._then);

  final _UndoOffer _self;
  final $Res Function(_UndoOffer) _then;

/// Create a copy of UndoOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? entry = null,Object? removalRevision = null,Object? deadlineMs = null,}) {
  return _then(_UndoOffer(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as FavoriteEntry,removalRevision: null == removalRevision ? _self.removalRevision : removalRevision // ignore: cast_nullable_to_non_nullable
as int,deadlineMs: null == deadlineMs ? _self.deadlineMs : deadlineMs // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of UndoOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<$Res> get entry {
  
  return $FavoriteEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// @nodoc
mixin _$FavoritesState {

 bool get ready; bool get loading; List<FavoriteEntry> get entries; List<FavoriteWriteCommand> get pending; Map<int, AppFailure> get writeFailures; AppFailure? get readFailure; UndoOffer? get undo;
/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoritesStateCopyWith<FavoritesState> get copyWith => _$FavoritesStateCopyWithImpl<FavoritesState>(this as FavoritesState, _$identity);

  /// Serializes this FavoritesState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesState&&(identical(other.ready, ready) || other.ready == ready)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other.entries, entries)&&const DeepCollectionEquality().equals(other.pending, pending)&&const DeepCollectionEquality().equals(other.writeFailures, writeFailures)&&(identical(other.readFailure, readFailure) || other.readFailure == readFailure)&&(identical(other.undo, undo) || other.undo == undo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ready,loading,const DeepCollectionEquality().hash(entries),const DeepCollectionEquality().hash(pending),const DeepCollectionEquality().hash(writeFailures),readFailure,undo);

@override
String toString() {
  return 'FavoritesState(ready: $ready, loading: $loading, entries: $entries, pending: $pending, writeFailures: $writeFailures, readFailure: $readFailure, undo: $undo)';
}


}

/// @nodoc
abstract mixin class $FavoritesStateCopyWith<$Res>  {
  factory $FavoritesStateCopyWith(FavoritesState value, $Res Function(FavoritesState) _then) = _$FavoritesStateCopyWithImpl;
@useResult
$Res call({
 bool ready, bool loading, List<FavoriteEntry> entries, List<FavoriteWriteCommand> pending, Map<int, AppFailure> writeFailures, AppFailure? readFailure, UndoOffer? undo
});


$AppFailureCopyWith<$Res>? get readFailure;$UndoOfferCopyWith<$Res>? get undo;

}
/// @nodoc
class _$FavoritesStateCopyWithImpl<$Res>
    implements $FavoritesStateCopyWith<$Res> {
  _$FavoritesStateCopyWithImpl(this._self, this._then);

  final FavoritesState _self;
  final $Res Function(FavoritesState) _then;

/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ready = null,Object? loading = null,Object? entries = null,Object? pending = null,Object? writeFailures = null,Object? readFailure = freezed,Object? undo = freezed,}) {
  return _then(_self.copyWith(
ready: null == ready ? _self.ready : ready // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<FavoriteEntry>,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as List<FavoriteWriteCommand>,writeFailures: null == writeFailures ? _self.writeFailures : writeFailures // ignore: cast_nullable_to_non_nullable
as Map<int, AppFailure>,readFailure: freezed == readFailure ? _self.readFailure : readFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,undo: freezed == undo ? _self.undo : undo // ignore: cast_nullable_to_non_nullable
as UndoOffer?,
  ));
}
/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppFailureCopyWith<$Res>? get readFailure {
    if (_self.readFailure == null) {
    return null;
  }

  return $AppFailureCopyWith<$Res>(_self.readFailure!, (value) {
    return _then(_self.copyWith(readFailure: value));
  });
}/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UndoOfferCopyWith<$Res>? get undo {
    if (_self.undo == null) {
    return null;
  }

  return $UndoOfferCopyWith<$Res>(_self.undo!, (value) {
    return _then(_self.copyWith(undo: value));
  });
}
}


/// Adds pattern-matching-related methods to [FavoritesState].
extension FavoritesStatePatterns on FavoritesState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoritesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoritesState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoritesState value)  $default,){
final _that = this;
switch (_that) {
case _FavoritesState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoritesState value)?  $default,){
final _that = this;
switch (_that) {
case _FavoritesState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool ready,  bool loading,  List<FavoriteEntry> entries,  List<FavoriteWriteCommand> pending,  Map<int, AppFailure> writeFailures,  AppFailure? readFailure,  UndoOffer? undo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoritesState() when $default != null:
return $default(_that.ready,_that.loading,_that.entries,_that.pending,_that.writeFailures,_that.readFailure,_that.undo);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool ready,  bool loading,  List<FavoriteEntry> entries,  List<FavoriteWriteCommand> pending,  Map<int, AppFailure> writeFailures,  AppFailure? readFailure,  UndoOffer? undo)  $default,) {final _that = this;
switch (_that) {
case _FavoritesState():
return $default(_that.ready,_that.loading,_that.entries,_that.pending,_that.writeFailures,_that.readFailure,_that.undo);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool ready,  bool loading,  List<FavoriteEntry> entries,  List<FavoriteWriteCommand> pending,  Map<int, AppFailure> writeFailures,  AppFailure? readFailure,  UndoOffer? undo)?  $default,) {final _that = this;
switch (_that) {
case _FavoritesState() when $default != null:
return $default(_that.ready,_that.loading,_that.entries,_that.pending,_that.writeFailures,_that.readFailure,_that.undo);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _FavoritesState extends FavoritesState {
  const _FavoritesState({this.ready = false, this.loading = true, final  List<FavoriteEntry> entries = const [], final  List<FavoriteWriteCommand> pending = const [], final  Map<int, AppFailure> writeFailures = const {}, this.readFailure, this.undo}): _entries = entries,_pending = pending,_writeFailures = writeFailures,super._();
  factory _FavoritesState.fromJson(Map<String, dynamic> json) => _$FavoritesStateFromJson(json);

@override@JsonKey() final  bool ready;
@override@JsonKey() final  bool loading;
 final  List<FavoriteEntry> _entries;
@override@JsonKey() List<FavoriteEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

 final  List<FavoriteWriteCommand> _pending;
@override@JsonKey() List<FavoriteWriteCommand> get pending {
  if (_pending is EqualUnmodifiableListView) return _pending;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pending);
}

 final  Map<int, AppFailure> _writeFailures;
@override@JsonKey() Map<int, AppFailure> get writeFailures {
  if (_writeFailures is EqualUnmodifiableMapView) return _writeFailures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_writeFailures);
}

@override final  AppFailure? readFailure;
@override final  UndoOffer? undo;

/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoritesStateCopyWith<_FavoritesState> get copyWith => __$FavoritesStateCopyWithImpl<_FavoritesState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoritesStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoritesState&&(identical(other.ready, ready) || other.ready == ready)&&(identical(other.loading, loading) || other.loading == loading)&&const DeepCollectionEquality().equals(other._entries, _entries)&&const DeepCollectionEquality().equals(other._pending, _pending)&&const DeepCollectionEquality().equals(other._writeFailures, _writeFailures)&&(identical(other.readFailure, readFailure) || other.readFailure == readFailure)&&(identical(other.undo, undo) || other.undo == undo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ready,loading,const DeepCollectionEquality().hash(_entries),const DeepCollectionEquality().hash(_pending),const DeepCollectionEquality().hash(_writeFailures),readFailure,undo);

@override
String toString() {
  return 'FavoritesState(ready: $ready, loading: $loading, entries: $entries, pending: $pending, writeFailures: $writeFailures, readFailure: $readFailure, undo: $undo)';
}


}

/// @nodoc
abstract mixin class _$FavoritesStateCopyWith<$Res> implements $FavoritesStateCopyWith<$Res> {
  factory _$FavoritesStateCopyWith(_FavoritesState value, $Res Function(_FavoritesState) _then) = __$FavoritesStateCopyWithImpl;
@override @useResult
$Res call({
 bool ready, bool loading, List<FavoriteEntry> entries, List<FavoriteWriteCommand> pending, Map<int, AppFailure> writeFailures, AppFailure? readFailure, UndoOffer? undo
});


@override $AppFailureCopyWith<$Res>? get readFailure;@override $UndoOfferCopyWith<$Res>? get undo;

}
/// @nodoc
class __$FavoritesStateCopyWithImpl<$Res>
    implements _$FavoritesStateCopyWith<$Res> {
  __$FavoritesStateCopyWithImpl(this._self, this._then);

  final _FavoritesState _self;
  final $Res Function(_FavoritesState) _then;

/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ready = null,Object? loading = null,Object? entries = null,Object? pending = null,Object? writeFailures = null,Object? readFailure = freezed,Object? undo = freezed,}) {
  return _then(_FavoritesState(
ready: null == ready ? _self.ready : ready // ignore: cast_nullable_to_non_nullable
as bool,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<FavoriteEntry>,pending: null == pending ? _self._pending : pending // ignore: cast_nullable_to_non_nullable
as List<FavoriteWriteCommand>,writeFailures: null == writeFailures ? _self._writeFailures : writeFailures // ignore: cast_nullable_to_non_nullable
as Map<int, AppFailure>,readFailure: freezed == readFailure ? _self.readFailure : readFailure // ignore: cast_nullable_to_non_nullable
as AppFailure?,undo: freezed == undo ? _self.undo : undo // ignore: cast_nullable_to_non_nullable
as UndoOffer?,
  ));
}

/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppFailureCopyWith<$Res>? get readFailure {
    if (_self.readFailure == null) {
    return null;
  }

  return $AppFailureCopyWith<$Res>(_self.readFailure!, (value) {
    return _then(_self.copyWith(readFailure: value));
  });
}/// Create a copy of FavoritesState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UndoOfferCopyWith<$Res>? get undo {
    if (_self.undo == null) {
    return null;
  }

  return $UndoOfferCopyWith<$Res>(_self.undo!, (value) {
    return _then(_self.copyWith(undo: value));
  });
}
}

// dart format on

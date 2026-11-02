// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FavoriteMovieSnapshot {

 int get movieId; String get title; String? get originalTitle; String? get posterPath; String? get backdropPath; CalendarDate? get releaseDate; TmdbRating? get rating;
/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteMovieSnapshotCopyWith<FavoriteMovieSnapshot> get copyWith => _$FavoriteMovieSnapshotCopyWithImpl<FavoriteMovieSnapshot>(this as FavoriteMovieSnapshot, _$identity);

  /// Serializes this FavoriteMovieSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteMovieSnapshot&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movieId,title,originalTitle,posterPath,backdropPath,releaseDate,rating);

@override
String toString() {
  return 'FavoriteMovieSnapshot(movieId: $movieId, title: $title, originalTitle: $originalTitle, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, rating: $rating)';
}


}

/// @nodoc
abstract mixin class $FavoriteMovieSnapshotCopyWith<$Res>  {
  factory $FavoriteMovieSnapshotCopyWith(FavoriteMovieSnapshot value, $Res Function(FavoriteMovieSnapshot) _then) = _$FavoriteMovieSnapshotCopyWithImpl;
@useResult
$Res call({
 int movieId, String title, String? originalTitle, String? posterPath, String? backdropPath, CalendarDate? releaseDate, TmdbRating? rating
});


$CalendarDateCopyWith<$Res>? get releaseDate;$TmdbRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class _$FavoriteMovieSnapshotCopyWithImpl<$Res>
    implements $FavoriteMovieSnapshotCopyWith<$Res> {
  _$FavoriteMovieSnapshotCopyWithImpl(this._self, this._then);

  final FavoriteMovieSnapshot _self;
  final $Res Function(FavoriteMovieSnapshot) _then;

/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movieId = null,Object? title = null,Object? originalTitle = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? rating = freezed,}) {
  return _then(_self.copyWith(
movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as CalendarDate?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as TmdbRating?,
  ));
}
/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res>? get releaseDate {
    if (_self.releaseDate == null) {
    return null;
  }

  return $CalendarDateCopyWith<$Res>(_self.releaseDate!, (value) {
    return _then(_self.copyWith(releaseDate: value));
  });
}/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TmdbRatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $TmdbRatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// Adds pattern-matching-related methods to [FavoriteMovieSnapshot].
extension FavoriteMovieSnapshotPatterns on FavoriteMovieSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteMovieSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteMovieSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteMovieSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteMovieSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteMovieSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteMovieSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int movieId,  String title,  String? originalTitle,  String? posterPath,  String? backdropPath,  CalendarDate? releaseDate,  TmdbRating? rating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteMovieSnapshot() when $default != null:
return $default(_that.movieId,_that.title,_that.originalTitle,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.rating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int movieId,  String title,  String? originalTitle,  String? posterPath,  String? backdropPath,  CalendarDate? releaseDate,  TmdbRating? rating)  $default,) {final _that = this;
switch (_that) {
case _FavoriteMovieSnapshot():
return $default(_that.movieId,_that.title,_that.originalTitle,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.rating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int movieId,  String title,  String? originalTitle,  String? posterPath,  String? backdropPath,  CalendarDate? releaseDate,  TmdbRating? rating)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteMovieSnapshot() when $default != null:
return $default(_that.movieId,_that.title,_that.originalTitle,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.rating);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _FavoriteMovieSnapshot extends FavoriteMovieSnapshot {
  const _FavoriteMovieSnapshot({required this.movieId, required this.title, this.originalTitle, this.posterPath, this.backdropPath, this.releaseDate, this.rating}): super._();
  factory _FavoriteMovieSnapshot.fromJson(Map<String, dynamic> json) => _$FavoriteMovieSnapshotFromJson(json);

@override final  int movieId;
@override final  String title;
@override final  String? originalTitle;
@override final  String? posterPath;
@override final  String? backdropPath;
@override final  CalendarDate? releaseDate;
@override final  TmdbRating? rating;

/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteMovieSnapshotCopyWith<_FavoriteMovieSnapshot> get copyWith => __$FavoriteMovieSnapshotCopyWithImpl<_FavoriteMovieSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteMovieSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteMovieSnapshot&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.rating, rating) || other.rating == rating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movieId,title,originalTitle,posterPath,backdropPath,releaseDate,rating);

@override
String toString() {
  return 'FavoriteMovieSnapshot(movieId: $movieId, title: $title, originalTitle: $originalTitle, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, rating: $rating)';
}


}

/// @nodoc
abstract mixin class _$FavoriteMovieSnapshotCopyWith<$Res> implements $FavoriteMovieSnapshotCopyWith<$Res> {
  factory _$FavoriteMovieSnapshotCopyWith(_FavoriteMovieSnapshot value, $Res Function(_FavoriteMovieSnapshot) _then) = __$FavoriteMovieSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int movieId, String title, String? originalTitle, String? posterPath, String? backdropPath, CalendarDate? releaseDate, TmdbRating? rating
});


@override $CalendarDateCopyWith<$Res>? get releaseDate;@override $TmdbRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class __$FavoriteMovieSnapshotCopyWithImpl<$Res>
    implements _$FavoriteMovieSnapshotCopyWith<$Res> {
  __$FavoriteMovieSnapshotCopyWithImpl(this._self, this._then);

  final _FavoriteMovieSnapshot _self;
  final $Res Function(_FavoriteMovieSnapshot) _then;

/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movieId = null,Object? title = null,Object? originalTitle = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? rating = freezed,}) {
  return _then(_FavoriteMovieSnapshot(
movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as CalendarDate?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as TmdbRating?,
  ));
}

/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res>? get releaseDate {
    if (_self.releaseDate == null) {
    return null;
  }

  return $CalendarDateCopyWith<$Res>(_self.releaseDate!, (value) {
    return _then(_self.copyWith(releaseDate: value));
  });
}/// Create a copy of FavoriteMovieSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TmdbRatingCopyWith<$Res>? get rating {
    if (_self.rating == null) {
    return null;
  }

  return $TmdbRatingCopyWith<$Res>(_self.rating!, (value) {
    return _then(_self.copyWith(rating: value));
  });
}
}


/// @nodoc
mixin _$FavoriteEntry {

 FavoriteMovieSnapshot get movie; int get addedOrder;@UtcDateTimeConverter() DateTime get addedAtUtc;
/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<FavoriteEntry> get copyWith => _$FavoriteEntryCopyWithImpl<FavoriteEntry>(this as FavoriteEntry, _$identity);

  /// Serializes this FavoriteEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteEntry&&(identical(other.movie, movie) || other.movie == movie)&&(identical(other.addedOrder, addedOrder) || other.addedOrder == addedOrder)&&(identical(other.addedAtUtc, addedAtUtc) || other.addedAtUtc == addedAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,addedOrder,addedAtUtc);

@override
String toString() {
  return 'FavoriteEntry(movie: $movie, addedOrder: $addedOrder, addedAtUtc: $addedAtUtc)';
}


}

/// @nodoc
abstract mixin class $FavoriteEntryCopyWith<$Res>  {
  factory $FavoriteEntryCopyWith(FavoriteEntry value, $Res Function(FavoriteEntry) _then) = _$FavoriteEntryCopyWithImpl;
@useResult
$Res call({
 FavoriteMovieSnapshot movie, int addedOrder,@UtcDateTimeConverter() DateTime addedAtUtc
});


$FavoriteMovieSnapshotCopyWith<$Res> get movie;

}
/// @nodoc
class _$FavoriteEntryCopyWithImpl<$Res>
    implements $FavoriteEntryCopyWith<$Res> {
  _$FavoriteEntryCopyWithImpl(this._self, this._then);

  final FavoriteEntry _self;
  final $Res Function(FavoriteEntry) _then;

/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movie = null,Object? addedOrder = null,Object? addedAtUtc = null,}) {
  return _then(_self.copyWith(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as FavoriteMovieSnapshot,addedOrder: null == addedOrder ? _self.addedOrder : addedOrder // ignore: cast_nullable_to_non_nullable
as int,addedAtUtc: null == addedAtUtc ? _self.addedAtUtc : addedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteMovieSnapshotCopyWith<$Res> get movie {
  
  return $FavoriteMovieSnapshotCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}


/// Adds pattern-matching-related methods to [FavoriteEntry].
extension FavoriteEntryPatterns on FavoriteEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteEntry value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FavoriteMovieSnapshot movie,  int addedOrder, @UtcDateTimeConverter()  DateTime addedAtUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
return $default(_that.movie,_that.addedOrder,_that.addedAtUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FavoriteMovieSnapshot movie,  int addedOrder, @UtcDateTimeConverter()  DateTime addedAtUtc)  $default,) {final _that = this;
switch (_that) {
case _FavoriteEntry():
return $default(_that.movie,_that.addedOrder,_that.addedAtUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FavoriteMovieSnapshot movie,  int addedOrder, @UtcDateTimeConverter()  DateTime addedAtUtc)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteEntry() when $default != null:
return $default(_that.movie,_that.addedOrder,_that.addedAtUtc);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _FavoriteEntry extends FavoriteEntry {
  const _FavoriteEntry({required this.movie, required this.addedOrder, @UtcDateTimeConverter() required this.addedAtUtc}): super._();
  factory _FavoriteEntry.fromJson(Map<String, dynamic> json) => _$FavoriteEntryFromJson(json);

@override final  FavoriteMovieSnapshot movie;
@override final  int addedOrder;
@override@UtcDateTimeConverter() final  DateTime addedAtUtc;

/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteEntryCopyWith<_FavoriteEntry> get copyWith => __$FavoriteEntryCopyWithImpl<_FavoriteEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteEntry&&(identical(other.movie, movie) || other.movie == movie)&&(identical(other.addedOrder, addedOrder) || other.addedOrder == addedOrder)&&(identical(other.addedAtUtc, addedAtUtc) || other.addedAtUtc == addedAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,addedOrder,addedAtUtc);

@override
String toString() {
  return 'FavoriteEntry(movie: $movie, addedOrder: $addedOrder, addedAtUtc: $addedAtUtc)';
}


}

/// @nodoc
abstract mixin class _$FavoriteEntryCopyWith<$Res> implements $FavoriteEntryCopyWith<$Res> {
  factory _$FavoriteEntryCopyWith(_FavoriteEntry value, $Res Function(_FavoriteEntry) _then) = __$FavoriteEntryCopyWithImpl;
@override @useResult
$Res call({
 FavoriteMovieSnapshot movie, int addedOrder,@UtcDateTimeConverter() DateTime addedAtUtc
});


@override $FavoriteMovieSnapshotCopyWith<$Res> get movie;

}
/// @nodoc
class __$FavoriteEntryCopyWithImpl<$Res>
    implements _$FavoriteEntryCopyWith<$Res> {
  __$FavoriteEntryCopyWithImpl(this._self, this._then);

  final _FavoriteEntry _self;
  final $Res Function(_FavoriteEntry) _then;

/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movie = null,Object? addedOrder = null,Object? addedAtUtc = null,}) {
  return _then(_FavoriteEntry(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as FavoriteMovieSnapshot,addedOrder: null == addedOrder ? _self.addedOrder : addedOrder // ignore: cast_nullable_to_non_nullable
as int,addedAtUtc: null == addedAtUtc ? _self.addedAtUtc : addedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of FavoriteEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteMovieSnapshotCopyWith<$Res> get movie {
  
  return $FavoriteMovieSnapshotCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}


/// @nodoc
mixin _$FavoritesBaseline {

 List<FavoriteEntry> get entries; int get lastAddedOrder;
/// Create a copy of FavoritesBaseline
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoritesBaselineCopyWith<FavoritesBaseline> get copyWith => _$FavoritesBaselineCopyWithImpl<FavoritesBaseline>(this as FavoritesBaseline, _$identity);

  /// Serializes this FavoritesBaseline to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoritesBaseline&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.lastAddedOrder, lastAddedOrder) || other.lastAddedOrder == lastAddedOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries),lastAddedOrder);

@override
String toString() {
  return 'FavoritesBaseline(entries: $entries, lastAddedOrder: $lastAddedOrder)';
}


}

/// @nodoc
abstract mixin class $FavoritesBaselineCopyWith<$Res>  {
  factory $FavoritesBaselineCopyWith(FavoritesBaseline value, $Res Function(FavoritesBaseline) _then) = _$FavoritesBaselineCopyWithImpl;
@useResult
$Res call({
 List<FavoriteEntry> entries, int lastAddedOrder
});




}
/// @nodoc
class _$FavoritesBaselineCopyWithImpl<$Res>
    implements $FavoritesBaselineCopyWith<$Res> {
  _$FavoritesBaselineCopyWithImpl(this._self, this._then);

  final FavoritesBaseline _self;
  final $Res Function(FavoritesBaseline) _then;

/// Create a copy of FavoritesBaseline
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? lastAddedOrder = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<FavoriteEntry>,lastAddedOrder: null == lastAddedOrder ? _self.lastAddedOrder : lastAddedOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FavoritesBaseline].
extension FavoritesBaselinePatterns on FavoritesBaseline {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoritesBaseline value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoritesBaseline() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoritesBaseline value)  $default,){
final _that = this;
switch (_that) {
case _FavoritesBaseline():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoritesBaseline value)?  $default,){
final _that = this;
switch (_that) {
case _FavoritesBaseline() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FavoriteEntry> entries,  int lastAddedOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoritesBaseline() when $default != null:
return $default(_that.entries,_that.lastAddedOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FavoriteEntry> entries,  int lastAddedOrder)  $default,) {final _that = this;
switch (_that) {
case _FavoritesBaseline():
return $default(_that.entries,_that.lastAddedOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FavoriteEntry> entries,  int lastAddedOrder)?  $default,) {final _that = this;
switch (_that) {
case _FavoritesBaseline() when $default != null:
return $default(_that.entries,_that.lastAddedOrder);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _FavoritesBaseline extends FavoritesBaseline {
  const _FavoritesBaseline({required final  List<FavoriteEntry> entries, required this.lastAddedOrder}): _entries = entries,super._();
  factory _FavoritesBaseline.fromJson(Map<String, dynamic> json) => _$FavoritesBaselineFromJson(json);

 final  List<FavoriteEntry> _entries;
@override List<FavoriteEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  int lastAddedOrder;

/// Create a copy of FavoritesBaseline
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoritesBaselineCopyWith<_FavoritesBaseline> get copyWith => __$FavoritesBaselineCopyWithImpl<_FavoritesBaseline>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoritesBaselineToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoritesBaseline&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.lastAddedOrder, lastAddedOrder) || other.lastAddedOrder == lastAddedOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),lastAddedOrder);

@override
String toString() {
  return 'FavoritesBaseline(entries: $entries, lastAddedOrder: $lastAddedOrder)';
}


}

/// @nodoc
abstract mixin class _$FavoritesBaselineCopyWith<$Res> implements $FavoritesBaselineCopyWith<$Res> {
  factory _$FavoritesBaselineCopyWith(_FavoritesBaseline value, $Res Function(_FavoritesBaseline) _then) = __$FavoritesBaselineCopyWithImpl;
@override @useResult
$Res call({
 List<FavoriteEntry> entries, int lastAddedOrder
});




}
/// @nodoc
class __$FavoritesBaselineCopyWithImpl<$Res>
    implements _$FavoritesBaselineCopyWith<$Res> {
  __$FavoritesBaselineCopyWithImpl(this._self, this._then);

  final _FavoritesBaseline _self;
  final $Res Function(_FavoritesBaseline) _then;

/// Create a copy of FavoritesBaseline
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? lastAddedOrder = null,}) {
  return _then(_FavoritesBaseline(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<FavoriteEntry>,lastAddedOrder: null == lastAddedOrder ? _self.lastAddedOrder : lastAddedOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$FavoriteWriteCommand {

 int get intentRevision; int get movieId; FavoriteEntry? get desiredEntry;
/// Create a copy of FavoriteWriteCommand
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FavoriteWriteCommandCopyWith<FavoriteWriteCommand> get copyWith => _$FavoriteWriteCommandCopyWithImpl<FavoriteWriteCommand>(this as FavoriteWriteCommand, _$identity);

  /// Serializes this FavoriteWriteCommand to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FavoriteWriteCommand&&(identical(other.intentRevision, intentRevision) || other.intentRevision == intentRevision)&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.desiredEntry, desiredEntry) || other.desiredEntry == desiredEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intentRevision,movieId,desiredEntry);

@override
String toString() {
  return 'FavoriteWriteCommand(intentRevision: $intentRevision, movieId: $movieId, desiredEntry: $desiredEntry)';
}


}

/// @nodoc
abstract mixin class $FavoriteWriteCommandCopyWith<$Res>  {
  factory $FavoriteWriteCommandCopyWith(FavoriteWriteCommand value, $Res Function(FavoriteWriteCommand) _then) = _$FavoriteWriteCommandCopyWithImpl;
@useResult
$Res call({
 int intentRevision, int movieId, FavoriteEntry? desiredEntry
});


$FavoriteEntryCopyWith<$Res>? get desiredEntry;

}
/// @nodoc
class _$FavoriteWriteCommandCopyWithImpl<$Res>
    implements $FavoriteWriteCommandCopyWith<$Res> {
  _$FavoriteWriteCommandCopyWithImpl(this._self, this._then);

  final FavoriteWriteCommand _self;
  final $Res Function(FavoriteWriteCommand) _then;

/// Create a copy of FavoriteWriteCommand
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intentRevision = null,Object? movieId = null,Object? desiredEntry = freezed,}) {
  return _then(_self.copyWith(
intentRevision: null == intentRevision ? _self.intentRevision : intentRevision // ignore: cast_nullable_to_non_nullable
as int,movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,desiredEntry: freezed == desiredEntry ? _self.desiredEntry : desiredEntry // ignore: cast_nullable_to_non_nullable
as FavoriteEntry?,
  ));
}
/// Create a copy of FavoriteWriteCommand
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<$Res>? get desiredEntry {
    if (_self.desiredEntry == null) {
    return null;
  }

  return $FavoriteEntryCopyWith<$Res>(_self.desiredEntry!, (value) {
    return _then(_self.copyWith(desiredEntry: value));
  });
}
}


/// Adds pattern-matching-related methods to [FavoriteWriteCommand].
extension FavoriteWriteCommandPatterns on FavoriteWriteCommand {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FavoriteWriteCommand value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FavoriteWriteCommand() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FavoriteWriteCommand value)  $default,){
final _that = this;
switch (_that) {
case _FavoriteWriteCommand():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FavoriteWriteCommand value)?  $default,){
final _that = this;
switch (_that) {
case _FavoriteWriteCommand() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int intentRevision,  int movieId,  FavoriteEntry? desiredEntry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FavoriteWriteCommand() when $default != null:
return $default(_that.intentRevision,_that.movieId,_that.desiredEntry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int intentRevision,  int movieId,  FavoriteEntry? desiredEntry)  $default,) {final _that = this;
switch (_that) {
case _FavoriteWriteCommand():
return $default(_that.intentRevision,_that.movieId,_that.desiredEntry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int intentRevision,  int movieId,  FavoriteEntry? desiredEntry)?  $default,) {final _that = this;
switch (_that) {
case _FavoriteWriteCommand() when $default != null:
return $default(_that.intentRevision,_that.movieId,_that.desiredEntry);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _FavoriteWriteCommand extends FavoriteWriteCommand {
  const _FavoriteWriteCommand({required this.intentRevision, required this.movieId, this.desiredEntry}): super._();
  factory _FavoriteWriteCommand.fromJson(Map<String, dynamic> json) => _$FavoriteWriteCommandFromJson(json);

@override final  int intentRevision;
@override final  int movieId;
@override final  FavoriteEntry? desiredEntry;

/// Create a copy of FavoriteWriteCommand
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FavoriteWriteCommandCopyWith<_FavoriteWriteCommand> get copyWith => __$FavoriteWriteCommandCopyWithImpl<_FavoriteWriteCommand>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FavoriteWriteCommandToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FavoriteWriteCommand&&(identical(other.intentRevision, intentRevision) || other.intentRevision == intentRevision)&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.desiredEntry, desiredEntry) || other.desiredEntry == desiredEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intentRevision,movieId,desiredEntry);

@override
String toString() {
  return 'FavoriteWriteCommand(intentRevision: $intentRevision, movieId: $movieId, desiredEntry: $desiredEntry)';
}


}

/// @nodoc
abstract mixin class _$FavoriteWriteCommandCopyWith<$Res> implements $FavoriteWriteCommandCopyWith<$Res> {
  factory _$FavoriteWriteCommandCopyWith(_FavoriteWriteCommand value, $Res Function(_FavoriteWriteCommand) _then) = __$FavoriteWriteCommandCopyWithImpl;
@override @useResult
$Res call({
 int intentRevision, int movieId, FavoriteEntry? desiredEntry
});


@override $FavoriteEntryCopyWith<$Res>? get desiredEntry;

}
/// @nodoc
class __$FavoriteWriteCommandCopyWithImpl<$Res>
    implements _$FavoriteWriteCommandCopyWith<$Res> {
  __$FavoriteWriteCommandCopyWithImpl(this._self, this._then);

  final _FavoriteWriteCommand _self;
  final $Res Function(_FavoriteWriteCommand) _then;

/// Create a copy of FavoriteWriteCommand
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intentRevision = null,Object? movieId = null,Object? desiredEntry = freezed,}) {
  return _then(_FavoriteWriteCommand(
intentRevision: null == intentRevision ? _self.intentRevision : intentRevision // ignore: cast_nullable_to_non_nullable
as int,movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,desiredEntry: freezed == desiredEntry ? _self.desiredEntry : desiredEntry // ignore: cast_nullable_to_non_nullable
as FavoriteEntry?,
  ));
}

/// Create a copy of FavoriteWriteCommand
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<$Res>? get desiredEntry {
    if (_self.desiredEntry == null) {
    return null;
  }

  return $FavoriteEntryCopyWith<$Res>(_self.desiredEntry!, (value) {
    return _then(_self.copyWith(desiredEntry: value));
  });
}
}


/// @nodoc
mixin _$PersistenceAck {

 int get intentRevision; int get movieId;@UtcDateTimeConverter() DateTime get committedAtUtc; FavoriteEntry? get storedEntry;
/// Create a copy of PersistenceAck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersistenceAckCopyWith<PersistenceAck> get copyWith => _$PersistenceAckCopyWithImpl<PersistenceAck>(this as PersistenceAck, _$identity);

  /// Serializes this PersistenceAck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersistenceAck&&(identical(other.intentRevision, intentRevision) || other.intentRevision == intentRevision)&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.committedAtUtc, committedAtUtc) || other.committedAtUtc == committedAtUtc)&&(identical(other.storedEntry, storedEntry) || other.storedEntry == storedEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intentRevision,movieId,committedAtUtc,storedEntry);

@override
String toString() {
  return 'PersistenceAck(intentRevision: $intentRevision, movieId: $movieId, committedAtUtc: $committedAtUtc, storedEntry: $storedEntry)';
}


}

/// @nodoc
abstract mixin class $PersistenceAckCopyWith<$Res>  {
  factory $PersistenceAckCopyWith(PersistenceAck value, $Res Function(PersistenceAck) _then) = _$PersistenceAckCopyWithImpl;
@useResult
$Res call({
 int intentRevision, int movieId,@UtcDateTimeConverter() DateTime committedAtUtc, FavoriteEntry? storedEntry
});


$FavoriteEntryCopyWith<$Res>? get storedEntry;

}
/// @nodoc
class _$PersistenceAckCopyWithImpl<$Res>
    implements $PersistenceAckCopyWith<$Res> {
  _$PersistenceAckCopyWithImpl(this._self, this._then);

  final PersistenceAck _self;
  final $Res Function(PersistenceAck) _then;

/// Create a copy of PersistenceAck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intentRevision = null,Object? movieId = null,Object? committedAtUtc = null,Object? storedEntry = freezed,}) {
  return _then(_self.copyWith(
intentRevision: null == intentRevision ? _self.intentRevision : intentRevision // ignore: cast_nullable_to_non_nullable
as int,movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,committedAtUtc: null == committedAtUtc ? _self.committedAtUtc : committedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,storedEntry: freezed == storedEntry ? _self.storedEntry : storedEntry // ignore: cast_nullable_to_non_nullable
as FavoriteEntry?,
  ));
}
/// Create a copy of PersistenceAck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<$Res>? get storedEntry {
    if (_self.storedEntry == null) {
    return null;
  }

  return $FavoriteEntryCopyWith<$Res>(_self.storedEntry!, (value) {
    return _then(_self.copyWith(storedEntry: value));
  });
}
}


/// Adds pattern-matching-related methods to [PersistenceAck].
extension PersistenceAckPatterns on PersistenceAck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersistenceAck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersistenceAck() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersistenceAck value)  $default,){
final _that = this;
switch (_that) {
case _PersistenceAck():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersistenceAck value)?  $default,){
final _that = this;
switch (_that) {
case _PersistenceAck() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int intentRevision,  int movieId, @UtcDateTimeConverter()  DateTime committedAtUtc,  FavoriteEntry? storedEntry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersistenceAck() when $default != null:
return $default(_that.intentRevision,_that.movieId,_that.committedAtUtc,_that.storedEntry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int intentRevision,  int movieId, @UtcDateTimeConverter()  DateTime committedAtUtc,  FavoriteEntry? storedEntry)  $default,) {final _that = this;
switch (_that) {
case _PersistenceAck():
return $default(_that.intentRevision,_that.movieId,_that.committedAtUtc,_that.storedEntry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int intentRevision,  int movieId, @UtcDateTimeConverter()  DateTime committedAtUtc,  FavoriteEntry? storedEntry)?  $default,) {final _that = this;
switch (_that) {
case _PersistenceAck() when $default != null:
return $default(_that.intentRevision,_that.movieId,_that.committedAtUtc,_that.storedEntry);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PersistenceAck extends PersistenceAck {
  const _PersistenceAck({required this.intentRevision, required this.movieId, @UtcDateTimeConverter() required this.committedAtUtc, this.storedEntry}): super._();
  factory _PersistenceAck.fromJson(Map<String, dynamic> json) => _$PersistenceAckFromJson(json);

@override final  int intentRevision;
@override final  int movieId;
@override@UtcDateTimeConverter() final  DateTime committedAtUtc;
@override final  FavoriteEntry? storedEntry;

/// Create a copy of PersistenceAck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersistenceAckCopyWith<_PersistenceAck> get copyWith => __$PersistenceAckCopyWithImpl<_PersistenceAck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersistenceAckToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersistenceAck&&(identical(other.intentRevision, intentRevision) || other.intentRevision == intentRevision)&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.committedAtUtc, committedAtUtc) || other.committedAtUtc == committedAtUtc)&&(identical(other.storedEntry, storedEntry) || other.storedEntry == storedEntry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intentRevision,movieId,committedAtUtc,storedEntry);

@override
String toString() {
  return 'PersistenceAck(intentRevision: $intentRevision, movieId: $movieId, committedAtUtc: $committedAtUtc, storedEntry: $storedEntry)';
}


}

/// @nodoc
abstract mixin class _$PersistenceAckCopyWith<$Res> implements $PersistenceAckCopyWith<$Res> {
  factory _$PersistenceAckCopyWith(_PersistenceAck value, $Res Function(_PersistenceAck) _then) = __$PersistenceAckCopyWithImpl;
@override @useResult
$Res call({
 int intentRevision, int movieId,@UtcDateTimeConverter() DateTime committedAtUtc, FavoriteEntry? storedEntry
});


@override $FavoriteEntryCopyWith<$Res>? get storedEntry;

}
/// @nodoc
class __$PersistenceAckCopyWithImpl<$Res>
    implements _$PersistenceAckCopyWith<$Res> {
  __$PersistenceAckCopyWithImpl(this._self, this._then);

  final _PersistenceAck _self;
  final $Res Function(_PersistenceAck) _then;

/// Create a copy of PersistenceAck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intentRevision = null,Object? movieId = null,Object? committedAtUtc = null,Object? storedEntry = freezed,}) {
  return _then(_PersistenceAck(
intentRevision: null == intentRevision ? _self.intentRevision : intentRevision // ignore: cast_nullable_to_non_nullable
as int,movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,committedAtUtc: null == committedAtUtc ? _self.committedAtUtc : committedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,storedEntry: freezed == storedEntry ? _self.storedEntry : storedEntry // ignore: cast_nullable_to_non_nullable
as FavoriteEntry?,
  ));
}

/// Create a copy of PersistenceAck
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FavoriteEntryCopyWith<$Res>? get storedEntry {
    if (_self.storedEntry == null) {
    return null;
  }

  return $FavoriteEntryCopyWith<$Res>(_self.storedEntry!, (value) {
    return _then(_self.copyWith(storedEntry: value));
  });
}
}

// dart format on

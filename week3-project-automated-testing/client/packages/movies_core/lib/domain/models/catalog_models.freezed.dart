// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CalendarDate {

 int get year; int get month; int get day;
/// Create a copy of CalendarDate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<CalendarDate> get copyWith => _$CalendarDateCopyWithImpl<CalendarDate>(this as CalendarDate, _$identity);

  /// Serializes this CalendarDate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalendarDate&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.day, day) || other.day == day));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,day);

@override
String toString() {
  return 'CalendarDate(year: $year, month: $month, day: $day)';
}


}

/// @nodoc
abstract mixin class $CalendarDateCopyWith<$Res>  {
  factory $CalendarDateCopyWith(CalendarDate value, $Res Function(CalendarDate) _then) = _$CalendarDateCopyWithImpl;
@useResult
$Res call({
 int year, int month, int day
});




}
/// @nodoc
class _$CalendarDateCopyWithImpl<$Res>
    implements $CalendarDateCopyWith<$Res> {
  _$CalendarDateCopyWithImpl(this._self, this._then);

  final CalendarDate _self;
  final $Res Function(CalendarDate) _then;

/// Create a copy of CalendarDate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? day = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CalendarDate].
extension CalendarDatePatterns on CalendarDate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalendarDate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalendarDate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalendarDate value)  $default,){
final _that = this;
switch (_that) {
case _CalendarDate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalendarDate value)?  $default,){
final _that = this;
switch (_that) {
case _CalendarDate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int day)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalendarDate() when $default != null:
return $default(_that.year,_that.month,_that.day);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int day)  $default,) {final _that = this;
switch (_that) {
case _CalendarDate():
return $default(_that.year,_that.month,_that.day);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int day)?  $default,) {final _that = this;
switch (_that) {
case _CalendarDate() when $default != null:
return $default(_that.year,_that.month,_that.day);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CalendarDate extends CalendarDate {
  const _CalendarDate({required this.year, required this.month, required this.day}): super._();
  factory _CalendarDate.fromJson(Map<String, dynamic> json) => _$CalendarDateFromJson(json);

@override final  int year;
@override final  int month;
@override final  int day;

/// Create a copy of CalendarDate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalendarDateCopyWith<_CalendarDate> get copyWith => __$CalendarDateCopyWithImpl<_CalendarDate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CalendarDateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalendarDate&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.day, day) || other.day == day));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,day);

@override
String toString() {
  return 'CalendarDate(year: $year, month: $month, day: $day)';
}


}

/// @nodoc
abstract mixin class _$CalendarDateCopyWith<$Res> implements $CalendarDateCopyWith<$Res> {
  factory _$CalendarDateCopyWith(_CalendarDate value, $Res Function(_CalendarDate) _then) = __$CalendarDateCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int day
});




}
/// @nodoc
class __$CalendarDateCopyWithImpl<$Res>
    implements _$CalendarDateCopyWith<$Res> {
  __$CalendarDateCopyWithImpl(this._self, this._then);

  final _CalendarDate _self;
  final $Res Function(_CalendarDate) _then;

/// Create a copy of CalendarDate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? day = null,}) {
  return _then(_CalendarDate(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TmdbRating {

 double get average; int get voteCount;
/// Create a copy of TmdbRating
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbRatingCopyWith<TmdbRating> get copyWith => _$TmdbRatingCopyWithImpl<TmdbRating>(this as TmdbRating, _$identity);

  /// Serializes this TmdbRating to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbRating&&(identical(other.average, average) || other.average == average)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,average,voteCount);

@override
String toString() {
  return 'TmdbRating(average: $average, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class $TmdbRatingCopyWith<$Res>  {
  factory $TmdbRatingCopyWith(TmdbRating value, $Res Function(TmdbRating) _then) = _$TmdbRatingCopyWithImpl;
@useResult
$Res call({
 double average, int voteCount
});




}
/// @nodoc
class _$TmdbRatingCopyWithImpl<$Res>
    implements $TmdbRatingCopyWith<$Res> {
  _$TmdbRatingCopyWithImpl(this._self, this._then);

  final TmdbRating _self;
  final $Res Function(TmdbRating) _then;

/// Create a copy of TmdbRating
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? average = null,Object? voteCount = null,}) {
  return _then(_self.copyWith(
average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbRating].
extension TmdbRatingPatterns on TmdbRating {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbRating value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbRating() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbRating value)  $default,){
final _that = this;
switch (_that) {
case _TmdbRating():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbRating value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbRating() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double average,  int voteCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbRating() when $default != null:
return $default(_that.average,_that.voteCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double average,  int voteCount)  $default,) {final _that = this;
switch (_that) {
case _TmdbRating():
return $default(_that.average,_that.voteCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double average,  int voteCount)?  $default,) {final _that = this;
switch (_that) {
case _TmdbRating() when $default != null:
return $default(_that.average,_that.voteCount);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TmdbRating extends TmdbRating {
  const _TmdbRating({required this.average, required this.voteCount}): super._();
  factory _TmdbRating.fromJson(Map<String, dynamic> json) => _$TmdbRatingFromJson(json);

@override final  double average;
@override final  int voteCount;

/// Create a copy of TmdbRating
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbRatingCopyWith<_TmdbRating> get copyWith => __$TmdbRatingCopyWithImpl<_TmdbRating>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbRatingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbRating&&(identical(other.average, average) || other.average == average)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,average,voteCount);

@override
String toString() {
  return 'TmdbRating(average: $average, voteCount: $voteCount)';
}


}

/// @nodoc
abstract mixin class _$TmdbRatingCopyWith<$Res> implements $TmdbRatingCopyWith<$Res> {
  factory _$TmdbRatingCopyWith(_TmdbRating value, $Res Function(_TmdbRating) _then) = __$TmdbRatingCopyWithImpl;
@override @useResult
$Res call({
 double average, int voteCount
});




}
/// @nodoc
class __$TmdbRatingCopyWithImpl<$Res>
    implements _$TmdbRatingCopyWith<$Res> {
  __$TmdbRatingCopyWithImpl(this._self, this._then);

  final _TmdbRating _self;
  final $Res Function(_TmdbRating) _then;

/// Create a copy of TmdbRating
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? average = null,Object? voteCount = null,}) {
  return _then(_TmdbRating(
average: null == average ? _self.average : average // ignore: cast_nullable_to_non_nullable
as double,voteCount: null == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$Genre {

 int get id; String get name;
/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenreCopyWith<Genre> get copyWith => _$GenreCopyWithImpl<Genre>(this as Genre, _$identity);

  /// Serializes this Genre to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Genre&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'Genre(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $GenreCopyWith<$Res>  {
  factory $GenreCopyWith(Genre value, $Res Function(Genre) _then) = _$GenreCopyWithImpl;
@useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class _$GenreCopyWithImpl<$Res>
    implements $GenreCopyWith<$Res> {
  _$GenreCopyWithImpl(this._self, this._then);

  final Genre _self;
  final $Res Function(Genre) _then;

/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Genre].
extension GenrePatterns on Genre {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Genre value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Genre() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Genre value)  $default,){
final _that = this;
switch (_that) {
case _Genre():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Genre value)?  $default,){
final _that = this;
switch (_that) {
case _Genre() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Genre() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _Genre():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _Genre() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Genre extends Genre {
  const _Genre({required this.id, required this.name}): super._();
  factory _Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);

@override final  int id;
@override final  String name;

/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenreCopyWith<_Genre> get copyWith => __$GenreCopyWithImpl<_Genre>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Genre&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'Genre(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GenreCopyWith<$Res> implements $GenreCopyWith<$Res> {
  factory _$GenreCopyWith(_Genre value, $Res Function(_Genre) _then) = __$GenreCopyWithImpl;
@override @useResult
$Res call({
 int id, String name
});




}
/// @nodoc
class __$GenreCopyWithImpl<$Res>
    implements _$GenreCopyWith<$Res> {
  __$GenreCopyWithImpl(this._self, this._then);

  final _Genre _self;
  final $Res Function(_Genre) _then;

/// Create a copy of Genre
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_Genre(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$MovieSummary {

 int get id; String get title; List<int> get genreIds; String? get originalTitle; String? get overview; String? get posterPath; String? get backdropPath; CalendarDate? get releaseDate; TmdbRating? get rating; String? get originalLanguage; double? get popularity; bool? get adult;
/// Create a copy of MovieSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieSummaryCopyWith<MovieSummary> get copyWith => _$MovieSummaryCopyWithImpl<MovieSummary>(this as MovieSummary, _$identity);

  /// Serializes this MovieSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.genreIds, genreIds)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.adult, adult) || other.adult == adult));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(genreIds),originalTitle,overview,posterPath,backdropPath,releaseDate,rating,originalLanguage,popularity,adult);

@override
String toString() {
  return 'MovieSummary(id: $id, title: $title, genreIds: $genreIds, originalTitle: $originalTitle, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, rating: $rating, originalLanguage: $originalLanguage, popularity: $popularity, adult: $adult)';
}


}

/// @nodoc
abstract mixin class $MovieSummaryCopyWith<$Res>  {
  factory $MovieSummaryCopyWith(MovieSummary value, $Res Function(MovieSummary) _then) = _$MovieSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String title, List<int> genreIds, String? originalTitle, String? overview, String? posterPath, String? backdropPath, CalendarDate? releaseDate, TmdbRating? rating, String? originalLanguage, double? popularity, bool? adult
});


$CalendarDateCopyWith<$Res>? get releaseDate;$TmdbRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class _$MovieSummaryCopyWithImpl<$Res>
    implements $MovieSummaryCopyWith<$Res> {
  _$MovieSummaryCopyWithImpl(this._self, this._then);

  final MovieSummary _self;
  final $Res Function(MovieSummary) _then;

/// Create a copy of MovieSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? genreIds = null,Object? originalTitle = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? rating = freezed,Object? originalLanguage = freezed,Object? popularity = freezed,Object? adult = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,genreIds: null == genreIds ? _self.genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as CalendarDate?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as TmdbRating?,originalLanguage: freezed == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String?,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double?,adult: freezed == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of MovieSummary
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
}/// Create a copy of MovieSummary
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


/// Adds pattern-matching-related methods to [MovieSummary].
extension MovieSummaryPatterns on MovieSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieSummary value)  $default,){
final _that = this;
switch (_that) {
case _MovieSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MovieSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  List<int> genreIds,  String? originalTitle,  String? overview,  String? posterPath,  String? backdropPath,  CalendarDate? releaseDate,  TmdbRating? rating,  String? originalLanguage,  double? popularity,  bool? adult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieSummary() when $default != null:
return $default(_that.id,_that.title,_that.genreIds,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.rating,_that.originalLanguage,_that.popularity,_that.adult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  List<int> genreIds,  String? originalTitle,  String? overview,  String? posterPath,  String? backdropPath,  CalendarDate? releaseDate,  TmdbRating? rating,  String? originalLanguage,  double? popularity,  bool? adult)  $default,) {final _that = this;
switch (_that) {
case _MovieSummary():
return $default(_that.id,_that.title,_that.genreIds,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.rating,_that.originalLanguage,_that.popularity,_that.adult);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  List<int> genreIds,  String? originalTitle,  String? overview,  String? posterPath,  String? backdropPath,  CalendarDate? releaseDate,  TmdbRating? rating,  String? originalLanguage,  double? popularity,  bool? adult)?  $default,) {final _that = this;
switch (_that) {
case _MovieSummary() when $default != null:
return $default(_that.id,_that.title,_that.genreIds,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.rating,_that.originalLanguage,_that.popularity,_that.adult);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MovieSummary extends MovieSummary {
  const _MovieSummary({required this.id, required this.title, final  List<int> genreIds = const [], this.originalTitle, this.overview, this.posterPath, this.backdropPath, this.releaseDate, this.rating, this.originalLanguage, this.popularity, this.adult}): _genreIds = genreIds,super._();
  factory _MovieSummary.fromJson(Map<String, dynamic> json) => _$MovieSummaryFromJson(json);

@override final  int id;
@override final  String title;
 final  List<int> _genreIds;
@override@JsonKey() List<int> get genreIds {
  if (_genreIds is EqualUnmodifiableListView) return _genreIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreIds);
}

@override final  String? originalTitle;
@override final  String? overview;
@override final  String? posterPath;
@override final  String? backdropPath;
@override final  CalendarDate? releaseDate;
@override final  TmdbRating? rating;
@override final  String? originalLanguage;
@override final  double? popularity;
@override final  bool? adult;

/// Create a copy of MovieSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieSummaryCopyWith<_MovieSummary> get copyWith => __$MovieSummaryCopyWithImpl<_MovieSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._genreIds, _genreIds)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.adult, adult) || other.adult == adult));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,const DeepCollectionEquality().hash(_genreIds),originalTitle,overview,posterPath,backdropPath,releaseDate,rating,originalLanguage,popularity,adult);

@override
String toString() {
  return 'MovieSummary(id: $id, title: $title, genreIds: $genreIds, originalTitle: $originalTitle, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, rating: $rating, originalLanguage: $originalLanguage, popularity: $popularity, adult: $adult)';
}


}

/// @nodoc
abstract mixin class _$MovieSummaryCopyWith<$Res> implements $MovieSummaryCopyWith<$Res> {
  factory _$MovieSummaryCopyWith(_MovieSummary value, $Res Function(_MovieSummary) _then) = __$MovieSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, List<int> genreIds, String? originalTitle, String? overview, String? posterPath, String? backdropPath, CalendarDate? releaseDate, TmdbRating? rating, String? originalLanguage, double? popularity, bool? adult
});


@override $CalendarDateCopyWith<$Res>? get releaseDate;@override $TmdbRatingCopyWith<$Res>? get rating;

}
/// @nodoc
class __$MovieSummaryCopyWithImpl<$Res>
    implements _$MovieSummaryCopyWith<$Res> {
  __$MovieSummaryCopyWithImpl(this._self, this._then);

  final _MovieSummary _self;
  final $Res Function(_MovieSummary) _then;

/// Create a copy of MovieSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? genreIds = null,Object? originalTitle = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? rating = freezed,Object? originalLanguage = freezed,Object? popularity = freezed,Object? adult = freezed,}) {
  return _then(_MovieSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,genreIds: null == genreIds ? _self._genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as CalendarDate?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as TmdbRating?,originalLanguage: freezed == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String?,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double?,adult: freezed == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of MovieSummary
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
}/// Create a copy of MovieSummary
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
mixin _$CollectionRef {

 int get id; String get name; String? get posterPath; String? get backdropPath;
/// Create a copy of CollectionRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionRefCopyWith<CollectionRef> get copyWith => _$CollectionRefCopyWithImpl<CollectionRef>(this as CollectionRef, _$identity);

  /// Serializes this CollectionRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,posterPath,backdropPath);

@override
String toString() {
  return 'CollectionRef(id: $id, name: $name, posterPath: $posterPath, backdropPath: $backdropPath)';
}


}

/// @nodoc
abstract mixin class $CollectionRefCopyWith<$Res>  {
  factory $CollectionRefCopyWith(CollectionRef value, $Res Function(CollectionRef) _then) = _$CollectionRefCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? posterPath, String? backdropPath
});




}
/// @nodoc
class _$CollectionRefCopyWithImpl<$Res>
    implements $CollectionRefCopyWith<$Res> {
  _$CollectionRefCopyWithImpl(this._self, this._then);

  final CollectionRef _self;
  final $Res Function(CollectionRef) _then;

/// Create a copy of CollectionRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? posterPath = freezed,Object? backdropPath = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionRef].
extension CollectionRefPatterns on CollectionRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionRef value)  $default,){
final _that = this;
switch (_that) {
case _CollectionRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionRef value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? posterPath,  String? backdropPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionRef() when $default != null:
return $default(_that.id,_that.name,_that.posterPath,_that.backdropPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? posterPath,  String? backdropPath)  $default,) {final _that = this;
switch (_that) {
case _CollectionRef():
return $default(_that.id,_that.name,_that.posterPath,_that.backdropPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? posterPath,  String? backdropPath)?  $default,) {final _that = this;
switch (_that) {
case _CollectionRef() when $default != null:
return $default(_that.id,_that.name,_that.posterPath,_that.backdropPath);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CollectionRef extends CollectionRef {
  const _CollectionRef({required this.id, required this.name, this.posterPath, this.backdropPath}): super._();
  factory _CollectionRef.fromJson(Map<String, dynamic> json) => _$CollectionRefFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? posterPath;
@override final  String? backdropPath;

/// Create a copy of CollectionRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionRefCopyWith<_CollectionRef> get copyWith => __$CollectionRefCopyWithImpl<_CollectionRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,posterPath,backdropPath);

@override
String toString() {
  return 'CollectionRef(id: $id, name: $name, posterPath: $posterPath, backdropPath: $backdropPath)';
}


}

/// @nodoc
abstract mixin class _$CollectionRefCopyWith<$Res> implements $CollectionRefCopyWith<$Res> {
  factory _$CollectionRefCopyWith(_CollectionRef value, $Res Function(_CollectionRef) _then) = __$CollectionRefCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? posterPath, String? backdropPath
});




}
/// @nodoc
class __$CollectionRefCopyWithImpl<$Res>
    implements _$CollectionRefCopyWith<$Res> {
  __$CollectionRefCopyWithImpl(this._self, this._then);

  final _CollectionRef _self;
  final $Res Function(_CollectionRef) _then;

/// Create a copy of CollectionRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? posterPath = freezed,Object? backdropPath = freezed,}) {
  return _then(_CollectionRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$MovieDetails {

 MovieSummary get movie; List<Genre> get genres; int? get runtimeMinutes; String? get status; String? get tagline; CollectionRef? get collection;
/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieDetailsCopyWith<MovieDetails> get copyWith => _$MovieDetailsCopyWithImpl<MovieDetails>(this as MovieDetails, _$identity);

  /// Serializes this MovieDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieDetails&&(identical(other.movie, movie) || other.movie == movie)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,const DeepCollectionEquality().hash(genres),runtimeMinutes,status,tagline,collection);

@override
String toString() {
  return 'MovieDetails(movie: $movie, genres: $genres, runtimeMinutes: $runtimeMinutes, status: $status, tagline: $tagline, collection: $collection)';
}


}

/// @nodoc
abstract mixin class $MovieDetailsCopyWith<$Res>  {
  factory $MovieDetailsCopyWith(MovieDetails value, $Res Function(MovieDetails) _then) = _$MovieDetailsCopyWithImpl;
@useResult
$Res call({
 MovieSummary movie, List<Genre> genres, int? runtimeMinutes, String? status, String? tagline, CollectionRef? collection
});


$MovieSummaryCopyWith<$Res> get movie;$CollectionRefCopyWith<$Res>? get collection;

}
/// @nodoc
class _$MovieDetailsCopyWithImpl<$Res>
    implements $MovieDetailsCopyWith<$Res> {
  _$MovieDetailsCopyWithImpl(this._self, this._then);

  final MovieDetails _self;
  final $Res Function(MovieDetails) _then;

/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movie = null,Object? genres = null,Object? runtimeMinutes = freezed,Object? status = freezed,Object? tagline = freezed,Object? collection = freezed,}) {
  return _then(_self.copyWith(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as MovieSummary,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as CollectionRef?,
  ));
}
/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieSummaryCopyWith<$Res> get movie {
  
  return $MovieSummaryCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectionRefCopyWith<$Res>? get collection {
    if (_self.collection == null) {
    return null;
  }

  return $CollectionRefCopyWith<$Res>(_self.collection!, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [MovieDetails].
extension MovieDetailsPatterns on MovieDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieDetails value)  $default,){
final _that = this;
switch (_that) {
case _MovieDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieDetails value)?  $default,){
final _that = this;
switch (_that) {
case _MovieDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MovieSummary movie,  List<Genre> genres,  int? runtimeMinutes,  String? status,  String? tagline,  CollectionRef? collection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieDetails() when $default != null:
return $default(_that.movie,_that.genres,_that.runtimeMinutes,_that.status,_that.tagline,_that.collection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MovieSummary movie,  List<Genre> genres,  int? runtimeMinutes,  String? status,  String? tagline,  CollectionRef? collection)  $default,) {final _that = this;
switch (_that) {
case _MovieDetails():
return $default(_that.movie,_that.genres,_that.runtimeMinutes,_that.status,_that.tagline,_that.collection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MovieSummary movie,  List<Genre> genres,  int? runtimeMinutes,  String? status,  String? tagline,  CollectionRef? collection)?  $default,) {final _that = this;
switch (_that) {
case _MovieDetails() when $default != null:
return $default(_that.movie,_that.genres,_that.runtimeMinutes,_that.status,_that.tagline,_that.collection);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MovieDetails extends MovieDetails {
  const _MovieDetails({required this.movie, final  List<Genre> genres = const [], this.runtimeMinutes, this.status, this.tagline, this.collection}): _genres = genres,super._();
  factory _MovieDetails.fromJson(Map<String, dynamic> json) => _$MovieDetailsFromJson(json);

@override final  MovieSummary movie;
 final  List<Genre> _genres;
@override@JsonKey() List<Genre> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  int? runtimeMinutes;
@override final  String? status;
@override final  String? tagline;
@override final  CollectionRef? collection;

/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieDetailsCopyWith<_MovieDetails> get copyWith => __$MovieDetailsCopyWithImpl<_MovieDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieDetails&&(identical(other.movie, movie) || other.movie == movie)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&(identical(other.collection, collection) || other.collection == collection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,const DeepCollectionEquality().hash(_genres),runtimeMinutes,status,tagline,collection);

@override
String toString() {
  return 'MovieDetails(movie: $movie, genres: $genres, runtimeMinutes: $runtimeMinutes, status: $status, tagline: $tagline, collection: $collection)';
}


}

/// @nodoc
abstract mixin class _$MovieDetailsCopyWith<$Res> implements $MovieDetailsCopyWith<$Res> {
  factory _$MovieDetailsCopyWith(_MovieDetails value, $Res Function(_MovieDetails) _then) = __$MovieDetailsCopyWithImpl;
@override @useResult
$Res call({
 MovieSummary movie, List<Genre> genres, int? runtimeMinutes, String? status, String? tagline, CollectionRef? collection
});


@override $MovieSummaryCopyWith<$Res> get movie;@override $CollectionRefCopyWith<$Res>? get collection;

}
/// @nodoc
class __$MovieDetailsCopyWithImpl<$Res>
    implements _$MovieDetailsCopyWith<$Res> {
  __$MovieDetailsCopyWithImpl(this._self, this._then);

  final _MovieDetails _self;
  final $Res Function(_MovieDetails) _then;

/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movie = null,Object? genres = null,Object? runtimeMinutes = freezed,Object? status = freezed,Object? tagline = freezed,Object? collection = freezed,}) {
  return _then(_MovieDetails(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as MovieSummary,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<Genre>,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,collection: freezed == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as CollectionRef?,
  ));
}

/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieSummaryCopyWith<$Res> get movie {
  
  return $MovieSummaryCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}/// Create a copy of MovieDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectionRefCopyWith<$Res>? get collection {
    if (_self.collection == null) {
    return null;
  }

  return $CollectionRefCopyWith<$Res>(_self.collection!, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}

// dart format on

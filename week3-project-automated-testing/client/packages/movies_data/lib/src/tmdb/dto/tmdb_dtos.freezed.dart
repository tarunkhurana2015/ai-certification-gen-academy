// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tmdb_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TmdbPageDto {

@JsonKey(fromJson: positiveInteger) int get page;@JsonKey(fromJson: nonnegativeInteger) int get totalPages;@JsonKey(fromJson: nonnegativeInteger) int get totalResults;@JsonKey(fromJson: jsonRows) List<Map<String, dynamic>> get results; Map<String, dynamic>? get dates;
/// Create a copy of TmdbPageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbPageDtoCopyWith<TmdbPageDto> get copyWith => _$TmdbPageDtoCopyWithImpl<TmdbPageDto>(this as TmdbPageDto, _$identity);

  /// Serializes this TmdbPageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbPageDto&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&const DeepCollectionEquality().equals(other.results, results)&&const DeepCollectionEquality().equals(other.dates, dates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,totalPages,totalResults,const DeepCollectionEquality().hash(results),const DeepCollectionEquality().hash(dates));

@override
String toString() {
  return 'TmdbPageDto(page: $page, totalPages: $totalPages, totalResults: $totalResults, results: $results, dates: $dates)';
}


}

/// @nodoc
abstract mixin class $TmdbPageDtoCopyWith<$Res>  {
  factory $TmdbPageDtoCopyWith(TmdbPageDto value, $Res Function(TmdbPageDto) _then) = _$TmdbPageDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int page,@JsonKey(fromJson: nonnegativeInteger) int totalPages,@JsonKey(fromJson: nonnegativeInteger) int totalResults,@JsonKey(fromJson: jsonRows) List<Map<String, dynamic>> results, Map<String, dynamic>? dates
});




}
/// @nodoc
class _$TmdbPageDtoCopyWithImpl<$Res>
    implements $TmdbPageDtoCopyWith<$Res> {
  _$TmdbPageDtoCopyWithImpl(this._self, this._then);

  final TmdbPageDto _self;
  final $Res Function(TmdbPageDto) _then;

/// Create a copy of TmdbPageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? totalPages = null,Object? totalResults = null,Object? results = null,Object? dates = freezed,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,dates: freezed == dates ? _self.dates : dates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbPageDto].
extension TmdbPageDtoPatterns on TmdbPageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbPageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbPageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbPageDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbPageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbPageDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbPageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int page, @JsonKey(fromJson: nonnegativeInteger)  int totalPages, @JsonKey(fromJson: nonnegativeInteger)  int totalResults, @JsonKey(fromJson: jsonRows)  List<Map<String, dynamic>> results,  Map<String, dynamic>? dates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbPageDto() when $default != null:
return $default(_that.page,_that.totalPages,_that.totalResults,_that.results,_that.dates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int page, @JsonKey(fromJson: nonnegativeInteger)  int totalPages, @JsonKey(fromJson: nonnegativeInteger)  int totalResults, @JsonKey(fromJson: jsonRows)  List<Map<String, dynamic>> results,  Map<String, dynamic>? dates)  $default,) {final _that = this;
switch (_that) {
case _TmdbPageDto():
return $default(_that.page,_that.totalPages,_that.totalResults,_that.results,_that.dates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: positiveInteger)  int page, @JsonKey(fromJson: nonnegativeInteger)  int totalPages, @JsonKey(fromJson: nonnegativeInteger)  int totalResults, @JsonKey(fromJson: jsonRows)  List<Map<String, dynamic>> results,  Map<String, dynamic>? dates)?  $default,) {final _that = this;
switch (_that) {
case _TmdbPageDto() when $default != null:
return $default(_that.page,_that.totalPages,_that.totalResults,_that.results,_that.dates);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true, explicitToJson: true)
class _TmdbPageDto implements TmdbPageDto {
  const _TmdbPageDto({@JsonKey(fromJson: positiveInteger) required this.page, @JsonKey(fromJson: nonnegativeInteger) required this.totalPages, @JsonKey(fromJson: nonnegativeInteger) required this.totalResults, @JsonKey(fromJson: jsonRows) required final  List<Map<String, dynamic>> results, final  Map<String, dynamic>? dates}): _results = results,_dates = dates;
  factory _TmdbPageDto.fromJson(Map<String, dynamic> json) => _$TmdbPageDtoFromJson(json);

@override@JsonKey(fromJson: positiveInteger) final  int page;
@override@JsonKey(fromJson: nonnegativeInteger) final  int totalPages;
@override@JsonKey(fromJson: nonnegativeInteger) final  int totalResults;
 final  List<Map<String, dynamic>> _results;
@override@JsonKey(fromJson: jsonRows) List<Map<String, dynamic>> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

 final  Map<String, dynamic>? _dates;
@override Map<String, dynamic>? get dates {
  final value = _dates;
  if (value == null) return null;
  if (_dates is EqualUnmodifiableMapView) return _dates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of TmdbPageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbPageDtoCopyWith<_TmdbPageDto> get copyWith => __$TmdbPageDtoCopyWithImpl<_TmdbPageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbPageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbPageDto&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&const DeepCollectionEquality().equals(other._results, _results)&&const DeepCollectionEquality().equals(other._dates, _dates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,totalPages,totalResults,const DeepCollectionEquality().hash(_results),const DeepCollectionEquality().hash(_dates));

@override
String toString() {
  return 'TmdbPageDto(page: $page, totalPages: $totalPages, totalResults: $totalResults, results: $results, dates: $dates)';
}


}

/// @nodoc
abstract mixin class _$TmdbPageDtoCopyWith<$Res> implements $TmdbPageDtoCopyWith<$Res> {
  factory _$TmdbPageDtoCopyWith(_TmdbPageDto value, $Res Function(_TmdbPageDto) _then) = __$TmdbPageDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int page,@JsonKey(fromJson: nonnegativeInteger) int totalPages,@JsonKey(fromJson: nonnegativeInteger) int totalResults,@JsonKey(fromJson: jsonRows) List<Map<String, dynamic>> results, Map<String, dynamic>? dates
});




}
/// @nodoc
class __$TmdbPageDtoCopyWithImpl<$Res>
    implements _$TmdbPageDtoCopyWith<$Res> {
  __$TmdbPageDtoCopyWithImpl(this._self, this._then);

  final _TmdbPageDto _self;
  final $Res Function(_TmdbPageDto) _then;

/// Create a copy of TmdbPageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? totalPages = null,Object? totalResults = null,Object? results = null,Object? dates = freezed,}) {
  return _then(_TmdbPageDto(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,dates: freezed == dates ? _self._dates : dates // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$TmdbMovieDto {

@JsonKey(fromJson: positiveInteger) int get id; String? get title; String? get name; String? get originalTitle; String? get originalName; String? get overview; String? get posterPath; String? get backdropPath; String? get releaseDate; double? get voteAverage;@JsonKey(fromJson: optionalInteger) int? get voteCount;@JsonKey(fromJson: genreIdsFromJson) List<int> get genreIds; String? get originalLanguage; double? get popularity; bool? get adult;@JsonKey(fromJson: optionalInteger) int? get runtime; String? get status; String? get tagline; Map<String, dynamic>? get belongsToCollection; List<TmdbGenreDto> get genres; String? get creditId; String? get character; String? get department; String? get job;
/// Create a copy of TmdbMovieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbMovieDtoCopyWith<TmdbMovieDto> get copyWith => _$TmdbMovieDtoCopyWithImpl<TmdbMovieDto>(this as TmdbMovieDto, _$identity);

  /// Serializes this TmdbMovieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbMovieDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&const DeepCollectionEquality().equals(other.genreIds, genreIds)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&const DeepCollectionEquality().equals(other.belongsToCollection, belongsToCollection)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,name,originalTitle,originalName,overview,posterPath,backdropPath,releaseDate,voteAverage,voteCount,const DeepCollectionEquality().hash(genreIds),originalLanguage,popularity,adult,runtime,status,tagline,const DeepCollectionEquality().hash(belongsToCollection),const DeepCollectionEquality().hash(genres),creditId,character,department,job]);

@override
String toString() {
  return 'TmdbMovieDto(id: $id, title: $title, name: $name, originalTitle: $originalTitle, originalName: $originalName, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, voteAverage: $voteAverage, voteCount: $voteCount, genreIds: $genreIds, originalLanguage: $originalLanguage, popularity: $popularity, adult: $adult, runtime: $runtime, status: $status, tagline: $tagline, belongsToCollection: $belongsToCollection, genres: $genres, creditId: $creditId, character: $character, department: $department, job: $job)';
}


}

/// @nodoc
abstract mixin class $TmdbMovieDtoCopyWith<$Res>  {
  factory $TmdbMovieDtoCopyWith(TmdbMovieDto value, $Res Function(TmdbMovieDto) _then) = _$TmdbMovieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String? title, String? name, String? originalTitle, String? originalName, String? overview, String? posterPath, String? backdropPath, String? releaseDate, double? voteAverage,@JsonKey(fromJson: optionalInteger) int? voteCount,@JsonKey(fromJson: genreIdsFromJson) List<int> genreIds, String? originalLanguage, double? popularity, bool? adult,@JsonKey(fromJson: optionalInteger) int? runtime, String? status, String? tagline, Map<String, dynamic>? belongsToCollection, List<TmdbGenreDto> genres, String? creditId, String? character, String? department, String? job
});




}
/// @nodoc
class _$TmdbMovieDtoCopyWithImpl<$Res>
    implements $TmdbMovieDtoCopyWith<$Res> {
  _$TmdbMovieDtoCopyWithImpl(this._self, this._then);

  final TmdbMovieDto _self;
  final $Res Function(TmdbMovieDto) _then;

/// Create a copy of TmdbMovieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = freezed,Object? name = freezed,Object? originalTitle = freezed,Object? originalName = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? voteAverage = freezed,Object? voteCount = freezed,Object? genreIds = null,Object? originalLanguage = freezed,Object? popularity = freezed,Object? adult = freezed,Object? runtime = freezed,Object? status = freezed,Object? tagline = freezed,Object? belongsToCollection = freezed,Object? genres = null,Object? creditId = freezed,Object? character = freezed,Object? department = freezed,Object? job = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,originalName: freezed == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,genreIds: null == genreIds ? _self.genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,originalLanguage: freezed == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String?,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double?,adult: freezed == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool?,runtime: freezed == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,belongsToCollection: freezed == belongsToCollection ? _self.belongsToCollection : belongsToCollection // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<TmdbGenreDto>,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbMovieDto].
extension TmdbMovieDtoPatterns on TmdbMovieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbMovieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbMovieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbMovieDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbMovieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbMovieDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbMovieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String? title,  String? name,  String? originalTitle,  String? originalName,  String? overview,  String? posterPath,  String? backdropPath,  String? releaseDate,  double? voteAverage, @JsonKey(fromJson: optionalInteger)  int? voteCount, @JsonKey(fromJson: genreIdsFromJson)  List<int> genreIds,  String? originalLanguage,  double? popularity,  bool? adult, @JsonKey(fromJson: optionalInteger)  int? runtime,  String? status,  String? tagline,  Map<String, dynamic>? belongsToCollection,  List<TmdbGenreDto> genres,  String? creditId,  String? character,  String? department,  String? job)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbMovieDto() when $default != null:
return $default(_that.id,_that.title,_that.name,_that.originalTitle,_that.originalName,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.voteAverage,_that.voteCount,_that.genreIds,_that.originalLanguage,_that.popularity,_that.adult,_that.runtime,_that.status,_that.tagline,_that.belongsToCollection,_that.genres,_that.creditId,_that.character,_that.department,_that.job);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String? title,  String? name,  String? originalTitle,  String? originalName,  String? overview,  String? posterPath,  String? backdropPath,  String? releaseDate,  double? voteAverage, @JsonKey(fromJson: optionalInteger)  int? voteCount, @JsonKey(fromJson: genreIdsFromJson)  List<int> genreIds,  String? originalLanguage,  double? popularity,  bool? adult, @JsonKey(fromJson: optionalInteger)  int? runtime,  String? status,  String? tagline,  Map<String, dynamic>? belongsToCollection,  List<TmdbGenreDto> genres,  String? creditId,  String? character,  String? department,  String? job)  $default,) {final _that = this;
switch (_that) {
case _TmdbMovieDto():
return $default(_that.id,_that.title,_that.name,_that.originalTitle,_that.originalName,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.voteAverage,_that.voteCount,_that.genreIds,_that.originalLanguage,_that.popularity,_that.adult,_that.runtime,_that.status,_that.tagline,_that.belongsToCollection,_that.genres,_that.creditId,_that.character,_that.department,_that.job);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: positiveInteger)  int id,  String? title,  String? name,  String? originalTitle,  String? originalName,  String? overview,  String? posterPath,  String? backdropPath,  String? releaseDate,  double? voteAverage, @JsonKey(fromJson: optionalInteger)  int? voteCount, @JsonKey(fromJson: genreIdsFromJson)  List<int> genreIds,  String? originalLanguage,  double? popularity,  bool? adult, @JsonKey(fromJson: optionalInteger)  int? runtime,  String? status,  String? tagline,  Map<String, dynamic>? belongsToCollection,  List<TmdbGenreDto> genres,  String? creditId,  String? character,  String? department,  String? job)?  $default,) {final _that = this;
switch (_that) {
case _TmdbMovieDto() when $default != null:
return $default(_that.id,_that.title,_that.name,_that.originalTitle,_that.originalName,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.voteAverage,_that.voteCount,_that.genreIds,_that.originalLanguage,_that.popularity,_that.adult,_that.runtime,_that.status,_that.tagline,_that.belongsToCollection,_that.genres,_that.creditId,_that.character,_that.department,_that.job);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true, explicitToJson: true)
class _TmdbMovieDto implements TmdbMovieDto {
  const _TmdbMovieDto({@JsonKey(fromJson: positiveInteger) required this.id, this.title, this.name, this.originalTitle, this.originalName, this.overview, this.posterPath, this.backdropPath, this.releaseDate, this.voteAverage, @JsonKey(fromJson: optionalInteger) this.voteCount, @JsonKey(fromJson: genreIdsFromJson) final  List<int> genreIds = const [], this.originalLanguage, this.popularity, this.adult, @JsonKey(fromJson: optionalInteger) this.runtime, this.status, this.tagline, final  Map<String, dynamic>? belongsToCollection, final  List<TmdbGenreDto> genres = const [], this.creditId, this.character, this.department, this.job}): _genreIds = genreIds,_belongsToCollection = belongsToCollection,_genres = genres;
  factory _TmdbMovieDto.fromJson(Map<String, dynamic> json) => _$TmdbMovieDtoFromJson(json);

@override@JsonKey(fromJson: positiveInteger) final  int id;
@override final  String? title;
@override final  String? name;
@override final  String? originalTitle;
@override final  String? originalName;
@override final  String? overview;
@override final  String? posterPath;
@override final  String? backdropPath;
@override final  String? releaseDate;
@override final  double? voteAverage;
@override@JsonKey(fromJson: optionalInteger) final  int? voteCount;
 final  List<int> _genreIds;
@override@JsonKey(fromJson: genreIdsFromJson) List<int> get genreIds {
  if (_genreIds is EqualUnmodifiableListView) return _genreIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genreIds);
}

@override final  String? originalLanguage;
@override final  double? popularity;
@override final  bool? adult;
@override@JsonKey(fromJson: optionalInteger) final  int? runtime;
@override final  String? status;
@override final  String? tagline;
 final  Map<String, dynamic>? _belongsToCollection;
@override Map<String, dynamic>? get belongsToCollection {
  final value = _belongsToCollection;
  if (value == null) return null;
  if (_belongsToCollection is EqualUnmodifiableMapView) return _belongsToCollection;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<TmdbGenreDto> _genres;
@override@JsonKey() List<TmdbGenreDto> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  String? creditId;
@override final  String? character;
@override final  String? department;
@override final  String? job;

/// Create a copy of TmdbMovieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbMovieDtoCopyWith<_TmdbMovieDto> get copyWith => __$TmdbMovieDtoCopyWithImpl<_TmdbMovieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbMovieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbMovieDto&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.name, name) || other.name == name)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.originalName, originalName) || other.originalName == originalName)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.voteCount, voteCount) || other.voteCount == voteCount)&&const DeepCollectionEquality().equals(other._genreIds, _genreIds)&&(identical(other.originalLanguage, originalLanguage) || other.originalLanguage == originalLanguage)&&(identical(other.popularity, popularity) || other.popularity == popularity)&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.runtime, runtime) || other.runtime == runtime)&&(identical(other.status, status) || other.status == status)&&(identical(other.tagline, tagline) || other.tagline == tagline)&&const DeepCollectionEquality().equals(other._belongsToCollection, _belongsToCollection)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,title,name,originalTitle,originalName,overview,posterPath,backdropPath,releaseDate,voteAverage,voteCount,const DeepCollectionEquality().hash(_genreIds),originalLanguage,popularity,adult,runtime,status,tagline,const DeepCollectionEquality().hash(_belongsToCollection),const DeepCollectionEquality().hash(_genres),creditId,character,department,job]);

@override
String toString() {
  return 'TmdbMovieDto(id: $id, title: $title, name: $name, originalTitle: $originalTitle, originalName: $originalName, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, voteAverage: $voteAverage, voteCount: $voteCount, genreIds: $genreIds, originalLanguage: $originalLanguage, popularity: $popularity, adult: $adult, runtime: $runtime, status: $status, tagline: $tagline, belongsToCollection: $belongsToCollection, genres: $genres, creditId: $creditId, character: $character, department: $department, job: $job)';
}


}

/// @nodoc
abstract mixin class _$TmdbMovieDtoCopyWith<$Res> implements $TmdbMovieDtoCopyWith<$Res> {
  factory _$TmdbMovieDtoCopyWith(_TmdbMovieDto value, $Res Function(_TmdbMovieDto) _then) = __$TmdbMovieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String? title, String? name, String? originalTitle, String? originalName, String? overview, String? posterPath, String? backdropPath, String? releaseDate, double? voteAverage,@JsonKey(fromJson: optionalInteger) int? voteCount,@JsonKey(fromJson: genreIdsFromJson) List<int> genreIds, String? originalLanguage, double? popularity, bool? adult,@JsonKey(fromJson: optionalInteger) int? runtime, String? status, String? tagline, Map<String, dynamic>? belongsToCollection, List<TmdbGenreDto> genres, String? creditId, String? character, String? department, String? job
});




}
/// @nodoc
class __$TmdbMovieDtoCopyWithImpl<$Res>
    implements _$TmdbMovieDtoCopyWith<$Res> {
  __$TmdbMovieDtoCopyWithImpl(this._self, this._then);

  final _TmdbMovieDto _self;
  final $Res Function(_TmdbMovieDto) _then;

/// Create a copy of TmdbMovieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = freezed,Object? name = freezed,Object? originalTitle = freezed,Object? originalName = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? voteAverage = freezed,Object? voteCount = freezed,Object? genreIds = null,Object? originalLanguage = freezed,Object? popularity = freezed,Object? adult = freezed,Object? runtime = freezed,Object? status = freezed,Object? tagline = freezed,Object? belongsToCollection = freezed,Object? genres = null,Object? creditId = freezed,Object? character = freezed,Object? department = freezed,Object? job = freezed,}) {
  return _then(_TmdbMovieDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,originalName: freezed == originalName ? _self.originalName : originalName // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,voteCount: freezed == voteCount ? _self.voteCount : voteCount // ignore: cast_nullable_to_non_nullable
as int?,genreIds: null == genreIds ? _self._genreIds : genreIds // ignore: cast_nullable_to_non_nullable
as List<int>,originalLanguage: freezed == originalLanguage ? _self.originalLanguage : originalLanguage // ignore: cast_nullable_to_non_nullable
as String?,popularity: freezed == popularity ? _self.popularity : popularity // ignore: cast_nullable_to_non_nullable
as double?,adult: freezed == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as bool?,runtime: freezed == runtime ? _self.runtime : runtime // ignore: cast_nullable_to_non_nullable
as int?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,tagline: freezed == tagline ? _self.tagline : tagline // ignore: cast_nullable_to_non_nullable
as String?,belongsToCollection: freezed == belongsToCollection ? _self._belongsToCollection : belongsToCollection // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<TmdbGenreDto>,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TmdbGenreDto {

@JsonKey(fromJson: positiveInteger) int get id; String get name;
/// Create a copy of TmdbGenreDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbGenreDtoCopyWith<TmdbGenreDto> get copyWith => _$TmdbGenreDtoCopyWithImpl<TmdbGenreDto>(this as TmdbGenreDto, _$identity);

  /// Serializes this TmdbGenreDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbGenreDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'TmdbGenreDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $TmdbGenreDtoCopyWith<$Res>  {
  factory $TmdbGenreDtoCopyWith(TmdbGenreDto value, $Res Function(TmdbGenreDto) _then) = _$TmdbGenreDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String name
});




}
/// @nodoc
class _$TmdbGenreDtoCopyWithImpl<$Res>
    implements $TmdbGenreDtoCopyWith<$Res> {
  _$TmdbGenreDtoCopyWithImpl(this._self, this._then);

  final TmdbGenreDto _self;
  final $Res Function(TmdbGenreDto) _then;

/// Create a copy of TmdbGenreDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbGenreDto].
extension TmdbGenreDtoPatterns on TmdbGenreDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbGenreDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbGenreDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbGenreDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbGenreDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbGenreDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbGenreDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbGenreDto() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String name)  $default,) {final _that = this;
switch (_that) {
case _TmdbGenreDto():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: positiveInteger)  int id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _TmdbGenreDto() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(checked: true)
class _TmdbGenreDto implements TmdbGenreDto {
  const _TmdbGenreDto({@JsonKey(fromJson: positiveInteger) required this.id, required this.name});
  factory _TmdbGenreDto.fromJson(Map<String, dynamic> json) => _$TmdbGenreDtoFromJson(json);

@override@JsonKey(fromJson: positiveInteger) final  int id;
@override final  String name;

/// Create a copy of TmdbGenreDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbGenreDtoCopyWith<_TmdbGenreDto> get copyWith => __$TmdbGenreDtoCopyWithImpl<_TmdbGenreDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbGenreDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbGenreDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'TmdbGenreDto(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$TmdbGenreDtoCopyWith<$Res> implements $TmdbGenreDtoCopyWith<$Res> {
  factory _$TmdbGenreDtoCopyWith(_TmdbGenreDto value, $Res Function(_TmdbGenreDto) _then) = __$TmdbGenreDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String name
});




}
/// @nodoc
class __$TmdbGenreDtoCopyWithImpl<$Res>
    implements _$TmdbGenreDtoCopyWith<$Res> {
  __$TmdbGenreDtoCopyWithImpl(this._self, this._then);

  final _TmdbGenreDto _self;
  final $Res Function(_TmdbGenreDto) _then;

/// Create a copy of TmdbGenreDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_TmdbGenreDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TmdbPersonDto {

@JsonKey(fromJson: positiveInteger) int get id; String get name; String? get profilePath; String? get knownForDepartment; String? get biography; String? get birthday; String? get deathday; String? get placeOfBirth; List<String> get alsoKnownAs; String? get creditId; String? get character; String? get department; String? get job;@JsonKey(fromJson: optionalInteger) int? get order;
/// Create a copy of TmdbPersonDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbPersonDtoCopyWith<TmdbPersonDto> get copyWith => _$TmdbPersonDtoCopyWithImpl<TmdbPersonDto>(this as TmdbPersonDto, _$identity);

  /// Serializes this TmdbPersonDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbPersonDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath)&&(identical(other.knownForDepartment, knownForDepartment) || other.knownForDepartment == knownForDepartment)&&(identical(other.biography, biography) || other.biography == biography)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.deathday, deathday) || other.deathday == deathday)&&(identical(other.placeOfBirth, placeOfBirth) || other.placeOfBirth == placeOfBirth)&&const DeepCollectionEquality().equals(other.alsoKnownAs, alsoKnownAs)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profilePath,knownForDepartment,biography,birthday,deathday,placeOfBirth,const DeepCollectionEquality().hash(alsoKnownAs),creditId,character,department,job,order);

@override
String toString() {
  return 'TmdbPersonDto(id: $id, name: $name, profilePath: $profilePath, knownForDepartment: $knownForDepartment, biography: $biography, birthday: $birthday, deathday: $deathday, placeOfBirth: $placeOfBirth, alsoKnownAs: $alsoKnownAs, creditId: $creditId, character: $character, department: $department, job: $job, order: $order)';
}


}

/// @nodoc
abstract mixin class $TmdbPersonDtoCopyWith<$Res>  {
  factory $TmdbPersonDtoCopyWith(TmdbPersonDto value, $Res Function(TmdbPersonDto) _then) = _$TmdbPersonDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String name, String? profilePath, String? knownForDepartment, String? biography, String? birthday, String? deathday, String? placeOfBirth, List<String> alsoKnownAs, String? creditId, String? character, String? department, String? job,@JsonKey(fromJson: optionalInteger) int? order
});




}
/// @nodoc
class _$TmdbPersonDtoCopyWithImpl<$Res>
    implements $TmdbPersonDtoCopyWith<$Res> {
  _$TmdbPersonDtoCopyWithImpl(this._self, this._then);

  final TmdbPersonDto _self;
  final $Res Function(TmdbPersonDto) _then;

/// Create a copy of TmdbPersonDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? profilePath = freezed,Object? knownForDepartment = freezed,Object? biography = freezed,Object? birthday = freezed,Object? deathday = freezed,Object? placeOfBirth = freezed,Object? alsoKnownAs = null,Object? creditId = freezed,Object? character = freezed,Object? department = freezed,Object? job = freezed,Object? order = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,knownForDepartment: freezed == knownForDepartment ? _self.knownForDepartment : knownForDepartment // ignore: cast_nullable_to_non_nullable
as String?,biography: freezed == biography ? _self.biography : biography // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,deathday: freezed == deathday ? _self.deathday : deathday // ignore: cast_nullable_to_non_nullable
as String?,placeOfBirth: freezed == placeOfBirth ? _self.placeOfBirth : placeOfBirth // ignore: cast_nullable_to_non_nullable
as String?,alsoKnownAs: null == alsoKnownAs ? _self.alsoKnownAs : alsoKnownAs // ignore: cast_nullable_to_non_nullable
as List<String>,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbPersonDto].
extension TmdbPersonDtoPatterns on TmdbPersonDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbPersonDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbPersonDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbPersonDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbPersonDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbPersonDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbPersonDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String name,  String? profilePath,  String? knownForDepartment,  String? biography,  String? birthday,  String? deathday,  String? placeOfBirth,  List<String> alsoKnownAs,  String? creditId,  String? character,  String? department,  String? job, @JsonKey(fromJson: optionalInteger)  int? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbPersonDto() when $default != null:
return $default(_that.id,_that.name,_that.profilePath,_that.knownForDepartment,_that.biography,_that.birthday,_that.deathday,_that.placeOfBirth,_that.alsoKnownAs,_that.creditId,_that.character,_that.department,_that.job,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String name,  String? profilePath,  String? knownForDepartment,  String? biography,  String? birthday,  String? deathday,  String? placeOfBirth,  List<String> alsoKnownAs,  String? creditId,  String? character,  String? department,  String? job, @JsonKey(fromJson: optionalInteger)  int? order)  $default,) {final _that = this;
switch (_that) {
case _TmdbPersonDto():
return $default(_that.id,_that.name,_that.profilePath,_that.knownForDepartment,_that.biography,_that.birthday,_that.deathday,_that.placeOfBirth,_that.alsoKnownAs,_that.creditId,_that.character,_that.department,_that.job,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: positiveInteger)  int id,  String name,  String? profilePath,  String? knownForDepartment,  String? biography,  String? birthday,  String? deathday,  String? placeOfBirth,  List<String> alsoKnownAs,  String? creditId,  String? character,  String? department,  String? job, @JsonKey(fromJson: optionalInteger)  int? order)?  $default,) {final _that = this;
switch (_that) {
case _TmdbPersonDto() when $default != null:
return $default(_that.id,_that.name,_that.profilePath,_that.knownForDepartment,_that.biography,_that.birthday,_that.deathday,_that.placeOfBirth,_that.alsoKnownAs,_that.creditId,_that.character,_that.department,_that.job,_that.order);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true, explicitToJson: true)
class _TmdbPersonDto implements TmdbPersonDto {
  const _TmdbPersonDto({@JsonKey(fromJson: positiveInteger) required this.id, required this.name, this.profilePath, this.knownForDepartment, this.biography, this.birthday, this.deathday, this.placeOfBirth, final  List<String> alsoKnownAs = const [], this.creditId, this.character, this.department, this.job, @JsonKey(fromJson: optionalInteger) this.order}): _alsoKnownAs = alsoKnownAs;
  factory _TmdbPersonDto.fromJson(Map<String, dynamic> json) => _$TmdbPersonDtoFromJson(json);

@override@JsonKey(fromJson: positiveInteger) final  int id;
@override final  String name;
@override final  String? profilePath;
@override final  String? knownForDepartment;
@override final  String? biography;
@override final  String? birthday;
@override final  String? deathday;
@override final  String? placeOfBirth;
 final  List<String> _alsoKnownAs;
@override@JsonKey() List<String> get alsoKnownAs {
  if (_alsoKnownAs is EqualUnmodifiableListView) return _alsoKnownAs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alsoKnownAs);
}

@override final  String? creditId;
@override final  String? character;
@override final  String? department;
@override final  String? job;
@override@JsonKey(fromJson: optionalInteger) final  int? order;

/// Create a copy of TmdbPersonDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbPersonDtoCopyWith<_TmdbPersonDto> get copyWith => __$TmdbPersonDtoCopyWithImpl<_TmdbPersonDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbPersonDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbPersonDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath)&&(identical(other.knownForDepartment, knownForDepartment) || other.knownForDepartment == knownForDepartment)&&(identical(other.biography, biography) || other.biography == biography)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.deathday, deathday) || other.deathday == deathday)&&(identical(other.placeOfBirth, placeOfBirth) || other.placeOfBirth == placeOfBirth)&&const DeepCollectionEquality().equals(other._alsoKnownAs, _alsoKnownAs)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profilePath,knownForDepartment,biography,birthday,deathday,placeOfBirth,const DeepCollectionEquality().hash(_alsoKnownAs),creditId,character,department,job,order);

@override
String toString() {
  return 'TmdbPersonDto(id: $id, name: $name, profilePath: $profilePath, knownForDepartment: $knownForDepartment, biography: $biography, birthday: $birthday, deathday: $deathday, placeOfBirth: $placeOfBirth, alsoKnownAs: $alsoKnownAs, creditId: $creditId, character: $character, department: $department, job: $job, order: $order)';
}


}

/// @nodoc
abstract mixin class _$TmdbPersonDtoCopyWith<$Res> implements $TmdbPersonDtoCopyWith<$Res> {
  factory _$TmdbPersonDtoCopyWith(_TmdbPersonDto value, $Res Function(_TmdbPersonDto) _then) = __$TmdbPersonDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String name, String? profilePath, String? knownForDepartment, String? biography, String? birthday, String? deathday, String? placeOfBirth, List<String> alsoKnownAs, String? creditId, String? character, String? department, String? job,@JsonKey(fromJson: optionalInteger) int? order
});




}
/// @nodoc
class __$TmdbPersonDtoCopyWithImpl<$Res>
    implements _$TmdbPersonDtoCopyWith<$Res> {
  __$TmdbPersonDtoCopyWithImpl(this._self, this._then);

  final _TmdbPersonDto _self;
  final $Res Function(_TmdbPersonDto) _then;

/// Create a copy of TmdbPersonDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? profilePath = freezed,Object? knownForDepartment = freezed,Object? biography = freezed,Object? birthday = freezed,Object? deathday = freezed,Object? placeOfBirth = freezed,Object? alsoKnownAs = null,Object? creditId = freezed,Object? character = freezed,Object? department = freezed,Object? job = freezed,Object? order = freezed,}) {
  return _then(_TmdbPersonDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,knownForDepartment: freezed == knownForDepartment ? _self.knownForDepartment : knownForDepartment // ignore: cast_nullable_to_non_nullable
as String?,biography: freezed == biography ? _self.biography : biography // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as String?,deathday: freezed == deathday ? _self.deathday : deathday // ignore: cast_nullable_to_non_nullable
as String?,placeOfBirth: freezed == placeOfBirth ? _self.placeOfBirth : placeOfBirth // ignore: cast_nullable_to_non_nullable
as String?,alsoKnownAs: null == alsoKnownAs ? _self._alsoKnownAs : alsoKnownAs // ignore: cast_nullable_to_non_nullable
as List<String>,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$TmdbCollectionDto {

@JsonKey(fromJson: positiveInteger) int get id; String? get name; String? get title; String? get overview; String? get posterPath; String? get backdropPath; List<Map<String, dynamic>>? get parts;
/// Create a copy of TmdbCollectionDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbCollectionDtoCopyWith<TmdbCollectionDto> get copyWith => _$TmdbCollectionDtoCopyWithImpl<TmdbCollectionDto>(this as TmdbCollectionDto, _$identity);

  /// Serializes this TmdbCollectionDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbCollectionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&const DeepCollectionEquality().equals(other.parts, parts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,overview,posterPath,backdropPath,const DeepCollectionEquality().hash(parts));

@override
String toString() {
  return 'TmdbCollectionDto(id: $id, name: $name, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, parts: $parts)';
}


}

/// @nodoc
abstract mixin class $TmdbCollectionDtoCopyWith<$Res>  {
  factory $TmdbCollectionDtoCopyWith(TmdbCollectionDto value, $Res Function(TmdbCollectionDto) _then) = _$TmdbCollectionDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String? name, String? title, String? overview, String? posterPath, String? backdropPath, List<Map<String, dynamic>>? parts
});




}
/// @nodoc
class _$TmdbCollectionDtoCopyWithImpl<$Res>
    implements $TmdbCollectionDtoCopyWith<$Res> {
  _$TmdbCollectionDtoCopyWithImpl(this._self, this._then);

  final TmdbCollectionDto _self;
  final $Res Function(TmdbCollectionDto) _then;

/// Create a copy of TmdbCollectionDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? title = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? parts = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,parts: freezed == parts ? _self.parts : parts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbCollectionDto].
extension TmdbCollectionDtoPatterns on TmdbCollectionDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbCollectionDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbCollectionDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbCollectionDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbCollectionDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbCollectionDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbCollectionDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String? name,  String? title,  String? overview,  String? posterPath,  String? backdropPath,  List<Map<String, dynamic>>? parts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbCollectionDto() when $default != null:
return $default(_that.id,_that.name,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.parts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: positiveInteger)  int id,  String? name,  String? title,  String? overview,  String? posterPath,  String? backdropPath,  List<Map<String, dynamic>>? parts)  $default,) {final _that = this;
switch (_that) {
case _TmdbCollectionDto():
return $default(_that.id,_that.name,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.parts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: positiveInteger)  int id,  String? name,  String? title,  String? overview,  String? posterPath,  String? backdropPath,  List<Map<String, dynamic>>? parts)?  $default,) {final _that = this;
switch (_that) {
case _TmdbCollectionDto() when $default != null:
return $default(_that.id,_that.name,_that.title,_that.overview,_that.posterPath,_that.backdropPath,_that.parts);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true, explicitToJson: true)
class _TmdbCollectionDto implements TmdbCollectionDto {
  const _TmdbCollectionDto({@JsonKey(fromJson: positiveInteger) required this.id, this.name, this.title, this.overview, this.posterPath, this.backdropPath, final  List<Map<String, dynamic>>? parts}): _parts = parts;
  factory _TmdbCollectionDto.fromJson(Map<String, dynamic> json) => _$TmdbCollectionDtoFromJson(json);

@override@JsonKey(fromJson: positiveInteger) final  int id;
@override final  String? name;
@override final  String? title;
@override final  String? overview;
@override final  String? posterPath;
@override final  String? backdropPath;
 final  List<Map<String, dynamic>>? _parts;
@override List<Map<String, dynamic>>? get parts {
  final value = _parts;
  if (value == null) return null;
  if (_parts is EqualUnmodifiableListView) return _parts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of TmdbCollectionDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbCollectionDtoCopyWith<_TmdbCollectionDto> get copyWith => __$TmdbCollectionDtoCopyWithImpl<_TmdbCollectionDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbCollectionDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbCollectionDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.title, title) || other.title == title)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&const DeepCollectionEquality().equals(other._parts, _parts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,title,overview,posterPath,backdropPath,const DeepCollectionEquality().hash(_parts));

@override
String toString() {
  return 'TmdbCollectionDto(id: $id, name: $name, title: $title, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, parts: $parts)';
}


}

/// @nodoc
abstract mixin class _$TmdbCollectionDtoCopyWith<$Res> implements $TmdbCollectionDtoCopyWith<$Res> {
  factory _$TmdbCollectionDtoCopyWith(_TmdbCollectionDto value, $Res Function(_TmdbCollectionDto) _then) = __$TmdbCollectionDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: positiveInteger) int id, String? name, String? title, String? overview, String? posterPath, String? backdropPath, List<Map<String, dynamic>>? parts
});




}
/// @nodoc
class __$TmdbCollectionDtoCopyWithImpl<$Res>
    implements _$TmdbCollectionDtoCopyWith<$Res> {
  __$TmdbCollectionDtoCopyWithImpl(this._self, this._then);

  final _TmdbCollectionDto _self;
  final $Res Function(_TmdbCollectionDto) _then;

/// Create a copy of TmdbCollectionDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? title = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? parts = freezed,}) {
  return _then(_TmdbCollectionDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,parts: freezed == parts ? _self._parts : parts // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>?,
  ));
}


}


/// @nodoc
mixin _$TmdbImageDto {

 String get filePath;@JsonKey(fromJson: positiveInteger) int get width;@JsonKey(fromJson: positiveInteger) int get height; double? get aspectRatio;@JsonKey(name: 'iso_639_1') String? get language;
/// Create a copy of TmdbImageDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbImageDtoCopyWith<TmdbImageDto> get copyWith => _$TmdbImageDtoCopyWithImpl<TmdbImageDto>(this as TmdbImageDto, _$identity);

  /// Serializes this TmdbImageDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbImageDto&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filePath,width,height,aspectRatio,language);

@override
String toString() {
  return 'TmdbImageDto(filePath: $filePath, width: $width, height: $height, aspectRatio: $aspectRatio, language: $language)';
}


}

/// @nodoc
abstract mixin class $TmdbImageDtoCopyWith<$Res>  {
  factory $TmdbImageDtoCopyWith(TmdbImageDto value, $Res Function(TmdbImageDto) _then) = _$TmdbImageDtoCopyWithImpl;
@useResult
$Res call({
 String filePath,@JsonKey(fromJson: positiveInteger) int width,@JsonKey(fromJson: positiveInteger) int height, double? aspectRatio,@JsonKey(name: 'iso_639_1') String? language
});




}
/// @nodoc
class _$TmdbImageDtoCopyWithImpl<$Res>
    implements $TmdbImageDtoCopyWith<$Res> {
  _$TmdbImageDtoCopyWithImpl(this._self, this._then);

  final TmdbImageDto _self;
  final $Res Function(TmdbImageDto) _then;

/// Create a copy of TmdbImageDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePath = null,Object? width = null,Object? height = null,Object? aspectRatio = freezed,Object? language = freezed,}) {
  return _then(_self.copyWith(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbImageDto].
extension TmdbImageDtoPatterns on TmdbImageDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbImageDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbImageDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbImageDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbImageDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbImageDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbImageDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String filePath, @JsonKey(fromJson: positiveInteger)  int width, @JsonKey(fromJson: positiveInteger)  int height,  double? aspectRatio, @JsonKey(name: 'iso_639_1')  String? language)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbImageDto() when $default != null:
return $default(_that.filePath,_that.width,_that.height,_that.aspectRatio,_that.language);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String filePath, @JsonKey(fromJson: positiveInteger)  int width, @JsonKey(fromJson: positiveInteger)  int height,  double? aspectRatio, @JsonKey(name: 'iso_639_1')  String? language)  $default,) {final _that = this;
switch (_that) {
case _TmdbImageDto():
return $default(_that.filePath,_that.width,_that.height,_that.aspectRatio,_that.language);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String filePath, @JsonKey(fromJson: positiveInteger)  int width, @JsonKey(fromJson: positiveInteger)  int height,  double? aspectRatio, @JsonKey(name: 'iso_639_1')  String? language)?  $default,) {final _that = this;
switch (_that) {
case _TmdbImageDto() when $default != null:
return $default(_that.filePath,_that.width,_that.height,_that.aspectRatio,_that.language);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class _TmdbImageDto implements TmdbImageDto {
  const _TmdbImageDto({required this.filePath, @JsonKey(fromJson: positiveInteger) required this.width, @JsonKey(fromJson: positiveInteger) required this.height, this.aspectRatio, @JsonKey(name: 'iso_639_1') this.language});
  factory _TmdbImageDto.fromJson(Map<String, dynamic> json) => _$TmdbImageDtoFromJson(json);

@override final  String filePath;
@override@JsonKey(fromJson: positiveInteger) final  int width;
@override@JsonKey(fromJson: positiveInteger) final  int height;
@override final  double? aspectRatio;
@override@JsonKey(name: 'iso_639_1') final  String? language;

/// Create a copy of TmdbImageDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbImageDtoCopyWith<_TmdbImageDto> get copyWith => __$TmdbImageDtoCopyWithImpl<_TmdbImageDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbImageDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbImageDto&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.language, language) || other.language == language));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filePath,width,height,aspectRatio,language);

@override
String toString() {
  return 'TmdbImageDto(filePath: $filePath, width: $width, height: $height, aspectRatio: $aspectRatio, language: $language)';
}


}

/// @nodoc
abstract mixin class _$TmdbImageDtoCopyWith<$Res> implements $TmdbImageDtoCopyWith<$Res> {
  factory _$TmdbImageDtoCopyWith(_TmdbImageDto value, $Res Function(_TmdbImageDto) _then) = __$TmdbImageDtoCopyWithImpl;
@override @useResult
$Res call({
 String filePath,@JsonKey(fromJson: positiveInteger) int width,@JsonKey(fromJson: positiveInteger) int height, double? aspectRatio,@JsonKey(name: 'iso_639_1') String? language
});




}
/// @nodoc
class __$TmdbImageDtoCopyWithImpl<$Res>
    implements _$TmdbImageDtoCopyWith<$Res> {
  __$TmdbImageDtoCopyWithImpl(this._self, this._then);

  final _TmdbImageDto _self;
  final $Res Function(_TmdbImageDto) _then;

/// Create a copy of TmdbImageDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? width = null,Object? height = null,Object? aspectRatio = freezed,Object? language = freezed,}) {
  return _then(_TmdbImageDto(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TmdbVideoDto {

 String? get id; String? get name; String? get key; String? get site; String? get type; bool get official; String? get publishedAt;
/// Create a copy of TmdbVideoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbVideoDtoCopyWith<TmdbVideoDto> get copyWith => _$TmdbVideoDtoCopyWithImpl<TmdbVideoDto>(this as TmdbVideoDto, _$identity);

  /// Serializes this TmdbVideoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbVideoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.key, key) || other.key == key)&&(identical(other.site, site) || other.site == site)&&(identical(other.type, type) || other.type == type)&&(identical(other.official, official) || other.official == official)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,key,site,type,official,publishedAt);

@override
String toString() {
  return 'TmdbVideoDto(id: $id, name: $name, key: $key, site: $site, type: $type, official: $official, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $TmdbVideoDtoCopyWith<$Res>  {
  factory $TmdbVideoDtoCopyWith(TmdbVideoDto value, $Res Function(TmdbVideoDto) _then) = _$TmdbVideoDtoCopyWithImpl;
@useResult
$Res call({
 String? id, String? name, String? key, String? site, String? type, bool official, String? publishedAt
});




}
/// @nodoc
class _$TmdbVideoDtoCopyWithImpl<$Res>
    implements $TmdbVideoDtoCopyWith<$Res> {
  _$TmdbVideoDtoCopyWithImpl(this._self, this._then);

  final TmdbVideoDto _self;
  final $Res Function(TmdbVideoDto) _then;

/// Create a copy of TmdbVideoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? key = freezed,Object? site = freezed,Object? type = freezed,Object? official = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,official: null == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbVideoDto].
extension TmdbVideoDtoPatterns on TmdbVideoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbVideoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbVideoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbVideoDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbVideoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbVideoDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbVideoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? name,  String? key,  String? site,  String? type,  bool official,  String? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbVideoDto() when $default != null:
return $default(_that.id,_that.name,_that.key,_that.site,_that.type,_that.official,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? name,  String? key,  String? site,  String? type,  bool official,  String? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _TmdbVideoDto():
return $default(_that.id,_that.name,_that.key,_that.site,_that.type,_that.official,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? name,  String? key,  String? site,  String? type,  bool official,  String? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _TmdbVideoDto() when $default != null:
return $default(_that.id,_that.name,_that.key,_that.site,_that.type,_that.official,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class _TmdbVideoDto implements TmdbVideoDto {
  const _TmdbVideoDto({this.id, this.name, this.key, this.site, this.type, this.official = false, this.publishedAt});
  factory _TmdbVideoDto.fromJson(Map<String, dynamic> json) => _$TmdbVideoDtoFromJson(json);

@override final  String? id;
@override final  String? name;
@override final  String? key;
@override final  String? site;
@override final  String? type;
@override@JsonKey() final  bool official;
@override final  String? publishedAt;

/// Create a copy of TmdbVideoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbVideoDtoCopyWith<_TmdbVideoDto> get copyWith => __$TmdbVideoDtoCopyWithImpl<_TmdbVideoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbVideoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbVideoDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.key, key) || other.key == key)&&(identical(other.site, site) || other.site == site)&&(identical(other.type, type) || other.type == type)&&(identical(other.official, official) || other.official == official)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,key,site,type,official,publishedAt);

@override
String toString() {
  return 'TmdbVideoDto(id: $id, name: $name, key: $key, site: $site, type: $type, official: $official, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$TmdbVideoDtoCopyWith<$Res> implements $TmdbVideoDtoCopyWith<$Res> {
  factory _$TmdbVideoDtoCopyWith(_TmdbVideoDto value, $Res Function(_TmdbVideoDto) _then) = __$TmdbVideoDtoCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? name, String? key, String? site, String? type, bool official, String? publishedAt
});




}
/// @nodoc
class __$TmdbVideoDtoCopyWithImpl<$Res>
    implements _$TmdbVideoDtoCopyWith<$Res> {
  __$TmdbVideoDtoCopyWithImpl(this._self, this._then);

  final _TmdbVideoDto _self;
  final $Res Function(_TmdbVideoDto) _then;

/// Create a copy of TmdbVideoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? key = freezed,Object? site = freezed,Object? type = freezed,Object? official = null,Object? publishedAt = freezed,}) {
  return _then(_TmdbVideoDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,key: freezed == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String?,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,official: null == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as bool,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TmdbReviewDto {

 String get id; String get author; String get content; Map<String, dynamic>? get authorDetails; String? get createdAt; String? get updatedAt;
/// Create a copy of TmdbReviewDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbReviewDtoCopyWith<TmdbReviewDto> get copyWith => _$TmdbReviewDtoCopyWithImpl<TmdbReviewDto>(this as TmdbReviewDto, _$identity);

  /// Serializes this TmdbReviewDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbReviewDto&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.authorDetails, authorDetails)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,content,const DeepCollectionEquality().hash(authorDetails),createdAt,updatedAt);

@override
String toString() {
  return 'TmdbReviewDto(id: $id, author: $author, content: $content, authorDetails: $authorDetails, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TmdbReviewDtoCopyWith<$Res>  {
  factory $TmdbReviewDtoCopyWith(TmdbReviewDto value, $Res Function(TmdbReviewDto) _then) = _$TmdbReviewDtoCopyWithImpl;
@useResult
$Res call({
 String id, String author, String content, Map<String, dynamic>? authorDetails, String? createdAt, String? updatedAt
});




}
/// @nodoc
class _$TmdbReviewDtoCopyWithImpl<$Res>
    implements $TmdbReviewDtoCopyWith<$Res> {
  _$TmdbReviewDtoCopyWithImpl(this._self, this._then);

  final TmdbReviewDto _self;
  final $Res Function(TmdbReviewDto) _then;

/// Create a copy of TmdbReviewDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? content = null,Object? authorDetails = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorDetails: freezed == authorDetails ? _self.authorDetails : authorDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbReviewDto].
extension TmdbReviewDtoPatterns on TmdbReviewDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbReviewDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbReviewDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbReviewDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbReviewDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbReviewDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbReviewDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String author,  String content,  Map<String, dynamic>? authorDetails,  String? createdAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbReviewDto() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.authorDetails,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String author,  String content,  Map<String, dynamic>? authorDetails,  String? createdAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TmdbReviewDto():
return $default(_that.id,_that.author,_that.content,_that.authorDetails,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String author,  String content,  Map<String, dynamic>? authorDetails,  String? createdAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TmdbReviewDto() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.authorDetails,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class _TmdbReviewDto implements TmdbReviewDto {
  const _TmdbReviewDto({required this.id, required this.author, required this.content, final  Map<String, dynamic>? authorDetails, this.createdAt, this.updatedAt}): _authorDetails = authorDetails;
  factory _TmdbReviewDto.fromJson(Map<String, dynamic> json) => _$TmdbReviewDtoFromJson(json);

@override final  String id;
@override final  String author;
@override final  String content;
 final  Map<String, dynamic>? _authorDetails;
@override Map<String, dynamic>? get authorDetails {
  final value = _authorDetails;
  if (value == null) return null;
  if (_authorDetails is EqualUnmodifiableMapView) return _authorDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? createdAt;
@override final  String? updatedAt;

/// Create a copy of TmdbReviewDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbReviewDtoCopyWith<_TmdbReviewDto> get copyWith => __$TmdbReviewDtoCopyWithImpl<_TmdbReviewDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbReviewDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbReviewDto&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._authorDetails, _authorDetails)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,content,const DeepCollectionEquality().hash(_authorDetails),createdAt,updatedAt);

@override
String toString() {
  return 'TmdbReviewDto(id: $id, author: $author, content: $content, authorDetails: $authorDetails, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TmdbReviewDtoCopyWith<$Res> implements $TmdbReviewDtoCopyWith<$Res> {
  factory _$TmdbReviewDtoCopyWith(_TmdbReviewDto value, $Res Function(_TmdbReviewDto) _then) = __$TmdbReviewDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String author, String content, Map<String, dynamic>? authorDetails, String? createdAt, String? updatedAt
});




}
/// @nodoc
class __$TmdbReviewDtoCopyWithImpl<$Res>
    implements _$TmdbReviewDtoCopyWith<$Res> {
  __$TmdbReviewDtoCopyWithImpl(this._self, this._then);

  final _TmdbReviewDto _self;
  final $Res Function(_TmdbReviewDto) _then;

/// Create a copy of TmdbReviewDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? content = null,Object? authorDetails = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_TmdbReviewDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorDetails: freezed == authorDetails ? _self._authorDetails : authorDetails // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TmdbImageConfigurationDto {

 String get secureBaseUrl; List<String> get posterSizes; List<String> get backdropSizes; List<String> get profileSizes;
/// Create a copy of TmdbImageConfigurationDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TmdbImageConfigurationDtoCopyWith<TmdbImageConfigurationDto> get copyWith => _$TmdbImageConfigurationDtoCopyWithImpl<TmdbImageConfigurationDto>(this as TmdbImageConfigurationDto, _$identity);

  /// Serializes this TmdbImageConfigurationDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TmdbImageConfigurationDto&&(identical(other.secureBaseUrl, secureBaseUrl) || other.secureBaseUrl == secureBaseUrl)&&const DeepCollectionEquality().equals(other.posterSizes, posterSizes)&&const DeepCollectionEquality().equals(other.backdropSizes, backdropSizes)&&const DeepCollectionEquality().equals(other.profileSizes, profileSizes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secureBaseUrl,const DeepCollectionEquality().hash(posterSizes),const DeepCollectionEquality().hash(backdropSizes),const DeepCollectionEquality().hash(profileSizes));

@override
String toString() {
  return 'TmdbImageConfigurationDto(secureBaseUrl: $secureBaseUrl, posterSizes: $posterSizes, backdropSizes: $backdropSizes, profileSizes: $profileSizes)';
}


}

/// @nodoc
abstract mixin class $TmdbImageConfigurationDtoCopyWith<$Res>  {
  factory $TmdbImageConfigurationDtoCopyWith(TmdbImageConfigurationDto value, $Res Function(TmdbImageConfigurationDto) _then) = _$TmdbImageConfigurationDtoCopyWithImpl;
@useResult
$Res call({
 String secureBaseUrl, List<String> posterSizes, List<String> backdropSizes, List<String> profileSizes
});




}
/// @nodoc
class _$TmdbImageConfigurationDtoCopyWithImpl<$Res>
    implements $TmdbImageConfigurationDtoCopyWith<$Res> {
  _$TmdbImageConfigurationDtoCopyWithImpl(this._self, this._then);

  final TmdbImageConfigurationDto _self;
  final $Res Function(TmdbImageConfigurationDto) _then;

/// Create a copy of TmdbImageConfigurationDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? secureBaseUrl = null,Object? posterSizes = null,Object? backdropSizes = null,Object? profileSizes = null,}) {
  return _then(_self.copyWith(
secureBaseUrl: null == secureBaseUrl ? _self.secureBaseUrl : secureBaseUrl // ignore: cast_nullable_to_non_nullable
as String,posterSizes: null == posterSizes ? _self.posterSizes : posterSizes // ignore: cast_nullable_to_non_nullable
as List<String>,backdropSizes: null == backdropSizes ? _self.backdropSizes : backdropSizes // ignore: cast_nullable_to_non_nullable
as List<String>,profileSizes: null == profileSizes ? _self.profileSizes : profileSizes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [TmdbImageConfigurationDto].
extension TmdbImageConfigurationDtoPatterns on TmdbImageConfigurationDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TmdbImageConfigurationDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TmdbImageConfigurationDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TmdbImageConfigurationDto value)  $default,){
final _that = this;
switch (_that) {
case _TmdbImageConfigurationDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TmdbImageConfigurationDto value)?  $default,){
final _that = this;
switch (_that) {
case _TmdbImageConfigurationDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String secureBaseUrl,  List<String> posterSizes,  List<String> backdropSizes,  List<String> profileSizes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TmdbImageConfigurationDto() when $default != null:
return $default(_that.secureBaseUrl,_that.posterSizes,_that.backdropSizes,_that.profileSizes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String secureBaseUrl,  List<String> posterSizes,  List<String> backdropSizes,  List<String> profileSizes)  $default,) {final _that = this;
switch (_that) {
case _TmdbImageConfigurationDto():
return $default(_that.secureBaseUrl,_that.posterSizes,_that.backdropSizes,_that.profileSizes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String secureBaseUrl,  List<String> posterSizes,  List<String> backdropSizes,  List<String> profileSizes)?  $default,) {final _that = this;
switch (_that) {
case _TmdbImageConfigurationDto() when $default != null:
return $default(_that.secureBaseUrl,_that.posterSizes,_that.backdropSizes,_that.profileSizes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake, checked: true)
class _TmdbImageConfigurationDto implements TmdbImageConfigurationDto {
  const _TmdbImageConfigurationDto({required this.secureBaseUrl, required final  List<String> posterSizes, required final  List<String> backdropSizes, required final  List<String> profileSizes}): _posterSizes = posterSizes,_backdropSizes = backdropSizes,_profileSizes = profileSizes;
  factory _TmdbImageConfigurationDto.fromJson(Map<String, dynamic> json) => _$TmdbImageConfigurationDtoFromJson(json);

@override final  String secureBaseUrl;
 final  List<String> _posterSizes;
@override List<String> get posterSizes {
  if (_posterSizes is EqualUnmodifiableListView) return _posterSizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posterSizes);
}

 final  List<String> _backdropSizes;
@override List<String> get backdropSizes {
  if (_backdropSizes is EqualUnmodifiableListView) return _backdropSizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_backdropSizes);
}

 final  List<String> _profileSizes;
@override List<String> get profileSizes {
  if (_profileSizes is EqualUnmodifiableListView) return _profileSizes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profileSizes);
}


/// Create a copy of TmdbImageConfigurationDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TmdbImageConfigurationDtoCopyWith<_TmdbImageConfigurationDto> get copyWith => __$TmdbImageConfigurationDtoCopyWithImpl<_TmdbImageConfigurationDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TmdbImageConfigurationDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TmdbImageConfigurationDto&&(identical(other.secureBaseUrl, secureBaseUrl) || other.secureBaseUrl == secureBaseUrl)&&const DeepCollectionEquality().equals(other._posterSizes, _posterSizes)&&const DeepCollectionEquality().equals(other._backdropSizes, _backdropSizes)&&const DeepCollectionEquality().equals(other._profileSizes, _profileSizes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secureBaseUrl,const DeepCollectionEquality().hash(_posterSizes),const DeepCollectionEquality().hash(_backdropSizes),const DeepCollectionEquality().hash(_profileSizes));

@override
String toString() {
  return 'TmdbImageConfigurationDto(secureBaseUrl: $secureBaseUrl, posterSizes: $posterSizes, backdropSizes: $backdropSizes, profileSizes: $profileSizes)';
}


}

/// @nodoc
abstract mixin class _$TmdbImageConfigurationDtoCopyWith<$Res> implements $TmdbImageConfigurationDtoCopyWith<$Res> {
  factory _$TmdbImageConfigurationDtoCopyWith(_TmdbImageConfigurationDto value, $Res Function(_TmdbImageConfigurationDto) _then) = __$TmdbImageConfigurationDtoCopyWithImpl;
@override @useResult
$Res call({
 String secureBaseUrl, List<String> posterSizes, List<String> backdropSizes, List<String> profileSizes
});




}
/// @nodoc
class __$TmdbImageConfigurationDtoCopyWithImpl<$Res>
    implements _$TmdbImageConfigurationDtoCopyWith<$Res> {
  __$TmdbImageConfigurationDtoCopyWithImpl(this._self, this._then);

  final _TmdbImageConfigurationDto _self;
  final $Res Function(_TmdbImageConfigurationDto) _then;

/// Create a copy of TmdbImageConfigurationDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? secureBaseUrl = null,Object? posterSizes = null,Object? backdropSizes = null,Object? profileSizes = null,}) {
  return _then(_TmdbImageConfigurationDto(
secureBaseUrl: null == secureBaseUrl ? _self.secureBaseUrl : secureBaseUrl // ignore: cast_nullable_to_non_nullable
as String,posterSizes: null == posterSizes ? _self._posterSizes : posterSizes // ignore: cast_nullable_to_non_nullable
as List<String>,backdropSizes: null == backdropSizes ? _self._backdropSizes : backdropSizes // ignore: cast_nullable_to_non_nullable
as List<String>,profileSizes: null == profileSizes ? _self._profileSizes : profileSizes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

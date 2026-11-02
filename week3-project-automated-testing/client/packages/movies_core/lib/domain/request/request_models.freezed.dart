// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RequestKey {

 String get mode; String get operation; int? get entityId; String? get query; String? get category; int? get seedMovieId; String get language; String? get region; Map<String, String> get filters; int? get page;
/// Create a copy of RequestKey
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestKeyCopyWith<RequestKey> get copyWith => _$RequestKeyCopyWithImpl<RequestKey>(this as RequestKey, _$identity);

  /// Serializes this RequestKey to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestKey&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&(identical(other.seedMovieId, seedMovieId) || other.seedMovieId == seedMovieId)&&(identical(other.language, language) || other.language == language)&&(identical(other.region, region) || other.region == region)&&const DeepCollectionEquality().equals(other.filters, filters)&&(identical(other.page, page) || other.page == page));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,operation,entityId,query,category,seedMovieId,language,region,const DeepCollectionEquality().hash(filters),page);

@override
String toString() {
  return 'RequestKey(mode: $mode, operation: $operation, entityId: $entityId, query: $query, category: $category, seedMovieId: $seedMovieId, language: $language, region: $region, filters: $filters, page: $page)';
}


}

/// @nodoc
abstract mixin class $RequestKeyCopyWith<$Res>  {
  factory $RequestKeyCopyWith(RequestKey value, $Res Function(RequestKey) _then) = _$RequestKeyCopyWithImpl;
@useResult
$Res call({
 String mode, String operation, int? entityId, String? query, String? category, int? seedMovieId, String language, String? region, Map<String, String> filters, int? page
});




}
/// @nodoc
class _$RequestKeyCopyWithImpl<$Res>
    implements $RequestKeyCopyWith<$Res> {
  _$RequestKeyCopyWithImpl(this._self, this._then);

  final RequestKey _self;
  final $Res Function(RequestKey) _then;

/// Create a copy of RequestKey
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? operation = null,Object? entityId = freezed,Object? query = freezed,Object? category = freezed,Object? seedMovieId = freezed,Object? language = null,Object? region = freezed,Object? filters = null,Object? page = freezed,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,seedMovieId: freezed == seedMovieId ? _self.seedMovieId : seedMovieId // ignore: cast_nullable_to_non_nullable
as int?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,filters: null == filters ? _self.filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestKey].
extension RequestKeyPatterns on RequestKey {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestKey value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestKey() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestKey value)  $default,){
final _that = this;
switch (_that) {
case _RequestKey():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestKey value)?  $default,){
final _that = this;
switch (_that) {
case _RequestKey() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mode,  String operation,  int? entityId,  String? query,  String? category,  int? seedMovieId,  String language,  String? region,  Map<String, String> filters,  int? page)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestKey() when $default != null:
return $default(_that.mode,_that.operation,_that.entityId,_that.query,_that.category,_that.seedMovieId,_that.language,_that.region,_that.filters,_that.page);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mode,  String operation,  int? entityId,  String? query,  String? category,  int? seedMovieId,  String language,  String? region,  Map<String, String> filters,  int? page)  $default,) {final _that = this;
switch (_that) {
case _RequestKey():
return $default(_that.mode,_that.operation,_that.entityId,_that.query,_that.category,_that.seedMovieId,_that.language,_that.region,_that.filters,_that.page);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mode,  String operation,  int? entityId,  String? query,  String? category,  int? seedMovieId,  String language,  String? region,  Map<String, String> filters,  int? page)?  $default,) {final _that = this;
switch (_that) {
case _RequestKey() when $default != null:
return $default(_that.mode,_that.operation,_that.entityId,_that.query,_that.category,_that.seedMovieId,_that.language,_that.region,_that.filters,_that.page);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RequestKey extends RequestKey {
  const _RequestKey({required this.mode, required this.operation, this.entityId, this.query, this.category, this.seedMovieId, this.language = 'en-US', this.region, final  Map<String, String> filters = const {}, this.page}): _filters = filters,super._();
  factory _RequestKey.fromJson(Map<String, dynamic> json) => _$RequestKeyFromJson(json);

@override final  String mode;
@override final  String operation;
@override final  int? entityId;
@override final  String? query;
@override final  String? category;
@override final  int? seedMovieId;
@override@JsonKey() final  String language;
@override final  String? region;
 final  Map<String, String> _filters;
@override@JsonKey() Map<String, String> get filters {
  if (_filters is EqualUnmodifiableMapView) return _filters;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_filters);
}

@override final  int? page;

/// Create a copy of RequestKey
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestKeyCopyWith<_RequestKey> get copyWith => __$RequestKeyCopyWithImpl<_RequestKey>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RequestKeyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestKey&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.query, query) || other.query == query)&&(identical(other.category, category) || other.category == category)&&(identical(other.seedMovieId, seedMovieId) || other.seedMovieId == seedMovieId)&&(identical(other.language, language) || other.language == language)&&(identical(other.region, region) || other.region == region)&&const DeepCollectionEquality().equals(other._filters, _filters)&&(identical(other.page, page) || other.page == page));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,operation,entityId,query,category,seedMovieId,language,region,const DeepCollectionEquality().hash(_filters),page);

@override
String toString() {
  return 'RequestKey(mode: $mode, operation: $operation, entityId: $entityId, query: $query, category: $category, seedMovieId: $seedMovieId, language: $language, region: $region, filters: $filters, page: $page)';
}


}

/// @nodoc
abstract mixin class _$RequestKeyCopyWith<$Res> implements $RequestKeyCopyWith<$Res> {
  factory _$RequestKeyCopyWith(_RequestKey value, $Res Function(_RequestKey) _then) = __$RequestKeyCopyWithImpl;
@override @useResult
$Res call({
 String mode, String operation, int? entityId, String? query, String? category, int? seedMovieId, String language, String? region, Map<String, String> filters, int? page
});




}
/// @nodoc
class __$RequestKeyCopyWithImpl<$Res>
    implements _$RequestKeyCopyWith<$Res> {
  __$RequestKeyCopyWithImpl(this._self, this._then);

  final _RequestKey _self;
  final $Res Function(_RequestKey) _then;

/// Create a copy of RequestKey
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? operation = null,Object? entityId = freezed,Object? query = freezed,Object? category = freezed,Object? seedMovieId = freezed,Object? language = null,Object? region = freezed,Object? filters = null,Object? page = freezed,}) {
  return _then(_RequestKey(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as int?,query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,seedMovieId: freezed == seedMovieId ? _self.seedMovieId : seedMovieId // ignore: cast_nullable_to_non_nullable
as int?,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,filters: null == filters ? _self._filters : filters // ignore: cast_nullable_to_non_nullable
as Map<String, String>,page: freezed == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$ReleaseWindow {

 CalendarDate get minimum; CalendarDate get maximum;
/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseWindowCopyWith<ReleaseWindow> get copyWith => _$ReleaseWindowCopyWithImpl<ReleaseWindow>(this as ReleaseWindow, _$identity);

  /// Serializes this ReleaseWindow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseWindow&&(identical(other.minimum, minimum) || other.minimum == minimum)&&(identical(other.maximum, maximum) || other.maximum == maximum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minimum,maximum);

@override
String toString() {
  return 'ReleaseWindow(minimum: $minimum, maximum: $maximum)';
}


}

/// @nodoc
abstract mixin class $ReleaseWindowCopyWith<$Res>  {
  factory $ReleaseWindowCopyWith(ReleaseWindow value, $Res Function(ReleaseWindow) _then) = _$ReleaseWindowCopyWithImpl;
@useResult
$Res call({
 CalendarDate minimum, CalendarDate maximum
});


$CalendarDateCopyWith<$Res> get minimum;$CalendarDateCopyWith<$Res> get maximum;

}
/// @nodoc
class _$ReleaseWindowCopyWithImpl<$Res>
    implements $ReleaseWindowCopyWith<$Res> {
  _$ReleaseWindowCopyWithImpl(this._self, this._then);

  final ReleaseWindow _self;
  final $Res Function(ReleaseWindow) _then;

/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minimum = null,Object? maximum = null,}) {
  return _then(_self.copyWith(
minimum: null == minimum ? _self.minimum : minimum // ignore: cast_nullable_to_non_nullable
as CalendarDate,maximum: null == maximum ? _self.maximum : maximum // ignore: cast_nullable_to_non_nullable
as CalendarDate,
  ));
}
/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res> get minimum {
  
  return $CalendarDateCopyWith<$Res>(_self.minimum, (value) {
    return _then(_self.copyWith(minimum: value));
  });
}/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res> get maximum {
  
  return $CalendarDateCopyWith<$Res>(_self.maximum, (value) {
    return _then(_self.copyWith(maximum: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReleaseWindow].
extension ReleaseWindowPatterns on ReleaseWindow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseWindow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseWindow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseWindow value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseWindow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseWindow value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseWindow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CalendarDate minimum,  CalendarDate maximum)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseWindow() when $default != null:
return $default(_that.minimum,_that.maximum);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CalendarDate minimum,  CalendarDate maximum)  $default,) {final _that = this;
switch (_that) {
case _ReleaseWindow():
return $default(_that.minimum,_that.maximum);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CalendarDate minimum,  CalendarDate maximum)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseWindow() when $default != null:
return $default(_that.minimum,_that.maximum);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ReleaseWindow extends ReleaseWindow {
  const _ReleaseWindow({required this.minimum, required this.maximum}): super._();
  factory _ReleaseWindow.fromJson(Map<String, dynamic> json) => _$ReleaseWindowFromJson(json);

@override final  CalendarDate minimum;
@override final  CalendarDate maximum;

/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseWindowCopyWith<_ReleaseWindow> get copyWith => __$ReleaseWindowCopyWithImpl<_ReleaseWindow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseWindowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseWindow&&(identical(other.minimum, minimum) || other.minimum == minimum)&&(identical(other.maximum, maximum) || other.maximum == maximum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minimum,maximum);

@override
String toString() {
  return 'ReleaseWindow(minimum: $minimum, maximum: $maximum)';
}


}

/// @nodoc
abstract mixin class _$ReleaseWindowCopyWith<$Res> implements $ReleaseWindowCopyWith<$Res> {
  factory _$ReleaseWindowCopyWith(_ReleaseWindow value, $Res Function(_ReleaseWindow) _then) = __$ReleaseWindowCopyWithImpl;
@override @useResult
$Res call({
 CalendarDate minimum, CalendarDate maximum
});


@override $CalendarDateCopyWith<$Res> get minimum;@override $CalendarDateCopyWith<$Res> get maximum;

}
/// @nodoc
class __$ReleaseWindowCopyWithImpl<$Res>
    implements _$ReleaseWindowCopyWith<$Res> {
  __$ReleaseWindowCopyWithImpl(this._self, this._then);

  final _ReleaseWindow _self;
  final $Res Function(_ReleaseWindow) _then;

/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minimum = null,Object? maximum = null,}) {
  return _then(_ReleaseWindow(
minimum: null == minimum ? _self.minimum : minimum // ignore: cast_nullable_to_non_nullable
as CalendarDate,maximum: null == maximum ? _self.maximum : maximum // ignore: cast_nullable_to_non_nullable
as CalendarDate,
  ));
}

/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res> get minimum {
  
  return $CalendarDateCopyWith<$Res>(_self.minimum, (value) {
    return _then(_self.copyWith(minimum: value));
  });
}/// Create a copy of ReleaseWindow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res> get maximum {
  
  return $CalendarDateCopyWith<$Res>(_self.maximum, (value) {
    return _then(_self.copyWith(maximum: value));
  });
}
}


/// @nodoc
mixin _$AppFailure {

 FailureKind get kind; String get operation;@UtcDateTimeConverter() DateTime get occurredAtUtc; bool get retryAllowed; RequestKey? get requestKey;@UtcDateTimeConverter() DateTime? get retryNotBeforeUtc; int? get httpStatus; int? get providerCode; int? get intentRevision;
/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppFailureCopyWith<AppFailure> get copyWith => _$AppFailureCopyWithImpl<AppFailure>(this as AppFailure, _$identity);

  /// Serializes this AppFailure to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppFailure&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.occurredAtUtc, occurredAtUtc) || other.occurredAtUtc == occurredAtUtc)&&(identical(other.retryAllowed, retryAllowed) || other.retryAllowed == retryAllowed)&&(identical(other.requestKey, requestKey) || other.requestKey == requestKey)&&(identical(other.retryNotBeforeUtc, retryNotBeforeUtc) || other.retryNotBeforeUtc == retryNotBeforeUtc)&&(identical(other.httpStatus, httpStatus) || other.httpStatus == httpStatus)&&(identical(other.providerCode, providerCode) || other.providerCode == providerCode)&&(identical(other.intentRevision, intentRevision) || other.intentRevision == intentRevision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,operation,occurredAtUtc,retryAllowed,requestKey,retryNotBeforeUtc,httpStatus,providerCode,intentRevision);

@override
String toString() {
  return 'AppFailure(kind: $kind, operation: $operation, occurredAtUtc: $occurredAtUtc, retryAllowed: $retryAllowed, requestKey: $requestKey, retryNotBeforeUtc: $retryNotBeforeUtc, httpStatus: $httpStatus, providerCode: $providerCode, intentRevision: $intentRevision)';
}


}

/// @nodoc
abstract mixin class $AppFailureCopyWith<$Res>  {
  factory $AppFailureCopyWith(AppFailure value, $Res Function(AppFailure) _then) = _$AppFailureCopyWithImpl;
@useResult
$Res call({
 FailureKind kind, String operation,@UtcDateTimeConverter() DateTime occurredAtUtc, bool retryAllowed, RequestKey? requestKey,@UtcDateTimeConverter() DateTime? retryNotBeforeUtc, int? httpStatus, int? providerCode, int? intentRevision
});


$RequestKeyCopyWith<$Res>? get requestKey;

}
/// @nodoc
class _$AppFailureCopyWithImpl<$Res>
    implements $AppFailureCopyWith<$Res> {
  _$AppFailureCopyWithImpl(this._self, this._then);

  final AppFailure _self;
  final $Res Function(AppFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? operation = null,Object? occurredAtUtc = null,Object? retryAllowed = null,Object? requestKey = freezed,Object? retryNotBeforeUtc = freezed,Object? httpStatus = freezed,Object? providerCode = freezed,Object? intentRevision = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FailureKind,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,occurredAtUtc: null == occurredAtUtc ? _self.occurredAtUtc : occurredAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,retryAllowed: null == retryAllowed ? _self.retryAllowed : retryAllowed // ignore: cast_nullable_to_non_nullable
as bool,requestKey: freezed == requestKey ? _self.requestKey : requestKey // ignore: cast_nullable_to_non_nullable
as RequestKey?,retryNotBeforeUtc: freezed == retryNotBeforeUtc ? _self.retryNotBeforeUtc : retryNotBeforeUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,httpStatus: freezed == httpStatus ? _self.httpStatus : httpStatus // ignore: cast_nullable_to_non_nullable
as int?,providerCode: freezed == providerCode ? _self.providerCode : providerCode // ignore: cast_nullable_to_non_nullable
as int?,intentRevision: freezed == intentRevision ? _self.intentRevision : intentRevision // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestKeyCopyWith<$Res>? get requestKey {
    if (_self.requestKey == null) {
    return null;
  }

  return $RequestKeyCopyWith<$Res>(_self.requestKey!, (value) {
    return _then(_self.copyWith(requestKey: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppFailure].
extension AppFailurePatterns on AppFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppFailure value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppFailure() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppFailure value)  $default,){
final _that = this;
switch (_that) {
case _AppFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppFailure value)?  $default,){
final _that = this;
switch (_that) {
case _AppFailure() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FailureKind kind,  String operation, @UtcDateTimeConverter()  DateTime occurredAtUtc,  bool retryAllowed,  RequestKey? requestKey, @UtcDateTimeConverter()  DateTime? retryNotBeforeUtc,  int? httpStatus,  int? providerCode,  int? intentRevision)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppFailure() when $default != null:
return $default(_that.kind,_that.operation,_that.occurredAtUtc,_that.retryAllowed,_that.requestKey,_that.retryNotBeforeUtc,_that.httpStatus,_that.providerCode,_that.intentRevision);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FailureKind kind,  String operation, @UtcDateTimeConverter()  DateTime occurredAtUtc,  bool retryAllowed,  RequestKey? requestKey, @UtcDateTimeConverter()  DateTime? retryNotBeforeUtc,  int? httpStatus,  int? providerCode,  int? intentRevision)  $default,) {final _that = this;
switch (_that) {
case _AppFailure():
return $default(_that.kind,_that.operation,_that.occurredAtUtc,_that.retryAllowed,_that.requestKey,_that.retryNotBeforeUtc,_that.httpStatus,_that.providerCode,_that.intentRevision);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FailureKind kind,  String operation, @UtcDateTimeConverter()  DateTime occurredAtUtc,  bool retryAllowed,  RequestKey? requestKey, @UtcDateTimeConverter()  DateTime? retryNotBeforeUtc,  int? httpStatus,  int? providerCode,  int? intentRevision)?  $default,) {final _that = this;
switch (_that) {
case _AppFailure() when $default != null:
return $default(_that.kind,_that.operation,_that.occurredAtUtc,_that.retryAllowed,_that.requestKey,_that.retryNotBeforeUtc,_that.httpStatus,_that.providerCode,_that.intentRevision);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _AppFailure extends AppFailure {
  const _AppFailure({required this.kind, required this.operation, @UtcDateTimeConverter() required this.occurredAtUtc, this.retryAllowed = true, this.requestKey, @UtcDateTimeConverter() this.retryNotBeforeUtc, this.httpStatus, this.providerCode, this.intentRevision}): super._();
  factory _AppFailure.fromJson(Map<String, dynamic> json) => _$AppFailureFromJson(json);

@override final  FailureKind kind;
@override final  String operation;
@override@UtcDateTimeConverter() final  DateTime occurredAtUtc;
@override@JsonKey() final  bool retryAllowed;
@override final  RequestKey? requestKey;
@override@UtcDateTimeConverter() final  DateTime? retryNotBeforeUtc;
@override final  int? httpStatus;
@override final  int? providerCode;
@override final  int? intentRevision;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppFailureCopyWith<_AppFailure> get copyWith => __$AppFailureCopyWithImpl<_AppFailure>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppFailureToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppFailure&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.occurredAtUtc, occurredAtUtc) || other.occurredAtUtc == occurredAtUtc)&&(identical(other.retryAllowed, retryAllowed) || other.retryAllowed == retryAllowed)&&(identical(other.requestKey, requestKey) || other.requestKey == requestKey)&&(identical(other.retryNotBeforeUtc, retryNotBeforeUtc) || other.retryNotBeforeUtc == retryNotBeforeUtc)&&(identical(other.httpStatus, httpStatus) || other.httpStatus == httpStatus)&&(identical(other.providerCode, providerCode) || other.providerCode == providerCode)&&(identical(other.intentRevision, intentRevision) || other.intentRevision == intentRevision));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,operation,occurredAtUtc,retryAllowed,requestKey,retryNotBeforeUtc,httpStatus,providerCode,intentRevision);

@override
String toString() {
  return 'AppFailure(kind: $kind, operation: $operation, occurredAtUtc: $occurredAtUtc, retryAllowed: $retryAllowed, requestKey: $requestKey, retryNotBeforeUtc: $retryNotBeforeUtc, httpStatus: $httpStatus, providerCode: $providerCode, intentRevision: $intentRevision)';
}


}

/// @nodoc
abstract mixin class _$AppFailureCopyWith<$Res> implements $AppFailureCopyWith<$Res> {
  factory _$AppFailureCopyWith(_AppFailure value, $Res Function(_AppFailure) _then) = __$AppFailureCopyWithImpl;
@override @useResult
$Res call({
 FailureKind kind, String operation,@UtcDateTimeConverter() DateTime occurredAtUtc, bool retryAllowed, RequestKey? requestKey,@UtcDateTimeConverter() DateTime? retryNotBeforeUtc, int? httpStatus, int? providerCode, int? intentRevision
});


@override $RequestKeyCopyWith<$Res>? get requestKey;

}
/// @nodoc
class __$AppFailureCopyWithImpl<$Res>
    implements _$AppFailureCopyWith<$Res> {
  __$AppFailureCopyWithImpl(this._self, this._then);

  final _AppFailure _self;
  final $Res Function(_AppFailure) _then;

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? operation = null,Object? occurredAtUtc = null,Object? retryAllowed = null,Object? requestKey = freezed,Object? retryNotBeforeUtc = freezed,Object? httpStatus = freezed,Object? providerCode = freezed,Object? intentRevision = freezed,}) {
  return _then(_AppFailure(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as FailureKind,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,occurredAtUtc: null == occurredAtUtc ? _self.occurredAtUtc : occurredAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime,retryAllowed: null == retryAllowed ? _self.retryAllowed : retryAllowed // ignore: cast_nullable_to_non_nullable
as bool,requestKey: freezed == requestKey ? _self.requestKey : requestKey // ignore: cast_nullable_to_non_nullable
as RequestKey?,retryNotBeforeUtc: freezed == retryNotBeforeUtc ? _self.retryNotBeforeUtc : retryNotBeforeUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,httpStatus: freezed == httpStatus ? _self.httpStatus : httpStatus // ignore: cast_nullable_to_non_nullable
as int?,providerCode: freezed == providerCode ? _self.providerCode : providerCode // ignore: cast_nullable_to_non_nullable
as int?,intentRevision: freezed == intentRevision ? _self.intentRevision : intentRevision // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of AppFailure
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestKeyCopyWith<$Res>? get requestKey {
    if (_self.requestKey == null) {
    return null;
  }

  return $RequestKeyCopyWith<$Res>(_self.requestKey!, (value) {
    return _then(_self.copyWith(requestKey: value));
  });
}
}


/// @nodoc
mixin _$PageResult<T> {

 List<T> get items; int get page; int get totalPages; int get totalResults; RequestKey get requestKey; ReleaseWindow? get releaseWindow;
/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageResultCopyWith<T, PageResult<T>> get copyWith => _$PageResultCopyWithImpl<T, PageResult<T>>(this as PageResult<T>, _$identity);

  /// Serializes this PageResult to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageResult<T>&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&(identical(other.requestKey, requestKey) || other.requestKey == requestKey)&&(identical(other.releaseWindow, releaseWindow) || other.releaseWindow == releaseWindow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,totalPages,totalResults,requestKey,releaseWindow);

@override
String toString() {
  return 'PageResult<$T>(items: $items, page: $page, totalPages: $totalPages, totalResults: $totalResults, requestKey: $requestKey, releaseWindow: $releaseWindow)';
}


}

/// @nodoc
abstract mixin class $PageResultCopyWith<T,$Res>  {
  factory $PageResultCopyWith(PageResult<T> value, $Res Function(PageResult<T>) _then) = _$PageResultCopyWithImpl;
@useResult
$Res call({
 List<T> items, int page, int totalPages, int totalResults, RequestKey requestKey, ReleaseWindow? releaseWindow
});


$RequestKeyCopyWith<$Res> get requestKey;$ReleaseWindowCopyWith<$Res>? get releaseWindow;

}
/// @nodoc
class _$PageResultCopyWithImpl<T,$Res>
    implements $PageResultCopyWith<T, $Res> {
  _$PageResultCopyWithImpl(this._self, this._then);

  final PageResult<T> _self;
  final $Res Function(PageResult<T>) _then;

/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? totalPages = null,Object? totalResults = null,Object? requestKey = null,Object? releaseWindow = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<T>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,requestKey: null == requestKey ? _self.requestKey : requestKey // ignore: cast_nullable_to_non_nullable
as RequestKey,releaseWindow: freezed == releaseWindow ? _self.releaseWindow : releaseWindow // ignore: cast_nullable_to_non_nullable
as ReleaseWindow?,
  ));
}
/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestKeyCopyWith<$Res> get requestKey {
  
  return $RequestKeyCopyWith<$Res>(_self.requestKey, (value) {
    return _then(_self.copyWith(requestKey: value));
  });
}/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseWindowCopyWith<$Res>? get releaseWindow {
    if (_self.releaseWindow == null) {
    return null;
  }

  return $ReleaseWindowCopyWith<$Res>(_self.releaseWindow!, (value) {
    return _then(_self.copyWith(releaseWindow: value));
  });
}
}


/// Adds pattern-matching-related methods to [PageResult].
extension PageResultPatterns<T> on PageResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageResult<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageResult<T> value)  $default,){
final _that = this;
switch (_that) {
case _PageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageResult<T> value)?  $default,){
final _that = this;
switch (_that) {
case _PageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<T> items,  int page,  int totalPages,  int totalResults,  RequestKey requestKey,  ReleaseWindow? releaseWindow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageResult() when $default != null:
return $default(_that.items,_that.page,_that.totalPages,_that.totalResults,_that.requestKey,_that.releaseWindow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<T> items,  int page,  int totalPages,  int totalResults,  RequestKey requestKey,  ReleaseWindow? releaseWindow)  $default,) {final _that = this;
switch (_that) {
case _PageResult():
return $default(_that.items,_that.page,_that.totalPages,_that.totalResults,_that.requestKey,_that.releaseWindow);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<T> items,  int page,  int totalPages,  int totalResults,  RequestKey requestKey,  ReleaseWindow? releaseWindow)?  $default,) {final _that = this;
switch (_that) {
case _PageResult() when $default != null:
return $default(_that.items,_that.page,_that.totalPages,_that.totalResults,_that.requestKey,_that.releaseWindow);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
class _PageResult<T> extends PageResult<T> {
  const _PageResult({required final  List<T> items, required this.page, required this.totalPages, required this.totalResults, required this.requestKey, this.releaseWindow}): _items = items,super._();
  factory _PageResult.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$PageResultFromJson(json,fromJsonT);

 final  List<T> _items;
@override List<T> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int totalPages;
@override final  int totalResults;
@override final  RequestKey requestKey;
@override final  ReleaseWindow? releaseWindow;

/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageResultCopyWith<T, _PageResult<T>> get copyWith => __$PageResultCopyWithImpl<T, _PageResult<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$PageResultToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageResult<T>&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.totalResults, totalResults) || other.totalResults == totalResults)&&(identical(other.requestKey, requestKey) || other.requestKey == requestKey)&&(identical(other.releaseWindow, releaseWindow) || other.releaseWindow == releaseWindow));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,totalPages,totalResults,requestKey,releaseWindow);

@override
String toString() {
  return 'PageResult<$T>(items: $items, page: $page, totalPages: $totalPages, totalResults: $totalResults, requestKey: $requestKey, releaseWindow: $releaseWindow)';
}


}

/// @nodoc
abstract mixin class _$PageResultCopyWith<T,$Res> implements $PageResultCopyWith<T, $Res> {
  factory _$PageResultCopyWith(_PageResult<T> value, $Res Function(_PageResult<T>) _then) = __$PageResultCopyWithImpl;
@override @useResult
$Res call({
 List<T> items, int page, int totalPages, int totalResults, RequestKey requestKey, ReleaseWindow? releaseWindow
});


@override $RequestKeyCopyWith<$Res> get requestKey;@override $ReleaseWindowCopyWith<$Res>? get releaseWindow;

}
/// @nodoc
class __$PageResultCopyWithImpl<T,$Res>
    implements _$PageResultCopyWith<T, $Res> {
  __$PageResultCopyWithImpl(this._self, this._then);

  final _PageResult<T> _self;
  final $Res Function(_PageResult<T>) _then;

/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? totalPages = null,Object? totalResults = null,Object? requestKey = null,Object? releaseWindow = freezed,}) {
  return _then(_PageResult<T>(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<T>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,totalResults: null == totalResults ? _self.totalResults : totalResults // ignore: cast_nullable_to_non_nullable
as int,requestKey: null == requestKey ? _self.requestKey : requestKey // ignore: cast_nullable_to_non_nullable
as RequestKey,releaseWindow: freezed == releaseWindow ? _self.releaseWindow : releaseWindow // ignore: cast_nullable_to_non_nullable
as ReleaseWindow?,
  ));
}

/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestKeyCopyWith<$Res> get requestKey {
  
  return $RequestKeyCopyWith<$Res>(_self.requestKey, (value) {
    return _then(_self.copyWith(requestKey: value));
  });
}/// Create a copy of PageResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReleaseWindowCopyWith<$Res>? get releaseWindow {
    if (_self.releaseWindow == null) {
    return null;
  }

  return $ReleaseWindowCopyWith<$Res>(_self.releaseWindow!, (value) {
    return _then(_self.copyWith(releaseWindow: value));
  });
}
}


/// @nodoc
mixin _$TrendingSelection {

 List<MovieSummary> get items; RequestKey get requestKey; String get timeWindow; int? get providerPage; int? get providerTotalPages; int? get providerTotalResults;
/// Create a copy of TrendingSelection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingSelectionCopyWith<TrendingSelection> get copyWith => _$TrendingSelectionCopyWithImpl<TrendingSelection>(this as TrendingSelection, _$identity);

  /// Serializes this TrendingSelection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingSelection&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.requestKey, requestKey) || other.requestKey == requestKey)&&(identical(other.timeWindow, timeWindow) || other.timeWindow == timeWindow)&&(identical(other.providerPage, providerPage) || other.providerPage == providerPage)&&(identical(other.providerTotalPages, providerTotalPages) || other.providerTotalPages == providerTotalPages)&&(identical(other.providerTotalResults, providerTotalResults) || other.providerTotalResults == providerTotalResults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),requestKey,timeWindow,providerPage,providerTotalPages,providerTotalResults);

@override
String toString() {
  return 'TrendingSelection(items: $items, requestKey: $requestKey, timeWindow: $timeWindow, providerPage: $providerPage, providerTotalPages: $providerTotalPages, providerTotalResults: $providerTotalResults)';
}


}

/// @nodoc
abstract mixin class $TrendingSelectionCopyWith<$Res>  {
  factory $TrendingSelectionCopyWith(TrendingSelection value, $Res Function(TrendingSelection) _then) = _$TrendingSelectionCopyWithImpl;
@useResult
$Res call({
 List<MovieSummary> items, RequestKey requestKey, String timeWindow, int? providerPage, int? providerTotalPages, int? providerTotalResults
});


$RequestKeyCopyWith<$Res> get requestKey;

}
/// @nodoc
class _$TrendingSelectionCopyWithImpl<$Res>
    implements $TrendingSelectionCopyWith<$Res> {
  _$TrendingSelectionCopyWithImpl(this._self, this._then);

  final TrendingSelection _self;
  final $Res Function(TrendingSelection) _then;

/// Create a copy of TrendingSelection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? requestKey = null,Object? timeWindow = null,Object? providerPage = freezed,Object? providerTotalPages = freezed,Object? providerTotalResults = freezed,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<MovieSummary>,requestKey: null == requestKey ? _self.requestKey : requestKey // ignore: cast_nullable_to_non_nullable
as RequestKey,timeWindow: null == timeWindow ? _self.timeWindow : timeWindow // ignore: cast_nullable_to_non_nullable
as String,providerPage: freezed == providerPage ? _self.providerPage : providerPage // ignore: cast_nullable_to_non_nullable
as int?,providerTotalPages: freezed == providerTotalPages ? _self.providerTotalPages : providerTotalPages // ignore: cast_nullable_to_non_nullable
as int?,providerTotalResults: freezed == providerTotalResults ? _self.providerTotalResults : providerTotalResults // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of TrendingSelection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestKeyCopyWith<$Res> get requestKey {
  
  return $RequestKeyCopyWith<$Res>(_self.requestKey, (value) {
    return _then(_self.copyWith(requestKey: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrendingSelection].
extension TrendingSelectionPatterns on TrendingSelection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingSelection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingSelection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingSelection value)  $default,){
final _that = this;
switch (_that) {
case _TrendingSelection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingSelection value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingSelection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<MovieSummary> items,  RequestKey requestKey,  String timeWindow,  int? providerPage,  int? providerTotalPages,  int? providerTotalResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingSelection() when $default != null:
return $default(_that.items,_that.requestKey,_that.timeWindow,_that.providerPage,_that.providerTotalPages,_that.providerTotalResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<MovieSummary> items,  RequestKey requestKey,  String timeWindow,  int? providerPage,  int? providerTotalPages,  int? providerTotalResults)  $default,) {final _that = this;
switch (_that) {
case _TrendingSelection():
return $default(_that.items,_that.requestKey,_that.timeWindow,_that.providerPage,_that.providerTotalPages,_that.providerTotalResults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<MovieSummary> items,  RequestKey requestKey,  String timeWindow,  int? providerPage,  int? providerTotalPages,  int? providerTotalResults)?  $default,) {final _that = this;
switch (_that) {
case _TrendingSelection() when $default != null:
return $default(_that.items,_that.requestKey,_that.timeWindow,_that.providerPage,_that.providerTotalPages,_that.providerTotalResults);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TrendingSelection extends TrendingSelection {
  const _TrendingSelection({required final  List<MovieSummary> items, required this.requestKey, this.timeWindow = 'week', this.providerPage, this.providerTotalPages, this.providerTotalResults}): _items = items,super._();
  factory _TrendingSelection.fromJson(Map<String, dynamic> json) => _$TrendingSelectionFromJson(json);

 final  List<MovieSummary> _items;
@override List<MovieSummary> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  RequestKey requestKey;
@override@JsonKey() final  String timeWindow;
@override final  int? providerPage;
@override final  int? providerTotalPages;
@override final  int? providerTotalResults;

/// Create a copy of TrendingSelection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingSelectionCopyWith<_TrendingSelection> get copyWith => __$TrendingSelectionCopyWithImpl<_TrendingSelection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendingSelectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingSelection&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.requestKey, requestKey) || other.requestKey == requestKey)&&(identical(other.timeWindow, timeWindow) || other.timeWindow == timeWindow)&&(identical(other.providerPage, providerPage) || other.providerPage == providerPage)&&(identical(other.providerTotalPages, providerTotalPages) || other.providerTotalPages == providerTotalPages)&&(identical(other.providerTotalResults, providerTotalResults) || other.providerTotalResults == providerTotalResults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),requestKey,timeWindow,providerPage,providerTotalPages,providerTotalResults);

@override
String toString() {
  return 'TrendingSelection(items: $items, requestKey: $requestKey, timeWindow: $timeWindow, providerPage: $providerPage, providerTotalPages: $providerTotalPages, providerTotalResults: $providerTotalResults)';
}


}

/// @nodoc
abstract mixin class _$TrendingSelectionCopyWith<$Res> implements $TrendingSelectionCopyWith<$Res> {
  factory _$TrendingSelectionCopyWith(_TrendingSelection value, $Res Function(_TrendingSelection) _then) = __$TrendingSelectionCopyWithImpl;
@override @useResult
$Res call({
 List<MovieSummary> items, RequestKey requestKey, String timeWindow, int? providerPage, int? providerTotalPages, int? providerTotalResults
});


@override $RequestKeyCopyWith<$Res> get requestKey;

}
/// @nodoc
class __$TrendingSelectionCopyWithImpl<$Res>
    implements _$TrendingSelectionCopyWith<$Res> {
  __$TrendingSelectionCopyWithImpl(this._self, this._then);

  final _TrendingSelection _self;
  final $Res Function(_TrendingSelection) _then;

/// Create a copy of TrendingSelection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? requestKey = null,Object? timeWindow = null,Object? providerPage = freezed,Object? providerTotalPages = freezed,Object? providerTotalResults = freezed,}) {
  return _then(_TrendingSelection(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<MovieSummary>,requestKey: null == requestKey ? _self.requestKey : requestKey // ignore: cast_nullable_to_non_nullable
as RequestKey,timeWindow: null == timeWindow ? _self.timeWindow : timeWindow // ignore: cast_nullable_to_non_nullable
as String,providerPage: freezed == providerPage ? _self.providerPage : providerPage // ignore: cast_nullable_to_non_nullable
as int?,providerTotalPages: freezed == providerTotalPages ? _self.providerTotalPages : providerTotalPages // ignore: cast_nullable_to_non_nullable
as int?,providerTotalResults: freezed == providerTotalResults ? _self.providerTotalResults : providerTotalResults // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of TrendingSelection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestKeyCopyWith<$Res> get requestKey {
  
  return $RequestKeyCopyWith<$Res>(_self.requestKey, (value) {
    return _then(_self.copyWith(requestKey: value));
  });
}
}


/// @nodoc
mixin _$RecommendationSource {

 String get kind; int? get seedMovieId; String? get seedTitle;
/// Create a copy of RecommendationSource
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationSourceCopyWith<RecommendationSource> get copyWith => _$RecommendationSourceCopyWithImpl<RecommendationSource>(this as RecommendationSource, _$identity);

  /// Serializes this RecommendationSource to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendationSource&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.seedMovieId, seedMovieId) || other.seedMovieId == seedMovieId)&&(identical(other.seedTitle, seedTitle) || other.seedTitle == seedTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,seedMovieId,seedTitle);

@override
String toString() {
  return 'RecommendationSource(kind: $kind, seedMovieId: $seedMovieId, seedTitle: $seedTitle)';
}


}

/// @nodoc
abstract mixin class $RecommendationSourceCopyWith<$Res>  {
  factory $RecommendationSourceCopyWith(RecommendationSource value, $Res Function(RecommendationSource) _then) = _$RecommendationSourceCopyWithImpl;
@useResult
$Res call({
 String kind, int? seedMovieId, String? seedTitle
});




}
/// @nodoc
class _$RecommendationSourceCopyWithImpl<$Res>
    implements $RecommendationSourceCopyWith<$Res> {
  _$RecommendationSourceCopyWithImpl(this._self, this._then);

  final RecommendationSource _self;
  final $Res Function(RecommendationSource) _then;

/// Create a copy of RecommendationSource
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? seedMovieId = freezed,Object? seedTitle = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,seedMovieId: freezed == seedMovieId ? _self.seedMovieId : seedMovieId // ignore: cast_nullable_to_non_nullable
as int?,seedTitle: freezed == seedTitle ? _self.seedTitle : seedTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendationSource].
extension RecommendationSourcePatterns on RecommendationSource {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendationSource value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendationSource() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendationSource value)  $default,){
final _that = this;
switch (_that) {
case _RecommendationSource():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendationSource value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendationSource() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String kind,  int? seedMovieId,  String? seedTitle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendationSource() when $default != null:
return $default(_that.kind,_that.seedMovieId,_that.seedTitle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String kind,  int? seedMovieId,  String? seedTitle)  $default,) {final _that = this;
switch (_that) {
case _RecommendationSource():
return $default(_that.kind,_that.seedMovieId,_that.seedTitle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String kind,  int? seedMovieId,  String? seedTitle)?  $default,) {final _that = this;
switch (_that) {
case _RecommendationSource() when $default != null:
return $default(_that.kind,_that.seedMovieId,_that.seedTitle);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _RecommendationSource extends RecommendationSource {
  const _RecommendationSource({required this.kind, this.seedMovieId, this.seedTitle}): super._();
  factory _RecommendationSource.fromJson(Map<String, dynamic> json) => _$RecommendationSourceFromJson(json);

@override final  String kind;
@override final  int? seedMovieId;
@override final  String? seedTitle;

/// Create a copy of RecommendationSource
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationSourceCopyWith<_RecommendationSource> get copyWith => __$RecommendationSourceCopyWithImpl<_RecommendationSource>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecommendationSourceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendationSource&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.seedMovieId, seedMovieId) || other.seedMovieId == seedMovieId)&&(identical(other.seedTitle, seedTitle) || other.seedTitle == seedTitle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,seedMovieId,seedTitle);

@override
String toString() {
  return 'RecommendationSource(kind: $kind, seedMovieId: $seedMovieId, seedTitle: $seedTitle)';
}


}

/// @nodoc
abstract mixin class _$RecommendationSourceCopyWith<$Res> implements $RecommendationSourceCopyWith<$Res> {
  factory _$RecommendationSourceCopyWith(_RecommendationSource value, $Res Function(_RecommendationSource) _then) = __$RecommendationSourceCopyWithImpl;
@override @useResult
$Res call({
 String kind, int? seedMovieId, String? seedTitle
});




}
/// @nodoc
class __$RecommendationSourceCopyWithImpl<$Res>
    implements _$RecommendationSourceCopyWith<$Res> {
  __$RecommendationSourceCopyWithImpl(this._self, this._then);

  final _RecommendationSource _self;
  final $Res Function(_RecommendationSource) _then;

/// Create a copy of RecommendationSource
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? seedMovieId = freezed,Object? seedTitle = freezed,}) {
  return _then(_RecommendationSource(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as String,seedMovieId: freezed == seedMovieId ? _self.seedMovieId : seedMovieId // ignore: cast_nullable_to_non_nullable
as int?,seedTitle: freezed == seedTitle ? _self.seedTitle : seedTitle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

Outcome<T> _$OutcomeFromJson<T>(
  Map<String, dynamic> json,T Function(Object?) fromJsonT
) {
        switch (json['type']) {
                  case 'success':
          return Success<T>.fromJson(
            json,fromJsonT
          );
                case 'failure':
          return Failed<T>.fromJson(
            json,fromJsonT
          );
                case 'cancelled':
          return Cancelled<T>.fromJson(
            json,fromJsonT
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'Outcome',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$Outcome<T> {



  /// Serializes this Outcome to a JSON map.
  Map<String, dynamic> toJson(Object? Function(T) toJsonT);


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Outcome<T>);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Outcome<$T>()';
}


}

/// @nodoc
class $OutcomeCopyWith<T,$Res>  {
$OutcomeCopyWith(Outcome<T> _, $Res Function(Outcome<T>) __);
}


/// Adds pattern-matching-related methods to [Outcome].
extension OutcomePatterns<T> on Outcome<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Success<T> value)?  success,TResult Function( Failed<T> value)?  failure,TResult Function( Cancelled<T> value)?  cancelled,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failed() when failure != null:
return failure(_that);case Cancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Success<T> value)  success,required TResult Function( Failed<T> value)  failure,required TResult Function( Cancelled<T> value)  cancelled,}){
final _that = this;
switch (_that) {
case Success():
return success(_that);case Failed():
return failure(_that);case Cancelled():
return cancelled(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Success<T> value)?  success,TResult? Function( Failed<T> value)?  failure,TResult? Function( Cancelled<T> value)?  cancelled,}){
final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that);case Failed() when failure != null:
return failure(_that);case Cancelled() when cancelled != null:
return cancelled(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T data)?  success,TResult Function( AppFailure error)?  failure,TResult Function()?  cancelled,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.data);case Failed() when failure != null:
return failure(_that.error);case Cancelled() when cancelled != null:
return cancelled();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T data)  success,required TResult Function( AppFailure error)  failure,required TResult Function()  cancelled,}) {final _that = this;
switch (_that) {
case Success():
return success(_that.data);case Failed():
return failure(_that.error);case Cancelled():
return cancelled();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T data)?  success,TResult? Function( AppFailure error)?  failure,TResult? Function()?  cancelled,}) {final _that = this;
switch (_that) {
case Success() when success != null:
return success(_that.data);case Failed() when failure != null:
return failure(_that.error);case Cancelled() when cancelled != null:
return cancelled();case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
class Success<T> extends Outcome<T> {
  const Success(this.data, {final  String? $type}): $type = $type ?? 'success',super._();
  factory Success.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$SuccessFromJson(json,fromJsonT);

 final  T data;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of Outcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<T, Success<T>> get copyWith => _$SuccessCopyWithImpl<T, Success<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$SuccessToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success<T>&&const DeepCollectionEquality().equals(other.data, data));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'Outcome<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<T,$Res> implements $OutcomeCopyWith<T, $Res> {
  factory $SuccessCopyWith(Success<T> value, $Res Function(Success<T>) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$SuccessCopyWithImpl<T,$Res>
    implements $SuccessCopyWith<T, $Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success<T> _self;
  final $Res Function(Success<T>) _then;

/// Create a copy of Outcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(Success<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc

@JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
class Failed<T> extends Outcome<T> {
  const Failed(this.error, {final  String? $type}): $type = $type ?? 'failure',super._();
  factory Failed.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$FailedFromJson(json,fromJsonT);

 final  AppFailure error;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of Outcome
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailedCopyWith<T, Failed<T>> get copyWith => _$FailedCopyWithImpl<T, Failed<T>>(this, _$identity);

@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$FailedToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failed<T>&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'Outcome<$T>.failure(error: $error)';
}


}

/// @nodoc
abstract mixin class $FailedCopyWith<T,$Res> implements $OutcomeCopyWith<T, $Res> {
  factory $FailedCopyWith(Failed<T> value, $Res Function(Failed<T>) _then) = _$FailedCopyWithImpl;
@useResult
$Res call({
 AppFailure error
});


$AppFailureCopyWith<$Res> get error;

}
/// @nodoc
class _$FailedCopyWithImpl<T,$Res>
    implements $FailedCopyWith<T, $Res> {
  _$FailedCopyWithImpl(this._self, this._then);

  final Failed<T> _self;
  final $Res Function(Failed<T>) _then;

/// Create a copy of Outcome
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(Failed<T>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as AppFailure,
  ));
}

/// Create a copy of Outcome
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppFailureCopyWith<$Res> get error {
  
  return $AppFailureCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

/// @nodoc

@JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
class Cancelled<T> extends Outcome<T> {
  const Cancelled({final  String? $type}): $type = $type ?? 'cancelled',super._();
  factory Cancelled.fromJson(Map<String, dynamic> json,T Function(Object?) fromJsonT) => _$CancelledFromJson(json,fromJsonT);



@JsonKey(name: 'type')
final String $type;



@override
Map<String, dynamic> toJson(Object? Function(T) toJsonT) {
  return _$CancelledToJson<T>(this, toJsonT);
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cancelled<T>);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Outcome<$T>.cancelled()';
}


}




// dart format on

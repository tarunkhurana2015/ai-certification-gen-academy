// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PersonSummary {

 int get id; String get name; String? get profilePath; String? get knownForDepartment;
/// Create a copy of PersonSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonSummaryCopyWith<PersonSummary> get copyWith => _$PersonSummaryCopyWithImpl<PersonSummary>(this as PersonSummary, _$identity);

  /// Serializes this PersonSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath)&&(identical(other.knownForDepartment, knownForDepartment) || other.knownForDepartment == knownForDepartment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profilePath,knownForDepartment);

@override
String toString() {
  return 'PersonSummary(id: $id, name: $name, profilePath: $profilePath, knownForDepartment: $knownForDepartment)';
}


}

/// @nodoc
abstract mixin class $PersonSummaryCopyWith<$Res>  {
  factory $PersonSummaryCopyWith(PersonSummary value, $Res Function(PersonSummary) _then) = _$PersonSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? profilePath, String? knownForDepartment
});




}
/// @nodoc
class _$PersonSummaryCopyWithImpl<$Res>
    implements $PersonSummaryCopyWith<$Res> {
  _$PersonSummaryCopyWithImpl(this._self, this._then);

  final PersonSummary _self;
  final $Res Function(PersonSummary) _then;

/// Create a copy of PersonSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? profilePath = freezed,Object? knownForDepartment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,knownForDepartment: freezed == knownForDepartment ? _self.knownForDepartment : knownForDepartment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonSummary].
extension PersonSummaryPatterns on PersonSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonSummary value)  $default,){
final _that = this;
switch (_that) {
case _PersonSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PersonSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? profilePath,  String? knownForDepartment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonSummary() when $default != null:
return $default(_that.id,_that.name,_that.profilePath,_that.knownForDepartment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? profilePath,  String? knownForDepartment)  $default,) {final _that = this;
switch (_that) {
case _PersonSummary():
return $default(_that.id,_that.name,_that.profilePath,_that.knownForDepartment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? profilePath,  String? knownForDepartment)?  $default,) {final _that = this;
switch (_that) {
case _PersonSummary() when $default != null:
return $default(_that.id,_that.name,_that.profilePath,_that.knownForDepartment);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PersonSummary extends PersonSummary {
  const _PersonSummary({required this.id, required this.name, this.profilePath, this.knownForDepartment}): super._();
  factory _PersonSummary.fromJson(Map<String, dynamic> json) => _$PersonSummaryFromJson(json);

@override final  int id;
@override final  String name;
@override final  String? profilePath;
@override final  String? knownForDepartment;

/// Create a copy of PersonSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonSummaryCopyWith<_PersonSummary> get copyWith => __$PersonSummaryCopyWithImpl<_PersonSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath)&&(identical(other.knownForDepartment, knownForDepartment) || other.knownForDepartment == knownForDepartment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,profilePath,knownForDepartment);

@override
String toString() {
  return 'PersonSummary(id: $id, name: $name, profilePath: $profilePath, knownForDepartment: $knownForDepartment)';
}


}

/// @nodoc
abstract mixin class _$PersonSummaryCopyWith<$Res> implements $PersonSummaryCopyWith<$Res> {
  factory _$PersonSummaryCopyWith(_PersonSummary value, $Res Function(_PersonSummary) _then) = __$PersonSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? profilePath, String? knownForDepartment
});




}
/// @nodoc
class __$PersonSummaryCopyWithImpl<$Res>
    implements _$PersonSummaryCopyWith<$Res> {
  __$PersonSummaryCopyWithImpl(this._self, this._then);

  final _PersonSummary _self;
  final $Res Function(_PersonSummary) _then;

/// Create a copy of PersonSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? profilePath = freezed,Object? knownForDepartment = freezed,}) {
  return _then(_PersonSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,knownForDepartment: freezed == knownForDepartment ? _self.knownForDepartment : knownForDepartment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PersonDetails {

 PersonSummary get person; List<String> get alsoKnownAs; String? get biography; CalendarDate? get birthday; CalendarDate? get deathday; String? get placeOfBirth;
/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonDetailsCopyWith<PersonDetails> get copyWith => _$PersonDetailsCopyWithImpl<PersonDetails>(this as PersonDetails, _$identity);

  /// Serializes this PersonDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonDetails&&(identical(other.person, person) || other.person == person)&&const DeepCollectionEquality().equals(other.alsoKnownAs, alsoKnownAs)&&(identical(other.biography, biography) || other.biography == biography)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.deathday, deathday) || other.deathday == deathday)&&(identical(other.placeOfBirth, placeOfBirth) || other.placeOfBirth == placeOfBirth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,const DeepCollectionEquality().hash(alsoKnownAs),biography,birthday,deathday,placeOfBirth);

@override
String toString() {
  return 'PersonDetails(person: $person, alsoKnownAs: $alsoKnownAs, biography: $biography, birthday: $birthday, deathday: $deathday, placeOfBirth: $placeOfBirth)';
}


}

/// @nodoc
abstract mixin class $PersonDetailsCopyWith<$Res>  {
  factory $PersonDetailsCopyWith(PersonDetails value, $Res Function(PersonDetails) _then) = _$PersonDetailsCopyWithImpl;
@useResult
$Res call({
 PersonSummary person, List<String> alsoKnownAs, String? biography, CalendarDate? birthday, CalendarDate? deathday, String? placeOfBirth
});


$PersonSummaryCopyWith<$Res> get person;$CalendarDateCopyWith<$Res>? get birthday;$CalendarDateCopyWith<$Res>? get deathday;

}
/// @nodoc
class _$PersonDetailsCopyWithImpl<$Res>
    implements $PersonDetailsCopyWith<$Res> {
  _$PersonDetailsCopyWithImpl(this._self, this._then);

  final PersonDetails _self;
  final $Res Function(PersonDetails) _then;

/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? alsoKnownAs = null,Object? biography = freezed,Object? birthday = freezed,Object? deathday = freezed,Object? placeOfBirth = freezed,}) {
  return _then(_self.copyWith(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as PersonSummary,alsoKnownAs: null == alsoKnownAs ? _self.alsoKnownAs : alsoKnownAs // ignore: cast_nullable_to_non_nullable
as List<String>,biography: freezed == biography ? _self.biography : biography // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as CalendarDate?,deathday: freezed == deathday ? _self.deathday : deathday // ignore: cast_nullable_to_non_nullable
as CalendarDate?,placeOfBirth: freezed == placeOfBirth ? _self.placeOfBirth : placeOfBirth // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonSummaryCopyWith<$Res> get person {
  
  return $PersonSummaryCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res>? get birthday {
    if (_self.birthday == null) {
    return null;
  }

  return $CalendarDateCopyWith<$Res>(_self.birthday!, (value) {
    return _then(_self.copyWith(birthday: value));
  });
}/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res>? get deathday {
    if (_self.deathday == null) {
    return null;
  }

  return $CalendarDateCopyWith<$Res>(_self.deathday!, (value) {
    return _then(_self.copyWith(deathday: value));
  });
}
}


/// Adds pattern-matching-related methods to [PersonDetails].
extension PersonDetailsPatterns on PersonDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonDetails value)  $default,){
final _that = this;
switch (_that) {
case _PersonDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonDetails value)?  $default,){
final _that = this;
switch (_that) {
case _PersonDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PersonSummary person,  List<String> alsoKnownAs,  String? biography,  CalendarDate? birthday,  CalendarDate? deathday,  String? placeOfBirth)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonDetails() when $default != null:
return $default(_that.person,_that.alsoKnownAs,_that.biography,_that.birthday,_that.deathday,_that.placeOfBirth);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PersonSummary person,  List<String> alsoKnownAs,  String? biography,  CalendarDate? birthday,  CalendarDate? deathday,  String? placeOfBirth)  $default,) {final _that = this;
switch (_that) {
case _PersonDetails():
return $default(_that.person,_that.alsoKnownAs,_that.biography,_that.birthday,_that.deathday,_that.placeOfBirth);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PersonSummary person,  List<String> alsoKnownAs,  String? biography,  CalendarDate? birthday,  CalendarDate? deathday,  String? placeOfBirth)?  $default,) {final _that = this;
switch (_that) {
case _PersonDetails() when $default != null:
return $default(_that.person,_that.alsoKnownAs,_that.biography,_that.birthday,_that.deathday,_that.placeOfBirth);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PersonDetails extends PersonDetails {
  const _PersonDetails({required this.person, final  List<String> alsoKnownAs = const [], this.biography, this.birthday, this.deathday, this.placeOfBirth}): _alsoKnownAs = alsoKnownAs,super._();
  factory _PersonDetails.fromJson(Map<String, dynamic> json) => _$PersonDetailsFromJson(json);

@override final  PersonSummary person;
 final  List<String> _alsoKnownAs;
@override@JsonKey() List<String> get alsoKnownAs {
  if (_alsoKnownAs is EqualUnmodifiableListView) return _alsoKnownAs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_alsoKnownAs);
}

@override final  String? biography;
@override final  CalendarDate? birthday;
@override final  CalendarDate? deathday;
@override final  String? placeOfBirth;

/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonDetailsCopyWith<_PersonDetails> get copyWith => __$PersonDetailsCopyWithImpl<_PersonDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonDetails&&(identical(other.person, person) || other.person == person)&&const DeepCollectionEquality().equals(other._alsoKnownAs, _alsoKnownAs)&&(identical(other.biography, biography) || other.biography == biography)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.deathday, deathday) || other.deathday == deathday)&&(identical(other.placeOfBirth, placeOfBirth) || other.placeOfBirth == placeOfBirth));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,const DeepCollectionEquality().hash(_alsoKnownAs),biography,birthday,deathday,placeOfBirth);

@override
String toString() {
  return 'PersonDetails(person: $person, alsoKnownAs: $alsoKnownAs, biography: $biography, birthday: $birthday, deathday: $deathday, placeOfBirth: $placeOfBirth)';
}


}

/// @nodoc
abstract mixin class _$PersonDetailsCopyWith<$Res> implements $PersonDetailsCopyWith<$Res> {
  factory _$PersonDetailsCopyWith(_PersonDetails value, $Res Function(_PersonDetails) _then) = __$PersonDetailsCopyWithImpl;
@override @useResult
$Res call({
 PersonSummary person, List<String> alsoKnownAs, String? biography, CalendarDate? birthday, CalendarDate? deathday, String? placeOfBirth
});


@override $PersonSummaryCopyWith<$Res> get person;@override $CalendarDateCopyWith<$Res>? get birthday;@override $CalendarDateCopyWith<$Res>? get deathday;

}
/// @nodoc
class __$PersonDetailsCopyWithImpl<$Res>
    implements _$PersonDetailsCopyWith<$Res> {
  __$PersonDetailsCopyWithImpl(this._self, this._then);

  final _PersonDetails _self;
  final $Res Function(_PersonDetails) _then;

/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? alsoKnownAs = null,Object? biography = freezed,Object? birthday = freezed,Object? deathday = freezed,Object? placeOfBirth = freezed,}) {
  return _then(_PersonDetails(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as PersonSummary,alsoKnownAs: null == alsoKnownAs ? _self._alsoKnownAs : alsoKnownAs // ignore: cast_nullable_to_non_nullable
as List<String>,biography: freezed == biography ? _self.biography : biography // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as CalendarDate?,deathday: freezed == deathday ? _self.deathday : deathday // ignore: cast_nullable_to_non_nullable
as CalendarDate?,placeOfBirth: freezed == placeOfBirth ? _self.placeOfBirth : placeOfBirth // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonSummaryCopyWith<$Res> get person {
  
  return $PersonSummaryCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res>? get birthday {
    if (_self.birthday == null) {
    return null;
  }

  return $CalendarDateCopyWith<$Res>(_self.birthday!, (value) {
    return _then(_self.copyWith(birthday: value));
  });
}/// Create a copy of PersonDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalendarDateCopyWith<$Res>? get deathday {
    if (_self.deathday == null) {
    return null;
  }

  return $CalendarDateCopyWith<$Res>(_self.deathday!, (value) {
    return _then(_self.copyWith(deathday: value));
  });
}
}


/// @nodoc
mixin _$CastCredit {

 PersonSummary get person; String? get creditId; String? get character; int? get order;
/// Create a copy of CastCredit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CastCreditCopyWith<CastCredit> get copyWith => _$CastCreditCopyWithImpl<CastCredit>(this as CastCredit, _$identity);

  /// Serializes this CastCredit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CastCredit&&(identical(other.person, person) || other.person == person)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,creditId,character,order);

@override
String toString() {
  return 'CastCredit(person: $person, creditId: $creditId, character: $character, order: $order)';
}


}

/// @nodoc
abstract mixin class $CastCreditCopyWith<$Res>  {
  factory $CastCreditCopyWith(CastCredit value, $Res Function(CastCredit) _then) = _$CastCreditCopyWithImpl;
@useResult
$Res call({
 PersonSummary person, String? creditId, String? character, int? order
});


$PersonSummaryCopyWith<$Res> get person;

}
/// @nodoc
class _$CastCreditCopyWithImpl<$Res>
    implements $CastCreditCopyWith<$Res> {
  _$CastCreditCopyWithImpl(this._self, this._then);

  final CastCredit _self;
  final $Res Function(CastCredit) _then;

/// Create a copy of CastCredit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? creditId = freezed,Object? character = freezed,Object? order = freezed,}) {
  return _then(_self.copyWith(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as PersonSummary,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of CastCredit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonSummaryCopyWith<$Res> get person {
  
  return $PersonSummaryCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}
}


/// Adds pattern-matching-related methods to [CastCredit].
extension CastCreditPatterns on CastCredit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CastCredit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CastCredit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CastCredit value)  $default,){
final _that = this;
switch (_that) {
case _CastCredit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CastCredit value)?  $default,){
final _that = this;
switch (_that) {
case _CastCredit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PersonSummary person,  String? creditId,  String? character,  int? order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CastCredit() when $default != null:
return $default(_that.person,_that.creditId,_that.character,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PersonSummary person,  String? creditId,  String? character,  int? order)  $default,) {final _that = this;
switch (_that) {
case _CastCredit():
return $default(_that.person,_that.creditId,_that.character,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PersonSummary person,  String? creditId,  String? character,  int? order)?  $default,) {final _that = this;
switch (_that) {
case _CastCredit() when $default != null:
return $default(_that.person,_that.creditId,_that.character,_that.order);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CastCredit extends CastCredit {
  const _CastCredit({required this.person, this.creditId, this.character, this.order}): super._();
  factory _CastCredit.fromJson(Map<String, dynamic> json) => _$CastCreditFromJson(json);

@override final  PersonSummary person;
@override final  String? creditId;
@override final  String? character;
@override final  int? order;

/// Create a copy of CastCredit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CastCreditCopyWith<_CastCredit> get copyWith => __$CastCreditCopyWithImpl<_CastCredit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CastCreditToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CastCredit&&(identical(other.person, person) || other.person == person)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,creditId,character,order);

@override
String toString() {
  return 'CastCredit(person: $person, creditId: $creditId, character: $character, order: $order)';
}


}

/// @nodoc
abstract mixin class _$CastCreditCopyWith<$Res> implements $CastCreditCopyWith<$Res> {
  factory _$CastCreditCopyWith(_CastCredit value, $Res Function(_CastCredit) _then) = __$CastCreditCopyWithImpl;
@override @useResult
$Res call({
 PersonSummary person, String? creditId, String? character, int? order
});


@override $PersonSummaryCopyWith<$Res> get person;

}
/// @nodoc
class __$CastCreditCopyWithImpl<$Res>
    implements _$CastCreditCopyWith<$Res> {
  __$CastCreditCopyWithImpl(this._self, this._then);

  final _CastCredit _self;
  final $Res Function(_CastCredit) _then;

/// Create a copy of CastCredit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? creditId = freezed,Object? character = freezed,Object? order = freezed,}) {
  return _then(_CastCredit(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as PersonSummary,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of CastCredit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonSummaryCopyWith<$Res> get person {
  
  return $PersonSummaryCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}
}


/// @nodoc
mixin _$CrewCredit {

 PersonSummary get person; String? get creditId; String? get department; String? get job;
/// Create a copy of CrewCredit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CrewCreditCopyWith<CrewCredit> get copyWith => _$CrewCreditCopyWithImpl<CrewCredit>(this as CrewCredit, _$identity);

  /// Serializes this CrewCredit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CrewCredit&&(identical(other.person, person) || other.person == person)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,creditId,department,job);

@override
String toString() {
  return 'CrewCredit(person: $person, creditId: $creditId, department: $department, job: $job)';
}


}

/// @nodoc
abstract mixin class $CrewCreditCopyWith<$Res>  {
  factory $CrewCreditCopyWith(CrewCredit value, $Res Function(CrewCredit) _then) = _$CrewCreditCopyWithImpl;
@useResult
$Res call({
 PersonSummary person, String? creditId, String? department, String? job
});


$PersonSummaryCopyWith<$Res> get person;

}
/// @nodoc
class _$CrewCreditCopyWithImpl<$Res>
    implements $CrewCreditCopyWith<$Res> {
  _$CrewCreditCopyWithImpl(this._self, this._then);

  final CrewCredit _self;
  final $Res Function(CrewCredit) _then;

/// Create a copy of CrewCredit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? person = null,Object? creditId = freezed,Object? department = freezed,Object? job = freezed,}) {
  return _then(_self.copyWith(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as PersonSummary,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of CrewCredit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonSummaryCopyWith<$Res> get person {
  
  return $PersonSummaryCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}
}


/// Adds pattern-matching-related methods to [CrewCredit].
extension CrewCreditPatterns on CrewCredit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CrewCredit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CrewCredit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CrewCredit value)  $default,){
final _that = this;
switch (_that) {
case _CrewCredit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CrewCredit value)?  $default,){
final _that = this;
switch (_that) {
case _CrewCredit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PersonSummary person,  String? creditId,  String? department,  String? job)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CrewCredit() when $default != null:
return $default(_that.person,_that.creditId,_that.department,_that.job);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PersonSummary person,  String? creditId,  String? department,  String? job)  $default,) {final _that = this;
switch (_that) {
case _CrewCredit():
return $default(_that.person,_that.creditId,_that.department,_that.job);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PersonSummary person,  String? creditId,  String? department,  String? job)?  $default,) {final _that = this;
switch (_that) {
case _CrewCredit() when $default != null:
return $default(_that.person,_that.creditId,_that.department,_that.job);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CrewCredit extends CrewCredit {
  const _CrewCredit({required this.person, this.creditId, this.department, this.job}): super._();
  factory _CrewCredit.fromJson(Map<String, dynamic> json) => _$CrewCreditFromJson(json);

@override final  PersonSummary person;
@override final  String? creditId;
@override final  String? department;
@override final  String? job;

/// Create a copy of CrewCredit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CrewCreditCopyWith<_CrewCredit> get copyWith => __$CrewCreditCopyWithImpl<_CrewCredit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CrewCreditToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CrewCredit&&(identical(other.person, person) || other.person == person)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,person,creditId,department,job);

@override
String toString() {
  return 'CrewCredit(person: $person, creditId: $creditId, department: $department, job: $job)';
}


}

/// @nodoc
abstract mixin class _$CrewCreditCopyWith<$Res> implements $CrewCreditCopyWith<$Res> {
  factory _$CrewCreditCopyWith(_CrewCredit value, $Res Function(_CrewCredit) _then) = __$CrewCreditCopyWithImpl;
@override @useResult
$Res call({
 PersonSummary person, String? creditId, String? department, String? job
});


@override $PersonSummaryCopyWith<$Res> get person;

}
/// @nodoc
class __$CrewCreditCopyWithImpl<$Res>
    implements _$CrewCreditCopyWith<$Res> {
  __$CrewCreditCopyWithImpl(this._self, this._then);

  final _CrewCredit _self;
  final $Res Function(_CrewCredit) _then;

/// Create a copy of CrewCredit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? person = null,Object? creditId = freezed,Object? department = freezed,Object? job = freezed,}) {
  return _then(_CrewCredit(
person: null == person ? _self.person : person // ignore: cast_nullable_to_non_nullable
as PersonSummary,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of CrewCredit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PersonSummaryCopyWith<$Res> get person {
  
  return $PersonSummaryCopyWith<$Res>(_self.person, (value) {
    return _then(_self.copyWith(person: value));
  });
}
}


/// @nodoc
mixin _$MovieCredits {

 int get movieId; List<CastCredit> get cast; List<CrewCredit> get crew;
/// Create a copy of MovieCredits
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieCreditsCopyWith<MovieCredits> get copyWith => _$MovieCreditsCopyWithImpl<MovieCredits>(this as MovieCredits, _$identity);

  /// Serializes this MovieCredits to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieCredits&&(identical(other.movieId, movieId) || other.movieId == movieId)&&const DeepCollectionEquality().equals(other.cast, cast)&&const DeepCollectionEquality().equals(other.crew, crew));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movieId,const DeepCollectionEquality().hash(cast),const DeepCollectionEquality().hash(crew));

@override
String toString() {
  return 'MovieCredits(movieId: $movieId, cast: $cast, crew: $crew)';
}


}

/// @nodoc
abstract mixin class $MovieCreditsCopyWith<$Res>  {
  factory $MovieCreditsCopyWith(MovieCredits value, $Res Function(MovieCredits) _then) = _$MovieCreditsCopyWithImpl;
@useResult
$Res call({
 int movieId, List<CastCredit> cast, List<CrewCredit> crew
});




}
/// @nodoc
class _$MovieCreditsCopyWithImpl<$Res>
    implements $MovieCreditsCopyWith<$Res> {
  _$MovieCreditsCopyWithImpl(this._self, this._then);

  final MovieCredits _self;
  final $Res Function(MovieCredits) _then;

/// Create a copy of MovieCredits
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movieId = null,Object? cast = null,Object? crew = null,}) {
  return _then(_self.copyWith(
movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,cast: null == cast ? _self.cast : cast // ignore: cast_nullable_to_non_nullable
as List<CastCredit>,crew: null == crew ? _self.crew : crew // ignore: cast_nullable_to_non_nullable
as List<CrewCredit>,
  ));
}

}


/// Adds pattern-matching-related methods to [MovieCredits].
extension MovieCreditsPatterns on MovieCredits {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieCredits value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieCredits() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieCredits value)  $default,){
final _that = this;
switch (_that) {
case _MovieCredits():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieCredits value)?  $default,){
final _that = this;
switch (_that) {
case _MovieCredits() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int movieId,  List<CastCredit> cast,  List<CrewCredit> crew)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieCredits() when $default != null:
return $default(_that.movieId,_that.cast,_that.crew);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int movieId,  List<CastCredit> cast,  List<CrewCredit> crew)  $default,) {final _that = this;
switch (_that) {
case _MovieCredits():
return $default(_that.movieId,_that.cast,_that.crew);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int movieId,  List<CastCredit> cast,  List<CrewCredit> crew)?  $default,) {final _that = this;
switch (_that) {
case _MovieCredits() when $default != null:
return $default(_that.movieId,_that.cast,_that.crew);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MovieCredits extends MovieCredits {
  const _MovieCredits({required this.movieId, final  List<CastCredit> cast = const [], final  List<CrewCredit> crew = const []}): _cast = cast,_crew = crew,super._();
  factory _MovieCredits.fromJson(Map<String, dynamic> json) => _$MovieCreditsFromJson(json);

@override final  int movieId;
 final  List<CastCredit> _cast;
@override@JsonKey() List<CastCredit> get cast {
  if (_cast is EqualUnmodifiableListView) return _cast;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cast);
}

 final  List<CrewCredit> _crew;
@override@JsonKey() List<CrewCredit> get crew {
  if (_crew is EqualUnmodifiableListView) return _crew;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_crew);
}


/// Create a copy of MovieCredits
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieCreditsCopyWith<_MovieCredits> get copyWith => __$MovieCreditsCopyWithImpl<_MovieCredits>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieCreditsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieCredits&&(identical(other.movieId, movieId) || other.movieId == movieId)&&const DeepCollectionEquality().equals(other._cast, _cast)&&const DeepCollectionEquality().equals(other._crew, _crew));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movieId,const DeepCollectionEquality().hash(_cast),const DeepCollectionEquality().hash(_crew));

@override
String toString() {
  return 'MovieCredits(movieId: $movieId, cast: $cast, crew: $crew)';
}


}

/// @nodoc
abstract mixin class _$MovieCreditsCopyWith<$Res> implements $MovieCreditsCopyWith<$Res> {
  factory _$MovieCreditsCopyWith(_MovieCredits value, $Res Function(_MovieCredits) _then) = __$MovieCreditsCopyWithImpl;
@override @useResult
$Res call({
 int movieId, List<CastCredit> cast, List<CrewCredit> crew
});




}
/// @nodoc
class __$MovieCreditsCopyWithImpl<$Res>
    implements _$MovieCreditsCopyWith<$Res> {
  __$MovieCreditsCopyWithImpl(this._self, this._then);

  final _MovieCredits _self;
  final $Res Function(_MovieCredits) _then;

/// Create a copy of MovieCredits
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movieId = null,Object? cast = null,Object? crew = null,}) {
  return _then(_MovieCredits(
movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,cast: null == cast ? _self._cast : cast // ignore: cast_nullable_to_non_nullable
as List<CastCredit>,crew: null == crew ? _self._crew : crew // ignore: cast_nullable_to_non_nullable
as List<CrewCredit>,
  ));
}


}


/// @nodoc
mixin _$CreditRole {

 CreditKind get kind; String? get creditId; String? get character; String? get department; String? get job;
/// Create a copy of CreditRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreditRoleCopyWith<CreditRole> get copyWith => _$CreditRoleCopyWithImpl<CreditRole>(this as CreditRole, _$identity);

  /// Serializes this CreditRole to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreditRole&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,creditId,character,department,job);

@override
String toString() {
  return 'CreditRole(kind: $kind, creditId: $creditId, character: $character, department: $department, job: $job)';
}


}

/// @nodoc
abstract mixin class $CreditRoleCopyWith<$Res>  {
  factory $CreditRoleCopyWith(CreditRole value, $Res Function(CreditRole) _then) = _$CreditRoleCopyWithImpl;
@useResult
$Res call({
 CreditKind kind, String? creditId, String? character, String? department, String? job
});




}
/// @nodoc
class _$CreditRoleCopyWithImpl<$Res>
    implements $CreditRoleCopyWith<$Res> {
  _$CreditRoleCopyWithImpl(this._self, this._then);

  final CreditRole _self;
  final $Res Function(CreditRole) _then;

/// Create a copy of CreditRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kind = null,Object? creditId = freezed,Object? character = freezed,Object? department = freezed,Object? job = freezed,}) {
  return _then(_self.copyWith(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CreditKind,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreditRole].
extension CreditRolePatterns on CreditRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreditRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreditRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreditRole value)  $default,){
final _that = this;
switch (_that) {
case _CreditRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreditRole value)?  $default,){
final _that = this;
switch (_that) {
case _CreditRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CreditKind kind,  String? creditId,  String? character,  String? department,  String? job)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreditRole() when $default != null:
return $default(_that.kind,_that.creditId,_that.character,_that.department,_that.job);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CreditKind kind,  String? creditId,  String? character,  String? department,  String? job)  $default,) {final _that = this;
switch (_that) {
case _CreditRole():
return $default(_that.kind,_that.creditId,_that.character,_that.department,_that.job);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CreditKind kind,  String? creditId,  String? character,  String? department,  String? job)?  $default,) {final _that = this;
switch (_that) {
case _CreditRole() when $default != null:
return $default(_that.kind,_that.creditId,_that.character,_that.department,_that.job);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CreditRole extends CreditRole {
  const _CreditRole({required this.kind, this.creditId, this.character, this.department, this.job}): super._();
  factory _CreditRole.fromJson(Map<String, dynamic> json) => _$CreditRoleFromJson(json);

@override final  CreditKind kind;
@override final  String? creditId;
@override final  String? character;
@override final  String? department;
@override final  String? job;

/// Create a copy of CreditRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreditRoleCopyWith<_CreditRole> get copyWith => __$CreditRoleCopyWithImpl<_CreditRole>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreditRoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreditRole&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.creditId, creditId) || other.creditId == creditId)&&(identical(other.character, character) || other.character == character)&&(identical(other.department, department) || other.department == department)&&(identical(other.job, job) || other.job == job));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,kind,creditId,character,department,job);

@override
String toString() {
  return 'CreditRole(kind: $kind, creditId: $creditId, character: $character, department: $department, job: $job)';
}


}

/// @nodoc
abstract mixin class _$CreditRoleCopyWith<$Res> implements $CreditRoleCopyWith<$Res> {
  factory _$CreditRoleCopyWith(_CreditRole value, $Res Function(_CreditRole) _then) = __$CreditRoleCopyWithImpl;
@override @useResult
$Res call({
 CreditKind kind, String? creditId, String? character, String? department, String? job
});




}
/// @nodoc
class __$CreditRoleCopyWithImpl<$Res>
    implements _$CreditRoleCopyWith<$Res> {
  __$CreditRoleCopyWithImpl(this._self, this._then);

  final _CreditRole _self;
  final $Res Function(_CreditRole) _then;

/// Create a copy of CreditRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kind = null,Object? creditId = freezed,Object? character = freezed,Object? department = freezed,Object? job = freezed,}) {
  return _then(_CreditRole(
kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as CreditKind,creditId: freezed == creditId ? _self.creditId : creditId // ignore: cast_nullable_to_non_nullable
as String?,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,job: freezed == job ? _self.job : job // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FilmographyEntry {

 MovieSummary get movie; List<CreditRole> get roles;
/// Create a copy of FilmographyEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilmographyEntryCopyWith<FilmographyEntry> get copyWith => _$FilmographyEntryCopyWithImpl<FilmographyEntry>(this as FilmographyEntry, _$identity);

  /// Serializes this FilmographyEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilmographyEntry&&(identical(other.movie, movie) || other.movie == movie)&&const DeepCollectionEquality().equals(other.roles, roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,const DeepCollectionEquality().hash(roles));

@override
String toString() {
  return 'FilmographyEntry(movie: $movie, roles: $roles)';
}


}

/// @nodoc
abstract mixin class $FilmographyEntryCopyWith<$Res>  {
  factory $FilmographyEntryCopyWith(FilmographyEntry value, $Res Function(FilmographyEntry) _then) = _$FilmographyEntryCopyWithImpl;
@useResult
$Res call({
 MovieSummary movie, List<CreditRole> roles
});


$MovieSummaryCopyWith<$Res> get movie;

}
/// @nodoc
class _$FilmographyEntryCopyWithImpl<$Res>
    implements $FilmographyEntryCopyWith<$Res> {
  _$FilmographyEntryCopyWithImpl(this._self, this._then);

  final FilmographyEntry _self;
  final $Res Function(FilmographyEntry) _then;

/// Create a copy of FilmographyEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? movie = null,Object? roles = null,}) {
  return _then(_self.copyWith(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as MovieSummary,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<CreditRole>,
  ));
}
/// Create a copy of FilmographyEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieSummaryCopyWith<$Res> get movie {
  
  return $MovieSummaryCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}


/// Adds pattern-matching-related methods to [FilmographyEntry].
extension FilmographyEntryPatterns on FilmographyEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilmographyEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilmographyEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilmographyEntry value)  $default,){
final _that = this;
switch (_that) {
case _FilmographyEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilmographyEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FilmographyEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MovieSummary movie,  List<CreditRole> roles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilmographyEntry() when $default != null:
return $default(_that.movie,_that.roles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MovieSummary movie,  List<CreditRole> roles)  $default,) {final _that = this;
switch (_that) {
case _FilmographyEntry():
return $default(_that.movie,_that.roles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MovieSummary movie,  List<CreditRole> roles)?  $default,) {final _that = this;
switch (_that) {
case _FilmographyEntry() when $default != null:
return $default(_that.movie,_that.roles);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _FilmographyEntry extends FilmographyEntry {
  const _FilmographyEntry({required this.movie, final  List<CreditRole> roles = const []}): _roles = roles,super._();
  factory _FilmographyEntry.fromJson(Map<String, dynamic> json) => _$FilmographyEntryFromJson(json);

@override final  MovieSummary movie;
 final  List<CreditRole> _roles;
@override@JsonKey() List<CreditRole> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}


/// Create a copy of FilmographyEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilmographyEntryCopyWith<_FilmographyEntry> get copyWith => __$FilmographyEntryCopyWithImpl<_FilmographyEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FilmographyEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilmographyEntry&&(identical(other.movie, movie) || other.movie == movie)&&const DeepCollectionEquality().equals(other._roles, _roles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,movie,const DeepCollectionEquality().hash(_roles));

@override
String toString() {
  return 'FilmographyEntry(movie: $movie, roles: $roles)';
}


}

/// @nodoc
abstract mixin class _$FilmographyEntryCopyWith<$Res> implements $FilmographyEntryCopyWith<$Res> {
  factory _$FilmographyEntryCopyWith(_FilmographyEntry value, $Res Function(_FilmographyEntry) _then) = __$FilmographyEntryCopyWithImpl;
@override @useResult
$Res call({
 MovieSummary movie, List<CreditRole> roles
});


@override $MovieSummaryCopyWith<$Res> get movie;

}
/// @nodoc
class __$FilmographyEntryCopyWithImpl<$Res>
    implements _$FilmographyEntryCopyWith<$Res> {
  __$FilmographyEntryCopyWithImpl(this._self, this._then);

  final _FilmographyEntry _self;
  final $Res Function(_FilmographyEntry) _then;

/// Create a copy of FilmographyEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? movie = null,Object? roles = null,}) {
  return _then(_FilmographyEntry(
movie: null == movie ? _self.movie : movie // ignore: cast_nullable_to_non_nullable
as MovieSummary,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<CreditRole>,
  ));
}

/// Create a copy of FilmographyEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovieSummaryCopyWith<$Res> get movie {
  
  return $MovieSummaryCopyWith<$Res>(_self.movie, (value) {
    return _then(_self.copyWith(movie: value));
  });
}
}


/// @nodoc
mixin _$PersonFilmography {

 int get personId; List<FilmographyEntry> get entries;
/// Create a copy of PersonFilmography
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PersonFilmographyCopyWith<PersonFilmography> get copyWith => _$PersonFilmographyCopyWithImpl<PersonFilmography>(this as PersonFilmography, _$identity);

  /// Serializes this PersonFilmography to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PersonFilmography&&(identical(other.personId, personId) || other.personId == personId)&&const DeepCollectionEquality().equals(other.entries, entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'PersonFilmography(personId: $personId, entries: $entries)';
}


}

/// @nodoc
abstract mixin class $PersonFilmographyCopyWith<$Res>  {
  factory $PersonFilmographyCopyWith(PersonFilmography value, $Res Function(PersonFilmography) _then) = _$PersonFilmographyCopyWithImpl;
@useResult
$Res call({
 int personId, List<FilmographyEntry> entries
});




}
/// @nodoc
class _$PersonFilmographyCopyWithImpl<$Res>
    implements $PersonFilmographyCopyWith<$Res> {
  _$PersonFilmographyCopyWithImpl(this._self, this._then);

  final PersonFilmography _self;
  final $Res Function(PersonFilmography) _then;

/// Create a copy of PersonFilmography
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? personId = null,Object? entries = null,}) {
  return _then(_self.copyWith(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<FilmographyEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [PersonFilmography].
extension PersonFilmographyPatterns on PersonFilmography {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PersonFilmography value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PersonFilmography() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PersonFilmography value)  $default,){
final _that = this;
switch (_that) {
case _PersonFilmography():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PersonFilmography value)?  $default,){
final _that = this;
switch (_that) {
case _PersonFilmography() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int personId,  List<FilmographyEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PersonFilmography() when $default != null:
return $default(_that.personId,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int personId,  List<FilmographyEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _PersonFilmography():
return $default(_that.personId,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int personId,  List<FilmographyEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _PersonFilmography() when $default != null:
return $default(_that.personId,_that.entries);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _PersonFilmography extends PersonFilmography {
  const _PersonFilmography({required this.personId, final  List<FilmographyEntry> entries = const []}): _entries = entries,super._();
  factory _PersonFilmography.fromJson(Map<String, dynamic> json) => _$PersonFilmographyFromJson(json);

@override final  int personId;
 final  List<FilmographyEntry> _entries;
@override@JsonKey() List<FilmographyEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of PersonFilmography
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PersonFilmographyCopyWith<_PersonFilmography> get copyWith => __$PersonFilmographyCopyWithImpl<_PersonFilmography>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PersonFilmographyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PersonFilmography&&(identical(other.personId, personId) || other.personId == personId)&&const DeepCollectionEquality().equals(other._entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,personId,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'PersonFilmography(personId: $personId, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$PersonFilmographyCopyWith<$Res> implements $PersonFilmographyCopyWith<$Res> {
  factory _$PersonFilmographyCopyWith(_PersonFilmography value, $Res Function(_PersonFilmography) _then) = __$PersonFilmographyCopyWithImpl;
@override @useResult
$Res call({
 int personId, List<FilmographyEntry> entries
});




}
/// @nodoc
class __$PersonFilmographyCopyWithImpl<$Res>
    implements _$PersonFilmographyCopyWith<$Res> {
  __$PersonFilmographyCopyWithImpl(this._self, this._then);

  final _PersonFilmography _self;
  final $Res Function(_PersonFilmography) _then;

/// Create a copy of PersonFilmography
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? personId = null,Object? entries = null,}) {
  return _then(_PersonFilmography(
personId: null == personId ? _self.personId : personId // ignore: cast_nullable_to_non_nullable
as int,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<FilmographyEntry>,
  ));
}


}

// dart format on

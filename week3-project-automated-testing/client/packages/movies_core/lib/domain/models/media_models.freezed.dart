// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageAsset {

 String get filePath; ImageKind get kind; int get width; int get height; String? get language; double? get aspectRatio;
/// Create a copy of ImageAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageAssetCopyWith<ImageAsset> get copyWith => _$ImageAssetCopyWithImpl<ImageAsset>(this as ImageAsset, _$identity);

  /// Serializes this ImageAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageAsset&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.language, language) || other.language == language)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filePath,kind,width,height,language,aspectRatio);

@override
String toString() {
  return 'ImageAsset(filePath: $filePath, kind: $kind, width: $width, height: $height, language: $language, aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class $ImageAssetCopyWith<$Res>  {
  factory $ImageAssetCopyWith(ImageAsset value, $Res Function(ImageAsset) _then) = _$ImageAssetCopyWithImpl;
@useResult
$Res call({
 String filePath, ImageKind kind, int width, int height, String? language, double? aspectRatio
});




}
/// @nodoc
class _$ImageAssetCopyWithImpl<$Res>
    implements $ImageAssetCopyWith<$Res> {
  _$ImageAssetCopyWithImpl(this._self, this._then);

  final ImageAsset _self;
  final $Res Function(ImageAsset) _then;

/// Create a copy of ImageAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePath = null,Object? kind = null,Object? width = null,Object? height = null,Object? language = freezed,Object? aspectRatio = freezed,}) {
  return _then(_self.copyWith(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ImageKind,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageAsset].
extension ImageAssetPatterns on ImageAsset {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageAsset() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageAsset value)  $default,){
final _that = this;
switch (_that) {
case _ImageAsset():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageAsset value)?  $default,){
final _that = this;
switch (_that) {
case _ImageAsset() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String filePath,  ImageKind kind,  int width,  int height,  String? language,  double? aspectRatio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageAsset() when $default != null:
return $default(_that.filePath,_that.kind,_that.width,_that.height,_that.language,_that.aspectRatio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String filePath,  ImageKind kind,  int width,  int height,  String? language,  double? aspectRatio)  $default,) {final _that = this;
switch (_that) {
case _ImageAsset():
return $default(_that.filePath,_that.kind,_that.width,_that.height,_that.language,_that.aspectRatio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String filePath,  ImageKind kind,  int width,  int height,  String? language,  double? aspectRatio)?  $default,) {final _that = this;
switch (_that) {
case _ImageAsset() when $default != null:
return $default(_that.filePath,_that.kind,_that.width,_that.height,_that.language,_that.aspectRatio);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ImageAsset extends ImageAsset {
  const _ImageAsset({required this.filePath, required this.kind, required this.width, required this.height, this.language, this.aspectRatio}): super._();
  factory _ImageAsset.fromJson(Map<String, dynamic> json) => _$ImageAssetFromJson(json);

@override final  String filePath;
@override final  ImageKind kind;
@override final  int width;
@override final  int height;
@override final  String? language;
@override final  double? aspectRatio;

/// Create a copy of ImageAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageAssetCopyWith<_ImageAsset> get copyWith => __$ImageAssetCopyWithImpl<_ImageAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageAsset&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.language, language) || other.language == language)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,filePath,kind,width,height,language,aspectRatio);

@override
String toString() {
  return 'ImageAsset(filePath: $filePath, kind: $kind, width: $width, height: $height, language: $language, aspectRatio: $aspectRatio)';
}


}

/// @nodoc
abstract mixin class _$ImageAssetCopyWith<$Res> implements $ImageAssetCopyWith<$Res> {
  factory _$ImageAssetCopyWith(_ImageAsset value, $Res Function(_ImageAsset) _then) = __$ImageAssetCopyWithImpl;
@override @useResult
$Res call({
 String filePath, ImageKind kind, int width, int height, String? language, double? aspectRatio
});




}
/// @nodoc
class __$ImageAssetCopyWithImpl<$Res>
    implements _$ImageAssetCopyWith<$Res> {
  __$ImageAssetCopyWithImpl(this._self, this._then);

  final _ImageAsset _self;
  final $Res Function(_ImageAsset) _then;

/// Create a copy of ImageAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePath = null,Object? kind = null,Object? width = null,Object? height = null,Object? language = freezed,Object? aspectRatio = freezed,}) {
  return _then(_ImageAsset(
filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ImageKind,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$ImageGallery {

 OwnerKind get ownerKind; int get ownerId; List<ImageAsset> get images;
/// Create a copy of ImageGallery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageGalleryCopyWith<ImageGallery> get copyWith => _$ImageGalleryCopyWithImpl<ImageGallery>(this as ImageGallery, _$identity);

  /// Serializes this ImageGallery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageGallery&&(identical(other.ownerKind, ownerKind) || other.ownerKind == ownerKind)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerKind,ownerId,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'ImageGallery(ownerKind: $ownerKind, ownerId: $ownerId, images: $images)';
}


}

/// @nodoc
abstract mixin class $ImageGalleryCopyWith<$Res>  {
  factory $ImageGalleryCopyWith(ImageGallery value, $Res Function(ImageGallery) _then) = _$ImageGalleryCopyWithImpl;
@useResult
$Res call({
 OwnerKind ownerKind, int ownerId, List<ImageAsset> images
});




}
/// @nodoc
class _$ImageGalleryCopyWithImpl<$Res>
    implements $ImageGalleryCopyWith<$Res> {
  _$ImageGalleryCopyWithImpl(this._self, this._then);

  final ImageGallery _self;
  final $Res Function(ImageGallery) _then;

/// Create a copy of ImageGallery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerKind = null,Object? ownerId = null,Object? images = null,}) {
  return _then(_self.copyWith(
ownerKind: null == ownerKind ? _self.ownerKind : ownerKind // ignore: cast_nullable_to_non_nullable
as OwnerKind,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ImageAsset>,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageGallery].
extension ImageGalleryPatterns on ImageGallery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageGallery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageGallery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageGallery value)  $default,){
final _that = this;
switch (_that) {
case _ImageGallery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageGallery value)?  $default,){
final _that = this;
switch (_that) {
case _ImageGallery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OwnerKind ownerKind,  int ownerId,  List<ImageAsset> images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageGallery() when $default != null:
return $default(_that.ownerKind,_that.ownerId,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OwnerKind ownerKind,  int ownerId,  List<ImageAsset> images)  $default,) {final _that = this;
switch (_that) {
case _ImageGallery():
return $default(_that.ownerKind,_that.ownerId,_that.images);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OwnerKind ownerKind,  int ownerId,  List<ImageAsset> images)?  $default,) {final _that = this;
switch (_that) {
case _ImageGallery() when $default != null:
return $default(_that.ownerKind,_that.ownerId,_that.images);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ImageGallery extends ImageGallery {
  const _ImageGallery({required this.ownerKind, required this.ownerId, final  List<ImageAsset> images = const []}): _images = images,super._();
  factory _ImageGallery.fromJson(Map<String, dynamic> json) => _$ImageGalleryFromJson(json);

@override final  OwnerKind ownerKind;
@override final  int ownerId;
 final  List<ImageAsset> _images;
@override@JsonKey() List<ImageAsset> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}


/// Create a copy of ImageGallery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageGalleryCopyWith<_ImageGallery> get copyWith => __$ImageGalleryCopyWithImpl<_ImageGallery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageGalleryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageGallery&&(identical(other.ownerKind, ownerKind) || other.ownerKind == ownerKind)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerKind,ownerId,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'ImageGallery(ownerKind: $ownerKind, ownerId: $ownerId, images: $images)';
}


}

/// @nodoc
abstract mixin class _$ImageGalleryCopyWith<$Res> implements $ImageGalleryCopyWith<$Res> {
  factory _$ImageGalleryCopyWith(_ImageGallery value, $Res Function(_ImageGallery) _then) = __$ImageGalleryCopyWithImpl;
@override @useResult
$Res call({
 OwnerKind ownerKind, int ownerId, List<ImageAsset> images
});




}
/// @nodoc
class __$ImageGalleryCopyWithImpl<$Res>
    implements _$ImageGalleryCopyWith<$Res> {
  __$ImageGalleryCopyWithImpl(this._self, this._then);

  final _ImageGallery _self;
  final $Res Function(_ImageGallery) _then;

/// Create a copy of ImageGallery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerKind = null,Object? ownerId = null,Object? images = null,}) {
  return _then(_ImageGallery(
ownerKind: null == ownerKind ? _self.ownerKind : ownerKind // ignore: cast_nullable_to_non_nullable
as OwnerKind,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as int,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ImageAsset>,
  ));
}


}


/// @nodoc
mixin _$MovieReview {

 String get id; String get author; String get content; double? get authorRating;@UtcDateTimeConverter() DateTime? get createdAtUtc;@UtcDateTimeConverter() DateTime? get updatedAtUtc;
/// Create a copy of MovieReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieReviewCopyWith<MovieReview> get copyWith => _$MovieReviewCopyWithImpl<MovieReview>(this as MovieReview, _$identity);

  /// Serializes this MovieReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieReview&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.authorRating, authorRating) || other.authorRating == authorRating)&&(identical(other.createdAtUtc, createdAtUtc) || other.createdAtUtc == createdAtUtc)&&(identical(other.updatedAtUtc, updatedAtUtc) || other.updatedAtUtc == updatedAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,content,authorRating,createdAtUtc,updatedAtUtc);

@override
String toString() {
  return 'MovieReview(id: $id, author: $author, content: $content, authorRating: $authorRating, createdAtUtc: $createdAtUtc, updatedAtUtc: $updatedAtUtc)';
}


}

/// @nodoc
abstract mixin class $MovieReviewCopyWith<$Res>  {
  factory $MovieReviewCopyWith(MovieReview value, $Res Function(MovieReview) _then) = _$MovieReviewCopyWithImpl;
@useResult
$Res call({
 String id, String author, String content, double? authorRating,@UtcDateTimeConverter() DateTime? createdAtUtc,@UtcDateTimeConverter() DateTime? updatedAtUtc
});




}
/// @nodoc
class _$MovieReviewCopyWithImpl<$Res>
    implements $MovieReviewCopyWith<$Res> {
  _$MovieReviewCopyWithImpl(this._self, this._then);

  final MovieReview _self;
  final $Res Function(MovieReview) _then;

/// Create a copy of MovieReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? author = null,Object? content = null,Object? authorRating = freezed,Object? createdAtUtc = freezed,Object? updatedAtUtc = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorRating: freezed == authorRating ? _self.authorRating : authorRating // ignore: cast_nullable_to_non_nullable
as double?,createdAtUtc: freezed == createdAtUtc ? _self.createdAtUtc : createdAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAtUtc: freezed == updatedAtUtc ? _self.updatedAtUtc : updatedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MovieReview].
extension MovieReviewPatterns on MovieReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieReview value)  $default,){
final _that = this;
switch (_that) {
case _MovieReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieReview value)?  $default,){
final _that = this;
switch (_that) {
case _MovieReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String author,  String content,  double? authorRating, @UtcDateTimeConverter()  DateTime? createdAtUtc, @UtcDateTimeConverter()  DateTime? updatedAtUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieReview() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.authorRating,_that.createdAtUtc,_that.updatedAtUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String author,  String content,  double? authorRating, @UtcDateTimeConverter()  DateTime? createdAtUtc, @UtcDateTimeConverter()  DateTime? updatedAtUtc)  $default,) {final _that = this;
switch (_that) {
case _MovieReview():
return $default(_that.id,_that.author,_that.content,_that.authorRating,_that.createdAtUtc,_that.updatedAtUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String author,  String content,  double? authorRating, @UtcDateTimeConverter()  DateTime? createdAtUtc, @UtcDateTimeConverter()  DateTime? updatedAtUtc)?  $default,) {final _that = this;
switch (_that) {
case _MovieReview() when $default != null:
return $default(_that.id,_that.author,_that.content,_that.authorRating,_that.createdAtUtc,_that.updatedAtUtc);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MovieReview extends MovieReview {
  const _MovieReview({required this.id, required this.author, required this.content, this.authorRating, @UtcDateTimeConverter() this.createdAtUtc, @UtcDateTimeConverter() this.updatedAtUtc}): super._();
  factory _MovieReview.fromJson(Map<String, dynamic> json) => _$MovieReviewFromJson(json);

@override final  String id;
@override final  String author;
@override final  String content;
@override final  double? authorRating;
@override@UtcDateTimeConverter() final  DateTime? createdAtUtc;
@override@UtcDateTimeConverter() final  DateTime? updatedAtUtc;

/// Create a copy of MovieReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieReviewCopyWith<_MovieReview> get copyWith => __$MovieReviewCopyWithImpl<_MovieReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieReviewToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieReview&&(identical(other.id, id) || other.id == id)&&(identical(other.author, author) || other.author == author)&&(identical(other.content, content) || other.content == content)&&(identical(other.authorRating, authorRating) || other.authorRating == authorRating)&&(identical(other.createdAtUtc, createdAtUtc) || other.createdAtUtc == createdAtUtc)&&(identical(other.updatedAtUtc, updatedAtUtc) || other.updatedAtUtc == updatedAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,author,content,authorRating,createdAtUtc,updatedAtUtc);

@override
String toString() {
  return 'MovieReview(id: $id, author: $author, content: $content, authorRating: $authorRating, createdAtUtc: $createdAtUtc, updatedAtUtc: $updatedAtUtc)';
}


}

/// @nodoc
abstract mixin class _$MovieReviewCopyWith<$Res> implements $MovieReviewCopyWith<$Res> {
  factory _$MovieReviewCopyWith(_MovieReview value, $Res Function(_MovieReview) _then) = __$MovieReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String author, String content, double? authorRating,@UtcDateTimeConverter() DateTime? createdAtUtc,@UtcDateTimeConverter() DateTime? updatedAtUtc
});




}
/// @nodoc
class __$MovieReviewCopyWithImpl<$Res>
    implements _$MovieReviewCopyWith<$Res> {
  __$MovieReviewCopyWithImpl(this._self, this._then);

  final _MovieReview _self;
  final $Res Function(_MovieReview) _then;

/// Create a copy of MovieReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? author = null,Object? content = null,Object? authorRating = freezed,Object? createdAtUtc = freezed,Object? updatedAtUtc = freezed,}) {
  return _then(_MovieReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,authorRating: freezed == authorRating ? _self.authorRating : authorRating // ignore: cast_nullable_to_non_nullable
as double?,createdAtUtc: freezed == createdAtUtc ? _self.createdAtUtc : createdAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAtUtc: freezed == updatedAtUtc ? _self.updatedAtUtc : updatedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TrailerLink {

 String get id; int get movieId; String get name; String get youtubeKey;@SecureUriConverter() Uri get url; bool get official;@UtcDateTimeConverter() DateTime? get publishedAtUtc;
/// Create a copy of TrailerLink
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrailerLinkCopyWith<TrailerLink> get copyWith => _$TrailerLinkCopyWithImpl<TrailerLink>(this as TrailerLink, _$identity);

  /// Serializes this TrailerLink to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrailerLink&&(identical(other.id, id) || other.id == id)&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.name, name) || other.name == name)&&(identical(other.youtubeKey, youtubeKey) || other.youtubeKey == youtubeKey)&&(identical(other.url, url) || other.url == url)&&(identical(other.official, official) || other.official == official)&&(identical(other.publishedAtUtc, publishedAtUtc) || other.publishedAtUtc == publishedAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,movieId,name,youtubeKey,url,official,publishedAtUtc);

@override
String toString() {
  return 'TrailerLink(id: $id, movieId: $movieId, name: $name, youtubeKey: $youtubeKey, url: $url, official: $official, publishedAtUtc: $publishedAtUtc)';
}


}

/// @nodoc
abstract mixin class $TrailerLinkCopyWith<$Res>  {
  factory $TrailerLinkCopyWith(TrailerLink value, $Res Function(TrailerLink) _then) = _$TrailerLinkCopyWithImpl;
@useResult
$Res call({
 String id, int movieId, String name, String youtubeKey,@SecureUriConverter() Uri url, bool official,@UtcDateTimeConverter() DateTime? publishedAtUtc
});




}
/// @nodoc
class _$TrailerLinkCopyWithImpl<$Res>
    implements $TrailerLinkCopyWith<$Res> {
  _$TrailerLinkCopyWithImpl(this._self, this._then);

  final TrailerLink _self;
  final $Res Function(TrailerLink) _then;

/// Create a copy of TrailerLink
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? movieId = null,Object? name = null,Object? youtubeKey = null,Object? url = null,Object? official = null,Object? publishedAtUtc = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,youtubeKey: null == youtubeKey ? _self.youtubeKey : youtubeKey // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,official: null == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as bool,publishedAtUtc: freezed == publishedAtUtc ? _self.publishedAtUtc : publishedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrailerLink].
extension TrailerLinkPatterns on TrailerLink {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrailerLink value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrailerLink() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrailerLink value)  $default,){
final _that = this;
switch (_that) {
case _TrailerLink():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrailerLink value)?  $default,){
final _that = this;
switch (_that) {
case _TrailerLink() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int movieId,  String name,  String youtubeKey, @SecureUriConverter()  Uri url,  bool official, @UtcDateTimeConverter()  DateTime? publishedAtUtc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrailerLink() when $default != null:
return $default(_that.id,_that.movieId,_that.name,_that.youtubeKey,_that.url,_that.official,_that.publishedAtUtc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int movieId,  String name,  String youtubeKey, @SecureUriConverter()  Uri url,  bool official, @UtcDateTimeConverter()  DateTime? publishedAtUtc)  $default,) {final _that = this;
switch (_that) {
case _TrailerLink():
return $default(_that.id,_that.movieId,_that.name,_that.youtubeKey,_that.url,_that.official,_that.publishedAtUtc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int movieId,  String name,  String youtubeKey, @SecureUriConverter()  Uri url,  bool official, @UtcDateTimeConverter()  DateTime? publishedAtUtc)?  $default,) {final _that = this;
switch (_that) {
case _TrailerLink() when $default != null:
return $default(_that.id,_that.movieId,_that.name,_that.youtubeKey,_that.url,_that.official,_that.publishedAtUtc);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _TrailerLink extends TrailerLink {
  const _TrailerLink({required this.id, required this.movieId, required this.name, required this.youtubeKey, @SecureUriConverter() required this.url, this.official = false, @UtcDateTimeConverter() this.publishedAtUtc}): super._();
  factory _TrailerLink.fromJson(Map<String, dynamic> json) => _$TrailerLinkFromJson(json);

@override final  String id;
@override final  int movieId;
@override final  String name;
@override final  String youtubeKey;
@override@SecureUriConverter() final  Uri url;
@override@JsonKey() final  bool official;
@override@UtcDateTimeConverter() final  DateTime? publishedAtUtc;

/// Create a copy of TrailerLink
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrailerLinkCopyWith<_TrailerLink> get copyWith => __$TrailerLinkCopyWithImpl<_TrailerLink>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrailerLinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrailerLink&&(identical(other.id, id) || other.id == id)&&(identical(other.movieId, movieId) || other.movieId == movieId)&&(identical(other.name, name) || other.name == name)&&(identical(other.youtubeKey, youtubeKey) || other.youtubeKey == youtubeKey)&&(identical(other.url, url) || other.url == url)&&(identical(other.official, official) || other.official == official)&&(identical(other.publishedAtUtc, publishedAtUtc) || other.publishedAtUtc == publishedAtUtc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,movieId,name,youtubeKey,url,official,publishedAtUtc);

@override
String toString() {
  return 'TrailerLink(id: $id, movieId: $movieId, name: $name, youtubeKey: $youtubeKey, url: $url, official: $official, publishedAtUtc: $publishedAtUtc)';
}


}

/// @nodoc
abstract mixin class _$TrailerLinkCopyWith<$Res> implements $TrailerLinkCopyWith<$Res> {
  factory _$TrailerLinkCopyWith(_TrailerLink value, $Res Function(_TrailerLink) _then) = __$TrailerLinkCopyWithImpl;
@override @useResult
$Res call({
 String id, int movieId, String name, String youtubeKey,@SecureUriConverter() Uri url, bool official,@UtcDateTimeConverter() DateTime? publishedAtUtc
});




}
/// @nodoc
class __$TrailerLinkCopyWithImpl<$Res>
    implements _$TrailerLinkCopyWith<$Res> {
  __$TrailerLinkCopyWithImpl(this._self, this._then);

  final _TrailerLink _self;
  final $Res Function(_TrailerLink) _then;

/// Create a copy of TrailerLink
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? movieId = null,Object? name = null,Object? youtubeKey = null,Object? url = null,Object? official = null,Object? publishedAtUtc = freezed,}) {
  return _then(_TrailerLink(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,movieId: null == movieId ? _self.movieId : movieId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,youtubeKey: null == youtubeKey ? _self.youtubeKey : youtubeKey // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,official: null == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as bool,publishedAtUtc: freezed == publishedAtUtc ? _self.publishedAtUtc : publishedAtUtc // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$MovieCollection {

 CollectionRef get collection; List<MovieSummary> get movies; String? get overview;
/// Create a copy of MovieCollection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovieCollectionCopyWith<MovieCollection> get copyWith => _$MovieCollectionCopyWithImpl<MovieCollection>(this as MovieCollection, _$identity);

  /// Serializes this MovieCollection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovieCollection&&(identical(other.collection, collection) || other.collection == collection)&&const DeepCollectionEquality().equals(other.movies, movies)&&(identical(other.overview, overview) || other.overview == overview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,collection,const DeepCollectionEquality().hash(movies),overview);

@override
String toString() {
  return 'MovieCollection(collection: $collection, movies: $movies, overview: $overview)';
}


}

/// @nodoc
abstract mixin class $MovieCollectionCopyWith<$Res>  {
  factory $MovieCollectionCopyWith(MovieCollection value, $Res Function(MovieCollection) _then) = _$MovieCollectionCopyWithImpl;
@useResult
$Res call({
 CollectionRef collection, List<MovieSummary> movies, String? overview
});


$CollectionRefCopyWith<$Res> get collection;

}
/// @nodoc
class _$MovieCollectionCopyWithImpl<$Res>
    implements $MovieCollectionCopyWith<$Res> {
  _$MovieCollectionCopyWithImpl(this._self, this._then);

  final MovieCollection _self;
  final $Res Function(MovieCollection) _then;

/// Create a copy of MovieCollection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? collection = null,Object? movies = null,Object? overview = freezed,}) {
  return _then(_self.copyWith(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as CollectionRef,movies: null == movies ? _self.movies : movies // ignore: cast_nullable_to_non_nullable
as List<MovieSummary>,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MovieCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectionRefCopyWith<$Res> get collection {
  
  return $CollectionRefCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// Adds pattern-matching-related methods to [MovieCollection].
extension MovieCollectionPatterns on MovieCollection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovieCollection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovieCollection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovieCollection value)  $default,){
final _that = this;
switch (_that) {
case _MovieCollection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovieCollection value)?  $default,){
final _that = this;
switch (_that) {
case _MovieCollection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CollectionRef collection,  List<MovieSummary> movies,  String? overview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovieCollection() when $default != null:
return $default(_that.collection,_that.movies,_that.overview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CollectionRef collection,  List<MovieSummary> movies,  String? overview)  $default,) {final _that = this;
switch (_that) {
case _MovieCollection():
return $default(_that.collection,_that.movies,_that.overview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CollectionRef collection,  List<MovieSummary> movies,  String? overview)?  $default,) {final _that = this;
switch (_that) {
case _MovieCollection() when $default != null:
return $default(_that.collection,_that.movies,_that.overview);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _MovieCollection extends MovieCollection {
  const _MovieCollection({required this.collection, final  List<MovieSummary> movies = const [], this.overview}): _movies = movies,super._();
  factory _MovieCollection.fromJson(Map<String, dynamic> json) => _$MovieCollectionFromJson(json);

@override final  CollectionRef collection;
 final  List<MovieSummary> _movies;
@override@JsonKey() List<MovieSummary> get movies {
  if (_movies is EqualUnmodifiableListView) return _movies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_movies);
}

@override final  String? overview;

/// Create a copy of MovieCollection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovieCollectionCopyWith<_MovieCollection> get copyWith => __$MovieCollectionCopyWithImpl<_MovieCollection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovieCollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovieCollection&&(identical(other.collection, collection) || other.collection == collection)&&const DeepCollectionEquality().equals(other._movies, _movies)&&(identical(other.overview, overview) || other.overview == overview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,collection,const DeepCollectionEquality().hash(_movies),overview);

@override
String toString() {
  return 'MovieCollection(collection: $collection, movies: $movies, overview: $overview)';
}


}

/// @nodoc
abstract mixin class _$MovieCollectionCopyWith<$Res> implements $MovieCollectionCopyWith<$Res> {
  factory _$MovieCollectionCopyWith(_MovieCollection value, $Res Function(_MovieCollection) _then) = __$MovieCollectionCopyWithImpl;
@override @useResult
$Res call({
 CollectionRef collection, List<MovieSummary> movies, String? overview
});


@override $CollectionRefCopyWith<$Res> get collection;

}
/// @nodoc
class __$MovieCollectionCopyWithImpl<$Res>
    implements _$MovieCollectionCopyWith<$Res> {
  __$MovieCollectionCopyWithImpl(this._self, this._then);

  final _MovieCollection _self;
  final $Res Function(_MovieCollection) _then;

/// Create a copy of MovieCollection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? collection = null,Object? movies = null,Object? overview = freezed,}) {
  return _then(_MovieCollection(
collection: null == collection ? _self.collection : collection // ignore: cast_nullable_to_non_nullable
as CollectionRef,movies: null == movies ? _self._movies : movies // ignore: cast_nullable_to_non_nullable
as List<MovieSummary>,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MovieCollection
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CollectionRefCopyWith<$Res> get collection {
  
  return $CollectionRefCopyWith<$Res>(_self.collection, (value) {
    return _then(_self.copyWith(collection: value));
  });
}
}


/// @nodoc
mixin _$ImageConfiguration {

@SecureUriConverter() Uri get secureBaseUrl; List<String> get posterSizes; List<String> get backdropSizes; List<String> get profileSizes;
/// Create a copy of ImageConfiguration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageConfigurationCopyWith<ImageConfiguration> get copyWith => _$ImageConfigurationCopyWithImpl<ImageConfiguration>(this as ImageConfiguration, _$identity);

  /// Serializes this ImageConfiguration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageConfiguration&&(identical(other.secureBaseUrl, secureBaseUrl) || other.secureBaseUrl == secureBaseUrl)&&const DeepCollectionEquality().equals(other.posterSizes, posterSizes)&&const DeepCollectionEquality().equals(other.backdropSizes, backdropSizes)&&const DeepCollectionEquality().equals(other.profileSizes, profileSizes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secureBaseUrl,const DeepCollectionEquality().hash(posterSizes),const DeepCollectionEquality().hash(backdropSizes),const DeepCollectionEquality().hash(profileSizes));

@override
String toString() {
  return 'ImageConfiguration(secureBaseUrl: $secureBaseUrl, posterSizes: $posterSizes, backdropSizes: $backdropSizes, profileSizes: $profileSizes)';
}


}

/// @nodoc
abstract mixin class $ImageConfigurationCopyWith<$Res>  {
  factory $ImageConfigurationCopyWith(ImageConfiguration value, $Res Function(ImageConfiguration) _then) = _$ImageConfigurationCopyWithImpl;
@useResult
$Res call({
@SecureUriConverter() Uri secureBaseUrl, List<String> posterSizes, List<String> backdropSizes, List<String> profileSizes
});




}
/// @nodoc
class _$ImageConfigurationCopyWithImpl<$Res>
    implements $ImageConfigurationCopyWith<$Res> {
  _$ImageConfigurationCopyWithImpl(this._self, this._then);

  final ImageConfiguration _self;
  final $Res Function(ImageConfiguration) _then;

/// Create a copy of ImageConfiguration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? secureBaseUrl = null,Object? posterSizes = null,Object? backdropSizes = null,Object? profileSizes = null,}) {
  return _then(_self.copyWith(
secureBaseUrl: null == secureBaseUrl ? _self.secureBaseUrl : secureBaseUrl // ignore: cast_nullable_to_non_nullable
as Uri,posterSizes: null == posterSizes ? _self.posterSizes : posterSizes // ignore: cast_nullable_to_non_nullable
as List<String>,backdropSizes: null == backdropSizes ? _self.backdropSizes : backdropSizes // ignore: cast_nullable_to_non_nullable
as List<String>,profileSizes: null == profileSizes ? _self.profileSizes : profileSizes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageConfiguration].
extension ImageConfigurationPatterns on ImageConfiguration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageConfiguration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageConfiguration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageConfiguration value)  $default,){
final _that = this;
switch (_that) {
case _ImageConfiguration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageConfiguration value)?  $default,){
final _that = this;
switch (_that) {
case _ImageConfiguration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@SecureUriConverter()  Uri secureBaseUrl,  List<String> posterSizes,  List<String> backdropSizes,  List<String> profileSizes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageConfiguration() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@SecureUriConverter()  Uri secureBaseUrl,  List<String> posterSizes,  List<String> backdropSizes,  List<String> profileSizes)  $default,) {final _that = this;
switch (_that) {
case _ImageConfiguration():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@SecureUriConverter()  Uri secureBaseUrl,  List<String> posterSizes,  List<String> backdropSizes,  List<String> profileSizes)?  $default,) {final _that = this;
switch (_that) {
case _ImageConfiguration() when $default != null:
return $default(_that.secureBaseUrl,_that.posterSizes,_that.backdropSizes,_that.profileSizes);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _ImageConfiguration extends ImageConfiguration {
  const _ImageConfiguration({@SecureUriConverter() required this.secureBaseUrl, required final  List<String> posterSizes, required final  List<String> backdropSizes, required final  List<String> profileSizes}): _posterSizes = posterSizes,_backdropSizes = backdropSizes,_profileSizes = profileSizes,super._();
  factory _ImageConfiguration.fromJson(Map<String, dynamic> json) => _$ImageConfigurationFromJson(json);

@override@SecureUriConverter() final  Uri secureBaseUrl;
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


/// Create a copy of ImageConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageConfigurationCopyWith<_ImageConfiguration> get copyWith => __$ImageConfigurationCopyWithImpl<_ImageConfiguration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageConfigurationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageConfiguration&&(identical(other.secureBaseUrl, secureBaseUrl) || other.secureBaseUrl == secureBaseUrl)&&const DeepCollectionEquality().equals(other._posterSizes, _posterSizes)&&const DeepCollectionEquality().equals(other._backdropSizes, _backdropSizes)&&const DeepCollectionEquality().equals(other._profileSizes, _profileSizes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,secureBaseUrl,const DeepCollectionEquality().hash(_posterSizes),const DeepCollectionEquality().hash(_backdropSizes),const DeepCollectionEquality().hash(_profileSizes));

@override
String toString() {
  return 'ImageConfiguration(secureBaseUrl: $secureBaseUrl, posterSizes: $posterSizes, backdropSizes: $backdropSizes, profileSizes: $profileSizes)';
}


}

/// @nodoc
abstract mixin class _$ImageConfigurationCopyWith<$Res> implements $ImageConfigurationCopyWith<$Res> {
  factory _$ImageConfigurationCopyWith(_ImageConfiguration value, $Res Function(_ImageConfiguration) _then) = __$ImageConfigurationCopyWithImpl;
@override @useResult
$Res call({
@SecureUriConverter() Uri secureBaseUrl, List<String> posterSizes, List<String> backdropSizes, List<String> profileSizes
});




}
/// @nodoc
class __$ImageConfigurationCopyWithImpl<$Res>
    implements _$ImageConfigurationCopyWith<$Res> {
  __$ImageConfigurationCopyWithImpl(this._self, this._then);

  final _ImageConfiguration _self;
  final $Res Function(_ImageConfiguration) _then;

/// Create a copy of ImageConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? secureBaseUrl = null,Object? posterSizes = null,Object? backdropSizes = null,Object? profileSizes = null,}) {
  return _then(_ImageConfiguration(
secureBaseUrl: null == secureBaseUrl ? _self.secureBaseUrl : secureBaseUrl // ignore: cast_nullable_to_non_nullable
as Uri,posterSizes: null == posterSizes ? _self._posterSizes : posterSizes // ignore: cast_nullable_to_non_nullable
as List<String>,backdropSizes: null == backdropSizes ? _self._backdropSizes : backdropSizes // ignore: cast_nullable_to_non_nullable
as List<String>,profileSizes: null == profileSizes ? _self._profileSizes : profileSizes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on

import 'json_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'catalog_models.dart';
part 'media_models.freezed.dart';
part 'media_models.g.dart';

enum ImageKind { poster, backdrop, profile }

enum OwnerKind { movie, person }

@freezed
abstract class ImageAsset with _$ImageAsset {
  const ImageAsset._();
  @JsonSerializable(explicitToJson: true)
  const factory ImageAsset({
    required String filePath,
    required ImageKind kind,
    required int width,
    required int height,
    String? language,
    double? aspectRatio,
  }) = _ImageAsset;
  factory ImageAsset.fromJson(Map<String, dynamic> json) =>
      _$ImageAssetFromJson(json);
}

@freezed
abstract class ImageGallery with _$ImageGallery {
  const ImageGallery._();
  @JsonSerializable(explicitToJson: true)
  const factory ImageGallery({
    required OwnerKind ownerKind,
    required int ownerId,
    @Default([]) List<ImageAsset> images,
  }) = _ImageGallery;
  factory ImageGallery.fromJson(Map<String, dynamic> json) =>
      _$ImageGalleryFromJson(json);
}

@freezed
abstract class MovieReview with _$MovieReview {
  const MovieReview._();
  @JsonSerializable(explicitToJson: true)
  const factory MovieReview({
    required String id,
    required String author,
    required String content,
    double? authorRating,
    @UtcDateTimeConverter() DateTime? createdAtUtc,
    @UtcDateTimeConverter() DateTime? updatedAtUtc,
  }) = _MovieReview;
  factory MovieReview.fromJson(Map<String, dynamic> json) =>
      _$MovieReviewFromJson(json);
}

@freezed
abstract class TrailerLink with _$TrailerLink {
  const TrailerLink._();
  @JsonSerializable(explicitToJson: true)
  const factory TrailerLink({
    required String id,
    required int movieId,
    required String name,
    required String youtubeKey,
    @SecureUriConverter() required Uri url,
    @Default(false) bool official,
    @UtcDateTimeConverter() DateTime? publishedAtUtc,
  }) = _TrailerLink;
  factory TrailerLink.fromJson(Map<String, dynamic> json) =>
      _$TrailerLinkFromJson(json);
}

@freezed
abstract class MovieCollection with _$MovieCollection {
  const MovieCollection._();
  @JsonSerializable(explicitToJson: true)
  const factory MovieCollection({
    required CollectionRef collection,
    @Default([]) List<MovieSummary> movies,
    String? overview,
  }) = _MovieCollection;
  factory MovieCollection.fromJson(Map<String, dynamic> json) =>
      _$MovieCollectionFromJson(json);
}

@freezed
abstract class ImageConfiguration with _$ImageConfiguration {
  const ImageConfiguration._();
  @JsonSerializable(explicitToJson: true)
  const factory ImageConfiguration({
    @SecureUriConverter() required Uri secureBaseUrl,
    required List<String> posterSizes,
    required List<String> backdropSizes,
    required List<String> profileSizes,
  }) = _ImageConfiguration;
  factory ImageConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ImageConfigurationFromJson(json);
}

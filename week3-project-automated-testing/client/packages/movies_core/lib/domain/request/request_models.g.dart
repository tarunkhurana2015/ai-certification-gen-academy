// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RequestKey _$RequestKeyFromJson(Map<String, dynamic> json) => _RequestKey(
  mode: json['mode'] as String,
  operation: json['operation'] as String,
  entityId: (json['entityId'] as num?)?.toInt(),
  query: json['query'] as String?,
  category: json['category'] as String?,
  seedMovieId: (json['seedMovieId'] as num?)?.toInt(),
  language: json['language'] as String? ?? 'en-US',
  region: json['region'] as String?,
  filters:
      (json['filters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  page: (json['page'] as num?)?.toInt(),
);

Map<String, dynamic> _$RequestKeyToJson(_RequestKey instance) =>
    <String, dynamic>{
      'mode': instance.mode,
      'operation': instance.operation,
      'entityId': instance.entityId,
      'query': instance.query,
      'category': instance.category,
      'seedMovieId': instance.seedMovieId,
      'language': instance.language,
      'region': instance.region,
      'filters': instance.filters,
      'page': instance.page,
    };

_ReleaseWindow _$ReleaseWindowFromJson(Map<String, dynamic> json) =>
    _ReleaseWindow(
      minimum: CalendarDate.fromJson(json['minimum'] as Map<String, dynamic>),
      maximum: CalendarDate.fromJson(json['maximum'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReleaseWindowToJson(_ReleaseWindow instance) =>
    <String, dynamic>{
      'minimum': instance.minimum.toJson(),
      'maximum': instance.maximum.toJson(),
    };

_AppFailure _$AppFailureFromJson(Map<String, dynamic> json) => _AppFailure(
  kind: $enumDecode(_$FailureKindEnumMap, json['kind']),
  operation: json['operation'] as String,
  occurredAtUtc: const UtcDateTimeConverter().fromJson(
    json['occurredAtUtc'] as String,
  ),
  retryAllowed: json['retryAllowed'] as bool? ?? true,
  requestKey: json['requestKey'] == null
      ? null
      : RequestKey.fromJson(json['requestKey'] as Map<String, dynamic>),
  retryNotBeforeUtc: _$JsonConverterFromJson<String, DateTime>(
    json['retryNotBeforeUtc'],
    const UtcDateTimeConverter().fromJson,
  ),
  httpStatus: (json['httpStatus'] as num?)?.toInt(),
  providerCode: (json['providerCode'] as num?)?.toInt(),
  intentRevision: (json['intentRevision'] as num?)?.toInt(),
);

Map<String, dynamic> _$AppFailureToJson(
  _AppFailure instance,
) => <String, dynamic>{
  'kind': _$FailureKindEnumMap[instance.kind]!,
  'operation': instance.operation,
  'occurredAtUtc': const UtcDateTimeConverter().toJson(instance.occurredAtUtc),
  'retryAllowed': instance.retryAllowed,
  'requestKey': instance.requestKey?.toJson(),
  'retryNotBeforeUtc': _$JsonConverterToJson<String, DateTime>(
    instance.retryNotBeforeUtc,
    const UtcDateTimeConverter().toJson,
  ),
  'httpStatus': instance.httpStatus,
  'providerCode': instance.providerCode,
  'intentRevision': instance.intentRevision,
};

const _$FailureKindEnumMap = {
  FailureKind.configuration: 'configuration',
  FailureKind.authentication: 'authentication',
  FailureKind.network: 'network',
  FailureKind.timeout: 'timeout',
  FailureKind.rateLimited: 'rateLimited',
  FailureKind.notFound: 'notFound',
  FailureKind.invalidRequest: 'invalidRequest',
  FailureKind.server: 'server',
  FailureKind.invalidData: 'invalidData',
  FailureKind.contentUnavailable: 'contentUnavailable',
  FailureKind.storageRead: 'storageRead',
  FailureKind.storageWrite: 'storageWrite',
  FailureKind.storageMigration: 'storageMigration',
  FailureKind.externalLink: 'externalLink',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);

_PageResult<T> _$PageResultFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _PageResult<T>(
  items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
  page: (json['page'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  totalResults: (json['totalResults'] as num).toInt(),
  requestKey: RequestKey.fromJson(json['requestKey'] as Map<String, dynamic>),
  releaseWindow: json['releaseWindow'] == null
      ? null
      : ReleaseWindow.fromJson(json['releaseWindow'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PageResultToJson<T>(
  _PageResult<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items.map(toJsonT).toList(),
  'page': instance.page,
  'totalPages': instance.totalPages,
  'totalResults': instance.totalResults,
  'requestKey': instance.requestKey.toJson(),
  'releaseWindow': instance.releaseWindow?.toJson(),
};

_TrendingSelection _$TrendingSelectionFromJson(Map<String, dynamic> json) =>
    _TrendingSelection(
      items: (json['items'] as List<dynamic>)
          .map((e) => MovieSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      requestKey: RequestKey.fromJson(
        json['requestKey'] as Map<String, dynamic>,
      ),
      timeWindow: json['timeWindow'] as String? ?? 'week',
      providerPage: (json['providerPage'] as num?)?.toInt(),
      providerTotalPages: (json['providerTotalPages'] as num?)?.toInt(),
      providerTotalResults: (json['providerTotalResults'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TrendingSelectionToJson(_TrendingSelection instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'requestKey': instance.requestKey.toJson(),
      'timeWindow': instance.timeWindow,
      'providerPage': instance.providerPage,
      'providerTotalPages': instance.providerTotalPages,
      'providerTotalResults': instance.providerTotalResults,
    };

_RecommendationSource _$RecommendationSourceFromJson(
  Map<String, dynamic> json,
) => _RecommendationSource(
  kind: json['kind'] as String,
  seedMovieId: (json['seedMovieId'] as num?)?.toInt(),
  seedTitle: json['seedTitle'] as String?,
);

Map<String, dynamic> _$RecommendationSourceToJson(
  _RecommendationSource instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'seedMovieId': instance.seedMovieId,
  'seedTitle': instance.seedTitle,
};

Success<T> _$SuccessFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => Success<T>(fromJsonT(json['data']), $type: json['type'] as String?);

Map<String, dynamic> _$SuccessToJson<T>(
  Success<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'data': toJsonT(instance.data), 'type': instance.$type};

Failed<T> _$FailedFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => Failed<T>(
  AppFailure.fromJson(json['error'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FailedToJson<T>(
  Failed<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'error': instance.error.toJson(),
  'type': instance.$type,
};

Cancelled<T> _$CancelledFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => Cancelled<T>($type: json['type'] as String?);

Map<String, dynamic> _$CancelledToJson<T>(
  Cancelled<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{'type': instance.$type};

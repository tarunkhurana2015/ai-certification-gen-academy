import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:movies_data/src/tmdb/tmdb_client.dart';

class JsonAdapter implements HttpClientAdapter {
  final responses = <String, Object?>{};
  final requests = <RequestOptions>[];
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(responses[options.uri.path]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

TmdbClient testClient(JsonAdapter adapter) => TmdbClient(
  token: 'test-token',
  dio: Dio()..httpClientAdapter = adapter,
  delay: (_) async {},
);
Map<String, Object?> rawMovie(
  int id, {
  String? title = 'A movie',
  bool adult = false,
}) => {
  'id': id,
  'title': title,
  'original_title': 'Original title',
  'overview': 'A story',
  'vote_average': 8,
  'vote_count': 12,
  'release_date': '2026-01-09',
  'genre_ids': [18],
  'adult': adult,
};
Map<String, Object?> rawPage(
  List<Object?> rows, {
  int page = 1,
  int totalPages = 1,
}) => {
  'results': rows,
  'page': page,
  'total_pages': totalPages,
  'total_results': rows.length,
};

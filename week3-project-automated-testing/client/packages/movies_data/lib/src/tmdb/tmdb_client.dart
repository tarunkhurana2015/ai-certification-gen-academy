import 'dart:async';
import 'dart:collection';
import 'dart:io' show HttpDate;
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:movies_core/movies_core.dart';
import '../cache/catalog_cache.dart';

/// The only credential-bearing catalog boundary. Raw payloads never leave data.
class TmdbClient {
  TmdbClient({
    required String token,
    Dio? dio,
    Clock? clock,
    this.deadline = const Duration(seconds: 25),
    Future<void> Function(Duration)? delay,
    Duration Function()? jitter,
    Schedule? schedule,
  }) : _token = token.trim(),
       _dio = dio ?? Dio(),
       clock = clock ?? SystemClock(),
       _delay = delay ?? Future<void>.delayed,
       _jitter = jitter ?? _randomJitter,
       _schedule = schedule ?? Timer.new {
    cache = CatalogCache(clock: this.clock);
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: false,
      maxRedirects: 0,
      responseType: ResponseType.json,
      validateStatus: (status) => status != null,
    );
  }
  final String _token;
  final Dio _dio;
  final Clock clock;
  final Duration deadline;
  final Future<void> Function(Duration) _delay;
  final Duration Function() _jitter;
  final Schedule _schedule;
  late final CatalogCache cache;
  final _queue = Queue<_ReadLease>();
  final _leases = <_ReadLease>{};
  int _active = 0;
  bool _closed = false;
  Duration? _cooldown;
  DateTime? _cooldownUtc;
  static Duration _randomJitter() =>
      Duration(milliseconds: 300 + Random().nextInt(501));
  AppFailure _failure(
    FailureKind kind,
    RequestKey key, {
    int? status,
    int? code,
    DateTime? retryAt,
  }) => AppFailure(
    kind: kind,
    operation: key.operation,
    requestKey: key,
    occurredAtUtc: clock.utcNow(),
    httpStatus: status,
    providerCode: code,
    retryNotBeforeUtc: retryAt,
    retryAllowed: !{
      FailureKind.configuration,
      FailureKind.authentication,
      FailureKind.invalidRequest,
      FailureKind.notFound,
      FailureKind.contentUnavailable,
    }.contains(kind),
  );
  void _enqueue(_ReadLease lease) {
    _leases.add(lease);
    if (_active < 4) {
      _active++;
      lease.active = true;
      lease.granted.complete(true);
    } else {
      _queue.add(lease);
    }
  }

  void _release(_ReadLease lease) {
    _leases.remove(lease);
    _queue.remove(lease);
    if (!lease.granted.isCompleted) lease.granted.complete(false);
    if (lease.active) {
      lease.active = false;
      _active--;
    }
    while (_active < 4 && _queue.isNotEmpty) {
      final next = _queue.removeFirst();
      if (next.closed) continue;
      next.active = true;
      _active++;
      next.granted.complete(true);
    }
  }

  Future<Outcome<T>> read<T extends Object>(
    String path, {
    Map<String, String> query = const {},
    required RequestKey key,
    CatalogReadOptions options = const CatalogReadOptions(),
    Duration ttl = const Duration(minutes: 5),
    required T Function(Map<String, dynamic>) map,
  }) async {
    if (_closed || options.cancellation?.isCancelled == true)
      return const Outcome.cancelled();
    if (_token.isEmpty || RegExp(r'\s').hasMatch(_token))
      return Outcome.failure(_failure(FailureKind.configuration, key));
    if (!RegExp(r'^/[a-z0-9_]+(?:/[a-z0-9_]+)*$').hasMatch(path))
      return Outcome.failure(_failure(FailureKind.invalidRequest, key));
    if (options.policy == ReadPolicy.cacheFirst) {
      final hit = cache.get<T>(key);
      if (hit != null) return Outcome.success(hit);
    }
    if (_cooldown != null && clock.elapsed < _cooldown!)
      return Outcome.failure(
        _failure(FailureKind.rateLimited, key, retryAt: _cooldownUtc),
      );
    final lease = _ReadLease();
    final start = clock.elapsed;
    final expired = Completer<Outcome<T>>();
    final cancelled = Completer<Outcome<T>>();
    void cancel() {
      lease.token.cancel();
      if (!lease.granted.isCompleted) {
        _queue.remove(lease);
        lease.granted.complete(false);
      }
    }

    lease.abort = () {
      if (!cancelled.isCompleted) cancelled.complete(const Outcome.cancelled());
      cancel();
    };
    final timer = _schedule(deadline, () {
      if (lease.closed) return;
      if (!expired.isCompleted)
        expired.complete(Outcome.failure(_failure(FailureKind.timeout, key)));
      cancel();
    });
    options.cancellation?.onCancel(lease.abort!);
    _enqueue(lease);
    bool isDone() =>
        lease.closed ||
        lease.token.isCancelled ||
        clock.elapsed - start >= deadline;
    Future<Outcome<T>> execute() async {
      if (!await lease.granted.future || isDone())
        return const Outcome.cancelled();
      for (var attempt = 0; attempt < 2; attempt++) {
        if (isDone()) return const Outcome.cancelled();
        if (_cooldown != null && clock.elapsed < _cooldown!)
          return Outcome.failure(
            _failure(FailureKind.rateLimited, key, retryAt: _cooldownUtc),
          );
        late AppFailure failure;
        try {
          final response = await _dio.getUri<dynamic>(
            Uri.https(
              'api.themoviedb.org',
              '/3$path',
              query.isEmpty ? null : query,
            ),
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $_token',
              },
              followRedirects: false,
            ),
            cancelToken: lease.token,
          );
          if (isDone())
            return clock.elapsed - start >= deadline
                ? Outcome.failure(_failure(FailureKind.timeout, key))
                : const Outcome.cancelled();
          final status = response.statusCode ?? 0;
          final body = response.data;
          final code = body is Map && body['status_code'] is int
              ? body['status_code'] as int
              : null;
          if (status >= 200 &&
              status < 300 &&
              !(body is Map && body['success'] == false)) {
            try {
              if (body is! Map<String, dynamic>)
                throw const FormatException('Expected JSON object');
              final value = map(body);
              if (isDone())
                return Outcome.failure(_failure(FailureKind.timeout, key));
              cache.put(key, value, ttl);
              return Outcome.success(value);
            } catch (error) {
              return Outcome.failure(
                _failure(
                  error is TmdbMappingFailure
                      ? error.kind
                      : FailureKind.invalidData,
                  key,
                  status: status,
                  code: code,
                ),
              );
            }
          }
          if (status == 429) {
            final duration = _retryAfter(response.headers.value('retry-after'));
            final candidate = clock.elapsed + duration;
            if (_cooldown == null || candidate > _cooldown!) {
              _cooldown = candidate;
              _cooldownUtc = clock.utcNow().add(duration);
            }
            return Outcome.failure(
              _failure(
                FailureKind.rateLimited,
                key,
                status: status,
                code: code,
                retryAt: _cooldownUtc,
              ),
            );
          }
          final kind = switch (status) {
            401 || 403 => FailureKind.authentication,
            404 => FailureKind.notFound,
            400 || 405 || 406 || 422 => FailureKind.invalidRequest,
            _ => code == 7 ? FailureKind.authentication : FailureKind.server,
          };
          failure = _failure(kind, key, status: status, code: code);
          if (kind != FailureKind.server ||
              !{500, 502, 503, 504}.contains(status))
            return Outcome.failure(failure);
        } on DioException catch (error) {
          if (isDone() || error.type == DioExceptionType.cancel)
            return const Outcome.cancelled();
          final kind = switch (error.type) {
            DioExceptionType.connectionTimeout ||
            DioExceptionType.sendTimeout ||
            DioExceptionType.receiveTimeout => FailureKind.timeout,
            _ => FailureKind.network,
          };
          if (error.error is FormatException)
            return Outcome.failure(_failure(FailureKind.invalidData, key));
          failure = _failure(kind, key);
          if (!{
            DioExceptionType.connectionTimeout,
            DioExceptionType.sendTimeout,
            DioExceptionType.receiveTimeout,
            DioExceptionType.connectionError,
          }.contains(error.type))
            return Outcome.failure(failure);
        } catch (_) {
          return Outcome.failure(_failure(FailureKind.network, key));
        }
        if (attempt == 1) return Outcome.failure(failure);
        final jitterMs = _jitter().inMilliseconds.clamp(300, 800);
        await _delay(Duration(milliseconds: jitterMs));
      }
      return Outcome.failure(_failure(FailureKind.network, key));
    }

    try {
      return await Future.any([execute(), expired.future, cancelled.future]);
    } finally {
      lease.closed = true;
      timer.cancel();
      lease.token.cancel();
      _release(lease);
    }
  }

  Duration _retryAfter(String? header) {
    final seconds = int.tryParse(header?.trim() ?? '');
    if (seconds != null && seconds >= 0) return Duration(seconds: seconds);
    if (header != null) {
      try {
        final duration = HttpDate.parse(
          header,
        ).toUtc().difference(clock.utcNow());
        if (!duration.isNegative) return duration;
      } catch (_) {
        /* Use the shared default. */
      }
    }
    return const Duration(seconds: 30);
  }

  void close() {
    _closed = true;
    for (final lease in _leases.toList()) {
      lease.abort?.call();
    }
    _dio.close(force: true);
    cache.clear();
  }
}

class _ReadLease {
  final granted = Completer<bool>();
  final token = CancelToken();
  bool active = false, closed = false;
  void Function()? abort;
}

class TmdbMappingFailure implements Exception {
  const TmdbMappingFailure(this.kind);
  final FailureKind kind;
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/src/tmdb/tmdb_client.dart';

class Adapter implements HttpClientAdapter {
  final calls = <RequestOptions>[];
  final fourStarted = Completer<void>();
  final pending = <Completer<ResponseBody>>[];
  int status = 200;
  String? retryAfter;
  bool hold = false;
  Object body = {'value': 1};
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    if (calls.length == 4 && !fourStarted.isCompleted) fourStarted.complete();
    if (hold) {
      final c = Completer<ResponseBody>();
      pending.add(c);
      return c.future;
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        if (retryAfter != null) 'retry-after': [retryAfter!],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class TransportClock implements Clock {
  Duration time = Duration.zero;
  @override
  Duration get elapsed => time;
  @override
  DateTime utcNow() => DateTime.utc(2026).add(time);
}

void main() {
  TmdbClient make(
    Adapter adapter, {
    String token = 'test-token',
    Clock? clock,
    Duration deadline = const Duration(seconds: 25),
  }) => TmdbClient(
    token: token,
    clock: clock,
    dio: Dio()..httpClientAdapter = adapter,
    deadline: deadline,
    delay: (_) async {},
    jitter: () => const Duration(milliseconds: 300),
  );
  const key = RequestKey(mode: 'live', operation: 'test');
  Future<Outcome<int>> read(
    TmdbClient client, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => client.read(
    '/movie/popular',
    query: const {'language': 'en-US', 'region': 'US', 'page': '1'},
    key: key,
    options: options,
    map: (json) => json['value'] as int,
  );
  for (final header in <String?>[
    '17',
    'Thu, 01 Jan 2026 00:00:20 GMT',
    null,
    'bad',
    '-4',
  ]) {
    test(
      'Retry-After $header sets a shared bounded explicit retry hint',
      () async {
        final clock = TransportClock();
        final adapter = Adapter()
          ..status = 429
          ..retryAfter = header;
        final client = make(adapter, clock: clock);
        addTearDown(client.close);
        final expected = header == '17'
            ? 17
            : header != null && header.startsWith('Thu')
            ? 20
            : 30;
        final result = await read(client);
        expect(
          result.failureOrNull!.retryNotBeforeUtc,
          clock.utcNow().add(Duration(seconds: expected)),
        );
        await read(client);
        expect(adapter.calls.length, 1);
        clock.time = Duration(seconds: expected);
        adapter.status = 200;
        expect((await read(client)).dataOrNull, 1);
        expect(adapter.calls.length, 2);
      },
    );
  }
  test('retry delay is clamped to 300 through 800 milliseconds', () async {
    for (final milliseconds in [-1, 500, 9999]) {
      final delays = <Duration>[];
      final adapter = Adapter()..status = 503;
      final client = TmdbClient(
        token: 'test',
        dio: Dio()..httpClientAdapter = adapter,
        delay: (duration) async {
          delays.add(duration);
        },
        jitter: () => Duration(milliseconds: milliseconds),
      );
      await read(client);
      expect(delays, [Duration(milliseconds: milliseconds.clamp(300, 800))]);
      expect(adapter.calls.length, 2);
      client.close();
    }
  });
  testWidgets('queue and retry backoff count toward the absolute deadline', (
    tester,
  ) async {
    final adapter = Adapter()..hold = true;
    final client = make(adapter);
    final pending = [
      for (var i = 0; i < 5; i++)
        client.read<int>(
          '/movie/$i',
          key: key.copyWith(entityId: i),
          map: (_) => 1,
        ),
    ];
    await tester.pump();
    await tester.pump(const Duration(seconds: 25));
    final results = await Future.wait(pending);
    expect(
      results.every((r) => r.failureOrNull?.kind == FailureKind.timeout),
      true,
    );
    expect(adapter.calls.length, 4);
    client.close();
    for (final response in adapter.pending) {
      response.complete(ResponseBody.fromString('{}', 200));
    }
    await tester.pump();
    final delayed = Completer<void>();
    final failing = Adapter()..status = 503;
    final second = TmdbClient(
      token: 'test',
      dio: Dio()..httpClientAdapter = failing,
      delay: (_) => delayed.future,
    );
    Outcome<int>? outcome;
    read(second).then((v) => outcome = v);
    await tester.pump();
    await tester.pump(const Duration(seconds: 25));
    expect(outcome?.failureOrNull?.kind, FailureKind.timeout);
    expect(failing.calls.length, 1);
    delayed.complete();
    await tester.pump();
    expect(failing.calls.length, 1);
    second.close();
  });
  test(
    'closing aborts active and queued work without starting another read',
    () async {
      final adapter = Adapter()..hold = true;
      final client = make(adapter);
      final pending = [
        for (var i = 0; i < 5; i++)
          client.read<int>(
            '/movie/$i',
            key: key.copyWith(entityId: i),
            map: (_) => 1,
          ),
      ];
      await adapter.fourStarted.future;
      client.close();
      expect(
        (await Future.wait(pending)).every((r) => r is Cancelled<int>),
        true,
      );
      expect(adapter.calls.length, 4);
      for (final response in adapter.pending) {
        response.complete(ResponseBody.fromString('{}', 200));
      }
    },
  );
  test(
    'fixed host bearer boundary, no redirects, cache and explicit refresh',
    () async {
      final adapter = Adapter();
      final client = make(adapter);
      addTearDown(client.close);
      expect((await read(client)).dataOrNull, 1);
      expect((await read(client)).dataOrNull, 1);
      expect(adapter.calls.length, 1);
      await read(
        client,
        options: const CatalogReadOptions(policy: ReadPolicy.refresh),
      );
      expect(adapter.calls.length, 2);
      final request = adapter.calls.first;
      expect(request.uri.host, 'api.themoviedb.org');
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(request.followRedirects, false);
      final invalid = await client.read<int>(
        'https://evil.test',
        key: key,
        map: (_) => 1,
      );
      expect(invalid.failureOrNull!.kind, FailureKind.invalidRequest);
      expect(adapter.calls.length, 2);
    },
  );
  test(
    'missing token and 401 are explicit failures without retry or fixture data',
    () async {
      final adapter = Adapter();
      final missing = make(adapter, token: '');
      addTearDown(missing.close);
      expect(
        (await read(missing)).failureOrNull!.kind,
        FailureKind.configuration,
      );
      expect(adapter.calls, isEmpty);
      final client = make(adapter..status = 401);
      addTearDown(client.close);
      expect(
        (await read(client)).failureOrNull!.kind,
        FailureKind.authentication,
      );
      expect(adapter.calls.length, 1);
    },
  );
  test(
    'one transient server retry; 429 starts shared cooldown immediately',
    () async {
      final adapter = Adapter()..status = 503;
      final client = make(adapter);
      addTearDown(client.close);
      expect((await read(client)).failureOrNull!.kind, FailureKind.server);
      expect(adapter.calls.length, 2);
      adapter.status = 429;
      adapter.retryAfter = '60';
      final failure = (await read(client)).failureOrNull!;
      expect(failure.kind, FailureKind.rateLimited);
      expect(failure.retryNotBeforeUtc, isNotNull);
      await read(client);
      expect(adapter.calls.length, 3);
    },
  );
  test(
    'four active reads; cancellation removes queued work without HTTP',
    () async {
      final adapter = Adapter()..hold = true;
      final client = make(adapter);
      addTearDown(client.close);
      final pending = [
        for (var i = 0; i < 4; i++)
          client.read<int>(
            '/movie/$i',
            key: key.copyWith(entityId: i),
            map: (_) => 1,
          ),
      ];
      await adapter.fourStarted.future.timeout(const Duration(seconds: 2));
      expect(adapter.calls.length, 4);
      final cancel = CancellationHandle();
      final fifth = client.read<int>(
        '/movie/5',
        key: key.copyWith(entityId: 5),
        options: CatalogReadOptions(cancellation: cancel),
        map: (_) => 1,
      );
      cancel.cancel();
      expect(await fifth, isA<Cancelled<int>>());
      expect(adapter.calls.length, 4);
      for (final p in adapter.pending) {
        p.complete(
          ResponseBody.fromString(
            '{}',
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          ),
        );
      }
      await Future.wait(pending);
    },
  );
  testWidgets('absolute deadline ends an unresponsive request', (tester) async {
    final adapter = Adapter()..hold = true;
    final client = make(adapter, deadline: const Duration(seconds: 25));
    addTearDown(client.close);
    Outcome<int>? outcome;
    read(client).then((value) => outcome = value);
    await tester.pump();
    await tester.pump(const Duration(seconds: 25));
    expect(outcome?.failureOrNull?.kind, FailureKind.timeout);
    for (final p in adapter.pending) {
      p.complete(ResponseBody.fromString('{}', 200));
    }
    await tester.pump();
  });
  test(
    'normalized authentication errors are never automatically retried',
    () async {
      final adapter = Adapter()
        ..status = 500
        ..body = {'success': false, 'status_code': 7};
      final client = make(adapter);
      addTearDown(client.close);
      expect(
        (await read(client)).failureOrNull!.kind,
        FailureKind.authentication,
      );
      expect(adapter.calls.length, 1);
    },
  );
  test(
    'concurrent 429 responses cannot shorten an existing shared cooldown',
    () async {
      final clock = TransportClock();
      final adapter = Adapter()..hold = true;
      final client = make(adapter, clock: clock);
      addTearDown(client.close);
      final reads = [
        for (var i = 0; i < 4; i++)
          client.read<int>(
            '/movie/$i',
            key: key.copyWith(entityId: i),
            map: (_) => 1,
          ),
      ];
      await adapter.fourStarted.future;
      ResponseBody limited(String seconds) => ResponseBody.fromString(
        '{}',
        429,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'retry-after': [seconds],
        },
      );
      adapter.pending[0].complete(limited('60'));
      await reads[0];
      adapter.pending[1].complete(limited('1'));
      await reads[1];
      for (final pending in adapter.pending.skip(2)) {
        pending.complete(
          ResponseBody.fromString(
            '{}',
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          ),
        );
      }
      await Future.wait(reads);
      clock.time = const Duration(seconds: 2);
      adapter.hold = false;
      final result = await read(client);
      expect(result.failureOrNull?.kind, FailureKind.rateLimited);
      expect(adapter.calls.length, 4);
    },
  );
}

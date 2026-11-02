import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/src/cache/catalog_cache.dart';

class TestClock implements Clock {
  Duration time = Duration.zero;
  @override
  Duration get elapsed => time;
  @override
  DateTime utcNow() => DateTime.utc(2026).add(time);
}

void main() {
  test(
    'default capacity retains exactly 128 fresh resources and promotes display reads',
    () {
      final cache = CatalogCache(clock: TestClock());
      RequestKey key(int id) =>
          RequestKey(mode: 'live', operation: 'movie', entityId: id);
      for (var id = 0; id < 128; id++) {
        cache.put(key(id), 'Movie $id', const Duration(minutes: 5));
      }
      expect(cache.get<String>(key(0)), 'Movie 0');
      cache.put(key(128), 'Movie 128', const Duration(minutes: 5));
      expect(cache.get<String>(key(1)), isNull);
      expect(cache.get<String>(key(0)), 'Movie 0');
      expect(cache.get<String>(key(128)), 'Movie 128');
    },
  );

  test('cache expires at TTL and promotes only fresh reads for LRU', () {
    final clock = TestClock();
    final cache = CatalogCache(clock: clock, capacity: 2);
    const a = RequestKey(mode: 'live', operation: 'a');
    const b = RequestKey(mode: 'live', operation: 'b');
    const c = RequestKey(mode: 'live', operation: 'c');
    cache.put(a, 'A', const Duration(minutes: 5));
    cache.put(b, 'B', const Duration(minutes: 5));
    expect(cache.get<String>(a), 'A');
    cache.put(c, 'C', const Duration(minutes: 5));
    expect(cache.get<String>(b), isNull);
    clock.time = const Duration(minutes: 5);
    expect(cache.get<String>(a), isNull);
  });
  test('mode, page and normalized query identities do not collide', () {
    final cache = CatalogCache(clock: TestClock());
    const key = RequestKey(
      mode: 'live',
      operation: 'search',
      query: 'A',
      page: 1,
    );
    cache.put(key, 'A', const Duration(minutes: 5));
    expect(cache.get<String>(key.copyWith(mode: 'fixture')), isNull);
    expect(cache.get<String>(key.copyWith(page: 2)), isNull);
    expect(cache.get<String>(key.copyWith(query: 'a')), isNull);
  });
}

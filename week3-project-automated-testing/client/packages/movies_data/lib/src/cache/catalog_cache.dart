import 'dart:collection';
import 'package:movies_core/movies_core.dart';

class CatalogCache {
  CatalogCache({required this.clock, this.capacity = 128}) {
    if (capacity < 1) throw ArgumentError.value(capacity, 'capacity');
  }
  final Clock clock;
  final int capacity;
  final _entries =
      LinkedHashMap<RequestKey, ({Object value, Duration expires})>();
  T? get<T>(RequestKey key) {
    final entry = _entries.remove(key);
    if (entry == null || entry.expires <= clock.elapsed) return null;
    _entries[key] = entry;
    return entry.value as T;
  }

  void put<T extends Object>(RequestKey key, T value, Duration ttl) {
    _entries.remove(key);
    _entries[key] = (value: value, expires: clock.elapsed + ttl);
    while (_entries.length > capacity) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() => _entries.clear();
}

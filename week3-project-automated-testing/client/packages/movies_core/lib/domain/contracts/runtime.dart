import 'dart:async';
import '../request/request_models.dart';

String normalizeQuery(String query) => query.trim();
int requirePositiveId(int value) {
  if (value <= 0) throw const FormatException('Invalid identifier');
  return value;
}

abstract interface class Clock {
  DateTime utcNow();
  Duration get elapsed;
}

class SystemClock implements Clock {
  final Stopwatch _watch = Stopwatch()..start();
  @override
  DateTime utcNow() => DateTime.now().toUtc();
  @override
  Duration get elapsed => _watch.elapsed;
}

class CancellationHandle {
  bool _cancelled = false;
  final List<void Function()> _listeners = [];
  bool get isCancelled => _cancelled;
  void onCancel(void Function() action) {
    if (_cancelled) {
      action();
    } else {
      _listeners.add(action);
    }
  }

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final action in _listeners) {
      action();
    }
    _listeners.clear();
  }
}

enum ReadPolicy { cacheFirst, refresh }

class CatalogReadOptions {
  const CatalogReadOptions({
    this.policy = ReadPolicy.cacheFirst,
    this.requestKey,
    this.cancellation,
  });
  final ReadPolicy policy;
  final RequestKey? requestKey;
  final CancellationHandle? cancellation;
}

typedef Schedule = Timer Function(Duration duration, void Function() action);

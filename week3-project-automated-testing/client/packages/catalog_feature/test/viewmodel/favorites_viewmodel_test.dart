import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';

class TestClock implements Clock {
  Duration now = Duration.zero;
  @override
  Duration get elapsed => now;
  @override
  DateTime utcNow() => DateTime.utc(2026, 1, 15).add(now);
}

class ManualTimer implements Timer {
  ManualTimer(this.due, this.callback);
  final Duration due;
  final void Function() callback;
  bool active = true;
  int count = 0;
  @override
  void cancel() {
    active = false;
  }

  @override
  bool get isActive => active;
  @override
  int get tick => count;
}

class Timers {
  Timers(this.clock);
  final TestClock clock;
  final List<ManualTimer> pending = [];
  Timer schedule(Duration delay, void Function() action) {
    final timer = ManualTimer(clock.now + delay, action);
    pending.add(timer);
    return timer;
  }

  void advance(Duration delta) {
    clock.now += delta;
    for (final timer in pending.toList()) {
      if (timer.active && timer.due <= clock.now) {
        timer.active = false;
        timer.count++;
        timer.callback();
      }
    }
  }
}

class PendingRepository implements FavoritesRepository {
  PendingRepository(this.entries, {this.failRead = false});
  final Map<int, FavoriteEntry> entries;
  bool failRead;
  final List<FavoriteWriteCommand> commands = [];
  final List<Completer<Outcome<PersistenceAck>>> completions = [];
  @override
  Future<Outcome<FavoritesBaseline>> readBaseline() async => failRead
      ? Outcome.failure(
          AppFailure(
            kind: FailureKind.storageRead,
            operation: 'read',
            occurredAtUtc: DateTime.utc(2026),
          ),
        )
      : Outcome.success(
          FavoritesBaseline(
            entries: entries.values.toList(),
            lastAddedOrder: entries.values.fold(
              0,
              (v, e) => v > e.addedOrder ? v : e.addedOrder,
            ),
          ),
        );
  @override
  Future<Outcome<PersistenceAck>> apply(FavoriteWriteCommand command) {
    commands.add(command);
    final c = Completer<Outcome<PersistenceAck>>();
    completions.add(c);
    return c.future;
  }

  void finish(int i, {bool fail = false}) {
    final cmd = commands[i];
    if (fail) {
      completions[i].complete(
        Outcome.failure(
          AppFailure(
            kind: FailureKind.storageWrite,
            operation: 'write',
            occurredAtUtc: DateTime.utc(2026),
            intentRevision: cmd.intentRevision,
          ),
        ),
      );
      return;
    }
    if (cmd.desiredEntry == null) {
      entries.remove(cmd.movieId);
    } else {
      entries[cmd.movieId] = cmd.desiredEntry!;
    }
    completions[i].complete(
      Outcome.success(
        PersistenceAck(
          intentRevision: cmd.intentRevision,
          movieId: cmd.movieId,
          storedEntry: cmd.desiredEntry,
          committedAtUtc: DateTime.utc(2026),
        ),
      ),
    );
  }
}

FavoriteEntry saved(int id, int order) => FavoriteEntry(
  movie: FavoriteMovieSnapshot(movieId: id, title: 'Movie $id'),
  addedOrder: order,
  addedAtUtc: DateTime.utc(2026),
);
Future<void> flush() => Future<void>.delayed(Duration.zero);

void main() {
  late TestClock clock;
  late Timers timers;
  late PendingRepository repository;
  late ProviderContainer container;
  Future<FavoritesViewModel> start({
    Map<int, FavoriteEntry>? initial,
    bool failRead = false,
  }) async {
    clock = TestClock();
    timers = Timers(clock);
    repository = PendingRepository(initial ?? {}, failRead: failRead);
    container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(clock),
        scheduleProvider.overrideWithValue(timers.schedule),
      ],
    );
    container.listen(favoritesViewModelProvider, (_, _) {});
    await flush();
    return container.read(favoritesViewModelProvider.notifier);
  }

  List<int> ids() => container
      .read(favoritesViewModelProvider)
      .entries
      .map((e) => e.movie.movieId)
      .toList();
  test('MOV-LIBRARY-001 add is optimistic, shared and idempotent', () async {
    final vm = await start();
    vm.addFavorite(const MovieSummary(id: 1, title: 'One'));
    vm.addFavorite(const MovieSummary(id: 1, title: 'One'));
    expect(ids(), [1]);
    expect(repository.commands.length, 1);
    expect(container.read(favoritesViewModelProvider).pending, isNotEmpty);
    repository.finish(0);
    await flush();
    expect(container.read(favoritesViewModelProvider).pending, isEmpty);
  });
  test(
    'MOV-LIBRARY-005 pending removal then Undo survives old acknowledgement',
    () async {
      final vm = await start(initial: {1: saved(1, 1), 2: saved(2, 2)});
      vm.removeFavorite(1);
      final token = container.read(favoritesViewModelProvider).undo!.token;
      expect(ids(), [2]);
      vm.undoRemoval(token);
      expect(ids(), [2, 1]);
      repository.finish(0);
      await flush();
      expect(ids(), [2, 1]);
      repository.finish(1);
      await flush();
      expect(ids(), [2, 1]);
    },
  );
  test(
    'MOV-LIBRARY-006 only latest offer works and background ends it',
    () async {
      final vm = await start(initial: {1: saved(1, 1), 2: saved(2, 2)});
      vm.removeFavorite(1);
      final old = container.read(favoritesViewModelProvider).undo!.token;
      vm.removeFavorite(2);
      vm.undoRemoval(old);
      expect(ids(), isEmpty);
      vm.onBackgrounded();
      expect(container.read(favoritesViewModelProvider).undo, isNull);
    },
  );
  test(
    'Undo has a fixed five-second deadline and cannot revive after expiry',
    () async {
      final vm = await start(initial: {1: saved(1, 1)});
      vm.removeFavorite(1);
      final token = container.read(favoritesViewModelProvider).undo!.token;
      timers.advance(const Duration(milliseconds: 4999));
      expect(container.read(favoritesViewModelProvider).undo, isNotNull);
      timers.advance(const Duration(milliseconds: 1));
      vm.undoRemoval(token);
      expect(ids(), isEmpty);
    },
  );
  test(
    'MOV-LIBRARY-007 failed remove preserves unrelated pending addition',
    () async {
      final vm = await start(initial: {1: saved(1, 1)});
      vm.addFavorite(const MovieSummary(id: 2, title: 'Two'));
      vm.removeFavorite(1);
      repository.finish(1, fail: true);
      await flush();
      expect(ids(), [2, 1]);
      expect(container.read(favoritesViewModelProvider).undo, isNull);
      repository.finish(0);
      await flush();
      expect(ids(), [2, 1]);
    },
  );
  test(
    'MOV-LIBRARY-008 failed read blocks mutation until successful Retry',
    () async {
      final vm = await start(initial: {1: saved(1, 1)}, failRead: true);
      vm.addFavorite(const MovieSummary(id: 2, title: 'Two'));
      expect(ids(), isEmpty);
      expect(repository.commands, isEmpty);
      repository.failRead = false;
      await vm.retryRead();
      expect(ids(), [1]);
    },
  );
  test('MOV-LIBRARY-011 failed add does not remain a saved favorite', () async {
    final vm = await start();
    vm.addFavorite(const MovieSummary(id: 1, title: 'One'));
    repository.finish(0, fail: true);
    await flush();
    expect(ids(), isEmpty);
    expect(
      container.read(favoritesViewModelProvider).writeFailures[1],
      isNotNull,
    );
  });
  test(
    'MOV-LIBRARY-012 failed restoration rolls back to committed removal',
    () async {
      final vm = await start(initial: {1: saved(1, 1)});
      vm.removeFavorite(1);
      final token = container.read(favoritesViewModelProvider).undo!.token;
      repository.finish(0);
      await flush();
      vm.undoRemoval(token);
      repository.finish(1, fail: true);
      await flush();
      expect(ids(), isEmpty);
    },
  );
  test(
    'write Retry is a fresh intent and cannot reverse a later explicit add',
    () async {
      final vm = await start(initial: {1: saved(1, 1)});
      vm.removeFavorite(1);
      repository.finish(0, fail: true);
      await flush();
      vm.retryFailedWrite(1);
      expect(ids(), isEmpty);
      expect(
        repository.commands[1].intentRevision,
        greaterThan(repository.commands[0].intentRevision),
      );
      vm.addFavorite(const MovieSummary(id: 1, title: 'One'));
      vm.retryFailedWrite(1);
      expect(ids(), [1]);
    },
  );
  test('Retry of failed add goes ahead of favorites saved afterward', () async {
    final vm = await start();
    vm.addFavorite(const MovieSummary(id: 1, title: 'One'));
    repository.finish(0, fail: true);
    await flush();
    vm.addFavorite(const MovieSummary(id: 2, title: 'Two'));
    repository.finish(1);
    await flush();
    vm.retryFailedWrite(1);
    expect(ids(), [1, 2]);
  });
}

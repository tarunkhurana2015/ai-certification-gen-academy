import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import '../providers/repository_providers.dart';
import '../state/favorites_state.dart';

final favoritesViewModelProvider =
    NotifierProvider<FavoritesViewModel, FavoritesState>(
      FavoritesViewModel.new,
    );

class FavoritesViewModel extends Notifier<FavoritesState> {
  late FavoritesRepository _repository;
  late Clock _clock;
  late Schedule _schedule;
  final Map<int, FavoriteEntry> _confirmed = {};
  final Map<int, int> _confirmedRevision = {};
  final Map<int, int> _latestIntent = {};
  final List<FavoriteWriteCommand> _pending = [];
  final Map<int, (FavoriteWriteCommand, String)> _failed = {};
  int _order = 0, _revision = 0, _readGeneration = 0;
  bool _alive = true;
  Timer? _timer;
  @override
  FavoritesState build() {
    _repository = ref.read(favoritesRepositoryProvider);
    _clock = ref.read(clockProvider);
    _schedule = ref.read(scheduleProvider);
    ref.onDispose(() {
      _alive = false;
      _timer?.cancel();
      _readGeneration++;
    });
    Future.microtask(retryRead);
    return const FavoritesState();
  }

  List<FavoriteEntry> _project() {
    final values = Map<int, FavoriteEntry>.of(_confirmed);
    for (final command in _pending) {
      if (command.desiredEntry == null) {
        values.remove(command.movieId);
      } else {
        values[command.movieId] = command.desiredEntry!;
      }
    }
    return values.values.toList()
      ..sort((a, b) => b.addedOrder.compareTo(a.addedOrder));
  }

  void _publish() {
    if (_alive)
      state = state.copyWith(
        entries: _project(),
        pending: List.of(_pending),
        loading: state.ready ? false : state.loading,
      );
  }

  Future<void> retryRead() async {
    final generation = ++_readGeneration;
    final revision = _revision;
    state = state.copyWith(loading: true, readFailure: null);
    final result = await _repository.readBaseline();
    if (!_alive || generation != _readGeneration || revision != _revision)
      return;
    switch (result) {
      case Success<FavoritesBaseline>(:final data):
        _confirmed
          ..clear()
          ..addEntries(data.entries.map((e) => MapEntry(e.movie.movieId, e)));
        if (data.lastAddedOrder > _order) _order = data.lastAddedOrder;
        state = state.copyWith(ready: true, loading: false, readFailure: null);
        _publish();
      case Failed<FavoritesBaseline>(:final error):
        state = state.copyWith(loading: false, readFailure: error);
      case Cancelled<FavoritesBaseline>():
        state = state.copyWith(loading: false);
    }
  }

  void addFavorite(MovieSummary movie) {
    if (!state.ready || state.contains(movie.id)) return;
    final snapshot = FavoriteMovieSnapshot(
      movieId: movie.id,
      title: movie.title,
      originalTitle: movie.originalTitle,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      releaseDate: movie.releaseDate,
      rating: movie.rating,
    );
    _dispatch(
      movie.id,
      FavoriteEntry(
        movie: snapshot,
        addedOrder: ++_order,
        addedAtUtc: _clock.utcNow(),
      ),
    );
  }

  void removeFavorite(int movieId) {
    if (!state.ready) return;
    final matches = state.entries.where((e) => e.movie.movieId == movieId);
    if (matches.isEmpty) return;
    final removed = matches.first;
    _clearUndo();
    final revision = _dispatch(movieId, null, kind: 'remove');
    final token = '$revision:$movieId';
    state = state.copyWith(
      undo: UndoOffer(
        token: token,
        entry: removed,
        removalRevision: revision,
        deadlineMs: _clock.elapsed.inMilliseconds + 5000,
      ),
    );
    _timer = _schedule(const Duration(seconds: 5), () {
      if (_alive && state.undo?.token == token) _clearUndo();
    });
  }

  void undoRemoval(String offerToken) {
    final offer = state.undo;
    if (offer == null || offer.token != offerToken) return;
    if (_clock.elapsed.inMilliseconds >= offer.deadlineMs) {
      _clearUndo();
      return;
    }
    if (_latestIntent[offer.entry.movie.movieId] != offer.removalRevision) {
      _clearUndo();
      return;
    }
    _clearUndo();
    _dispatch(offer.entry.movie.movieId, offer.entry, kind: 'restore');
  }

  bool canRetryWrite(int movieId) =>
      _failed[movieId] != null &&
      _latestIntent[movieId] == _failed[movieId]!.$1.intentRevision;
  String? failureTitle(int movieId) =>
      _failed[movieId]?.$1.desiredEntry?.movie.title ??
      _confirmed[movieId]?.movie.title;
  void retryFailedWrite(int movieId) {
    if (!state.ready || !canRetryWrite(movieId)) return;
    final failed = _failed[movieId]!;
    if (failed.$2 == 'remove') {
      removeFavorite(movieId);
    } else {
      final entry = failed.$1.desiredEntry;
      _dispatch(
        movieId,
        failed.$2 == 'add'
            ? entry?.copyWith(addedOrder: ++_order, addedAtUtc: _clock.utcNow())
            : entry,
        kind: failed.$2,
      );
    }
  }

  void onBackgrounded() => _clearUndo();
  void _clearUndo() {
    _timer?.cancel();
    _timer = null;
    if (_alive && state.undo != null) state = state.copyWith(undo: null);
  }

  int _dispatch(int movieId, FavoriteEntry? desired, {String kind = 'add'}) {
    if (state.undo?.entry.movie.movieId == movieId) _clearUndo();
    final revision = ++_revision;
    _failed.remove(movieId);
    _latestIntent[movieId] = revision;
    _readGeneration++;
    final command = FavoriteWriteCommand(
      intentRevision: revision,
      movieId: movieId,
      desiredEntry: desired,
    );
    _pending.add(command);
    final failures = Map<int, AppFailure>.of(state.writeFailures)
      ..remove(movieId);
    state = state.copyWith(writeFailures: failures);
    _publish();
    unawaited(_persist(command, kind));
    return revision;
  }

  Future<void> _persist(FavoriteWriteCommand command, String kind) async {
    Outcome<PersistenceAck> result;
    try {
      result = await _repository.apply(command);
    } catch (_) {
      result = Outcome.failure(
        AppFailure(
          kind: FailureKind.storageWrite,
          operation: 'favorites.write',
          occurredAtUtc: _clock.utcNow(),
          intentRevision: command.intentRevision,
        ),
      );
    }
    if (!_alive) return;
    _pending.removeWhere((c) => c.intentRevision == command.intentRevision);
    final failures = Map<int, AppFailure>.of(state.writeFailures);
    if (result case Success<PersistenceAck>(:final data)) {
      if (command.intentRevision >=
          (_confirmedRevision[command.movieId] ?? 0)) {
        _confirmedRevision[command.movieId] = command.intentRevision;
        if (data.storedEntry == null) {
          _confirmed.remove(command.movieId);
        } else {
          _confirmed[command.movieId] = data.storedEntry!;
        }
      }
      if ((failures[command.movieId]?.intentRevision ?? 0) <=
          command.intentRevision) {
        failures.remove(command.movieId);
        _failed.remove(command.movieId);
      }
    } else {
      failures[command.movieId] =
          (result.failureOrNull ??
                  AppFailure(
                    kind: FailureKind.storageWrite,
                    operation: 'favorites.write',
                    occurredAtUtc: _clock.utcNow(),
                  ))
              .copyWith(intentRevision: command.intentRevision);
      _failed[command.movieId] = (command, kind);
      if (state.undo?.removalRevision == command.intentRevision) _clearUndo();
    }
    state = state.copyWith(writeFailures: failures);
    _publish();
  }
}

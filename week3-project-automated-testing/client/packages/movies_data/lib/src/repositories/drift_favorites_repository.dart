import 'dart:async';
import 'package:drift/drift.dart';
import 'package:movies_core/movies_core.dart';
import '../database/movies_database.dart';

class DriftFavoritesRepository implements FavoritesRepository {
  DriftFavoritesRepository(this.database, {Clock? clock})
    : clock = clock ?? SystemClock();
  final MoviesDatabase database;
  final Clock clock;
  Future<void> _tail = Future.value();

  Future<Outcome<T>> _enqueue<T>(
    String operation,
    Future<T> Function() body, {
    int? revision,
  }) {
    final result = Completer<Outcome<T>>();
    _tail = _tail.then((_) async {
      try {
        result.complete(Outcome.success(await body()));
      } catch (error) {
        result.complete(
          Outcome.failure(
            AppFailure(
              kind: error is StorageMigrationException
                  ? FailureKind.storageMigration
                  : operation == 'favorites.read'
                  ? FailureKind.storageRead
                  : FailureKind.storageWrite,
              operation: operation,
              occurredAtUtc: clock.utcNow(),
              intentRevision: revision,
            ),
          ),
        );
      }
    });
    return result.future;
  }

  FavoriteEntry _entry(FavoriteRecord row) => FavoriteEntry(
    movie: FavoriteMovieSnapshot(
      movieId: requirePositiveId(row.movieId),
      title: row.title,
      originalTitle: row.originalTitle,
      posterPath: row.posterPath,
      backdropPath: row.backdropPath,
      releaseDate: row.releaseDate == null
          ? null
          : CalendarDate.fromIso(row.releaseDate!),
      rating: row.voteAverage == null
          ? null
          : TmdbRating(average: row.voteAverage!, voteCount: row.voteCount!),
    ),
    addedOrder: row.addedOrder,
    addedAtUtc: DateTime.fromMillisecondsSinceEpoch(
      row.addedAtUtc,
      isUtc: true,
    ),
  );

  @override
  Future<Outcome<FavoritesBaseline>> readBaseline() => _enqueue(
    'favorites.read',
    () => database.transaction(() async {
      final meta = await database.select(database.favoriteMeta).getSingle();
      final rows = await (database.select(
        database.favoriteRecords,
      )..orderBy([(t) => OrderingTerm.desc(t.addedOrder)])).get();
      if (meta.lastAddedOrder < 0 ||
          rows.any((r) => r.addedOrder > meta.lastAddedOrder))
        throw const FormatException('Invalid saved order');
      return FavoritesBaseline(
        entries: rows.map(_entry).toList(),
        lastAddedOrder: meta.lastAddedOrder,
      );
    }),
  );

  @override
  Future<Outcome<PersistenceAck>> apply(FavoriteWriteCommand command) =>
      _enqueue(
        'favorites.write',
        () => database.transaction(() async {
          requirePositiveId(command.movieId);
          final entry = command.desiredEntry;
          final meta = await database.select(database.favoriteMeta).getSingle();
          if (entry == null) {
            await (database.delete(
              database.favoriteRecords,
            )..where((t) => t.movieId.equals(command.movieId))).go();
          } else {
            if (entry.movie.movieId != command.movieId ||
                entry.addedOrder <= 0 ||
                entry.movie.title.trim().isEmpty)
              throw const FormatException('Invalid favorite');
            final m = entry.movie;
            await database
                .into(database.favoriteRecords)
                .insertOnConflictUpdate(
                  FavoriteRecordsCompanion(
                    movieId: Value(m.movieId),
                    title: Value(m.title),
                    originalTitle: Value(m.originalTitle),
                    posterPath: Value(m.posterPath),
                    backdropPath: Value(m.backdropPath),
                    releaseDate: Value(m.releaseDate?.iso),
                    voteAverage: Value(m.rating?.average),
                    voteCount: Value(m.rating?.voteCount),
                    addedOrder: Value(entry.addedOrder),
                    addedAtUtc: Value(
                      entry.addedAtUtc.toUtc().millisecondsSinceEpoch,
                    ),
                  ),
                );
            if (entry.addedOrder > meta.lastAddedOrder) {
              await (database.update(
                database.favoriteMeta,
              )..where((t) => t.singletonId.equals(1))).write(
                FavoriteMetaCompanion(lastAddedOrder: Value(entry.addedOrder)),
              );
            }
          }
          return PersistenceAck(
            intentRevision: command.intentRevision,
            movieId: command.movieId,
            storedEntry: entry,
            committedAtUtc: clock.utcNow(),
          );
        }),
        revision: command.intentRevision,
      );
}

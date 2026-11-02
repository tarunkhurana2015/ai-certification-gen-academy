import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';

FavoriteEntry entry(int id, int order) => FavoriteEntry(
  movie: FavoriteMovieSnapshot(movieId: id, title: 'Movie $id'),
  addedOrder: order,
  addedAtUtc: DateTime.utc(2026, 1, 15),
);
void main() {
  late MoviesDatabase db;
  late DriftFavoritesRepository repository;
  setUp(() {
    db = MoviesDatabase(NativeDatabase.memory());
    repository = DriftFavoritesRepository(db);
  });
  tearDown(() async {
    await db.close();
  });
  test(
    'highest removed order is not reused; Undo restores prior position',
    () async {
      expect((await repository.readBaseline()).dataOrNull!.lastAddedOrder, 0);
      await repository.apply(
        FavoriteWriteCommand(
          intentRevision: 1,
          movieId: 1,
          desiredEntry: entry(1, 1),
        ),
      );
      await repository.apply(
        const FavoriteWriteCommand(intentRevision: 2, movieId: 1),
      );
      await repository.apply(
        FavoriteWriteCommand(
          intentRevision: 3,
          movieId: 2,
          desiredEntry: entry(2, 2),
        ),
      );
      await repository.apply(
        FavoriteWriteCommand(
          intentRevision: 4,
          movieId: 1,
          desiredEntry: entry(1, 1),
        ),
      );
      final baseline = (await repository.readBaseline()).dataOrNull!;
      expect(baseline.entries.map((e) => e.movie.movieId), [2, 1]);
      expect(baseline.lastAddedOrder, 2);
    },
  );
  test(
    'queued desired state writes and baseline reads preserve FIFO',
    () async {
      final a = repository.apply(
        FavoriteWriteCommand(
          intentRevision: 1,
          movieId: 1,
          desiredEntry: entry(1, 1),
        ),
      );
      final b = repository.apply(
        const FavoriteWriteCommand(intentRevision: 2, movieId: 1),
      );
      final c = repository.apply(
        FavoriteWriteCommand(
          intentRevision: 3,
          movieId: 1,
          desiredEntry: entry(1, 1),
        ),
      );
      expect(
        (await Future.wait([a, b, c])).map((a) => a.dataOrNull!.intentRevision),
        [1, 2, 3],
      );
      expect(
        (await repository.readBaseline())
            .dataOrNull!
            .entries
            .single
            .movie
            .movieId,
        1,
      );
    },
  );
  test('constraint failure rolls back row and metadata atomically', () async {
    await repository.apply(
      FavoriteWriteCommand(
        intentRevision: 1,
        movieId: 1,
        desiredEntry: entry(1, 1),
      ),
    );
    final failed = await repository.apply(
      FavoriteWriteCommand(
        intentRevision: 2,
        movieId: 2,
        desiredEntry: entry(2, 1),
      ),
    );
    expect(failed.failureOrNull!.kind, FailureKind.storageWrite);
    final baseline = (await repository.readBaseline()).dataOrNull!;
    expect(baseline.entries.length, 1);
    expect(baseline.lastAddedOrder, 1);
  });
  test(
    'missing metadata fails without silently clearing saved movies',
    () async {
      await repository.apply(
        FavoriteWriteCommand(
          intentRevision: 1,
          movieId: 1,
          desiredEntry: entry(1, 1),
        ),
      );
      await db.customStatement('DELETE FROM favorites_meta');
      expect(
        (await repository.readBaseline()).failureOrNull!.kind,
        FailureKind.storageRead,
      );
      expect((await db.select(db.favoriteRecords).get()).length, 1);
    },
  );
}

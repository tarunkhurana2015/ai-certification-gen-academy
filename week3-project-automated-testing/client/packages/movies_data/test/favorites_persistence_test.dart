import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';

void main() {
  for (final restore in [false, true]) {
    test(
      '${restore ? 'MOV-LIBRARY-010' : 'MOV-LIBRARY-004'} saved ${restore ? 'Undo restoration' : 'removal'} survives file reopen',
      () async {
        final dir = await Directory.systemTemp.createTemp(
          'movies-restore-test-',
        );
        final file = File('${dir.path}/library.sqlite');
        var db = MoviesDatabase(NativeDatabase(file));
        var repo = DriftFavoritesRepository(db);
        final saved = FavoriteEntry(
          movie: const FavoriteMovieSnapshot(
            movieId: 900001,
            title: 'Northbound',
          ),
          addedOrder: 4,
          addedAtUtc: DateTime.utc(2026),
        );
        expect(
          (await repo.apply(
            FavoriteWriteCommand(
              intentRevision: 1,
              movieId: 900001,
              desiredEntry: saved,
            ),
          )).failureOrNull,
          isNull,
        );
        expect(
          (await repo.apply(
            const FavoriteWriteCommand(intentRevision: 2, movieId: 900001),
          )).failureOrNull,
          isNull,
        );
        if (restore)
          expect(
            (await repo.apply(
              FavoriteWriteCommand(
                intentRevision: 3,
                movieId: 900001,
                desiredEntry: saved,
              ),
            )).failureOrNull,
            isNull,
          );
        await db.close();
        db = MoviesDatabase(NativeDatabase(file));
        repo = DriftFavoritesRepository(db);
        final baseline = (await repo.readBaseline()).dataOrNull!;
        expect(
          baseline.entries.map((e) => e.movie.movieId),
          restore ? [900001] : isEmpty,
        );
        expect(baseline.lastAddedOrder, 4);
        if (restore) expect(baseline.entries.single.addedOrder, 4);
        await db.close();
        await dir.delete(recursive: true);
      },
    );
  }

  test(
    'MOV-LIBRARY-002 acknowledged favorite and high-water survive a file reopen',
    () async {
      final dir = await Directory.systemTemp.createTemp('movies-db-test-');
      final file = File('${dir.path}/library.sqlite');
      var db = MoviesDatabase(NativeDatabase(file));
      var repo = DriftFavoritesRepository(db);
      final saved = await repo.apply(
        FavoriteWriteCommand(
          intentRevision: 1,
          movieId: 900001,
          desiredEntry: FavoriteEntry(
            movie: const FavoriteMovieSnapshot(
              movieId: 900001,
              title: 'Northbound',
            ),
            addedOrder: 3,
            addedAtUtc: DateTime.utc(2026, 1, 15),
          ),
        ),
      );
      expect(saved.failureOrNull, isNull);
      await db.close();
      db = MoviesDatabase(NativeDatabase(file));
      repo = DriftFavoritesRepository(db);
      final baseline = (await repo.readBaseline()).dataOrNull!;
      expect(baseline.entries.single.movie.title, 'Northbound');
      expect(baseline.lastAddedOrder, 3);
      await db.close();
      await dir.delete(recursive: true);
    },
  );
}

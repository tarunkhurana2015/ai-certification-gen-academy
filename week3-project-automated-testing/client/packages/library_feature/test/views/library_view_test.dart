import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:library_feature/presentation/views/library_view.dart';

class MemoryFavorites implements FavoritesRepository {
  bool failRead = false;
  final Map<int, FavoriteEntry> entries = {
    900001: FavoriteEntry(
      movie: const FavoriteMovieSnapshot(movieId: 900001, title: 'Northbound'),
      addedOrder: 1,
      addedAtUtc: DateTime.utc(2026),
    ),
  };
  @override
  Future<Outcome<FavoritesBaseline>> readBaseline() async => failRead
      ? Outcome.failure(
          AppFailure(
            kind: FailureKind.storageRead,
            operation: 'favorites.read',
            occurredAtUtc: DateTime.utc(2026),
          ),
        )
      : Outcome.success(
          FavoritesBaseline(
            entries: entries.values.toList(),
            lastAddedOrder: 1,
          ),
        );
  @override
  Future<Outcome<PersistenceAck>> apply(FavoriteWriteCommand c) async {
    if (c.desiredEntry == null) {
      entries.remove(c.movieId);
    } else {
      entries[c.movieId] = c.desiredEntry!;
    }
    return Outcome.success(
      PersistenceAck(
        intentRevision: c.intentRevision,
        movieId: c.movieId,
        storedEntry: c.desiredEntry,
        committedAtUtc: DateTime.utc(2026),
      ),
    );
  }
}

void main() {
  testWidgets(
    'MOV-LIBRARY-008 read Retry recovers the saved Library through its ViewModel',
    (tester) async {
      final repository = MemoryFavorites()..failRead = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoritesRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(home: Scaffold(body: LibraryView())),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Your Library could not be loaded. Saved movies have not been cleared.',
        ),
        findsOneWidget,
      );
      expect(find.text('Northbound'), findsNothing);
      repository.failRead = false;
      await tester.tap(
        find.byKey(const ValueKey('movies.library.favorites.retry')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Northbound'), findsOneWidget);
    },
  );
  testWidgets(
    'MOV-LIBRARY-003 removal updates Library and global Undo restores it',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            favoritesRepositoryProvider.overrideWithValue(MemoryFavorites()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  Expanded(child: LibraryView()),
                  UndoBanner(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Northbound'), findsOneWidget);
      await tester.tap(
        find.byKey(
          const ValueKey('movies.library.favorites.movie.900001.remove'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Northbound'), findsNothing);
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Northbound'), findsOneWidget);
    },
  );
}

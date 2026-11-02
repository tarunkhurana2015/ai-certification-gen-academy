import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';

class EmptyFavorites extends Fake implements FavoritesRepository {
  @override
  Future<Outcome<FavoritesBaseline>> readBaseline() async =>
      const Outcome.success(FavoritesBaseline(entries: [], lastAddedOrder: 0));
}

void main() {
  testWidgets(
    'MOV-RECOVERY-004 rate-limited continuation has one disabled recovery action',
    (tester) async {
      var calls = 0;
      const source = RequestKey(mode: 'fixture', operation: 'popular', page: 1);
      final state = MovieListingState(
        items: const [MovieSummary(id: 1, title: 'Northbound')],
        requested: source,
        displayed: source,
        page: 1,
        totalPages: 2,
        continuationError: AppFailure(
          kind: FailureKind.rateLimited,
          operation: 'popular',
          occurredAtUtc: DateTime.now().toUtc(),
          retryNotBeforeUtc: DateTime.now().toUtc().add(
            const Duration(minutes: 1),
          ),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            favoritesRepositoryProvider.overrideWithValue(EmptyFavorites()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MovieListing(
                  state: state,
                  branch: 'browse',
                  identifier: 'results',
                  onRetry: () => calls++,
                  onLoadMore: () => calls++,
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey('results.load_more')), findsNothing);
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('results.continuation.retry')),
            )
            .onPressed,
        isNull,
      );
      expect(calls, 0);
      expect(find.text('No movies were found.'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';

PageResult<MovieSummary> page(String query, int number, {int total = 1}) =>
    PageResult(
      items: [MovieSummary(id: number, title: query)],
      page: number,
      totalPages: total,
      totalResults: total,
      requestKey: RequestKey(
        mode: 'fixture',
        operation: 'search',
        query: query,
        page: number,
      ),
    );
void main() {
  test('obsolete success and failure cannot replace a newer source', () async {
    final values = <MovieListingState>[];
    final session = MovieListingSession(
      clock: SystemClock(),
      onChanged: values.add,
    );
    addTearDown(session.dispose);
    final a = Completer<Outcome<PageResult<MovieSummary>>>();
    final b = Completer<Outcome<PageResult<MovieSummary>>>();
    final first = session.load(
      const RequestKey(mode: 'fixture', operation: 'search', query: 'A'),
      (p, o) => a.future,
      label: 'Results for A',
    );
    final second = session.load(
      const RequestKey(mode: 'fixture', operation: 'search', query: 'B'),
      (p, o) => b.future,
      label: 'Results for B',
    );
    b.complete(Outcome.success(page('B', 1)));
    await second;
    a.complete(
      Outcome.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: 'search',
          occurredAtUtc: DateTime.utc(2026),
        ),
      ),
    );
    await first;
    expect(session.state.items.single.title, 'B');
    expect(session.state.error, isNull);
    expect(session.state.displayedLabel, 'Results for B');
  });
  test(
    'a failed new query retains the old source and its continuation',
    () async {
      final session = MovieListingSession(
        clock: SystemClock(),
        onChanged: (_) {},
      );
      addTearDown(session.dispose);
      await session.load(
        const RequestKey(mode: 'fixture', operation: 'search', query: 'A'),
        (p, o) async => Outcome.success(page('A', p, total: 2)),
        label: 'Results for A',
      );
      await session.load(
        const RequestKey(mode: 'fixture', operation: 'search', query: 'B'),
        (p, o) async => Outcome.failure(
          AppFailure(
            kind: FailureKind.network,
            operation: 'search',
            occurredAtUtc: DateTime.utc(2026),
          ),
        ),
        label: 'Results for B',
      );
      await session.loadMore();
      expect(session.state.items.map((m) => m.title), ['A', 'A']);
      expect(session.state.displayed!.query, 'A');
      expect(session.state.requested!.query, 'B');
      expect(session.state.error, isNotNull);
    },
  );
}

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:search_feature/presentation/viewmodel/search_viewmodel.dart';

class Movies extends Fake implements MovieRepository {
  int pages = 1;
  final calls = <String>[];
  final pending = <String, Completer<Outcome<PageResult<MovieSummary>>>>{};
  @override
  Future<Outcome<PageResult<MovieSummary>>> searchMovies(
    String query,
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) async {
    calls.add(query);
    if (pending.containsKey('$query:$page'))
      return pending['$query:$page']!.future;
    if (pending.containsKey(query)) return pending[query]!.future;
    return Outcome.success(
      PageResult(
        items: [MovieSummary(id: 1, title: query)],
        page: page,
        totalPages: pages,
        totalResults: 1,
        requestKey: RequestKey(
          mode: 'fixture',
          operation: 'search',
          query: query,
          page: page,
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'resubmitting an unchanged empty-result query ends debounce without duplicate request',
    (tester) async {
      final data = Movies();
      data.pending['A'] = Completer()
        ..complete(
          const Outcome.success(
            PageResult(
              items: [],
              page: 1,
              totalPages: 0,
              totalResults: 0,
              requestKey: RequestKey(
                mode: 'fixture',
                operation: 'search',
                query: 'A',
                page: 1,
              ),
            ),
          ),
        );
      final c = ProviderContainer(
        overrides: [movieRepositoryProvider.overrideWithValue(data)],
      );
      addTearDown(c.dispose);
      final vm = c.read(searchViewModelProvider.notifier);
      vm.edit('A');
      await vm.submit();
      vm.edit('A ');
      await vm.submit();
      expect(data.calls, ['A']);
      expect(c.read(searchViewModelProvider).debouncing, false);
    },
  );

  testWidgets('MOV-SEARCH-001 waits exactly 350 milliseconds', (tester) async {
    final data = Movies();
    final c = ProviderContainer(
      overrides: [movieRepositoryProvider.overrideWithValue(data)],
    );
    addTearDown(c.dispose);
    final vm = c.read(searchViewModelProvider.notifier);
    vm.edit('  Northbound  ');
    await tester.pump(const Duration(milliseconds: 349));
    expect(data.calls, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(data.calls, ['Northbound']);
  });
  testWidgets(
    'MOV-SEARCH-003 submit consumes pending debounce and Clear cancels',
    (tester) async {
      final data = Movies();
      final c = ProviderContainer(
        overrides: [movieRepositoryProvider.overrideWithValue(data)],
      );
      addTearDown(c.dispose);
      final vm = c.read(searchViewModelProvider.notifier);
      vm.edit('A');
      await vm.submit();
      await tester.pump(const Duration(seconds: 1));
      expect(data.calls, ['A']);
      vm.edit('B');
      vm.clear();
      await tester.pump(const Duration(seconds: 1));
      expect(data.calls, ['A']);
      expect(c.read(searchViewModelProvider).query, '');
      expect(c.read(searchViewModelProvider).listing.items, isEmpty);
    },
  );
  testWidgets('MOV-SEARCH-002 an edit resets the debounce', (tester) async {
    final data = Movies();
    final c = ProviderContainer(
      overrides: [movieRepositoryProvider.overrideWithValue(data)],
    );
    addTearDown(c.dispose);
    final vm = c.read(searchViewModelProvider.notifier);
    vm.edit('A');
    await tester.pump(const Duration(milliseconds: 300));
    vm.edit('B');
    await tester.pump(const Duration(milliseconds: 349));
    expect(data.calls, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    expect(data.calls, ['B']);
  });
  for (final failure in [false, true]) {
    testWidgets(
      'MOV-SEARCH-004 stale ${failure ? 'failure' : 'success'} is ignored',
      (tester) async {
        final data = Movies();
        final old = Completer<Outcome<PageResult<MovieSummary>>>();
        data.pending['A'] = old;
        final c = ProviderContainer(
          overrides: [movieRepositoryProvider.overrideWithValue(data)],
        );
        addTearDown(c.dispose);
        final vm = c.read(searchViewModelProvider.notifier);
        vm.edit('A');
        await tester.pump(const Duration(milliseconds: 350));
        vm.edit('B');
        await tester.pump(const Duration(milliseconds: 350));
        old.complete(
          failure
              ? Outcome.failure(
                  AppFailure(
                    kind: FailureKind.network,
                    operation: 'search',
                    occurredAtUtc: DateTime.utc(2026),
                  ),
                )
              : const Outcome.success(
                  PageResult(
                    items: [MovieSummary(id: 2, title: 'A')],
                    page: 1,
                    totalPages: 1,
                    totalResults: 1,
                    requestKey: RequestKey(
                      mode: 'fixture',
                      operation: 'search',
                      query: 'A',
                    ),
                  ),
                ),
        );
        await tester.pump();
        expect(c.read(searchViewModelProvider).listing.items.single.title, 'B');
        expect(c.read(searchViewModelProvider).listing.error, isNull);
      },
    );
  }
  testWidgets('MOV-SEARCH-005 Clear ignores an in-flight completion', (
    tester,
  ) async {
    final data = Movies();
    final old = Completer<Outcome<PageResult<MovieSummary>>>();
    data.pending['A'] = old;
    final c = ProviderContainer(
      overrides: [movieRepositoryProvider.overrideWithValue(data)],
    );
    addTearDown(c.dispose);
    final vm = c.read(searchViewModelProvider.notifier);
    vm.edit('A');
    await tester.pump(const Duration(milliseconds: 350));
    vm.clear();
    old.complete(
      Outcome.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: 'search',
          occurredAtUtc: DateTime.utc(2026),
        ),
      ),
    );
    await tester.pump();
    expect(c.read(searchViewModelProvider).listing.error, isNull);
    expect(c.read(searchViewModelProvider).query, isEmpty);
  });
  for (final oldFailure in [false, true]) {
    testWidgets(
      'MOV-SEARCH-009 old continuation ${oldFailure ? 'failure' : 'success'} cannot change a replacement query',
      (tester) async {
        final data = Movies()..pages = 2;
        final old = Completer<Outcome<PageResult<MovieSummary>>>();
        data.pending['A:2'] = old;
        final container = ProviderContainer(
          overrides: [movieRepositoryProvider.overrideWithValue(data)],
        );
        addTearDown(container.dispose);
        final vm = container.read(searchViewModelProvider.notifier);
        vm.edit('A');
        await vm.submit();
        final more = vm.loadMore();
        vm.edit('B');
        await vm.submit();
        old.complete(
          oldFailure
              ? Outcome.failure(
                  AppFailure(
                    kind: FailureKind.network,
                    operation: 'search',
                    occurredAtUtc: DateTime.utc(2026),
                  ),
                )
              : const Outcome.success(
                  PageResult(
                    items: [MovieSummary(id: 2, title: 'A second page')],
                    page: 2,
                    totalPages: 2,
                    totalResults: 2,
                    requestKey: RequestKey(
                      mode: 'fixture',
                      operation: 'search',
                      query: 'A',
                      page: 2,
                    ),
                  ),
                ),
        );
        await more;
        await tester.pump();
        final state = container.read(searchViewModelProvider).listing;
        expect(state.items.single.title, 'B');
        expect(state.error, isNull);
        expect(state.continuationError, isNull);
        expect(state.page, 1);
      },
    );
  }
  testWidgets(
    'MOV-SEARCH-003 a second explicit submit does not duplicate an active query',
    (tester) async {
      final data = Movies();
      final pending = Completer<Outcome<PageResult<MovieSummary>>>();
      data.pending['A'] = pending;
      final container = ProviderContainer(
        overrides: [movieRepositoryProvider.overrideWithValue(data)],
      );
      addTearDown(container.dispose);
      final vm = container.read(searchViewModelProvider.notifier);
      vm.edit('A');
      final first = vm.submit();
      await vm.submit();
      expect(data.calls, ['A']);
      pending.complete(
        const Outcome.success(
          PageResult(
            items: [],
            page: 1,
            totalPages: 0,
            totalResults: 0,
            requestKey: RequestKey(
              mode: 'fixture',
              operation: 'search',
              query: 'A',
            ),
          ),
        ),
      );
      await first;
      vm.edit('   ');
      await vm.submit();
      expect(container.read(searchViewModelProvider).query, '');
      expect(data.calls, ['A']);
    },
  );
}

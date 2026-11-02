import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:browse_feature/presentation/viewmodel/browse_viewmodel.dart';
import 'package:browse_feature/presentation/state/browse_state.dart';

class Discovery extends Fake implements DiscoveryRepository {
  final calls = <String>[];
  Future<Outcome<PageResult<MovieSummary>>> Function(String, int)? response;
  Future<Outcome<PageResult<MovieSummary>>> read(
    String category,
    int page,
  ) async {
    calls.add('$category:$page');
    if (response != null) return response!(category, page);
    return Outcome.success(
      PageResult(
        items: [MovieSummary(id: page, title: category)],
        page: page,
        totalPages: 2,
        totalResults: 2,
        requestKey: RequestKey(
          mode: 'fixture',
          operation: category,
          page: page,
        ),
      ),
    );
  }

  @override
  Future<Outcome<PageResult<MovieSummary>>> getPopular(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => read('popular', page);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getTopRated(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => read('top_rated', page);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getNowPlaying(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => read('now_playing', page);
  @override
  Future<Outcome<PageResult<MovieSummary>>> getUpcoming(
    int page, {
    CatalogReadOptions options = const CatalogReadOptions(),
  }) => read('upcoming', page);
}

void main() {
  for (final fail in [false, true]) {
    test(
      'MOV-BROWSE-004 late Popular continuation ${fail ? 'failure' : 'success'} cannot change Top Rated',
      () async {
        final pending = Completer<Outcome<PageResult<MovieSummary>>>();
        final data = Discovery();
        final c = ProviderContainer(
          overrides: [discoveryRepositoryProvider.overrideWithValue(data)],
        );
        addTearDown(c.dispose);
        c.read(browseViewModelProvider);
        await Future<void>.delayed(Duration.zero);
        final vm = c.read(browseViewModelProvider.notifier);
        await vm.select(BrowseCategory.popular);
        data.response = (category, page) async => category == 'popular'
            ? pending.future
            : Outcome.success(
                PageResult(
                  items: [MovieSummary(id: 88, title: category)],
                  page: page,
                  totalPages: 1,
                  totalResults: 1,
                  requestKey: RequestKey(
                    mode: 'fixture',
                    operation: category,
                    page: page,
                  ),
                ),
              );
        final old = vm.loadMore();
        await vm.select(BrowseCategory.topRated);
        pending.complete(
          fail
              ? Outcome.failure(
                  AppFailure(
                    kind: FailureKind.network,
                    operation: 'popular',
                    occurredAtUtc: DateTime.utc(2026),
                  ),
                )
              : Outcome.success(
                  const PageResult(
                    items: [MovieSummary(id: 99, title: 'obsolete')],
                    page: 2,
                    totalPages: 2,
                    totalResults: 2,
                    requestKey: RequestKey(
                      mode: 'fixture',
                      operation: 'popular',
                      page: 2,
                    ),
                  ),
                ),
        );
        await old;
        expect(
          c.read(browseViewModelProvider).category,
          BrowseCategory.topRated,
        );
        expect(
          c.read(browseViewModelProvider).listing.items.single.title,
          'top_rated',
        );
        expect(
          c.read(browseViewModelProvider).listing.continuationError,
          isNull,
        );
      },
    );
  }
  test(
    'MOV-BROWSE-003 continuation failure retains page and retries exactly the failed cursor',
    () async {
      final data = Discovery();
      final c = ProviderContainer(
        overrides: [discoveryRepositoryProvider.overrideWithValue(data)],
      );
      addTearDown(c.dispose);
      c.read(browseViewModelProvider);
      await Future<void>.delayed(Duration.zero);
      final vm = c.read(browseViewModelProvider.notifier);
      data.response = (category, page) async => Outcome.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: category,
          occurredAtUtc: DateTime.utc(2026),
        ),
      );
      await vm.loadMore();
      expect(c.read(browseViewModelProvider).listing.items.single.id, 1);
      expect(c.read(browseViewModelProvider).listing.page, 1);
      expect(
        c.read(browseViewModelProvider).listing.continuationError,
        isNotNull,
      );
      data.response = null;
      await vm.loadMore();
      expect(c.read(browseViewModelProvider).listing.items.map((m) => m.id), [
        1,
        2,
      ]);
      expect(data.calls, ['now_playing:1', 'now_playing:2', 'now_playing:2']);
    },
  );

  test(
    'MOV-BROWSE-001 defaults to Now Playing and isolates Upcoming',
    () async {
      final data = Discovery();
      final c = ProviderContainer(
        overrides: [discoveryRepositoryProvider.overrideWithValue(data)],
      );
      addTearDown(c.dispose);
      c.read(browseViewModelProvider);
      await Future<void>.delayed(Duration.zero);
      expect(
        c.read(browseViewModelProvider).listing.items.single.title,
        'now_playing',
      );
      await c
          .read(browseViewModelProvider.notifier)
          .select(BrowseCategory.upcoming);
      expect(
        c.read(browseViewModelProvider).listing.displayedLabel,
        'Upcoming',
      );
      expect(
        c.read(browseViewModelProvider).listing.items.single.title,
        'upcoming',
      );
    },
  );
  test('MOV-BROWSE-002 continuation is guarded and exhausts', () async {
    final data = Discovery();
    final c = ProviderContainer(
      overrides: [discoveryRepositoryProvider.overrideWithValue(data)],
    );
    addTearDown(c.dispose);
    c.read(browseViewModelProvider);
    await Future<void>.delayed(Duration.zero);
    final vm = c.read(browseViewModelProvider.notifier);
    await Future.wait([vm.loadMore(), vm.loadMore()]);
    await vm.loadMore();
    expect(data.calls, ['now_playing:1', 'now_playing:2']);
    expect(c.read(browseViewModelProvider).listing.canLoadMore, false);
  });
}

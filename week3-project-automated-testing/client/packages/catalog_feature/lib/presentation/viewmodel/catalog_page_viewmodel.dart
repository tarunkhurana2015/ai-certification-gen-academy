import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import '../providers/repository_providers.dart';
import '../state/catalog_page_state.dart';

final catalogPageProvider = NotifierProvider.autoDispose
    .family<CatalogPageViewModel, CatalogPageState, CatalogIdentity>(
      CatalogPageViewModel.new,
    );

class CatalogPageViewModel extends Notifier<CatalogPageState> {
  CatalogPageViewModel(this.identity);
  final CatalogIdentity identity;
  int _generation = 0;
  bool _alive = true;
  late Clock _clock;
  CancellationHandle? _cancel, _moreCancel;
  @override
  CatalogPageState build() {
    _clock = ref.read(clockProvider);
    ref.onDispose(() {
      _alive = false;
      _generation++;
      _cancel?.cancel();
      _moreCancel?.cancel();
    });
    Future.microtask(load);
    return const CatalogPageState();
  }

  RequestKey _key(int page) => RequestKey(
    mode: ref.read(catalogModeProvider),
    operation: identity.kind.name,
    entityId: identity.id,
    page: page,
    filters: const {'adultPolicy': 'excludeFlagged-v1'},
  );
  Future<Outcome<CatalogPayload>> _wrap<T>(Future<Outcome<T>> future) async =>
      switch (await future) {
        Success<T>(:final data) => Outcome.success(CatalogValue<T>(data)),
        Failed<T>(:final error) => Outcome.failure(error),
        Cancelled<T>() => const Outcome.cancelled(),
      };
  Future<Outcome<CatalogPayload>> _fetch(int page, CatalogReadOptions options) {
    if (identity.id <= 0)
      return Future.value(
        Outcome.failure(
          AppFailure(
            kind: FailureKind.invalidRequest,
            operation: identity.kind.name,
            occurredAtUtc: _clock.utcNow(),
            retryAllowed: false,
          ),
        ),
      );
    final id = identity.id;
    return switch (identity.kind) {
      CatalogKind.movie => _wrap(
        ref.read(movieRepositoryProvider).getMovie(id, options: options),
      ),
      CatalogKind.cast => _wrap(
        ref.read(movieRepositoryProvider).getCredits(id, options: options),
      ),
      CatalogKind.person => _wrap(
        ref.read(personRepositoryProvider).getPerson(id, options: options),
      ),
      CatalogKind.filmography => _wrap(
        ref.read(personRepositoryProvider).getFilmography(id, options: options),
      ),
      CatalogKind.collection => _wrap(
        ref.read(movieRepositoryProvider).getCollection(id, options: options),
      ),
      CatalogKind.related => _wrap(
        ref
            .read(movieRepositoryProvider)
            .getRelatedMovies(id, page, options: options),
      ),
      CatalogKind.movieImages => _wrap(
        ref.read(movieRepositoryProvider).getImages(id, options: options),
      ),
      CatalogKind.personImages => _wrap(
        ref.read(personRepositoryProvider).getImages(id, options: options),
      ),
      CatalogKind.reviews => _wrap(
        ref
            .read(movieRepositoryProvider)
            .getReviews(id, page, options: options),
      ),
      CatalogKind.trailers => _wrap(
        ref.read(movieRepositoryProvider).getTrailers(id, options: options),
      ),
    };
  }

  Future<void> load({bool refresh = false}) async {
    if (!_alive) return;
    final generation = ++_generation;
    _cancel?.cancel();
    _moreCancel?.cancel();
    final cancel = CancellationHandle();
    _cancel = cancel;
    final key = _key(1);
    final old = state;
    state = CatalogPageState(
      data: old.data,
      requested: key,
      displayed: old.displayed,
      loading: true,
    );
    Outcome<CatalogPayload> result;
    try {
      result = await _fetch(
        1,
        CatalogReadOptions(
          policy: refresh ? ReadPolicy.refresh : ReadPolicy.cacheFirst,
          requestKey: key,
          cancellation: cancel,
        ),
      );
    } catch (_) {
      result = Outcome<CatalogPayload>.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: identity.kind.name,
          occurredAtUtc: _clock.utcNow(),
        ),
      );
    }
    if (!_alive || generation != _generation || cancel.isCancelled) return;
    if (result case Success<CatalogPayload>(:final data)) {
      state = CatalogPageState(
        data: data,
        requested: key,
        displayed: key,
        loading: false,
      );
    } else {
      state = CatalogPageState(
        data: old.data,
        requested: key,
        displayed: old.displayed,
        loading: false,
        error: result.failureOrNull,
      );
    }
  }

  Future<void> loadMore() async {
    if (!_alive || state.loading || state.loadingMore || !state.canLoadMore)
      return;
    final previous = state;
    final generation = _generation;
    final page = switch (previous.data) {
      CatalogValue<PageResult<MovieSummary>>(:final value) => value.page + 1,
      CatalogValue<PageResult<MovieReview>>(:final value) => value.page + 1,
      _ => 1,
    };
    final cancel = CancellationHandle();
    _moreCancel = cancel;
    final key = _key(page);
    state = CatalogPageState(
      data: previous.data,
      requested: previous.requested,
      displayed: previous.displayed,
      loading: false,
      error: previous.error,
      loadingMore: true,
    );
    Outcome<CatalogPayload> result;
    try {
      result = await _fetch(
        page,
        CatalogReadOptions(requestKey: key, cancellation: cancel),
      );
    } catch (_) {
      result = Outcome<CatalogPayload>.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: identity.kind.name,
          occurredAtUtc: _clock.utcNow(),
          requestKey: key,
        ),
      );
    }
    if (result case Success<CatalogPayload>(:final data)) {
      final valid = switch (data) {
        CatalogValue<PageResult<MovieSummary>>(:final value) =>
          value.page == page &&
              value.requestKey.entityId == identity.id &&
              value.requestKey.operation == identity.kind.name,
        CatalogValue<PageResult<MovieReview>>(:final value) =>
          value.page == page &&
              value.requestKey.entityId == identity.id &&
              value.requestKey.operation == identity.kind.name,
        _ => false,
      };
      if (!valid)
        result = Outcome<CatalogPayload>.failure(
          AppFailure(
            kind: FailureKind.invalidData,
            operation: identity.kind.name,
            occurredAtUtc: _clock.utcNow(),
            requestKey: key,
          ),
        );
    }
    if (!_alive || generation != _generation || cancel.isCancelled) return;
    if (result case Success<CatalogPayload>(:final data)) {
      CatalogPayload merged = data;
      if (previous.data case CatalogValue<PageResult<MovieSummary>>(
        :final value,
      )) {
        final next = (data as CatalogValue<PageResult<MovieSummary>>).value;
        final items = {for (final m in value.items) m.id: m};
        for (final m in next.items) {
          items.putIfAbsent(m.id, () => m);
        }
        merged = CatalogValue(next.copyWith(items: items.values.toList()));
      } else if (previous.data case CatalogValue<PageResult<MovieReview>>(
        :final value,
      )) {
        final next = (data as CatalogValue<PageResult<MovieReview>>).value;
        final items = {for (final m in value.items) m.id: m};
        for (final m in next.items) {
          items.putIfAbsent(m.id, () => m);
        }
        merged = CatalogValue(next.copyWith(items: items.values.toList()));
      }
      state = CatalogPageState(
        data: merged,
        requested: previous.requested,
        displayed: key,
        loading: false,
        error: previous.error,
      );
    } else {
      state = CatalogPageState(
        data: previous.data,
        requested: previous.requested,
        displayed: previous.displayed,
        loading: false,
        error: previous.error,
        continuationError: result.failureOrNull,
      );
    }
  }
}

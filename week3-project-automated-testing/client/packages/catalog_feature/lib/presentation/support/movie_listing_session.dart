import 'package:movies_core/movies_core.dart';

typedef MoviePageFetcher =
    Future<Outcome<PageResult<MovieSummary>>> Function(
      int page,
      CatalogReadOptions options,
    );

/// One independently cancellable source. Displayed identity always follows the
/// content, even when replacing it with a different source fails.
class MovieListingState {
  const MovieListingState({
    this.items = const [],
    this.requested,
    this.displayed,
    this.requestedLabel = '',
    this.displayedLabel = '',
    this.loading = false,
    this.continuing = false,
    this.error,
    this.continuationError,
    this.page = 0,
    this.totalPages = 0,
  });
  final List<MovieSummary> items;
  final RequestKey? requested, displayed;
  final String requestedLabel, displayedLabel;
  final bool loading, continuing;
  final AppFailure? error, continuationError;
  final int page, totalPages;
  bool get canLoadMore => displayed != null && page < totalPages && page < 500;
  bool get retainsOtherSource =>
      displayed != null &&
      requested != null &&
      displayed!.copyWith(page: null) != requested!.copyWith(page: null);
}

class MovieListingSession {
  MovieListingSession({required this.clock, required this.onChanged});
  final Clock clock;
  final void Function(MovieListingState) onChanged;
  MovieListingState state = const MovieListingState();
  MoviePageFetcher? _requestedFetch, _displayedFetch;
  CancellationHandle? _cancel, _moreCancel;
  int _generation = 0;
  bool _alive = true;
  void _emit(MovieListingState value) {
    if (_alive) {
      state = value;
      onChanged(value);
    }
  }

  void invalidatePending() {
    _generation++;
    _cancel?.cancel();
    _moreCancel?.cancel();
    _emit(
      MovieListingState(
        items: state.items,
        requested: state.requested,
        displayed: state.displayed,
        requestedLabel: state.requestedLabel,
        displayedLabel: state.displayedLabel,
        page: state.page,
        totalPages: state.totalPages,
      ),
    );
  }

  void clear() {
    invalidatePending();
    _requestedFetch = null;
    _displayedFetch = null;
    _emit(const MovieListingState());
  }

  Future<void> retry() => state.requested == null || _requestedFetch == null
      ? Future.value()
      : load(
          state.requested!,
          _requestedFetch!,
          label: state.requestedLabel,
          refresh: true,
        );
  Future<void> load(
    RequestKey key,
    MoviePageFetcher fetch, {
    required String label,
    bool refresh = false,
  }) async {
    if (!_alive) return;
    final generation = ++_generation;
    _cancel?.cancel();
    _moreCancel?.cancel();
    final cancel = CancellationHandle();
    _cancel = cancel;
    _requestedFetch = fetch;
    final old = state;
    final request = key.copyWith(page: 1);
    _emit(
      MovieListingState(
        items: old.items,
        requested: request,
        displayed: old.displayed,
        requestedLabel: label,
        displayedLabel: old.displayedLabel,
        loading: true,
        page: old.page,
        totalPages: old.totalPages,
      ),
    );
    final result = await _read(fetch, 1, request, cancel, refresh);
    if (!_alive || generation != _generation || cancel.isCancelled) return;
    if (result case Success<PageResult<MovieSummary>>(:final data)) {
      _displayedFetch = fetch;
      _emit(
        MovieListingState(
          items: List.unmodifiable(_unique(data.items)),
          requested: request,
          displayed: request,
          requestedLabel: label,
          displayedLabel: label,
          page: data.page,
          totalPages: data.totalPages,
        ),
      );
    } else {
      _emit(
        MovieListingState(
          items: old.items,
          requested: request,
          displayed: old.displayed,
          requestedLabel: label,
          displayedLabel: old.displayedLabel,
          page: old.page,
          totalPages: old.totalPages,
          error: result.failureOrNull,
        ),
      );
    }
  }

  Future<Outcome<PageResult<MovieSummary>>> _read(
    MoviePageFetcher fetch,
    int page,
    RequestKey key,
    CancellationHandle cancel,
    bool refresh,
  ) async {
    try {
      final result = await fetch(
        page,
        CatalogReadOptions(
          requestKey: key,
          cancellation: cancel,
          policy: refresh ? ReadPolicy.refresh : ReadPolicy.cacheFirst,
        ),
      );
      if (result case Success<PageResult<MovieSummary>>(:final data)) {
        if (data.page != page || data.totalPages < 0 || data.totalResults < 0) {
          return Outcome.failure(
            AppFailure(
              kind: FailureKind.invalidData,
              operation: key.operation,
              occurredAtUtc: clock.utcNow(),
              requestKey: key,
            ),
          );
        }
      }
      return result;
    } catch (_) {
      return Outcome.failure(
        AppFailure(
          kind: FailureKind.network,
          operation: key.operation,
          occurredAtUtc: clock.utcNow(),
          requestKey: key,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (!_alive ||
        state.loading ||
        state.continuing ||
        !state.canLoadMore ||
        _displayedFetch == null)
      return;
    final old = state;
    final generation = _generation;
    final cancel = CancellationHandle();
    _moreCancel = cancel;
    final key = old.displayed!.copyWith(page: old.page + 1);
    _emit(
      MovieListingState(
        items: old.items,
        requested: old.requested,
        displayed: old.displayed,
        requestedLabel: old.requestedLabel,
        displayedLabel: old.displayedLabel,
        page: old.page,
        totalPages: old.totalPages,
        error: old.error,
        continuing: true,
      ),
    );
    final result = await _read(
      _displayedFetch!,
      old.page + 1,
      key,
      cancel,
      false,
    );
    if (!_alive || generation != _generation || cancel.isCancelled) return;
    final data = result.dataOrNull;
    _emit(
      MovieListingState(
        items: data == null
            ? old.items
            : List.unmodifiable(_unique([...old.items, ...data.items])),
        requested: old.requested,
        displayed: data == null ? old.displayed : key,
        requestedLabel: old.requestedLabel,
        displayedLabel: old.displayedLabel,
        page: data?.page ?? old.page,
        totalPages: data?.totalPages ?? old.totalPages,
        error: old.error,
        continuationError: result.failureOrNull,
      ),
    );
  }

  Iterable<MovieSummary> _unique(Iterable<MovieSummary> movies) {
    final ids = <int>{};
    return movies.where((movie) => ids.add(movie.id));
  }

  void dispose() {
    _alive = false;
    _generation++;
    _cancel?.cancel();
    _moreCancel?.cancel();
  }
}

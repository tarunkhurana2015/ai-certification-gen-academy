import 'package:test/test.dart';
import 'package:movies_core/movies_core.dart';

void main() {
  test('canonical movie resources retain typed values through JSON', () {
    final movie = MovieSummary(
      id: 1,
      title: 'Northbound',
      rating: const TmdbRating(average: 7.8, voteCount: 12),
      releaseDate: const CalendarDate(year: 2026, month: 1, day: 9),
    );
    final details = MovieDetails(
      movie: movie,
      genres: const [Genre(id: 18, name: 'Drama')],
      collection: const CollectionRef(id: 2, name: 'Collection'),
    );
    expect(MovieDetails.fromJson(details.toJson()), details);
    final window = ReleaseWindow(
      minimum: const CalendarDate(year: 2026, month: 1, day: 1),
      maximum: const CalendarDate(year: 2026, month: 1, day: 31),
    );
    expect(ReleaseWindow.fromJson(window.toJson()), window);
    final source = const RecommendationSource(
      kind: 'seeded',
      seedMovieId: 1,
      seedTitle: 'Northbound',
    );
    expect(RecommendationSource.fromJson(source.toJson()), source);
    final trending = TrendingSelection(
      items: [movie],
      requestKey: const RequestKey(mode: 'fixture', operation: 'trending'),
    );
    expect(TrendingSelection.fromJson(trending.toJson()), trending);
    final failure = AppFailure(
      kind: FailureKind.network,
      operation: 'movie',
      occurredAtUtc: DateTime.utc(2026),
      retryNotBeforeUtc: DateTime.utc(2026, 1, 1, 0, 1),
    );
    expect(AppFailure.fromJson(failure.toJson()), failure);
    final success = Outcome.success(movie);
    expect(
      Outcome<MovieSummary>.fromJson(
        success.toJson((value) => value.toJson()),
        (value) => MovieSummary.fromJson(value as Map<String, dynamic>),
      ),
      success,
    );
    final trailer = TrailerLink(
      id: 't',
      movieId: 1,
      name: 'Trailer',
      youtubeKey: 'AbCdEfGh123',
      url: Uri.parse('https://www.youtube.com/watch?v=AbCdEfGh123'),
    );
    expect(TrailerLink.fromJson(trailer.toJson()), trailer);
  });
  test(
    'canonical instant serialization always emits UTC even from a local DateTime',
    () {
      final local = DateTime(2026, 1, 1, 12);
      final failure = AppFailure(
        kind: FailureKind.network,
        operation: 'movie',
        occurredAtUtc: local,
      );
      final value = failure.toJson()['occurredAtUtc'] as String;
      expect(value, local.toUtc().toIso8601String());
      expect(value.endsWith('Z'), true);
    },
  );
  test(
    'canonical URI JSON rejects insecure or relative external destinations',
    () {
      for (final url in [
        'http://www.youtube.com/watch?v=AbCdEfGh123',
        'relative/path',
        'https://user@www.youtube.com/watch?v=AbCdEfGh123',
      ]) {
        expect(
          () => TrailerLink.fromJson({
            'id': 'x',
            'movieId': 1,
            'name': 'Trailer',
            'youtubeKey': 'AbCdEfGh123',
            'url': url,
          }),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'cancellation listeners registered after cancellation fire exactly once',
    () {
      final cancellation = CancellationHandle();
      cancellation.cancel();
      var calls = 0;
      cancellation.onCancel(() => calls++);
      cancellation.cancel();
      expect(calls, 1);
    },
  );
}

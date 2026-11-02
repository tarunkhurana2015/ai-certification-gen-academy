import 'package:movies_core/movies_core.dart';
import 'package:test/test.dart';

void main() {
  test(
    'nested movie and paged outcome serialize without provider key leakage',
    () {
      final movie = MovieSummary(
        id: 900001,
        title: 'Northbound',
        releaseDate: CalendarDate.fromIso('2026-01-09'),
      );
      final page = PageResult<MovieSummary>(
        items: [movie],
        page: 1,
        totalPages: 1,
        totalResults: 1,
        requestKey: const RequestKey(mode: 'fixture', operation: 'search'),
      );
      final encoded = page.toJson((m) => m.toJson());
      expect(
        PageResult<MovieSummary>.fromJson(
          encoded,
          (j) => MovieSummary.fromJson(j as Map<String, dynamic>),
        ).items.single.title,
        'Northbound',
      );
      expect(movie.toJson().containsKey('release_date'), isFalse);
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';

void main() {
  test(
    'explicit fixtures use local artwork and cancellation has no success',
    () async {
      final catalog = FixtureCatalog();
      final trending = (await catalog.getTrending()).dataOrNull!;
      expect(trending.canContinue, isFalse);
      expect(trending.requestKey.mode, 'fixture');
      expect(
        trending.items
            .where((m) => m.posterPath != null)
            .every((m) => m.posterPath!.startsWith('fixture:')),
        isTrue,
      );
      final cancel = CancellationHandle()..cancel();
      expect(
        await catalog.getMovie(
          900001,
          options: CatalogReadOptions(cancellation: cancel),
        ),
        isA<Cancelled<MovieDetails>>(),
      );
    },
  );
}

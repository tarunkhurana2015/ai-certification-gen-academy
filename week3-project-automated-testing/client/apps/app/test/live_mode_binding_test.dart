import 'package:flutter_test/flutter_test.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'package:movies/bootstrap/dependency_bindings.dart';
import 'package:movies_data/movies_data.dart';

void main() {
  test(
    'valid live configuration binds real repositories and never the fixture catalog',
    () async {
      final dependencies = createDependencies(
        const AppConfig(readToken: 'test-token'),
        favoritesDatabase: MoviesDatabase.inMemory(),
      );
      addTearDown(dependencies.close);
      expect(dependencies.movies, isA<TmdbCatalog>());
      expect(dependencies.people, isA<TmdbPersonRepository>());
      expect(dependencies.simulatedLinks, false);
    },
  );
  test(
    'missing and invalid live configuration preserve a separate local Library binding',
    () async {
      for (final config in [
        const AppConfig(),
        const AppConfig(readToken: 'test-token', invalidMode: true),
      ]) {
        final dependencies = createDependencies(
          config,
          favoritesDatabase: MoviesDatabase.inMemory(),
        );
        expect(dependencies.movies, isA<UnavailableCatalog>());
        expect(dependencies.favorites, isA<DriftFavoritesRepository>());
        expect(dependencies.simulatedLinks, false);
        await dependencies.close();
      }
    },
  );
}

// Native verification only. This entrypoint never opens a user's normal Library.
import 'package:flutter/material.dart';
import 'package:movies/app.dart';
import 'package:movies/bootstrap/app_config.dart';
import 'package:movies/bootstrap/dependency_bindings.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';

class AcknowledgedFavorites implements FavoritesRepository {
  AcknowledgedFavorites(this.inner);
  final FavoritesRepository inner;
  final persisted = ValueNotifier<Set<int>?>(null);
  @override
  Future<Outcome<FavoritesBaseline>> readBaseline() async {
    final result = await inner.readBaseline();
    if (result.dataOrNull case final data?) {
      persisted.value = data.entries.map((e) => e.movie.movieId).toSet();
    }
    return result;
  }

  @override
  Future<Outcome<PersistenceAck>> apply(FavoriteWriteCommand command) async {
    final result = await inner.apply(command);
    if (result.dataOrNull != null) await readBaseline();
    return result;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  const config = AppConfig(mode: CatalogMode.fixture);
  const name = String.fromEnvironment(
    'MOVIES_TEST_DATABASE',
    defaultValue: 'movies_test_native_verification',
  );
  final base = createDependencies(
    config,
    favoritesDatabase: MoviesDatabase.isolatedTest(name),
  );
  final favorites = AcknowledgedFavorites(base.favorites);
  final dependencies = AppDependencies(
    discovery: base.discovery,
    movies: base.movies,
    people: base.people,
    artwork: base.artwork,
    favorites: favorites,
    externalLinks: base.externalLinks,
    clock: base.clock,
    artworkSource: base.artworkSource,
    close: base.close,
    simulatedLinks: true,
  );
  runApp(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          ValueListenableBuilder<Set<int>?>(
            valueListenable: favorites.persisted,
            builder: (context, ids, child) {
              final sorted = ids?.toList()?..sort();
              final value = sorted == null
                  ? 'loading'
                  : sorted.isEmpty
                  ? 'empty'
                  : sorted.join('_');
              return Semantics(
                identifier: 'movies.testing.persisted.$value',
                child: Text(
                  'Test-owned saved Library: $value',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              );
            },
          ),
          Expanded(
            child: MoviesApp(config: config, dependencies: dependencies),
          ),
        ],
      ),
    ),
  );
}

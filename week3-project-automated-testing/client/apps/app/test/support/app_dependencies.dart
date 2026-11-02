import 'package:movies/bootstrap/dependency_bindings.dart';
import 'package:movies/platform/external_link_gateway.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';

class MemoryFavorites implements FavoritesRepository {
  final Map<int, FavoriteEntry> entries = {};
  int order = 0;
  @override
  Future<Outcome<FavoritesBaseline>> readBaseline() async => Outcome.success(
    FavoritesBaseline(entries: entries.values.toList(), lastAddedOrder: order),
  );
  @override
  Future<Outcome<PersistenceAck>> apply(FavoriteWriteCommand c) async {
    if (c.desiredEntry == null) {
      entries.remove(c.movieId);
    } else {
      entries[c.movieId] = c.desiredEntry!;
      if (c.desiredEntry!.addedOrder > order) {
        order = c.desiredEntry!.addedOrder;
      }
    }
    return Outcome.success(
      PersistenceAck(
        intentRevision: c.intentRevision,
        movieId: c.movieId,
        storedEntry: c.desiredEntry,
        committedAtUtc: DateTime.utc(2026),
      ),
    );
  }
}

AppDependencies testDependencies({
  DiscoveryRepository? discovery,
  MovieRepository? movies,
  PersonRepository? people,
  FavoritesRepository? favorites,
}) {
  final c = FixtureCatalog();
  final clock = SystemClock();
  return AppDependencies(
    discovery: discovery ?? c,
    movies: movies ?? c,
    people: people ?? c,
    artwork: c,
    favorites: favorites ?? MemoryFavorites(),
    externalLinks: AppExternalLinkGateway(simulated: true, clock: clock),
    clock: clock,
    artworkSource: (p) => p,
    close: () async {},
    simulatedLinks: true,
  );
}

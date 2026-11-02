import 'package:movies_core/movies_core.dart';
import 'package:movies_data/movies_data.dart';
import '../platform/external_link_gateway.dart';
import 'app_config.dart';

class AppDependencies {
  const AppDependencies({
    required this.discovery,
    required this.movies,
    required this.people,
    required this.artwork,
    required this.favorites,
    required this.externalLinks,
    required this.clock,
    required this.artworkSource,
    required this.close,
    this.simulatedLinks = false,
    this.configuredArtworkSource,
  });
  final DiscoveryRepository discovery;
  final MovieRepository movies;
  final PersonRepository people;
  final ArtworkConfigurationRepository artwork;
  final FavoritesRepository favorites;
  final ExternalLinkGateway externalLinks;
  final Clock clock;
  final String? Function(String?) artworkSource;
  final Future<void> Function() close;
  final bool simulatedLinks;
  final String? Function(ImageConfiguration, String?, ImageKind)?
  configuredArtworkSource;
}

AppDependencies createDependencies(
  AppConfig config, {
  MoviesDatabase? favoritesDatabase,
}) {
  final Clock clock = config.isFixture ? _DemoClock() : SystemClock();
  final database =
      favoritesDatabase ??
      MoviesDatabase.application(fixture: config.isFixture);
  final favorites = DriftFavoritesRepository(database, clock: clock);
  final gateway = AppExternalLinkGateway(
    simulated: config.isFixture,
    clock: clock,
  );
  if (config.isFixture) {
    final catalog = FixtureCatalog();
    return AppDependencies(
      discovery: catalog,
      movies: catalog,
      people: catalog,
      artwork: catalog,
      favorites: favorites,
      externalLinks: gateway,
      clock: clock,
      artworkSource: (path) => path,
      close: database.close,
      simulatedLinks: true,
    );
  }
  if (config.catalogAvailable) {
    final client = TmdbClient(token: config.readToken, clock: clock);
    final catalog = TmdbCatalog(client);
    return AppDependencies(
      discovery: catalog,
      movies: catalog,
      people: TmdbPersonRepository(catalog),
      artwork: catalog,
      favorites: favorites,
      externalLinks: gateway,
      clock: clock,
      artworkSource: (_) => null,
      configuredArtworkSource: (configuration, path, kind) => buildArtworkUrl(
        configuration,
        path,
        kind: kind,
        logicalWidth: kind == ImageKind.backdrop
            ? 640
            : kind == ImageKind.profile
            ? 104
            : 250,
        pixelRatio: kind == ImageKind.profile ? 3 : 2,
      )?.toString(),
      close: () async {
        client.close();
        await database.close();
      },
    );
  }
  final catalog = UnavailableCatalog(clock: clock);
  return AppDependencies(
    discovery: catalog,
    movies: catalog,
    people: catalog,
    artwork: catalog,
    favorites: favorites,
    externalLinks: gateway,
    clock: clock,
    artworkSource: (path) => null,
    close: database.close,
  );
}

class _DemoClock implements Clock {
  final SystemClock _clock = SystemClock();
  @override
  Duration get elapsed => _clock.elapsed;
  @override
  DateTime utcNow() => DateTime.utc(2026, 1, 15).add(elapsed);
}

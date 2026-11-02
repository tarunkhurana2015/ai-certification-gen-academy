import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';

final discoveryRepositoryProvider = Provider<DiscoveryRepository>(
  (ref) => throw StateError('Discovery repository must be bound by the host'),
);
final movieRepositoryProvider = Provider<MovieRepository>(
  (ref) => throw StateError('Movie repository must be bound by the host'),
);
final personRepositoryProvider = Provider<PersonRepository>(
  (ref) => throw StateError('Person repository must be bound by the host'),
);
final artworkConfigurationRepositoryProvider =
    Provider<ArtworkConfigurationRepository>(
      (ref) => throw StateError('Artwork repository must be bound by the host'),
    );
final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => throw StateError('Favorites repository must be bound by the host'),
);
final externalLinkGatewayProvider = Provider<ExternalLinkGateway>(
  (ref) => throw StateError('External gateway must be bound by the host'),
);
final clockProvider = Provider<Clock>((ref) => SystemClock());
final scheduleProvider = Provider<Schedule>(
  (ref) =>
      (duration, action) => Timer(duration, action),
);
final artworkSourceProvider = Provider<String? Function(String?)>(
  (ref) =>
      (path) => null,
);
final linksAreSimulatedProvider = Provider<bool>((ref) => false);
final catalogModeProvider = Provider<String>((ref) => 'live');
final backdropSourceProvider = Provider<String? Function(String?)>(
  (ref) => ref.watch(artworkSourceProvider),
);
final profileSourceProvider = Provider<String? Function(String?)>(
  (ref) => ref.watch(artworkSourceProvider),
);

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_core/movies_core.dart';
import 'package:catalog_feature/catalog_feature.dart';

class ArtworkRepository extends Fake implements ArtworkConfigurationRepository {
  bool fail = false;
  @override
  Future<Outcome<ImageConfiguration>> getConfiguration({
    CatalogReadOptions options = const CatalogReadOptions(),
  }) async => fail
      ? Outcome.failure(
          AppFailure(
            kind: FailureKind.network,
            operation: 'configuration',
            occurredAtUtc: DateTime.utc(2026),
          ),
        )
      : Outcome.success(
          ImageConfiguration(
            secureBaseUrl: Uri.parse('https://image.tmdb.org/t/p/'),
            posterSizes: ['w500'],
            backdropSizes: ['w1280'],
            profileSizes: ['h632'],
          ),
        );
}

void main() {
  test(
    'configuration refresh failure retains usable artwork and explicit recovery',
    () async {
      final repository = ArtworkRepository();
      final container = ProviderContainer.test(
        overrides: [
          artworkConfigurationRepositoryProvider.overrideWithValue(repository),
        ],
      );
      container.read(artworkConfigurationProvider);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(artworkConfigurationProvider).data, isNotNull);
      repository.fail = true;
      await container
          .read(artworkConfigurationProvider.notifier)
          .load(refresh: true);
      expect(container.read(artworkConfigurationProvider).data, isNotNull);
      expect(container.read(artworkConfigurationProvider).error, isNotNull);
      repository.fail = false;
      await container
          .read(artworkConfigurationProvider.notifier)
          .load(refresh: true);
      expect(container.read(artworkConfigurationProvider).error, isNull);
    },
  );
}

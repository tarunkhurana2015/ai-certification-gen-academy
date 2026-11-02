import 'package:flutter_test/flutter_test.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_data/src/tmdb/tmdb_catalog.dart';
import 'package:movies_data/src/tmdb/artwork_urls.dart';
import 'support/tmdb_harness.dart';

void main() {
  final configuration = ImageConfiguration(
    secureBaseUrl: Uri.parse('https://image.tmdb.org/t/p/'),
    posterSizes: ['w154', 'w342', 'w500', 'original'],
    backdropSizes: ['w300', 'w780', 'w1280', 'original'],
    profileSizes: ['w45', 'w185', 'h632', 'original'],
  );
  test(
    'image URL preserves base/size and handles advertised height-based profile sizes',
    () {
      expect(
        buildArtworkUrl(
          configuration,
          '/image.jpg',
          kind: ImageKind.poster,
          logicalWidth: 250,
          pixelRatio: 2,
        ).toString(),
        'https://image.tmdb.org/t/p/w500/image.jpg',
      );
      expect(
        buildArtworkUrl(
          configuration,
          '/image.jpg',
          kind: ImageKind.profile,
          logicalWidth: 104,
          pixelRatio: 3,
        ).toString(),
        'https://image.tmdb.org/t/p/h632/image.jpg',
      );
    },
  );
  test(
    'arbitrary URLs, traversal and executable paths cannot become artwork URLs',
    () {
      for (final path in [
        'https://evil.test/a.jpg',
        '//evil.test/a.jpg',
        '/../a.jpg',
        '/a%2F.jpg',
        'javascript:alert(1)',
      ]) {
        expect(buildArtworkUrl(configuration, path), isNull);
      }
    },
  );
  test(
    'configuration uses secure base and no unsupported query parameters',
    () async {
      final adapter = JsonAdapter()
        ..responses['/3/configuration'] = {
          'images': {
            'secure_base_url': 'https://image.tmdb.org/t/p/',
            'poster_sizes': ['w500'],
            'backdrop_sizes': ['w1280'],
            'profile_sizes': ['h632'],
          },
        };
      final client = testClient(adapter);
      addTearDown(client.close);
      final result = await TmdbCatalog(client).getConfiguration();
      expect(result.dataOrNull!.profileSizes, ['h632']);
      expect(adapter.requests.single.uri.hasQuery, false);
    },
  );
}

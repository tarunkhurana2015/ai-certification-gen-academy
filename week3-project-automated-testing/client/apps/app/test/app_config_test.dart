import 'package:flutter_test/flutter_test.dart';
import 'package:movies/bootstrap/app_config.dart';

void main() {
  test('live is default and missing token remains unavailable', () {
    final config = AppConfig.fromValues({});
    expect(config.mode, CatalogMode.live);
    expect(config.catalogAvailable, isFalse);
  });
  test('fixture requires explicit selection and needs no token', () {
    expect(
      AppConfig.fromValues({'MOVIES_DATA_MODE': 'fixture'}).isFixture,
      isTrue,
    );
  });
  test('unknown mode never selects fixture or claims availability', () {
    final config = AppConfig.fromValues({
      'MOVIES_DATA_MODE': 'bad',
      'TMDB_READ_ACCESS_TOKEN': 'test',
    });
    expect(config.invalidMode, isTrue);
    expect(config.catalogAvailable, isFalse);
  });
}

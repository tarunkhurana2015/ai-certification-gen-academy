enum CatalogMode { live, fixture }

class AppConfig {
  const AppConfig({
    this.mode = CatalogMode.live,
    this.readToken = '',
    this.invalidMode = false,
  });
  factory AppConfig.fromValues(Map<String, String> values) {
    final value = values['MOVIES_DATA_MODE'] ?? 'live';
    return AppConfig(
      mode: value == 'fixture' ? CatalogMode.fixture : CatalogMode.live,
      readToken: (values['TMDB_READ_ACCESS_TOKEN'] ?? '').trim(),
      invalidMode: value != 'live' && value != 'fixture',
    );
  }
  factory AppConfig.fromEnvironment() => AppConfig.fromValues(const {
    'MOVIES_DATA_MODE': String.fromEnvironment(
      'MOVIES_DATA_MODE',
      defaultValue: 'live',
    ),
    'TMDB_READ_ACCESS_TOKEN': String.fromEnvironment('TMDB_READ_ACCESS_TOKEN'),
  });
  final CatalogMode mode;
  final String readToken;
  final bool invalidMode;
  bool get isFixture => !invalidMode && mode == CatalogMode.fixture;
  bool get catalogAvailable =>
      !invalidMode && (isFixture || readToken.isNotEmpty);
}

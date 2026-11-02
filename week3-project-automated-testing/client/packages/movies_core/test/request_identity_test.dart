import 'package:movies_core/movies_core.dart';
import 'package:test/test.dart';

void main() {
  test('request identity preserves query case, spacing and source', () {
    expect(normalizeQuery('  Star  Wars  '), 'Star  Wars');
    expect(normalizeQuery('   '), isEmpty);
    expect(
      const RequestKey(mode: 'live', operation: 'search', query: 'A'),
      isNot(const RequestKey(mode: 'fixture', operation: 'search', query: 'A')),
    );
  });
}

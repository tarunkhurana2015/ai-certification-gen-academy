import 'package:movies_core/movies_core.dart';
import 'package:test/test.dart';

void main() {
  test('calendar dates reject impossible days and never shift timezone', () {
    expect(CalendarDate.fromIso('2026-01-09').iso, '2026-01-09');
    expect(() => CalendarDate.fromIso('2026-02-31'), throwsFormatException);
    expect(() => requirePositiveId(0), throwsFormatException);
  });
}

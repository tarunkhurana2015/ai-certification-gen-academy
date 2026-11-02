// Compatibility entrypoint; all native journeys now use test-owned SQLite files.
import 'client_journeys_test.dart' as journeys;

void main() => journeys.main();

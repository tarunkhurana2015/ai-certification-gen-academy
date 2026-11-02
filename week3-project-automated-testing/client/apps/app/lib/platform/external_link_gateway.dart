import 'package:movies_core/movies_core.dart';
import 'package:url_launcher/url_launcher.dart';

class AppExternalLinkGateway implements ExternalLinkGateway {
  AppExternalLinkGateway({
    this.simulated = false,
    Clock? clock,
    Future<bool> Function(Uri)? launch,
  }) : clock = clock ?? SystemClock(),
       _launch = launch ?? _external;
  final bool simulated;
  final Clock clock;
  final Future<bool> Function(Uri) _launch;
  static Future<bool> _external(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
  bool _base(Uri uri) =>
      uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      (!uri.hasPort || uri.port == 443) &&
      uri.fragment.isEmpty;
  bool _trailer(Uri uri) =>
      _base(uri) &&
      uri.host == 'www.youtube.com' &&
      uri.path == '/watch' &&
      uri.queryParametersAll.length == 1 &&
      uri.queryParametersAll['v']?.length == 1 &&
      RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(uri.queryParameters['v'] ?? '');
  Future<Outcome<bool>> _open(Uri uri, bool allowed) async {
    if (allowed) {
      try {
        if (simulated || await _launch(uri)) return const Outcome.success(true);
      } catch (_) {
        /* Return a safe failure below. */
      }
    }
    return Outcome.failure(
      AppFailure(
        kind: FailureKind.externalLink,
        operation: 'external.open',
        occurredAtUtc: clock.utcNow(),
        retryAllowed: allowed,
      ),
    );
  }

  @override
  Future<Outcome<bool>> openTrailer(TrailerLink trailer) =>
      _open(trailer.url, _trailer(trailer.url));
  @override
  Future<Outcome<bool>> openAttributionLink(Uri destination) => _open(
    destination,
    _base(destination) &&
        destination.host == 'www.themoviedb.org' &&
        destination.path == '/' &&
        destination.query.isEmpty,
  );
}

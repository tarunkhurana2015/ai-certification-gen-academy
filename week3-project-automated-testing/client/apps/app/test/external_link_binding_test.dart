import 'package:flutter_test/flutter_test.dart';
import 'package:movies/platform/external_link_gateway.dart';
import 'package:movies_core/movies_core.dart';

TrailerLink trailer(String url) => TrailerLink(
  id: 'trailer',
  movieId: 900001,
  name: 'Trailer',
  youtubeKey: 'AbCdEfGh123',
  url: Uri.parse(url),
  official: true,
);
void main() {
  test(
    'MOV-EXTERNAL-001 fixture links never invoke the native browser',
    () async {
      var calls = 0;
      final gateway = AppExternalLinkGateway(
        simulated: true,
        launch: (_) async {
          calls++;
          return true;
        },
      );
      expect(
        (await gateway.openTrailer(
          trailer('https://www.youtube.com/watch?v=AbCdEfGh123'),
        )).dataOrNull,
        true,
      );
      expect(calls, 0);
    },
  );
  test(
    'MOV-EXTERNAL-002 rejects unsupported and malformed external destinations',
    () async {
      var calls = 0;
      final gateway = AppExternalLinkGateway(
        launch: (_) async {
          calls++;
          return true;
        },
      );
      for (final url in [
        'http://www.youtube.com/watch?v=AbCdEfGh123',
        'https://www.youtube.com.evil.test/watch?v=AbCdEfGh123',
        'https://user@www.youtube.com/watch?v=AbCdEfGh123',
        'https://www.youtube.com/watch?v=short',
        'https://www.youtube.com/watch?v=AbCdEfGh123&v=AbCdEfGh123',
        'https://www.youtube.com:8443/watch?v=AbCdEfGh123',
      ]) {
        expect(
          (await gateway.openTrailer(trailer(url))).failureOrNull?.kind,
          FailureKind.externalLink,
          reason: url,
        );
      }
      expect(calls, 0);
    },
  );
  test(
    'MOV-EXTERNAL-001 live binding launches the allowed URI once and reports rejection',
    () async {
      final calls = <Uri>[];
      final gateway = AppExternalLinkGateway(
        launch: (uri) async {
          calls.add(uri);
          return false;
        },
      );
      expect(
        (await gateway.openTrailer(
          trailer('https://www.youtube.com/watch?v=AbCdEfGh123'),
        )).failureOrNull?.kind,
        FailureKind.externalLink,
      );
      expect(calls.single.host, 'www.youtube.com');
    },
  );
}

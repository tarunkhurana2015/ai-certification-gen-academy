import 'dart:math' as math;
import 'package:movies_core/movies_core.dart';

String? validatedImagePath(String? value) =>
    value != null &&
        RegExp(r'^/[A-Za-z0-9_-][A-Za-z0-9._-]*$').hasMatch(value) &&
        !value.contains('..')
    ? value
    : null;
bool validImageBase(Uri base) =>
    base.scheme == 'https' &&
    base.host == 'image.tmdb.org' &&
    base.path == '/t/p/' &&
    base.userInfo.isEmpty &&
    !base.hasQuery &&
    !base.hasFragment &&
    base.port == 443;

/// Uses only advertised thumbnail sizes. Height-based profile variants are
/// compared using the ordinary 2:3 portrait target; they remain unmodified URLs.
Uri? buildArtworkUrl(
  ImageConfiguration configuration,
  String? path, {
  ImageKind kind = ImageKind.poster,
  double logicalWidth = 250,
  double pixelRatio = 2,
}) {
  final file = validatedImagePath(path);
  if (file == null ||
      !validImageBase(configuration.secureBaseUrl) ||
      !logicalWidth.isFinite ||
      !pixelRatio.isFinite ||
      logicalWidth <= 0 ||
      pixelRatio <= 0)
    return null;
  final sizes = switch (kind) {
    ImageKind.poster => configuration.posterSizes,
    ImageKind.backdrop => configuration.backdropSizes,
    ImageKind.profile => configuration.profileSizes,
  };
  final cap = switch (kind) {
    ImageKind.poster => 500,
    ImageKind.backdrop => 1280,
    ImageKind.profile => 342,
  };
  final target = math.min(logicalWidth * pixelRatio, cap);
  final candidates = <({String name, double width})>[];
  for (final size in sizes) {
    if (!RegExp(r'^[wh][1-9][0-9]*$').hasMatch(size)) continue;
    final dimension = int.tryParse(size.substring(1));
    if (dimension == null || dimension > 8192) continue;
    candidates.add((
      name: size,
      width: dimension * (size.startsWith('h') ? 2 / 3 : 1),
    ));
  }
  if (candidates.isEmpty) return null;
  candidates.sort((a, b) => a.width.compareTo(b.width));
  final selected = candidates.firstWhere(
    (candidate) => candidate.width >= target,
    orElse: () => candidates.last,
  );
  return Uri.parse('${configuration.secureBaseUrl}${selected.name}$file');
}

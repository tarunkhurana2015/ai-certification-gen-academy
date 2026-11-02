import 'package:flutter/material.dart';
import 'studio_artwork.dart';

/// Only resolved HTTPS or explicit local-asset sources are loaded.
class Artwork extends StatelessWidget {
  const Artwork({
    super.key,
    this.source,
    required this.title,
    this.fit = BoxFit.cover,
    this.showTypography = true,
  });
  final String? source;
  final String title;
  final BoxFit fit;
  final bool showTypography;
  @override
  Widget build(BuildContext context) {
    final fallback = _FallbackArtwork(title: title);
    final path = source;
    if (path == null || path.isEmpty) return fallback;
    if (path.startsWith('fixture:'))
      return StudioArtwork(title: title, showTypography: showTypography);
    if (path.startsWith('asset:'))
      return Image.asset(
        path.substring(6),
        fit: fit,
        excludeFromSemantics: true,
        errorBuilder: (_, _, _) => fallback,
      );
    final uri = Uri.tryParse(path);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty)
      return fallback;
    return Image.network(
      path,
      fit: fit,
      excludeFromSemantics: true,
      errorBuilder: (_, _, _) => fallback,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
    );
  }
}

class _FallbackArtwork extends StatelessWidget {
  const _FallbackArtwork({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    const palettes = [
      [Color(0xff493c6d), Color(0xff17131e)],
      [Color(0xff4b655f), Color(0xff101b1c)],
      [Color(0xff895f47), Color(0xff241522)],
      [Color(0xff334d70), Color(0xff17131e)],
    ];
    final palette =
        palettes[title.codeUnits.fold(0, (a, b) => a + b) % palettes.length];
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: palette,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.local_movies_outlined,
            size: 56,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

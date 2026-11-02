import 'package:flutter/material.dart';
import 'package:movies_core/movies_core.dart';
import '../artwork/artwork.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.identifier,
    required this.onOpen,
    this.onFavorite,
    this.favorite,
    this.imageSource,
  });
  final MovieSummary movie;
  final String identifier;
  final VoidCallback onOpen;
  final VoidCallback? onFavorite;
  final bool? favorite;
  final String? imageSource;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 2 / 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Semantics(
                  identifier: '$identifier.open',
                  button: true,
                  label: 'Open ${movie.title}',
                  onTap: onOpen,
                  excludeSemantics: true,
                  child: InkWell(
                    key: ValueKey('$identifier.open'),
                    onTap: onOpen,
                    child: Artwork(source: imageSource, title: movie.title),
                  ),
                ),
                if (onFavorite != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Semantics(
                      identifier: '$identifier.favorite',
                      button: true,
                      label: favorite == null
                          ? 'Favorites unavailable for ${movie.title}'
                          : '${favorite! ? 'Remove' : 'Favorite'} ${movie.title}',
                      enabled: favorite != null,
                      toggled: favorite ?? false,
                      onTap: favorite == null ? null : onFavorite,
                      excludeSemantics: true,
                      child: Material(
                        color: const Color(0xff1c1a23),
                        shape: const CircleBorder(),
                        child: IconButton(
                          key: ValueKey('$identifier.favorite'),
                          onPressed: favorite == null ? null : onFavorite,
                          icon: Icon(
                            favorite == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: scheme.primary,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (movie.rating != null)
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xff111015),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Text(
                          'TMDB ${movie.rating!.average.toStringAsFixed(1)}/10',
                          style: const TextStyle(
                            color: Color(0xffefcd87),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: InkWell(
            onTap: onOpen,
            child: Text(
              movie.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        if (movie.releaseDate != null)
          Text(
            '${movie.releaseDate!.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
      ],
    );
  }
}

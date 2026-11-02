import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_ui/movies_ui.dart';
import '../providers/repository_providers.dart';
import '../viewmodel/favorites_viewmodel.dart';

class CatalogMovieCard extends ConsumerWidget {
  const CatalogMovieCard({
    super.key,
    required this.movie,
    required this.branch,
    required this.identifier,
    this.onOpen,
  });
  final MovieSummary movie;
  final String branch, identifier;
  final VoidCallback? onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesViewModelProvider);
    final actions = ref.read(favoritesViewModelProvider.notifier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MovieCard(
          movie: movie,
          identifier: identifier,
          imageSource: ref.watch(artworkSourceProvider)(movie.posterPath),
          favorite: favorites.ready ? favorites.contains(movie.id) : null,
          onOpen: onOpen ?? () => context.push('/$branch/movie/${movie.id}'),
          onFavorite: () => favorites.contains(movie.id)
              ? actions.removeFavorite(movie.id)
              : actions.addFavorite(movie),
        ),
        if (favorites.writeFailures.containsKey(movie.id))
          ErrorNotice(
            identifier: identifier,
            message: 'Your change could not be saved.',
            onRetry: actions.canRetryWrite(movie.id)
                ? () => actions.retryFailedWrite(movie.id)
                : null,
          ),
      ],
    );
  }
}

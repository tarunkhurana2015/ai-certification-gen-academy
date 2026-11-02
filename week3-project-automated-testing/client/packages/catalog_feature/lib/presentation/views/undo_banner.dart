import 'package:flutter/material.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/favorites_viewmodel.dart';

class UndoBanner extends ConsumerWidget {
  const UndoBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(favoritesViewModelProvider).undo;
    if (offer == null) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          children: [
            Text(
              '${offer.entry.movie.title} removed',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            TextButton(
              key: ValueKey(
                'movies.shell.undo.movie.${offer.entry.movie.movieId}.restore',
              ),
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => ref
                  .read(favoritesViewModelProvider.notifier)
                  .undoRemoval(offer.token),
              child: const Text('Undo'),
            ).identified(
              'movies.shell.undo.movie.${offer.entry.movie.movieId}.restore',
            ),
          ],
        ),
      ),
    );
  }
}

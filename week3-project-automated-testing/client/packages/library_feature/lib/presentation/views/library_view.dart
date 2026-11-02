import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:movies_ui/movies_ui.dart';
import '../viewmodel/library_viewmodel.dart';

class LibraryView extends ConsumerWidget {
  const LibraryView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(libraryViewModelProvider).favorites;
    final actions = ref.read(favoritesViewModelProvider.notifier);
    final viewModel = ref.read(libraryViewModelProvider.notifier);
    final resolve = ref.watch(artworkSourceProvider);
    return ContentWidth(
      child: ListView(
        key: const PageStorageKey('library.scroll'),
        padding: const EdgeInsets.all(24),
        children: [
          Semantics(
            header: true,
            identifier: 'movies.library.screen',
            child: Text(
              'Your Library',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Your favorites, saved on this device.'),
          const SizedBox(height: 24),
          if (state.loading && !state.ready)
            const Center(child: CircularProgressIndicator()),
          if (state.readFailure != null)
            ErrorNotice(
              identifier: 'movies.library.favorites',
              message:
                  'Your Library could not be loaded. Saved movies have not been cleared.',
              onRetry: viewModel.retryRead,
            ),
          if (state.ready && state.entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Text(
                'A place for your favorites. Tap a heart on any movie to save it here.',
              ),
            ),
          for (final entry in state.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Semantics(
                        identifier:
                            'movies.library.favorites.movie.${entry.movie.movieId}.open',
                        button: true,
                        label: 'Open ${entry.movie.title}',
                        onTap: () => context.push(
                          '/library/movie/${entry.movie.movieId}',
                        ),
                        excludeSemantics: true,
                        child: InkWell(
                          key: ValueKey(
                            'movies.library.favorites.movie.${entry.movie.movieId}.open',
                          ),
                          onTap: () => context.push(
                            '/library/movie/${entry.movie.movieId}',
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 64,
                                height: 96,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Artwork(
                                    source: resolve(entry.movie.posterPath),
                                    title: entry.movie.title,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.movie.title,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    if (entry.movie.releaseDate != null)
                                      Text('${entry.movie.releaseDate!.year}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Semantics(
                      identifier:
                          'movies.library.favorites.movie.${entry.movie.movieId}.remove',
                      button: true,
                      label: 'Remove ${entry.movie.title}',
                      enabled: state.ready,
                      excludeSemantics: true,
                      onTap: state.ready
                          ? () => viewModel.remove(entry.movie.movieId)
                          : null,
                      child: IconButton(
                        key: ValueKey(
                          'movies.library.favorites.movie.${entry.movie.movieId}.remove',
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        onPressed: state.ready
                            ? () => viewModel.remove(entry.movie.movieId)
                            : null,
                        icon: const Icon(Icons.favorite),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          for (final error in state.writeFailures.entries)
            ErrorNotice(
              identifier: 'movies.library.write.${error.key}',
              message:
                  'A change${actions.failureTitle(error.key) == null ? '' : ' to ${actions.failureTitle(error.key)}'} could not be saved.',
              onRetry: actions.canRetryWrite(error.key)
                  ? () => actions.retryFailedWrite(error.key)
                  : null,
            ),
        ],
      ),
    );
  }
}

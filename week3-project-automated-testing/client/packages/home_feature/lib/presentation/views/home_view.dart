import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../viewmodel/home_viewmodel.dart';
import '../viewmodel/home_sources.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);
    final padding = pagePadding(MediaQuery.sizeOf(context).width);
    return Semantics(
      identifier: 'movies.home.screen',
      child: ContentWidth(
        child: RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView(
            key: const PageStorageKey('movies.home.scroll'),
            padding: EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR NEXT GREAT STORY',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        letterSpacing: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Stay for the story.',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explore a world of films, faces, and unexpected favorites.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (state.featured.isNotEmpty)
                _FeaturedCarousel(movies: state.featured),
              for (final source in homeSources)
                Padding(
                  padding: EdgeInsets.fromLTRB(padding, 32, padding, 0),
                  child: Builder(
                    builder: (context) {
                      final section = state.sections[source]!;
                      final movies = state.shelf(source);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            children: [
                              Text(
                                homeTitle(source),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton(
                                key: ValueKey(
                                  'movies.home.shelf.$source.see_all',
                                ),
                                onPressed: section.displayed == null
                                    ? null
                                    : () {
                                        final displayed = section.displayed!;
                                        context.push(
                                          Uri(
                                            path: '/home/list/$source',
                                            queryParameters: {
                                              if (displayed.seedMovieId != null)
                                                'seed':
                                                    '${displayed.seedMovieId}',
                                              'label': section.displayedLabel,
                                            },
                                          ).toString(),
                                        );
                                      },
                                child: const Text('See all →'),
                              ).identified('movies.home.shelf.$source.see_all'),
                            ],
                          ),
                          if (source == 'recommended' ||
                              section.retainsOtherSource)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                section.displayedLabel.isEmpty
                                    ? section.requestedLabel
                                    : section.displayedLabel,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          if (section.error != null)
                            ErrorNotice(
                              identifier: 'movies.home.shelf.$source',
                              message: failureMessage(section.error!),
                              retryNotBeforeUtc:
                                  section.error!.retryNotBeforeUtc,
                              clock: ref.read(clockProvider),
                              onRetry: section.error!.retryAllowed
                                  ? () => vm.retry(source)
                                  : null,
                            ),
                          if (section.loading && movies.isEmpty)
                            const SizedBox(
                              height: 100,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          if (!section.loading &&
                              section.error == null &&
                              movies.isEmpty)
                            Text(
                              section.canLoadMore
                                  ? 'No eligible movies on this page. Use See all to continue.'
                                  : 'No movies are available in this section.',
                            ),
                          if (movies.isNotEmpty)
                            SingleChildScrollView(
                              key: PageStorageKey(
                                'movies.home.shelf.$source.scroll',
                              ),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final movie in movies)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 14),
                                      child: SizedBox(
                                        width: 156,
                                        child: CatalogMovieCard(
                                          movie: movie,
                                          branch: 'home',
                                          identifier:
                                              'movies.home.shelf.$source.movie.${movie.id}',
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: TextButton.icon(
                  key: const ValueKey('movies.home.about.open'),
                  onPressed: () => context.push('/home/about'),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('About Movies & credits'),
                ).identified('movies.home.about.open'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCarousel extends ConsumerStatefulWidget {
  const _FeaturedCarousel({required this.movies});
  final List<MovieSummary> movies;
  @override
  ConsumerState<_FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends ConsumerState<_FeaturedCarousel> {
  final _pages = PageController(viewportFraction: 0.9);
  int _index = 0;
  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _move(int direction) {
    final target = (_index + direction).clamp(0, widget.movies.length - 1);
    _pages.animateToPage(
      target,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesViewModelProvider);
    final actions = ref.read(favoritesViewModelProvider.notifier);
    final height = 440 + (MediaQuery.textScalerOf(context).scale(18) - 18) * 15;
    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            key: const ValueKey('movies.home.carousel'),
            controller: _pages,
            itemCount: widget.movies.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              final base = 'movies.home.carousel.featured.movie.${movie.id}';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Artwork(
                        source: ref.watch(backdropSourceProvider)(
                          movie.backdropPath ?? movie.posterPath,
                        ),
                        title: movie.title,
                        showTypography: false,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Color(0xCC080A10),
                              Color(0xFF080A10),
                            ],
                            stops: [0, 0.5, 1],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'IN THE SPOTLIGHT',
                              style: TextStyle(
                                color: Color(0xFFD6C5FF),
                                fontSize: 11,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              movie.title,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${movie.releaseDate?.year ?? 'Release date unavailable'}  ·  ${movie.rating == null ? 'TMDB · Not rated' : 'TMDB ${movie.rating!.average.toStringAsFixed(1)} / 10'}',
                              style: const TextStyle(color: Color(0xFFE1DDEB)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              movie.overview ??
                                  'Discover the story behind this movie.',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFE1DDEB),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    key: ValueKey('$base.open'),
                                    onPressed: () =>
                                        context.push('/home/movie/${movie.id}'),
                                    child: const Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
                                        Icon(Icons.arrow_outward),
                                        Text('Explore movie'),
                                      ],
                                    ),
                                  ).identified('$base.open'),
                                ),
                                const SizedBox(width: 12),
                                IconButton.filledTonal(
                                  key: ValueKey('$base.favorite'),
                                  tooltip: !favorites.ready
                                      ? 'Favorites unavailable for ${movie.title}'
                                      : favorites.contains(movie.id)
                                      ? 'Remove ${movie.title} from favorites'
                                      : 'Favorite ${movie.title}',
                                  onPressed: !favorites.ready
                                      ? null
                                      : () => favorites.contains(movie.id)
                                            ? actions.removeFavorite(movie.id)
                                            : actions.addFavorite(movie),
                                  icon: Icon(
                                    favorites.contains(movie.id)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                  ),
                                ).identified(
                                  '$base.favorite',
                                  toggled: favorites.ready
                                      ? favorites.contains(movie.id)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                key: const ValueKey('movies.home.carousel.previous'),
                tooltip: 'Previous featured movie',
                onPressed: _index == 0 ? null : () => _move(-1),
                icon: const Icon(Icons.arrow_back),
              ).identified('movies.home.carousel.previous'),
              Text(
                '${_index + 1} / ${widget.movies.length}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              IconButton(
                key: const ValueKey('movies.home.carousel.next'),
                tooltip: 'Next featured movie',
                onPressed: _index == widget.movies.length - 1
                    ? null
                    : () => _move(1),
                icon: const Icon(Icons.arrow_forward),
              ).identified('movies.home.carousel.next'),
            ],
          ),
        ),
      ],
    );
  }
}

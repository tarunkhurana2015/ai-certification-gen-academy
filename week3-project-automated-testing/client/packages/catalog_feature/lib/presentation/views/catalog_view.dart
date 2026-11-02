import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_core/movies_core.dart';
import 'package:movies_ui/movies_ui.dart';
import '../providers/repository_providers.dart';
import '../state/catalog_page_state.dart';
import '../viewmodel/catalog_page_viewmodel.dart';
import '../viewmodel/favorites_viewmodel.dart';
import 'catalog_movie_card.dart';
import '../support/paged_scroll_boundary.dart';

class CatalogView extends ConsumerWidget {
  const CatalogView({super.key, required this.identity});
  final CatalogIdentity identity;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogPageProvider(identity));
    final actions = ref.read(catalogPageProvider(identity).notifier);
    final base = catalogBase(identity);
    final title = switch (state.data) {
      CatalogValue<MovieDetails>(:final value) => value.movie.title,
      CatalogValue<PersonDetails>(:final value) => value.person.name,
      CatalogValue<MovieCollection>(:final value) => value.collection.name,
      _ => switch (identity.kind) {
        CatalogKind.cast => 'Cast & credits',
        CatalogKind.person => 'Person',
        CatalogKind.filmography => 'Filmography',
        CatalogKind.collection => 'Collection',
        CatalogKind.related => 'Related movies',
        CatalogKind.movieImages || CatalogKind.personImages => 'Images',
        CatalogKind.reviews => 'Reviews',
        _ => 'Movie',
      },
    };
    return Semantics(
      key: ValueKey('$base.screen'),
      identifier: '$base.screen',
      container: true,
      child: ContentWidth(
        child: PagedScrollBoundary(
          canRead:
              state.canLoadMore &&
              !state.loading &&
              !state.loadingMore &&
              state.error == null &&
              state.continuationError == null,
          onRead: actions.loadMore,
          child: CustomScrollView(
            key: ValueKey('$base.scroll'),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                toolbarHeight: MediaQuery.textScalerOf(context).scale(20) + 36,
                leading: Semantics(
                  identifier: '$base.back',
                  label: 'Back',
                  button: true,
                  enabled: context.canPop(),
                  onTap: context.canPop() ? () => context.pop() : null,
                  excludeSemantics: true,
                  child: IconButton(
                    key: ValueKey('$base.back'),
                    tooltip: 'Back',
                    onPressed: context.canPop() ? () => context.pop() : null,
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                ),
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                bottom: ref.watch(catalogModeProvider) == 'fixture'
                    ? PreferredSize(
                        preferredSize: Size.fromHeight(
                          MediaQuery.textScalerOf(context).scale(12) + 12,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Demo data',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                    : null,
              ),
              SliverPadding(
                padding: EdgeInsets.all(
                  pagePadding(MediaQuery.sizeOf(context).width),
                ),
                sliver: SliverList.list(
                  children: [
                    if (state.error != null)
                      ErrorNotice(
                        identifier: base,
                        message: failureMessage(state.error!),
                        retryNotBeforeUtc: state.error!.retryNotBeforeUtc,
                        clock: ref.read(clockProvider),
                        onRetry: state.error!.retryAllowed
                            ? () => actions.load(refresh: true)
                            : null,
                      ),
                    if (state.data == null && state.loading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (identity.kind != CatalogKind.movie &&
                        identity.kind != CatalogKind.person &&
                        identity.kind != CatalogKind.collection)
                      _ParentContext(identity: identity),
                    if (state.data != null)
                      ..._contents(context, ref, state.data!, base),
                    if (state.loading && state.data != null)
                      const LinearProgressIndicator(),
                    if (state.continuationError != null)
                      ErrorNotice(
                        identifier: base,
                        message: 'More results could not be loaded.',
                        retryNotBeforeUtc:
                            state.continuationError!.retryNotBeforeUtc,
                        clock: ref.read(clockProvider),
                        onRetry: state.continuationError!.retryAllowed
                            ? actions.loadMore
                            : null,
                      ),
                    if (state.loadingMore)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (state.canLoadMore &&
                        !state.loadingMore &&
                        state.continuationError == null)
                      TextButton(
                        key: ValueKey('$base.load_more'),
                        onPressed: actions.loadMore,
                        child: const Text('Load more'),
                      ).identified('$base.load_more'),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _contents(
    BuildContext context,
    WidgetRef ref,
    CatalogPayload data,
    String base,
  ) => switch (data) {
    CatalogValue<MovieDetails>(:final value) => _movie(
      context,
      ref,
      value,
      base,
    ),
    CatalogValue<MovieCredits>(:final value) => [
      Text('Cast & credits', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      if (value.cast.isEmpty) const Text('No cast has been supplied.'),
      for (final credit in value.cast)
        _PersonRow(
          person: credit.person,
          subtitle: credit.character ?? 'Cast',
          identifier:
              '$base.credit.${_credit(credit.creditId, credit.person.id, credit.character)}',
          onOpen: () =>
              context.push('/${identity.branch}/person/${credit.person.id}'),
        ),
      if (value.crew.isNotEmpty)
        const Padding(
          padding: EdgeInsets.only(top: 24, bottom: 12),
          child: Text('Crew'),
        ),
      for (final credit in value.crew)
        _PersonRow(
          person: credit.person,
          subtitle: [
            credit.department,
            credit.job,
          ].whereType<String>().join(' · '),
          identifier:
              '$base.credit.${_credit(credit.creditId, credit.person.id, credit.job)}',
          onOpen: () =>
              context.push('/${identity.branch}/person/${credit.person.id}'),
        ),
    ],
    CatalogValue<PersonDetails>(:final value) => [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            height: 144,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Artwork(
                source: ref.watch(profileSourceProvider)(
                  value.person.profilePath,
                ),
                title: value.person.name,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.person.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (value.person.knownForDepartment != null)
                  Text(value.person.knownForDepartment!),
                if (value.placeOfBirth != null) Text(value.placeOfBirth!),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
      const SectionHeading(title: 'Biography'),
      const SizedBox(height: 12),
      Text(
        value.biography ?? 'No biography has been supplied.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      if (value.birthday != null)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Born ${value.birthday!.iso}'),
        ),
      if (value.deathday != null) Text('Died ${value.deathday!.iso}'),
      const SizedBox(height: 24),
      _Action(
        identifier: '$base.filmography.open',
        label: 'Filmography',
        onPressed: () => context.push(
          '/${identity.branch}/person/${identity.id}/filmography',
        ),
      ),
      _Action(
        identifier: '$base.images.open',
        label: 'Person images',
        onPressed: () =>
            context.push('/${identity.branch}/person/${identity.id}/images'),
      ),
    ],
    CatalogValue<PersonFilmography>(:final value) => [
      Text('Filmography', style: Theme.of(context).textTheme.headlineMedium),
      const Text('Most recent release first'),
      const SizedBox(height: 16),
      if (value.entries.isEmpty)
        const Text('No movie credits have been supplied.'),
      for (final entry in value.entries)
        _MovieRow(
          movie: entry.movie,
          branch: identity.branch,
          identifier: '$base.movie.${entry.movie.id}',
          subtitle: entry.roles
              .map((r) => r.character ?? r.job ?? 'Movie credit')
              .toSet()
              .join(' · '),
        ),
    ],
    CatalogValue<MovieCollection>(:final value) => [
      Text(
        value.collection.name,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 12),
      Text(value.overview ?? 'A collection of connected movies.'),
      const SizedBox(height: 12),
      const Text('In release order'),
      if (value.movies.isEmpty)
        const Text('No collection movies have been supplied.'),
      for (final movie in value.movies)
        _MovieRow(
          movie: movie,
          branch: identity.branch,
          identifier: '$base.movie.${movie.id}',
        ),
    ],
    CatalogValue<PageResult<MovieSummary>>(:final value) => [
      Text('Related movies', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      if (value.items.isEmpty)
        Text(
          value.page < value.totalPages
              ? 'No eligible titles on this page.'
              : 'No related titles have been supplied.',
        ),
      for (final movie in value.items)
        _MovieRow(
          movie: movie,
          branch: identity.branch,
          identifier: '$base.movie.${movie.id}',
        ),
    ],
    CatalogValue<ImageGallery>(:final value) => [
      Text('Images', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      if (value.images.isEmpty) const Text('No images have been supplied.'),
      for (final image in value.images)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            identifier:
                '$base.asset.${Uri.encodeComponent(image.filePath)}.open',
            label: '${image.kind.name} image',
            child: InkWell(
              key: ValueKey(
                '$base.asset.${Uri.encodeComponent(image.filePath)}.open',
              ),
              onTap: () => showDialog<void>(
                context: context,
                useRootNavigator: false,
                builder: (context) => Dialog(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: image.width / image.height,
                          child: Artwork(
                            source: ref.read(switch (image.kind) {
                              ImageKind.poster => artworkSourceProvider,
                              ImageKind.backdrop => backdropSourceProvider,
                              ImageKind.profile => profileSourceProvider,
                            })(image.filePath),
                            title: 'Image',
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: AspectRatio(
                aspectRatio: image.width / image.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Artwork(
                    source: ref.watch(switch (image.kind) {
                      ImageKind.poster => artworkSourceProvider,
                      ImageKind.backdrop => backdropSourceProvider,
                      ImageKind.profile => profileSourceProvider,
                    })(image.filePath),
                    title: 'Image',
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
    CatalogValue<PageResult<MovieReview>>(:final value) => [
      Text('Reviews', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      if (value.items.isEmpty) const Text('No reviews have been supplied.'),
      for (final review in value.items)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.author,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (review.authorRating != null)
                  Text('Reviewer rating ${review.authorRating}/10'),
                const SizedBox(height: 12),
                Text(
                  review.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                Semantics(
                  identifier:
                      '$base.review.${Uri.encodeComponent(review.id)}.open',
                  child: TextButton(
                    key: ValueKey(
                      '$base.review.${Uri.encodeComponent(review.id)}.open',
                    ),
                    onPressed: () => showDialog<void>(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) => AlertDialog(
                        scrollable: true,
                        title: Text(review.author),
                        content: SelectableText(review.content),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('Read full review'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TMDB review',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
    ],
    _ => [const Text('No information has been supplied.')],
  };
  List<Widget> _movie(
    BuildContext context,
    WidgetRef ref,
    MovieDetails details,
    String base,
  ) {
    final m = details.movie;
    final favorites = ref.watch(favoritesViewModelProvider);
    final favoriteActions = ref.read(favoritesViewModelProvider.notifier);
    return [
      AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Artwork(
            source: ref.watch(backdropSourceProvider)(
              m.backdropPath ?? m.posterPath,
            ),
            title: m.title,
          ),
        ),
      ),
      const SizedBox(height: 24),
      Semantics(
        header: true,
        child: Text(m.title, style: Theme.of(context).textTheme.headlineMedium),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          if (m.releaseDate != null) Text('${m.releaseDate!.year}'),
          Text(
            details.runtimeMinutes == null
                ? 'Runtime unavailable'
                : '${details.runtimeMinutes! ~/ 60}h ${details.runtimeMinutes! % 60}m',
          ),
          if (m.originalLanguage != null)
            Text(m.originalLanguage!.toUpperCase()),
          if (details.status != null) Text(details.status!),
        ],
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final genre in details.genres) Chip(label: Text(genre.name)),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        m.rating == null
            ? 'TMDB · Not rated'
            : 'TMDB ${m.rating!.average.toStringAsFixed(1)} / 10 · ${m.rating!.voteCount} votes',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 16),
      Semantics(
        identifier: '$base.favorite',
        toggled: favorites.contains(m.id),
        enabled: favorites.ready,
        child: FilledButton.icon(
          key: ValueKey('$base.favorite'),
          onPressed: !favorites.ready
              ? null
              : () => favorites.contains(m.id)
                    ? favoriteActions.removeFavorite(m.id)
                    : favoriteActions.addFavorite(m),
          icon: Icon(
            favorites.contains(m.id) ? Icons.favorite : Icons.favorite_border,
          ),
          label: Text(
            !favorites.ready
                ? 'Loading favorites'
                : favorites.contains(m.id)
                ? 'Remove favorite'
                : 'Favorite',
          ),
        ),
      ),
      if (favorites.writeFailures.containsKey(m.id))
        ErrorNotice(
          identifier: '$base.favorite',
          message: 'Your favorite change could not be saved.',
          onRetry: favoriteActions.canRetryWrite(m.id)
              ? () => favoriteActions.retryFailedWrite(m.id)
              : null,
        ),
      const SizedBox(height: 24),
      const SectionHeading(title: 'The story'),
      const SizedBox(height: 12),
      Text(
        m.overview ?? 'No overview has been supplied.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 16),
      _TrailerAction(identity: identity),
      const SizedBox(height: 24),
      _Action(
        identifier: '$base.cast.open',
        label: 'Full cast & credits',
        onPressed: () => context.push('/${identity.branch}/movie/${m.id}/cast'),
      ),
      _CastPreview(identity: identity),
      const SizedBox(height: 24),
      const SectionHeading(title: 'Explore this movie'),
      if (details.collection != null)
        _Action(
          identifier: '$base.collection.open',
          label: 'Explore ${details.collection!.name}',
          onPressed: () => context.push(
            '/${identity.branch}/collection/${details.collection!.id}',
          ),
        ),
      _Action(
        identifier: '$base.related.open',
        label: 'Related movies',
        onPressed: () =>
            context.push('/${identity.branch}/movie/${m.id}/related'),
      ),
      _Action(
        identifier: '$base.images.open',
        label: 'Movie images',
        onPressed: () =>
            context.push('/${identity.branch}/movie/${m.id}/images'),
      ),
      _Action(
        identifier: '$base.reviews.open',
        label: 'Read reviews',
        onPressed: () =>
            context.push('/${identity.branch}/movie/${m.id}/reviews'),
      ),
      _RelatedPreview(identity: identity),
    ];
  }
}

String _credit(String? creditId, int personId, String? role) =>
    Uri.encodeComponent(creditId ?? '$personId|${role ?? ''}');

class _Action extends StatelessWidget {
  const _Action({
    required this.identifier,
    required this.label,
    required this.onPressed,
  });
  final String identifier, label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: Semantics(
      identifier: identifier,
      child: TextButton(
        key: ValueKey(identifier),
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          alignment: Alignment.centerLeft,
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

class _PersonRow extends ConsumerWidget {
  const _PersonRow({
    required this.person,
    required this.subtitle,
    required this.identifier,
    required this.onOpen,
  });
  final PersonSummary person;
  final String subtitle, identifier;
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Semantics(
    identifier: '$identifier.open',
    button: true,
    label: '${person.name}, $subtitle',
    onTap: onOpen,
    excludeSemantics: true,
    child: InkWell(
      key: ValueKey('$identifier.open'),
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Artwork(
                  source: ref.watch(profileSourceProvider)(person.profilePath),
                  title: person.name,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(subtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

class _MovieRow extends ConsumerWidget {
  const _MovieRow({
    required this.movie,
    required this.branch,
    required this.identifier,
    this.subtitle,
  });
  final MovieSummary movie;
  final String branch, identifier;
  final String? subtitle;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 112,
          child: CatalogMovieCard(
            movie: movie,
            branch: branch,
            identifier: identifier,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(movie.title, style: Theme.of(context).textTheme.titleLarge),
              if (movie.releaseDate != null) Text(movie.releaseDate!.iso),
              if (subtitle != null) Text(subtitle!),
              const SizedBox(height: 8),
              Text(
                movie.overview ?? 'No overview supplied.',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _CastPreview extends ConsumerWidget {
  const _CastPreview({required this.identity});
  final CatalogIdentity identity;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (
      branch: identity.branch,
      entry: identity.entry,
      id: identity.id,
      kind: CatalogKind.cast,
    );
    final state = ref.watch(catalogPageProvider(key));
    final error = state.error == null
        ? null
        : ErrorNotice(
            identifier: '${catalogBase(identity)}.cast',
            message: 'Cast could not be loaded.',
            retryNotBeforeUtc: state.error!.retryNotBeforeUtc,
            clock: ref.read(clockProvider),
            onRetry: () =>
                ref.read(catalogPageProvider(key).notifier).load(refresh: true),
          );
    if (state.data case CatalogValue<MovieCredits>(:final value))
      return Column(
        children: [
          if (error != null) error,
          for (final c in value.cast.take(3))
            _PersonRow(
              person: c.person,
              subtitle: c.character ?? 'Cast',
              identifier:
                  '${catalogBase(identity)}.cast.preview.${_credit(c.creditId, c.person.id, c.character)}',
              onOpen: () =>
                  context.push('/${identity.branch}/person/${c.person.id}'),
            ),
        ],
      );
    return error ??
        const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator()),
        );
  }
}

class _TrailerAction extends ConsumerWidget {
  const _TrailerAction({required this.identity});
  final CatalogIdentity identity;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (
      branch: identity.branch,
      entry: identity.entry,
      id: identity.id,
      kind: CatalogKind.trailers,
    );
    final state = ref.watch(catalogPageProvider(key));
    final error = state.error == null
        ? null
        : ErrorNotice(
            identifier: '${catalogBase(identity)}.trailer',
            message: 'Trailer information could not be loaded.',
            retryNotBeforeUtc: state.error!.retryNotBeforeUtc,
            clock: ref.read(clockProvider),
            onRetry: () =>
                ref.read(catalogPageProvider(key).notifier).load(refresh: true),
          );
    if (state.data case CatalogValue<List<TrailerLink>>(:final value)) {
      if (value.isEmpty)
        return Column(
          children: [
            if (error != null) error,
            const Text('No supported trailer has been supplied.'),
          ],
        );
      return Column(
        children: [
          if (error != null) error,
          _Action(
            identifier: '${catalogBase(identity)}.trailer.open',
            label: 'Trailer link ↗',
            onPressed: () async {
              final result = await ref
                  .read(externalLinkGatewayProvider)
                  .openTrailer(value.first);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.failureOrNull != null
                        ? 'The trailer could not be opened.'
                        : ref.read(linksAreSimulatedProvider)
                        ? 'Demo: link opening simulated'
                        : 'Opening trailer in your browser.',
                  ),
                ),
              );
            },
          ),
        ],
      );
    }
    return error ?? const SizedBox.shrink();
  }
}

class _RelatedPreview extends ConsumerWidget {
  const _RelatedPreview({required this.identity});
  final CatalogIdentity identity;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (
      branch: identity.branch,
      entry: identity.entry,
      id: identity.id,
      kind: CatalogKind.related,
    );
    final state = ref.watch(catalogPageProvider(key));
    final error = state.error == null
        ? null
        : ErrorNotice(
            identifier: '${catalogBase(identity)}.related',
            message: 'Related titles could not be loaded.',
            retryNotBeforeUtc: state.error!.retryNotBeforeUtc,
            clock: ref.read(clockProvider),
            onRetry: () =>
                ref.read(catalogPageProvider(key).notifier).load(refresh: true),
          );
    if (state.data case CatalogValue<PageResult<MovieSummary>>(:final value))
      return Column(
        children: [
          if (error != null) error,
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final movie in value.items.take(4))
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 136,
                        child: CatalogMovieCard(
                          movie: movie,
                          branch: identity.branch,
                          identifier:
                              '${catalogBase(identity)}.related.preview.movie.${movie.id}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    return error ?? const SizedBox.shrink();
  }
}

class _ParentContext extends ConsumerWidget {
  const _ParentContext({required this.identity});
  final CatalogIdentity identity;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person =
        identity.kind == CatalogKind.filmography ||
        identity.kind == CatalogKind.personImages;
    final key = (
      branch: identity.branch,
      entry: identity.entry,
      id: identity.id,
      kind: person ? CatalogKind.person : CatalogKind.movie,
    );
    final state = ref.watch(catalogPageProvider(key));
    final title = switch (state.data) {
      CatalogValue<MovieDetails>(:final value) => value.movie.title,
      CatalogValue<PersonDetails>(:final value) => value.person.name,
      _ => null,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        title ?? (person ? 'Person information' : 'Movie information'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

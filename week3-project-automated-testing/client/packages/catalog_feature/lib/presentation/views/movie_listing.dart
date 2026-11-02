import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:movies_core/movies_core.dart';
import '../support/movie_listing_session.dart';
import '../state/catalog_page_state.dart';
import 'catalog_movie_card.dart';

/// A shrink-wrapped adaptive catalog, usable inside each branch's retained scroll.
class MovieListing extends StatelessWidget {
  const MovieListing({
    super.key,
    required this.state,
    required this.branch,
    required this.identifier,
    required this.onRetry,
    required this.onLoadMore,
    this.clock,
    this.emptyMessage = 'No movies were found.',
  });
  final MovieListingState state;
  final Clock? clock;
  final String branch, identifier, emptyMessage;
  final VoidCallback onRetry, onLoadMore;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (state.error != null)
        ErrorNotice(
          identifier: identifier,
          retryNotBeforeUtc: state.error!.retryNotBeforeUtc,
          clock: clock,
          message: '${state.requestedLabel}: ${failureMessage(state.error!)}',
          onRetry: state.error!.retryAllowed ? onRetry : null,
        ),
      if (state.retainsOtherSource)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Still showing ${state.displayedLabel}',
            key: ValueKey('$identifier.retained_source'),
          ),
        ),
      if (state.loading)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (!state.loading && state.error == null && state.items.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            state.canLoadMore
                ? 'No eligible movies on this page. Load more to continue.'
                : emptyMessage,
          ),
        ),
      if (state.items.isNotEmpty)
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
            final columns = math.max(
              1,
              (constraints.maxWidth / (156 * math.min(scale, 2))).floor(),
            );
            final width = (constraints.maxWidth - 16 * (columns - 1)) / columns;
            return Wrap(
              spacing: 16,
              runSpacing: 24,
              children: [
                for (final movie in state.items)
                  SizedBox(
                    width: width,
                    child: CatalogMovieCard(
                      movie: movie,
                      branch: branch,
                      identifier: '$identifier.movie.${movie.id}',
                    ),
                  ),
              ],
            );
          },
        ),
      if (state.continuationError != null)
        ErrorNotice(
          identifier: '$identifier.continuation',
          retryNotBeforeUtc: state.continuationError!.retryNotBeforeUtc,
          clock: clock,
          message: 'More movies: ${failureMessage(state.continuationError!)}',
          onRetry: state.continuationError!.retryAllowed ? onLoadMore : null,
        ),
      if (state.continuing)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      if (state.canLoadMore &&
          !state.continuing &&
          state.continuationError == null)
        TextButton(
          key: ValueKey('$identifier.load_more'),
          onPressed: state.loading ? null : onLoadMore,
          child: const Text('Load more'),
        ).identified('$identifier.load_more'),
      if (state.displayed != null &&
          !state.canLoadMore &&
          state.items.isNotEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('You’re all caught up.'),
        ),
    ],
  );
}

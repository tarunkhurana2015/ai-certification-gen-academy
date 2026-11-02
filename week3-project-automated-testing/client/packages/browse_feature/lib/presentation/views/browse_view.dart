import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../state/browse_state.dart';
import '../viewmodel/browse_viewmodel.dart';

class BrowseView extends ConsumerWidget {
  const BrowseView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(browseViewModelProvider);
    final vm = ref.read(browseViewModelProvider.notifier);
    return Semantics(
      identifier: 'movies.browse.screen',
      child: ContentWidth(
        child: PagedScrollBoundary(
          canRead:
              state.listing.canLoadMore &&
              !state.listing.loading &&
              !state.listing.continuing &&
              state.listing.error == null &&
              state.listing.continuationError == null,
          onRead: vm.loadMore,
          child: ListView(
            key: const PageStorageKey('movies.browse.scroll'),
            padding: EdgeInsets.all(
              pagePadding(MediaQuery.sizeOf(context).width),
            ),
            children: [
              Text(
                'Find your next obsession.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              const Text(
                'New releases. Future favorites. Stories worth finding.',
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in BrowseCategory.values)
                    Semantics(
                      identifier: 'movies.browse.category.${category.apiName}',
                      child: ChoiceChip(
                        key: ValueKey(
                          'movies.browse.category.${category.apiName}',
                        ),
                        label: Text(category.label),
                        selected: state.category == category,
                        onSelected: (_) => vm.select(category),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                state.listing.displayedLabel.isEmpty
                    ? state.category.label
                    : state.listing.displayedLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              MovieListing(
                clock: ref.read(clockProvider),
                state: state.listing,
                branch: 'browse',
                identifier: 'movies.browse.results',
                onRetry: vm.retry,
                onLoadMore: vm.loadMore,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

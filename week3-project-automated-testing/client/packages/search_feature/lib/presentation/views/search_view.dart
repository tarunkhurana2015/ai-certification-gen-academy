import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../viewmodel/search_viewmodel.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});
  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchViewModelProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchViewModelProvider);
    final vm = ref.read(searchViewModelProvider.notifier);
    return Semantics(
      identifier: 'movies.search.screen',
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
            key: const PageStorageKey('movies.search.scroll'),
            padding: EdgeInsets.all(
              pagePadding(MediaQuery.sizeOf(context).width),
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Text(
                'A story is only a search away.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Semantics(
                identifier: 'movies.search.query.input',
                child: TextField(
                  key: const ValueKey('movies.search.query.input'),
                  controller: _controller,
                  onChanged: vm.edit,
                  onSubmitted: (_) => vm.submit(),
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Search movies',
                    hintText: 'Try a title',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      key: const ValueKey('movies.search.query.clear'),
                      tooltip: 'Clear search',
                      onPressed: () {
                        _controller.clear();
                        vm.clear();
                      },
                      icon: const Icon(Icons.close),
                    ).identified('movies.search.query.clear'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (state.query.trim().isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.movie_filter_outlined, size: 64),
                      SizedBox(height: 20),
                      Text(
                        'Find a film. Follow the cast. Discover something unexpected.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else ...[
                if (state.listing.displayed != null)
                  Text(
                    state.listing.displayedLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                const SizedBox(height: 16),
                if (state.debouncing && state.listing.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Searching…'),
                  )
                else
                  MovieListing(
                    clock: ref.read(clockProvider),
                    state: state.listing,
                    branch: 'search',
                    identifier: 'movies.search.results',
                    onRetry: vm.retry,
                    onLoadMore: vm.loadMore,
                    emptyMessage: 'No movies match this title.',
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../viewmodel/home_listing_viewmodel.dart';
import '../viewmodel/home_sources.dart';

class HomeListingView extends ConsumerWidget {
  const HomeListingView({super.key, required this.identity});
  final HomeListingIdentity identity;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeListingProvider(identity));
    final vm = ref.read(homeListingProvider(identity).notifier);
    return ContentWidth(
      child: PagedScrollBoundary(
        canRead:
            state.canLoadMore &&
            !state.loading &&
            !state.continuing &&
            state.error == null &&
            state.continuationError == null,
        onRead: vm.loadMore,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              title: Text(homeTitle(identity.source)),
            ),
            SliverPadding(
              padding: EdgeInsets.all(
                pagePadding(MediaQuery.sizeOf(context).width),
              ),
              sliver: SliverList.list(
                children: [
                  Text(
                    state.displayedLabel.isEmpty
                        ? identity.label
                        : state.displayedLabel,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  MovieListing(
                    clock: ref.read(clockProvider),
                    state: state,
                    branch: 'home',
                    identifier: 'movies.home.list.${identity.source}',
                    onRetry: vm.retry,
                    onLoadMore: vm.loadMore,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

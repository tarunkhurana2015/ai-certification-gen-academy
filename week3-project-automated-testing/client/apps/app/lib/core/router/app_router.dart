import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_feature/home_feature.dart';
import 'package:browse_feature/browse_feature.dart';
import 'package:search_feature/search_feature.dart';
import 'package:library_feature/library_feature.dart';
import 'package:catalog_feature/catalog_feature.dart';
import '../../bootstrap/app_config.dart';

GoRouter createAppRouter({
  String initialLocation = '/home',
  AppConfig config = const AppConfig(),
}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) =>
          MoviesShell(shell: shell, config: config),
      branches: [
        StatefulShellBranch(
          routes: [
            ...buildHomeRoutes(),
            ...buildCatalogRoutes(branch: 'home'),
          ],
        ),
        StatefulShellBranch(
          routes: [
            ...buildBrowseRoutes(),
            ...buildCatalogRoutes(branch: 'browse'),
          ],
        ),
        StatefulShellBranch(
          routes: [
            ...buildSearchRoutes(),
            ...buildCatalogRoutes(branch: 'search'),
          ],
        ),
        StatefulShellBranch(
          routes: [
            ...buildLibraryRoutes(),
            ...buildCatalogRoutes(branch: 'library'),
          ],
        ),
      ],
    ),
  ],
);

class MoviesShell extends ConsumerStatefulWidget {
  const MoviesShell({super.key, required this.shell, required this.config});
  final StatefulNavigationShell shell;
  final AppConfig config;
  @override
  ConsumerState<MoviesShell> createState() => _MoviesShellState();
}

class _MoviesShellState extends ConsumerState<MoviesShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      ref.read(favoritesViewModelProvider.notifier).onBackgrounded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final media = MediaQuery.of(context);
    final tightKeyboard = keyboard > 0 && media.size.height - keyboard < 240;
    final compactTabs = tightKeyboard || media.textScaler.scale(12) > 18;
    final destinations = const [
      (Icons.home_outlined, 'Home', 'home'),
      (Icons.grid_view_rounded, 'Browse', 'browse'),
      (Icons.search, 'Search', 'search'),
      (Icons.bookmark_border, 'Library', 'library'),
    ];
    return Scaffold(
      appBar:
          keyboard > 0 ||
              media.size.height < 500 ||
              GoRouterState.of(context).uri.pathSegments.length > 1
          ? null
          : AppBar(
              leading: GoRouter.of(context).canPop()
                  ? IconButton(
                      tooltip: 'Back',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    )
                  : null,
              title: const Text('Movies'),
              toolbarHeight: MediaQuery.textScalerOf(context).scale(20) + 36,
              bottom: widget.config.isFixture
                  ? PreferredSize(
                      preferredSize: Size.fromHeight(
                        media.textScaler.scale(12) + 12,
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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const ArtworkStatusBanner(),
            Expanded(child: widget.shell),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: tightKeyboard
                ? (media.size.height - keyboard - media.padding.top - 40).clamp(
                    0,
                    double.infinity,
                  )
                : (media.size.height - keyboard - media.padding.top) * .45,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(child: SingleChildScrollView(child: UndoBanner())),
              ColoredBox(
                color: scheme.surface,
                child: SafeArea(
                  top: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: tightKeyboard ? 48 : 64,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (var i = 0; i < destinations.length; i++)
                          Expanded(
                            child: Semantics(
                              identifier:
                                  'movies.shell.tab.${destinations[i].$3}',
                              label: destinations[i].$2,
                              button: true,
                              selected: widget.shell.currentIndex == i,
                              onTap: () => widget.shell.goBranch(i),
                              excludeSemantics: true,
                              child: InkWell(
                                key: ValueKey(
                                  'movies.shell.tab.${destinations[i].$3}',
                                ),
                                onTap: () => widget.shell.goBranch(i),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 48,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 4,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (keyboard == 0)
                                          Container(
                                            width: 28,
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.shell.currentIndex == i
                                                  ? scheme.primary
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        if (keyboard == 0)
                                          const SizedBox(height: 6),
                                        if (keyboard == 0)
                                          Icon(
                                            destinations[i].$1,
                                            color:
                                                widget.shell.currentIndex == i
                                                ? scheme.primary
                                                : scheme.onSurfaceVariant,
                                          ),
                                        if (keyboard == 0)
                                          const SizedBox(height: 4),
                                        if (compactTabs)
                                          Tooltip(
                                            message: destinations[i].$2,
                                            child: Icon(destinations[i].$1),
                                          ),
                                        if (!compactTabs)
                                          Text(
                                            destinations[i].$2,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                                  widget.shell.currentIndex == i
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color:
                                                  widget.shell.currentIndex == i
                                                  ? scheme.primary
                                                  : scheme.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

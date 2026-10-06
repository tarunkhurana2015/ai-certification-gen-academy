import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio_feature/portfolio_feature.dart';
import 'package:allocation_feature/allocation_feature.dart';
import 'package:analytics_feature/analytics_feature.dart';
import '../theme/app_theme.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AdaptiveAppScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AdaptiveAppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;

        if (isDesktop) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  extended: constraints.maxWidth >= 960,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.brandSeed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.candlestick_chart, color: AppTheme.brandSeed, size: 24),
                        ),
                        if (constraints.maxWidth >= 960) ...[
                          const SizedBox(width: 12),
                          const Text(
                            'GenStockFolio',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: IconButton(
                          icon: Icon(
                            themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                          ),
                          tooltip: 'Toggle Theme',
                          onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                        ),
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.input),
                      selectedIcon: Icon(Icons.input, color: AppTheme.brandSeed),
                      label: Text('Import & Data'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.pie_chart_outline),
                      selectedIcon: Icon(Icons.pie_chart, color: AppTheme.brandSeed),
                      label: Text('Allocation'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.timeline),
                      selectedIcon: Icon(Icons.timeline, color: AppTheme.brandSeed),
                      label: Text('Performance'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        // Mobile Layout (< 600dp)
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.input),
                label: 'Import',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart),
                label: 'Allocation',
              ),
              NavigationDestination(
                icon: Icon(Icons.timeline),
                label: 'Performance',
              ),
            ],
          ),
        );
      },
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/import',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdaptiveAppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              PortfolioRouterConfig.route,
            ],
          ),
          StatefulShellBranch(
            routes: [
              AllocationRouterConfig.route,
            ],
          ),
          StatefulShellBranch(
            routes: [
              AnalyticsRouterConfig.route,
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});

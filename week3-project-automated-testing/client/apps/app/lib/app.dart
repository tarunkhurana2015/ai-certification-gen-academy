import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_feature/home_feature.dart';
import 'package:browse_feature/browse_feature.dart';
import 'package:search_feature/search_feature.dart';
import 'package:library_feature/library_feature.dart';
import 'package:catalog_feature/catalog_feature.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:movies_core/movies_core.dart';
import 'l10n/generated/generated_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'bootstrap/app_config.dart';
import 'bootstrap/dependency_bindings.dart';

class MoviesApp extends StatefulWidget {
  const MoviesApp({
    super.key,
    this.config = const AppConfig(),
    this.dependencies,
  });
  final AppConfig config;
  final AppDependencies? dependencies;
  @override
  State<MoviesApp> createState() => _MoviesAppState();
}

class _MoviesAppState extends State<MoviesApp> {
  late final dependencies =
      widget.dependencies ?? createDependencies(widget.config);
  late final router = createAppRouter(config: widget.config);
  @override
  void dispose() {
    router.dispose();
    unawaited(dependencies.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderScope(
    retry: (_, _) => null,
    overrides: [
      catalogModeProvider.overrideWithValue(
        widget.config.isFixture ? 'fixture' : 'live',
      ),
      discoveryRepositoryProvider.overrideWithValue(dependencies.discovery),
      movieRepositoryProvider.overrideWithValue(dependencies.movies),
      personRepositoryProvider.overrideWithValue(dependencies.people),
      artworkConfigurationRepositoryProvider.overrideWithValue(
        dependencies.artwork,
      ),
      favoritesRepositoryProvider.overrideWithValue(dependencies.favorites),
      externalLinkGatewayProvider.overrideWithValue(dependencies.externalLinks),
      clockProvider.overrideWithValue(dependencies.clock),
      artworkConfigurationEnabledProvider.overrideWithValue(
        dependencies.configuredArtworkSource != null,
      ),
      for (final pair in [
        (artworkSourceProvider, ImageKind.poster),
        (backdropSourceProvider, ImageKind.backdrop),
        (profileSourceProvider, ImageKind.profile),
      ])
        pair.$1.overrideWith((ref) {
          final builder = dependencies.configuredArtworkSource;
          if (builder == null) return dependencies.artworkSource;
          final configuration = ref.watch(artworkConfigurationProvider).data;
          return (path) => configuration == null
              ? null
              : builder(configuration, path, pair.$2);
        }),
      linksAreSimulatedProvider.overrideWithValue(dependencies.simulatedLinks),
    ],
    child: MaterialApp.router(
      title: 'Movies',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      locale: const Locale('en'),
      supportedLocales: MoviesLocalizations.supportedLocales,
      localizationsDelegates: [
        ...MoviesLocalizations.localizationsDelegates,
        MoviesUiLocalizations.delegate,
        CatalogFeatureLocalizations.delegate,
        HomeFeatureLocalizations.delegate,
        BrowseFeatureLocalizations.delegate,
        SearchFeatureLocalizations.delegate,
        LibraryFeatureLocalizations.delegate,
      ],
    ),
  );
}

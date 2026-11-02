import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movies_ui/movies_ui.dart';
import 'package:catalog_feature/catalog_feature.dart';

class AboutView extends ConsumerWidget {
  const AboutView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => ContentWidth(
    child: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('About Movies'),
          leading: IconButton(
            tooltip: 'Back',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(
            pagePadding(MediaQuery.sizeOf(context).width),
          ),
          sliver: SliverList.list(
            children: [
              Text('Movies', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              const Text(
                'Follow your curiosity. Discover movies and the people behind them.',
              ),
              const SizedBox(height: 32),
              const Text(
                'Movie data & credits',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(
                    'assets/branding/tmdb-logo.png',
                    package: 'home_feature',
                    width: 180,
                    semanticLabel: 'TMDB logo',
                  ),
                ),
              ),
              const Text(
                'TMDB supplies the live movie catalog, credits, artwork, and ratings.',
              ),
              const SizedBox(height: 16),
              Semantics(
                identifier: 'movies.home.about.notice',
                child: Text(
                  'This product uses the TMDB API but is not endorsed or certified by TMDB.',
                  key: ValueKey('movies.home.about.notice'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                key: const ValueKey('movies.home.about.tmdb_link'),
                onPressed: () async {
                  final result = await ref
                      .read(externalLinkGatewayProvider)
                      .openAttributionLink(
                        Uri.https('www.themoviedb.org', '/'),
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result.failureOrNull != null
                            ? 'TMDB could not be opened.'
                            : ref.read(linksAreSimulatedProvider)
                            ? 'Demo: link opening simulated'
                            : 'Opening TMDB in your browser.',
                      ),
                    ),
                  );
                },
                child: const Text('Visit TMDB ↗'),
              ).identified('movies.home.about.tmdb_link'),
              if (ref.watch(catalogModeProvider) == 'fixture')
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text(
                    'Demo data uses fictional movies and people, with original local artwork. Browser links are simulated.',
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

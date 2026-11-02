import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../state/catalog_page_state.dart';
import '../views/catalog_view.dart';

List<RouteBase> buildCatalogRoutes({required String branch}) {
  GoRoute route(
    String suffix,
    String name,
    CatalogKind kind,
    String parameter,
  ) => GoRoute(
    path: '/$branch/$suffix',
    name: '$branch.$name',
    builder: (context, state) => Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CatalogView(
        identity: (
          branch: branch,
          entry: state.pageKey.value,
          id: int.tryParse(state.pathParameters[parameter] ?? '') ?? 0,
          kind: kind,
        ),
      ),
    ),
  );
  return [
    route('movie/:movieId', 'movie', CatalogKind.movie, 'movieId'),
    route('movie/:movieId/cast', 'cast', CatalogKind.cast, 'movieId'),
    route('person/:personId', 'person', CatalogKind.person, 'personId'),
    route(
      'person/:personId/filmography',
      'filmography',
      CatalogKind.filmography,
      'personId',
    ),
    route(
      'collection/:collectionId',
      'collection',
      CatalogKind.collection,
      'collectionId',
    ),
    route('movie/:movieId/related', 'related', CatalogKind.related, 'movieId'),
    route(
      'movie/:movieId/images',
      'movieImages',
      CatalogKind.movieImages,
      'movieId',
    ),
    route(
      'person/:personId/images',
      'personImages',
      CatalogKind.personImages,
      'personId',
    ),
    route('movie/:movieId/reviews', 'reviews', CatalogKind.reviews, 'movieId'),
  ];
}

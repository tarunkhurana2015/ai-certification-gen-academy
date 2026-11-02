import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/home_view.dart';
import '../views/home_listing_view.dart';
import '../views/about_view.dart';

List<RouteBase> buildHomeRoutes() => [
  GoRoute(
    path: '/home',
    name: 'home.root',
    builder: (context, state) => const HomeView(),
  ),
  GoRoute(
    path: '/home/about',
    name: 'home.about',
    builder: (context, state) => Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const AboutView(),
    ),
  ),
  GoRoute(
    path: '/home/list/:source',
    name: 'home.list',
    builder: (context, state) => Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: HomeListingView(
        identity: (
          entry: state.pageKey.value,
          source: state.pathParameters['source']!,
          seed: int.tryParse(state.uri.queryParameters['seed'] ?? ''),
          label: state.uri.queryParameters['label'] ?? 'Movies',
        ),
      ),
    ),
  ),
];

import 'package:go_router/go_router.dart';
import '../views/search_view.dart';

List<RouteBase> buildSearchRoutes() => [
  GoRoute(
    path: '/search',
    name: 'search.root',
    builder: (context, state) => const SearchView(),
  ),
];

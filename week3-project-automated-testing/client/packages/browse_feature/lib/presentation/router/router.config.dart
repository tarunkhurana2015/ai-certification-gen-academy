import 'package:go_router/go_router.dart';
import '../views/browse_view.dart';

List<RouteBase> buildBrowseRoutes() => [
  GoRoute(
    path: '/browse',
    name: 'browse.root',
    builder: (context, state) => const BrowseView(),
  ),
];

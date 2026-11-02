import 'package:go_router/go_router.dart';
import '../views/library_view.dart';

List<RouteBase> buildLibraryRoutes() => [
  GoRoute(
    path: '/library',
    name: 'library.root',
    builder: (context, state) => const LibraryView(),
  ),
];

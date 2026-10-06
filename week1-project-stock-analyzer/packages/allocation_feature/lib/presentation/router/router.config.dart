import 'package:go_router/go_router.dart';
import '../views/allocation_view.dart';

class AllocationRouterConfig {
  static const String routeName = 'allocation';
  static const String routePath = '/allocation';

  static final RouteBase route = GoRoute(
    path: routePath,
    name: routeName,
    builder: (context, state) => const AllocationView(),
  );
}

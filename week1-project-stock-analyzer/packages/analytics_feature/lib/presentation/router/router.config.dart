import 'package:go_router/go_router.dart';
import '../views/analytics_view.dart';

class AnalyticsRouterConfig {
  static const String routeName = 'analytics';
  static const String routePath = '/analytics';

  static final RouteBase route = GoRoute(
    path: routePath,
    name: routeName,
    builder: (context, state) => const AnalyticsView(),
  );
}

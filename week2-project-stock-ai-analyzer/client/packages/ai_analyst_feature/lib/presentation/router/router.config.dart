import 'package:go_router/go_router.dart';
import '../views/kpi_dashboard_view.dart';

class AiAnalystRouterConfig {
  static const String routeName = 'ai-analyst';
  static const String routePath = '/ai-analyst';

  static final RouteBase route = GoRoute(
    path: routePath,
    name: routeName,
    builder: (context, state) => const KpiDashboardView(),
  );
}

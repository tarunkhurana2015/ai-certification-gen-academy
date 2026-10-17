import 'package:go_router/go_router.dart';
import '../views/portfolio_ingest_view.dart';

class PortfolioRouterConfig {
  static const String routeName = 'import';
  static const String routePath = '/import';

  static final RouteBase route = GoRoute(
    path: routePath,
    name: routeName,
    builder: (context, state) => const PortfolioIngestView(),
  );
}

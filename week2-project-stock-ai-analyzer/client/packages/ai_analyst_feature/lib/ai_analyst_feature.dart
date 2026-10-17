library ai_analyst_feature;

// Domain Entities
export 'domain/entities/quarterly_kpis.dart';

// Data
export 'data/datasources/mock_kpi_datasource.dart';

// Presentation State & ViewModel
export 'presentation/state/kpi_dashboard_state.dart';
export 'presentation/viewmodel/kpi_dashboard_viewmodel.dart';

// Presentation Views & Widgets
export 'presentation/views/kpi_dashboard_view.dart';
export 'presentation/views/widgets/executive_summary_card.dart';
export 'presentation/views/widgets/kpi_metric_card.dart';
export 'presentation/views/widgets/kpi_scorecard_grid.dart';
export 'presentation/views/widgets/margin_trend_chart.dart';
export 'presentation/views/widgets/report_selector_header.dart';
export 'presentation/views/widgets/report_ingestion_panel.dart';
export 'presentation/views/widgets/ai_analyst_chat_window.dart';

// Router
export 'presentation/router/router.config.dart';

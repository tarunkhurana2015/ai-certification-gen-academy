import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/remote_kpi_datasource.dart';
import '../../../domain/entities/quarterly_kpis.dart';
import '../viewmodel/kpi_dashboard_viewmodel.dart';
import 'widgets/ai_analyst_chat_window.dart';
import 'widgets/executive_summary_card.dart';
import 'widgets/kpi_scorecard_grid.dart';
import 'widgets/margin_trend_chart.dart';
import 'widgets/report_ingestion_panel.dart';
import 'widgets/report_selector_header.dart';

class KpiDashboardView extends ConsumerStatefulWidget {
  const KpiDashboardView({super.key});

  @override
  ConsumerState<KpiDashboardView> createState() => _KpiDashboardViewState();
}

class _KpiDashboardViewState extends ConsumerState<KpiDashboardView> {
  bool _showIngestionPanel = false;

  void _openMobileChatSheet(BuildContext context, QuarterlyKpis report) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return AiAnalystChatWindow(
              report: report,
              onClose: () => Navigator.pop(context),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kpiDashboardViewModelProvider);
    final viewModel = ref.read(kpiDashboardViewModelProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Hydrating Financial KPIs from SQLite...'),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Card(
            color: colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: colorScheme.error, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to Load Financial Dashboard',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => viewModel.loadReports(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final report = state.selectedReport;
    if (report == null) {
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReportSelectorHeader(
                      selectedReport: null,
                      availableReports: state.availableReports,
                      onReportSelected: (selected) => viewModel.selectReport(selected),
                      onIngestTap: null,
                    ),
                    const SizedBox(height: 20),
                    ReportIngestionPanel(
                      onReportIngested: (newReport) {
                        viewModel.addAndSelectReport(newReport);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Successfully ingested and indexed ${newReport.ticker} ${newReport.fiscalPeriodDisplay}!',
                            ),
                            backgroundColor: Colors.green.shade800,
                          ),
                        );
                      },
                      onCancel: null,
                      remoteDataSource: ref.read(remoteKpiDataSourceProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 960;

        final dashboardContent = SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportSelectorHeader(
                selectedReport: report,
                availableReports: state.availableReports,
                onReportSelected: (selected) => viewModel.selectReport(selected),
                onIngestTap: () => setState(() => _showIngestionPanel = !_showIngestionPanel),
              ),
              if (_showIngestionPanel) ...[
                const SizedBox(height: 16),
                ReportIngestionPanel(
                  onReportIngested: (newReport) {
                    viewModel.addAndSelectReport(newReport);
                    setState(() => _showIngestionPanel = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Successfully ingested and indexed ${newReport.ticker} ${newReport.fiscalPeriodDisplay}!'),
                        backgroundColor: Colors.green.shade800,
                      ),
                    );
                  },
                  onCancel: () => setState(() => _showIngestionPanel = false),
                  remoteDataSource: ref.read(remoteKpiDataSourceProvider),
                ),
              ],
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, headerConstraints) {
                  final isSideBySide = headerConstraints.maxWidth >= 640;
                  if (isSideBySide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ExecutiveSummaryCard(
                            summaryBullets: report.summaryBullets,
                            companyName: report.companyName,
                            fiscalPeriod: report.fiscalPeriodDisplay,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: MarginTrendChart(kpis: report),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExecutiveSummaryCard(
                          summaryBullets: report.summaryBullets,
                          companyName: report.companyName,
                          fiscalPeriod: report.fiscalPeriodDisplay,
                        ),
                        const SizedBox(height: 14),
                        MarginTrendChart(kpis: report),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 18),
              KpiScorecardGrid(kpis: report),
              const SizedBox(height: 36),
            ],
          ),
        );

        if (isDesktop) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: dashboardContent,
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  SizedBox(
                    width: 380,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AiAnalystChatWindow(
                        report: report,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Mobile / Compact screen
        return Scaffold(
          body: SafeArea(child: dashboardContent),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openMobileChatSheet(context, report),
            icon: const Icon(Icons.psychology),
            label: const Text('AI Copilot'),
          ),
        );
      },
    );
  }
}


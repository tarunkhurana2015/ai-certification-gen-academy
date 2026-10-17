import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/mock_kpi_datasource.dart';
import '../../domain/entities/quarterly_kpis.dart';
import '../state/kpi_dashboard_state.dart';

class KpiDashboardViewModel extends Notifier<KpiDashboardState> {
  @override
  KpiDashboardState build() {
    final initialReports = MockKpiDataSource.benchmarkReports;
    return KpiDashboardState(
      isLoading: false,
      availableReports: initialReports,
      selectedReport: initialReports.isNotEmpty ? initialReports.first : null,
    );
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final reports = await MockKpiDataSource.getAvailableReports();
      state = state.copyWith(
        isLoading: false,
        availableReports: reports,
        selectedReport: reports.isNotEmpty ? reports.first : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load KPI reports: $e',
      );
    }
  }

  void selectReport(QuarterlyKpis report) {
    state = state.copyWith(selectedReport: report);
  }

  void selectReportByDocId(String docId) {
    final match = state.availableReports.where((r) => r.documentId == docId).firstOrNull;
    if (match != null) {
      state = state.copyWith(selectedReport: match);
    }
  }

  void addAndSelectReport(QuarterlyKpis newReport) {
    final existingIndex = state.availableReports.indexWhere(
      (r) => r.documentId == newReport.documentId,
    );
    final updatedList = List<QuarterlyKpis>.from(state.availableReports);
    if (existingIndex >= 0) {
      updatedList[existingIndex] = newReport;
    } else {
      updatedList.insert(0, newReport);
    }
    state = state.copyWith(
      availableReports: updatedList,
      selectedReport: newReport,
    );
  }
}

final kpiDashboardViewModelProvider =
    NotifierProvider<KpiDashboardViewModel, KpiDashboardState>(KpiDashboardViewModel.new);


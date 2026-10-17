import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote_kpi_datasource.dart';
import '../../domain/entities/quarterly_kpis.dart';
import '../state/kpi_dashboard_state.dart';

class KpiDashboardViewModel extends Notifier<KpiDashboardState> {
  @override
  KpiDashboardState build() {
    return const KpiDashboardState(
      isLoading: false,
      availableReports: [],
      selectedReport: null,
    );
  }

  /// Loads available reports by querying the FastAPI backend via [RemoteKpiDataSource].
  ///
  /// Automatically falls back to mock benchmark data if the backend is unreachable.
  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final remoteDataSource = ref.read(remoteKpiDataSourceProvider);
      final reports = await remoteDataSource.getAvailableReports();
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

  /// Uploads a PDF to the live FastAPI ingestion pipeline and adds the extracted
  /// record to the dashboard state.
  Future<QuarterlyKpis> uploadReport({
    required List<int> fileBytes,
    required String fileName,
    String? ticker,
    String? quarter,
    int? year,
    bool force = true,
  }) async {
    final remoteDataSource = ref.read(remoteKpiDataSourceProvider);
    final report = await remoteDataSource.uploadAndIngestPdf(
      fileBytes: fileBytes,
      fileName: fileName,
      ticker: ticker,
      quarter: quarter,
      year: year,
      force: force,
    );
    addAndSelectReport(report);
    return report;
  }
}

final kpiDashboardViewModelProvider =
    NotifierProvider<KpiDashboardViewModel, KpiDashboardState>(KpiDashboardViewModel.new);

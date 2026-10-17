import '../../domain/entities/quarterly_kpis.dart';

class KpiDashboardState {
  final bool isLoading;
  final QuarterlyKpis? selectedReport;
  final List<QuarterlyKpis> availableReports;
  final String? errorMessage;

  const KpiDashboardState({
    this.isLoading = false,
    this.selectedReport,
    this.availableReports = const [],
    this.errorMessage,
  });

  KpiDashboardState copyWith({
    bool? isLoading,
    QuarterlyKpis? selectedReport,
    List<QuarterlyKpis>? availableReports,
    String? errorMessage,
  }) {
    return KpiDashboardState(
      isLoading: isLoading ?? this.isLoading,
      selectedReport: selectedReport ?? this.selectedReport,
      availableReports: availableReports ?? this.availableReports,
      errorMessage: errorMessage,
    );
  }
}

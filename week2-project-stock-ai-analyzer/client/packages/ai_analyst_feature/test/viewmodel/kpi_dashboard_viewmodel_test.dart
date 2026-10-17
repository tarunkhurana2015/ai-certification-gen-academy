import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_analyst_feature/ai_analyst_feature.dart';

void main() {
  group('QuarterlyKpis Entity & JSON Tests', () {
    test('Correctly serializes and deserializes benchmark Tesla Q2 report', () {
      final sample = MockKpiDataSource.benchmarkReports.first;
      final json = sample.toJson();
      final reconstructed = QuarterlyKpis.fromJson(json);

      expect(reconstructed.ticker, equals('TSLA'));
      expect(reconstructed.fiscalPeriodDisplay, equals('Q2 2026'));
      expect(reconstructed.profitability.totalRevenueMillions, equals(25500.0));
      expect(reconstructed.profitability.grossMarginPct, equals(17.95));
      expect(reconstructed.cashFlow.freeCashFlowMillions, equals(1340.0));
      expect(reconstructed.balanceSheet.netCashMillions, equals(25370.0));
    });
  });

  group('KpiDashboardViewModel Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initializes with empty reports and null selection until PDF is ingested', () {
      final state = container.read(kpiDashboardViewModelProvider);

      expect(state.isLoading, isFalse);
      expect(state.availableReports.isEmpty, isTrue);
      expect(state.selectedReport, isNull);
    });

    test('addAndSelectReport adds ingested report and updates selectedReport', () {
      final notifier = container.read(kpiDashboardViewModelProvider.notifier);
      final sample = MockKpiDataSource.benchmarkReports.first;

      notifier.addAndSelectReport(sample);

      final state = container.read(kpiDashboardViewModelProvider);
      expect(state.availableReports.length, equals(1));
      expect(state.selectedReport?.ticker, equals('TSLA'));
      expect(state.selectedReport?.fiscalQuarter, equals('Q2'));
    });

    test('selectReport updates selectedReport state', () {
      final notifier = container.read(kpiDashboardViewModelProvider.notifier);
      for (final r in MockKpiDataSource.benchmarkReports) {
        notifier.addAndSelectReport(r);
      }
      final initial = container.read(kpiDashboardViewModelProvider);

      final appleReport = initial.availableReports.firstWhere((r) => r.ticker == 'AAPL');
      notifier.selectReport(appleReport);

      final updated = container.read(kpiDashboardViewModelProvider);
      expect(updated.selectedReport?.ticker, equals('AAPL'));
      expect(updated.selectedReport?.profitability.grossMarginPct, equals(46.58));
    });

    test('selectReportByDocId selects report matching doc ID', () {
      final notifier = container.read(kpiDashboardViewModelProvider.notifier);
      for (final r in MockKpiDataSource.benchmarkReports) {
        notifier.addAndSelectReport(r);
      }
      notifier.selectReportByDocId('doc_tsla_2026_q1');

      final updated = container.read(kpiDashboardViewModelProvider);
      expect(updated.selectedReport?.documentId, equals('doc_tsla_2026_q1'));
      expect(updated.selectedReport?.fiscalQuarter, equals('Q1'));
    });

    test('loadReports refreshes available reports asynchronously', () async {
      final notifier = container.read(kpiDashboardViewModelProvider.notifier);
      await notifier.loadReports();

      final updated = container.read(kpiDashboardViewModelProvider);
      expect(updated.isLoading, isFalse);
      expect(updated.availableReports.length, greaterThanOrEqualTo(3));
    });
  });
}


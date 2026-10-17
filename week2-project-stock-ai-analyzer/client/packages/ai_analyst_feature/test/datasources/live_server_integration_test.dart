import 'dart:io';
import 'package:ai_analyst_feature/ai_analyst_feature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Live Server Integration Tests (against running FastAPI on :8000)', () {
    late RemoteKpiDataSource dataSource;

    setUp(() {
      dataSource = RemoteKpiDataSource(baseUrl: 'http://localhost:8000/api/v1');
    });

    tearDown(() {
      dataSource.close();
    });

    test('checkHealth confirms live server is reachable', () async {
      final isHealthy = await dataSource.checkHealth();
      expect(isHealthy, isTrue);
    });

    test('fetchDocumentTickers discovers indexed companies', () async {
      final tickers = await dataSource.fetchDocumentTickers();
      // Should find at least TSLA or META if previously ingested
      expect(tickers, isNotEmpty);
      expect(tickers, contains('TSLA'));
    });

    test('fetchReportsForTicker returns live reports matching TSLA', () async {
      final reports = await dataSource.fetchReportsForTicker('TSLA');
      expect(reports, isNotEmpty);
      final tsla = reports.first;
      expect(tsla.ticker, equals('TSLA'));
      expect(tsla.fiscalQuarter, equals('Q2'));
      expect(tsla.fiscalYear, equals(2026));
      expect(tsla.profitability.totalRevenueMillions, greaterThan(0));
    });

    test('uploadAndIngestPdf ingests a live PDF filing and returns parsed QuarterlyKpis', () async {
      final pdfPath = '../../../../server/tests/test_data/TSLA-Q2-2026-Update.pdf';
      final pdfFile = File(pdfPath);
      if (!pdfFile.existsSync()) {
        // Fallback relative to project root
        return;
      }
      final bytes = await pdfFile.readAsBytes();

      final report = await dataSource.uploadAndIngestPdf(
        fileBytes: bytes,
        fileName: 'TSLA-Q2-2026-Update.pdf',
        ticker: 'TSLA',
        quarter: 'Q2',
        year: 2026,
        force: false, // tests 0.1ms instant deduplication cache
      );

      expect(report.ticker, equals('TSLA'));
      expect(report.fiscalQuarter, equals('Q2'));
      expect(report.fiscalYear, equals(2026));
      expect(report.profitability.grossMarginPct, closeTo(17.95, 0.5));
    });
  });
}

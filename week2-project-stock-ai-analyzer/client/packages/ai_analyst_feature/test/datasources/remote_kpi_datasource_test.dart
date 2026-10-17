import 'dart:convert';
import 'package:ai_analyst_feature/ai_analyst_feature.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('RemoteKpiDataSource Unit Tests', () {
    test('fetchReportsForTicker parses client_reports JSON into QuarterlyKpis list', () async {
      final sample = MockKpiDataSource.benchmarkReports.first;
      final mockResponse = jsonEncode({
        'ticker': 'TSLA',
        'reports_count': 1,
        'client_reports': [sample.toJson()],
      });

      final client = MockClient((request) async {
        expect(request.url.path, equals('/api/v1/kpi/TSLA'));
        expect(request.method, equals('GET'));
        return http.Response(mockResponse, 200);
      });

      final dataSource = RemoteKpiDataSource(
        baseUrl: 'http://localhost:8000/api/v1',
        client: client,
      );

      final reports = await dataSource.fetchReportsForTicker('TSLA');
      expect(reports.length, equals(1));
      expect(reports.first.ticker, equals('TSLA'));
      expect(reports.first.profitability.totalRevenueMillions, equals(25500.0));
      expect(reports.first.cashFlow.freeCashFlowMillions, equals(1340.0));
    });

    test('fetchLatestReport returns single QuarterlyKpis', () async {
      final sample = MockKpiDataSource.benchmarkReports.first;
      final mockResponse = jsonEncode({
        'ticker': 'TSLA',
        'client_report': sample.toJson(),
      });

      final client = MockClient((request) async {
        expect(request.url.path, equals('/api/v1/kpi/TSLA/latest'));
        return http.Response(mockResponse, 200);
      });

      final dataSource = RemoteKpiDataSource(
        baseUrl: 'http://localhost:8000/api/v1',
        client: client,
      );

      final report = await dataSource.fetchLatestReport('TSLA');
      expect(report, isNotNull);
      expect(report?.ticker, equals('TSLA'));
      expect(report?.fiscalPeriodDisplay, equals('Q2 2026'));
    });

    test('fetchDocumentTickers extracts unique tickers from catalog', () async {
      final mockCatalog = jsonEncode([
        {'id': '1', 'ticker': 'TSLA', 'fiscal_quarter': 'Q2', 'fiscal_year': 2026},
        {'id': '2', 'ticker': 'meta', 'fiscal_quarter': 'Q2', 'fiscal_year': 2026},
      ]);

      final client = MockClient((request) async {
        expect(request.url.path, equals('/api/v1/documents'));
        return http.Response(mockCatalog, 200);
      });

      final dataSource = RemoteKpiDataSource(
        baseUrl: 'http://localhost:8000/api/v1',
        client: client,
      );

      final tickers = await dataSource.fetchDocumentTickers();
      expect(tickers, containsAll(['TSLA', 'META']));
    });

    test('getAvailableReports falls back to mock data if backend throws exception', () async {
      final client = MockClient((request) async {
        throw http.ClientException('Connection refused');
      });

      final dataSource = RemoteKpiDataSource(
        baseUrl: 'http://localhost:8000/api/v1',
        client: client,
      );

      final reports = await dataSource.getAvailableReports();
      expect(reports.isNotEmpty, isTrue);
      expect(reports.any((r) => r.ticker == 'TSLA'), isTrue);
    });

    test('uploadAndIngestPdf sends multipart request and parses client_kpis', () async {
      final sample = MockKpiDataSource.benchmarkReports.first;
      final mockUploadResponse = jsonEncode({
        'task_id': 'task-123',
        'document_id': 'doc-123',
        'status': 'COMPLETED',
        'message': 'Successfully ingested TSLA Q2 2026',
        'is_duplicate': false,
        'ticker': 'TSLA',
        'fiscal_quarter': 'Q2',
        'fiscal_year': 2026,
        'client_kpis': sample.toJson(),
      });

      final client = MockClient((request) async {
        expect(request.url.path, equals('/api/v1/ingestion/upload'));
        expect(request.method, equals('POST'));
        return http.Response(mockUploadResponse, 200);
      });

      final dataSource = RemoteKpiDataSource(
        baseUrl: 'http://localhost:8000/api/v1',
        client: client,
      );

      final result = await dataSource.uploadAndIngestPdf(
        fileBytes: [0x25, 0x50, 0x44, 0x46],
        fileName: 'TSLA-Q2-2026.pdf',
        ticker: 'TSLA',
        quarter: 'Q2',
        year: 2026,
      );

      expect(result.ticker, equals('TSLA'));
      expect(result.fiscalQuarter, equals('Q2'));
      expect(result.profitability.totalRevenueMillions, equals(25500.0));
    });
  });
}

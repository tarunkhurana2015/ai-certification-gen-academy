import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/quarterly_kpis.dart';
import 'mock_kpi_datasource.dart';

/// Custom cross-platform exception for backend API errors.
class RemoteApiException implements Exception {
  final String message;
  final Uri? uri;
  final int? statusCode;

  const RemoteApiException(this.message, {this.uri, this.statusCode});

  @override
  String toString() => 'RemoteApiException: $message (statusCode: $statusCode, uri: $uri)';
}

/// REST API DataSource communicating with the Python FastAPI backend server.
///
/// Implements live query and multipart upload operations against:
///  - `GET  /health`
///  - `GET  /api/v1/kpi/{ticker}`
///  - `GET  /api/v1/kpi/{ticker}/latest`
///  - `GET  /api/v1/documents`
///  - `POST /api/v1/ingestion/upload`
///
/// Automatically falls back to [MockKpiDataSource] if the server is offline or unreachable,
/// ensuring robust offline-first resilience for headless testing and disconnected devices.
class RemoteKpiDataSource {
  final String baseUrl;
  final http.Client _client;

  RemoteKpiDataSource({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  /// Default API root dynamically adapted for the target runtime platform.
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/v1';
    }
    try {
      if (io.Platform.isAndroid) {
        // Android Emulator loops back to development host via 10.0.2.2
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (_) {}
    // iOS Simulator, macOS Desktop, and local Linux/Windows host
    return 'http://localhost:8000/api/v1';
  }

  /// Fast liveness probe to verify if FastAPI backend is currently running.
  Future<bool> checkHealth() async {
    try {
      final healthUrl = baseUrl.replaceAll('/api/v1', '/health');
      final uri = Uri.parse(healthUrl);
      final response = await _client.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(milliseconds: 350));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Fetches all quarterly KPI reports for a given stock ticker.
  Future<List<QuarterlyKpis>> fetchReportsForTicker(String ticker) async {
    final uri = Uri.parse('$baseUrl/kpi/${ticker.toUpperCase()}');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final clientReports = data['client_reports'] as List<dynamic>? ?? [];
      return clientReports
          .map((r) => QuarterlyKpis.fromJson(r as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw RemoteApiException(
        'Server returned ${response.statusCode}: ${response.body}',
        uri: uri,
        statusCode: response.statusCode,
      );
    }
  }

  /// Fetches the single most recent quarterly report for a ticker.
  Future<QuarterlyKpis?> fetchLatestReport(String ticker) async {
    final uri = Uri.parse('$baseUrl/kpi/${ticker.toUpperCase()}/latest');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final clientReport = data['client_report'] as Map<String, dynamic>?;
      if (clientReport != null) {
        return QuarterlyKpis.fromJson(clientReport);
      }
      return null;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw RemoteApiException(
        'Server returned ${response.statusCode}: ${response.body}',
        uri: uri,
        statusCode: response.statusCode,
      );
    }
  }

  /// Lists all documents in the database to discover available tickers.
  Future<List<String>> fetchDocumentTickers() async {
    final uri = Uri.parse('$baseUrl/documents');
    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List<dynamic>;
      final tickers = <String>{};
      for (final item in list) {
        if (item is Map<String, dynamic> && item['ticker'] != null) {
          tickers.add(item['ticker'].toString().toUpperCase());
        }
      }
      return tickers.toList();
    }
    return [];
  }

  /// Loads available reports from the live server.
  ///
  /// Falls back seamlessly to [MockKpiDataSource.getAvailableReports] if the server
  /// is offline, unreachable, or times out.
  Future<List<QuarterlyKpis>> getAvailableReports({
    List<String> defaultTickers = const ['TSLA', 'META'],
  }) async {
    try {
      // Fast check if server is reachable before executing individual queries
      final isAlive = await checkHealth();
      if (!isAlive) {
        return await MockKpiDataSource.getAvailableReports();
      }

      // 1. Discover tickers present in the server database
      var tickersToQuery = defaultTickers;
      try {
        final serverTickers = await fetchDocumentTickers();
        if (serverTickers.isNotEmpty) {
          tickersToQuery = serverTickers;
        }
      } catch (_) {
        // Use default tickers if document catalog endpoint fails
      }

      // 2. Query reports for each ticker
      final List<QuarterlyKpis> aggregated = [];
      for (final ticker in tickersToQuery) {
        try {
          final reports = await fetchReportsForTicker(ticker);
          aggregated.addAll(reports);
        } catch (_) {
          // Continue attempting remaining tickers
        }
      }

      if (aggregated.isNotEmpty) {
        return aggregated;
      }

      // If server returned 0 reports (empty DB), fallback to benchmark reports
      return await MockKpiDataSource.getAvailableReports();
    } catch (e) {
      debugPrint('[RemoteKpiDataSource] Backend unreachable, falling back to mock data: $e');
      return await MockKpiDataSource.getAvailableReports();
    }
  }

  /// Uploads a PDF filing to `/api/v1/ingestion/upload` and receives real extracted GAAP KPIs.
  Future<QuarterlyKpis> uploadAndIngestPdf({
    required List<int> fileBytes,
    required String fileName,
    String? ticker,
    String? quarter,
    int? year,
    bool force = true,
  }) async {
    final uri = Uri.parse('$baseUrl/ingestion/upload');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    request.fields['force'] = force.toString();
    request.fields['save_artifacts'] = 'true';
    if (ticker != null && ticker.trim().isNotEmpty) {
      request.fields['ticker'] = ticker.trim().toUpperCase();
    }
    if (quarter != null && quarter.trim().isNotEmpty) {
      request.fields['quarter'] = quarter.trim().toUpperCase();
    }
    if (year != null) {
      request.fields['year'] = year.toString();
    }

    final streamedResponse = await _client.send(request).timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final clientKpis = data['client_kpis'] as Map<String, dynamic>?;
      if (clientKpis != null) {
        return QuarterlyKpis.fromJson(clientKpis);
      }

      // If client_kpis was omitted (e.g. duplicate check), fetch latest report
      final resolvedTicker = (data['ticker'] as String?) ?? ticker ?? 'TSLA';
      final latest = await fetchLatestReport(resolvedTicker);
      if (latest != null) {
        return latest;
      }
      throw Exception('Ingestion completed but no KPI record could be loaded.');
    } else {
      throw RemoteApiException(
        'Ingestion failed with status ${response.statusCode}: ${response.body}',
        uri: uri,
        statusCode: response.statusCode,
      );
    }
  }

  void close() {
    _client.close();
  }
}

/// Riverpod provider for the RemoteKpiDataSource singleton.
final remoteKpiDataSourceProvider = Provider<RemoteKpiDataSource>((ref) {
  final dataSource = RemoteKpiDataSource();
  ref.onDispose(() => dataSource.close());
  return dataSource;
});

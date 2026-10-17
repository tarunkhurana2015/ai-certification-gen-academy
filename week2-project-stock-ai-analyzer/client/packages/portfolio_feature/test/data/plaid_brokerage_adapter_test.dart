import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio_feature/portfolio_feature.dart';

class MockHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) handler;

  MockHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlaidBrokerageAdapter Tests', () {
    test('connects successfully in Sandbox mode and loads demo positions', () async {
      final adapter = PlaidBrokerageAdapter();
      expect(adapter.isConnectedToLiveBrokerage, false);

      final result = await adapter.connectBrokerageAccount(
        authToken: 'access-sandbox-plaid-demo',
        institutionName: 'First Platypus Bank',
        isSandbox: true,
      );

      expect(result is Success<bool>, true);
      expect((result as Success<bool>).data, true);
      expect(adapter.isConnectedToLiveBrokerage, true);
      expect(adapter.isSandboxMode, true);
      expect(adapter.institutionName, 'First Platypus Bank');
      expect(adapter.lastSyncTime, isNotNull);

      final holdings = await adapter.fetchHoldings();
      expect(holdings is Success<List<HoldingPosition>>, true);
      final list = (holdings as Success<List<HoldingPosition>>).data;
      expect(list.length, 6);
      expect(list.any((h) => h.symbol == 'VOO'), true);
      expect(list.any((h) => h.symbol == 'AAPL'), true);
      expect(list.any((h) => h.symbol == 'NVDA'), true);
    });

    test('Step 2: createLinkToken sends correct body and returns link_token', () async {
      final client = MockHttpClient((request) async {
        expect(request.url.path, '/link/token/create');
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(request.headers['PLAID-CLIENT-ID'], 'test_client_id');
        expect(request.headers['PLAID-SECRET'], 'test_secret');

        final body = jsonDecode(await (request as http.Request).body) as Map<String, dynamic>;
        expect(body['client_id'], 'test_client_id');
        expect(body['secret'], 'test_secret');
        expect(body['products'], ['investments']);
        expect(body['client_name'], contains('GenStockFolio'));

        return http.Response(
          jsonEncode({
            'link_token': 'link-sandbox-12345678-abcd',
            'expiration': '2026-10-06T12:00:00Z',
            'request_id': 'req_link_1',
          }),
          200,
        );
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final result = await adapter.createLinkToken(
        clientId: 'test_client_id',
        secret: 'test_secret',
      );

      expect(result is Success<String>, true);
      expect((result as Success<String>).data, 'link-sandbox-12345678-abcd');
      expect(adapter.linkToken, 'link-sandbox-12345678-abcd');
    });

    test('Step 3: createSandboxPublicToken returns public_token', () async {
      final client = MockHttpClient((request) async {
        expect(request.url.path, '/sandbox/public_token/create');
        expect(request.headers['PLAID-CLIENT-ID'], 'test_client_id');
        expect(request.headers['PLAID-SECRET'], 'test_secret');

        final body = jsonDecode(await (request as http.Request).body) as Map<String, dynamic>;
        expect(body['institution_id'], 'ins_1');
        expect(body['initial_products'], ['investments']);

        return http.Response(
          jsonEncode({
            'public_token': 'public-sandbox-demo-123',
            'request_id': 'req_pub_1',
          }),
          200,
        );
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final result = await adapter.createSandboxPublicToken(
        clientId: 'test_client_id',
        secret: 'test_secret',
        institutionId: 'ins_1',
      );

      expect(result is Success<String>, true);
      expect((result as Success<String>).data, 'public-sandbox-demo-123');
      expect(adapter.publicToken, 'public-sandbox-demo-123');
    });

    test('Step 4: exchangePublicToken calls /item/public_token/exchange and stores in memory', () async {
      final client = MockHttpClient((request) async {
        expect(request.url.path, '/item/public_token/exchange');
        expect(request.headers['PLAID-CLIENT-ID'], 'test_client_id');
        expect(request.headers['PLAID-SECRET'], 'test_secret');

        final body = jsonDecode(await (request as http.Request).body) as Map<String, dynamic>;
        expect(body['public_token'], 'public-sandbox-demo-123');

        return http.Response(
          jsonEncode({
            'access_token': 'access-sandbox-perm-999',
            'item_id': 'item-sandbox-item-888',
            'request_id': 'req_exchange_1',
          }),
          200,
        );
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final result = await adapter.exchangePublicToken(
        clientId: 'test_client_id',
        secret: 'test_secret',
        publicToken: 'public-sandbox-demo-123',
      );

      expect(result is Success<Map<String, String>>, true);
      final data = (result as Success<Map<String, String>>).data;
      expect(data['access_token'], 'access-sandbox-perm-999');
      expect(data['item_id'], 'item-sandbox-item-888');
      expect(adapter.itemId, 'item-sandbox-item-888');
    });

    test('parses live Plaid /investments/holdings/get response and cross-references securities', () async {
      final mockPlaidJson = {
        'accounts': [
          {
            'account_id': 'acc_123',
            'name': 'Plaid Premier Brokerage',
            'type': 'investment',
            'subtype': 'brokerage',
          }
        ],
        'holdings': [
          {
            'account_id': 'acc_123',
            'security_id': 'sec_aapl_id',
            'quantity': 20.0,
            'cost_basis': 3600.0,
            'institution_price': 225.0,
            'institution_value': 4500.0,
          },
          {
            'account_id': 'acc_123',
            'security_id': 'sec_nvda_id',
            'quantity': 50.0,
            'cost_basis': 5500.0,
            'institution_price': 130.0,
            'institution_value': 6500.0,
          },
          {
            'account_id': 'acc_123',
            'security_id': 'sec_zero_qty',
            'quantity': 0.0,
            'cost_basis': 0.0,
            'institution_price': 50.0,
          }
        ],
        'securities': [
          {
            'security_id': 'sec_aapl_id',
            'ticker_symbol': 'AAPL',
            'name': 'Apple Inc.',
            'type': 'equity',
            'close_price': 225.0,
          },
          {
            'security_id': 'sec_nvda_id',
            'ticker_symbol': 'NVDA',
            'name': 'NVIDIA Corporation',
            'type': 'equity',
            'close_price': 130.0,
          }
        ]
      };

      final client = MockHttpClient((request) async {
        expect(request.url.path, '/investments/holdings/get');
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(request.headers['PLAID-CLIENT-ID'], 'test_client_id');
        expect(request.headers['PLAID-SECRET'], 'test_secret');
        return http.Response(jsonEncode(mockPlaidJson), 200);
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final connectResult = await adapter.connectBrokerageAccount(
        authToken: 'access-sandbox-12345',
        clientId: 'test_client_id',
        secret: 'test_secret',
        institutionName: 'Fidelity Investments (via Plaid)',
        isSandbox: false,
      );

      expect(connectResult is Success, true);
      final holdingsResult = await adapter.fetchHoldings();
      expect(holdingsResult is Success<List<HoldingPosition>>, true);

      final positions = (holdingsResult as Success<List<HoldingPosition>>).data;
      expect(positions.length, 2); // Zero quantity holding is excluded

      final aapl = positions.firstWhere((p) => p.symbol == 'AAPL');
      expect(aapl.companyName, 'Apple Inc.');
      expect(aapl.shares, 20.0);
      expect(aapl.avgCostBasis, 180.0); // 3600 / 20
      expect(aapl.currentPrice, 225.0);
      expect(aapl.sector, 'Technology');

      final nvda = positions.firstWhere((p) => p.symbol == 'NVDA');
      expect(nvda.shares, 50.0);
      expect(nvda.avgCostBasis, 110.0); // 5500 / 50
      expect(nvda.currentPrice, 130.0);
    });

    test('calls /investments/transactions/get and parses investment transactions', () async {
      final mockTxJson = {
        'investment_transactions': [
          {
            'investment_transaction_id': 'tx_123',
            'account_id': 'acc_123',
            'security_id': 'sec_voo',
            'date': '2025-01-15',
            'name': 'BUY VOO',
            'quantity': 50.0,
            'amount': 24260.0,
            'price': 485.20,
            'fees': 0.0,
            'type': 'buy',
            'subtype': 'buy',
            'iso_currency_code': 'USD',
          }
        ],
        'securities': [
          {
            'security_id': 'sec_voo',
            'ticker_symbol': 'VOO',
            'name': 'Vanguard S&P 500 ETF',
          }
        ],
        'total_investment_transactions': 1,
      };

      final client = MockHttpClient((request) async {
        if (request.url.path == '/investments/holdings/get') {
          return http.Response(jsonEncode({'holdings': [], 'securities': []}), 200);
        }
        expect(request.url.path, '/investments/transactions/get');
        return http.Response(jsonEncode(mockTxJson), 200);
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      await adapter.connectBrokerageAccount(
        authToken: 'access-perm-123',
        clientId: 'test_client_id',
        secret: 'test_secret',
        isSandbox: false,
      );

      final txResult = await adapter.fetchTransactions(
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 2, 1),
      );

      expect(txResult is Success<List<InvestmentTransaction>>, true);
      final txs = (txResult as Success<List<InvestmentTransaction>>).data;
      expect(txs.length, 1);
      expect(txs.first.symbol, 'VOO');
      expect(txs.first.quantity, 50.0);
      expect(txs.first.price, 485.20);
      expect(txs.first.type, 'buy');
    });

    test('completePlaidFlow executes 5-step flow end-to-end', () async {
      final client = MockHttpClient((request) async {
        if (request.url.path == '/link/token/create') {
          return http.Response(jsonEncode({'link_token': 'link-test-1'}), 200);
        }
        if (request.url.path == '/sandbox/public_token/create') {
          return http.Response(jsonEncode({'public_token': 'pub-test-1'}), 200);
        }
        if (request.url.path == '/item/public_token/exchange') {
          return http.Response(
            jsonEncode({'access_token': 'acc-test-1', 'item_id': 'item-1'}),
            200,
          );
        }
        if (request.url.path == '/investments/holdings/get') {
          return http.Response(
            jsonEncode({
              'holdings': [
                {
                  'account_id': 'acc_1',
                  'security_id': 'sec_1',
                  'quantity': 10.0,
                  'cost_basis': 1500.0,
                  'institution_price': 160.0,
                }
              ],
              'securities': [
                {
                  'security_id': 'sec_1',
                  'ticker_symbol': 'MSFT',
                  'name': 'Microsoft Corporation',
                  'type': 'equity',
                }
              ]
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final flowResult = await adapter.completePlaidFlow(
        clientId: 'test_id',
        secret: 'test_secret',
        environment: 'sandbox',
      );

      expect(flowResult is Success<bool>, true);
      expect((flowResult as Success<bool>).data, true);
      expect(adapter.isConnectedToLiveBrokerage, true);
      expect(adapter.itemId, 'item-1');

      final holdings = await adapter.fetchHoldings();
      expect(holdings is Success<List<HoldingPosition>>, true);
      expect((holdings as Success<List<HoldingPosition>>).data.first.symbol, 'MSFT');
    });

    test('returns failure when Plaid API returns error response', () async {
      final client = MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'error_type': 'ITEM_ERROR',
            'error_code': 'INVALID_ACCESS_TOKEN',
            'display_message': 'Provided access token is invalid or expired.',
          }),
          400,
        );
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final result = await adapter.connectBrokerageAccount(
        authToken: 'invalid_token',
        clientId: 'test_id',
        secret: 'test_secret',
        isSandbox: false,
      );

      expect(result is Failure, true);
      expect(
        (result as Failure).errorMessage,
        contains('INVALID_ACCESS_TOKEN'),
      );
      expect(adapter.isConnectedToLiveBrokerage, false);
    });

    test('disconnect unlinks account and clears all in-memory credentials', () async {
      final adapter = PlaidBrokerageAdapter();
      await adapter.connectBrokerageAccount(
        authToken: 'token',
        isSandbox: true,
      );
      expect(adapter.isConnectedToLiveBrokerage, true);

      await adapter.disconnectBrokerageAccount();
      expect(adapter.isConnectedToLiveBrokerage, false);
      expect(adapter.accountIdentifier, isNull);
      expect(adapter.lastSyncTime, isNull);
      expect(adapter.itemId, isNull);
      expect(adapter.linkToken, isNull);
      expect(adapter.publicToken, isNull);

      // Verify that no credentials were ever stored in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('access_token'), isNull);
      expect(prefs.getString('client_id'), isNull);
      expect(prefs.getString('secret'), isNull);
    });

    test('getInstitutions sends correct request body, headers, and parses PlaidInstitutionsResponse', () async {
      final mockInstitutionsJson = {
        'institutions': [
          {
            'country_codes': ['US'],
            'institution_id': 'ins_1',
            'name': 'Bank of America',
            'products': [
              'assets',
              'auth',
              'balance',
              'transactions',
              'identity',
              'liabilities',
              'investments',
            ],
            'routing_numbers': ['011000138', '011200365', '011400495'],
            'dtc_numbers': ['2236', '0955', '1367'],
            'oauth': false,
            'connection_availability': 'SUPPORTED',
            'url': 'https://www.bankofamerica.com',
            'primary_color': '#0055b8',
            'logo': 'base64_logo_data',
          }
        ],
        'request_id': 'tbFyCEqkU774ZGG',
        'total': 11384,
      };

      final client = MockHttpClient((request) async {
        expect(request.url.path, '/institutions/get');
        expect(request.headers['Content-Type'], contains('application/json'));
        expect(request.headers['PLAID-CLIENT-ID'], 'test_client_id');
        expect(request.headers['PLAID-SECRET'], 'test_secret');

        final body = jsonDecode(await (request as http.Request).body) as Map<String, dynamic>;
        expect(body['client_id'], 'test_client_id');
        expect(body['secret'], 'test_secret');
        expect(body['count'], 10);
        expect(body['offset'], 0);
        expect(body['country_codes'], ['US']);
        expect(body['options'], isNotNull);
        expect(body['options']['products'], ['investments']);
        expect(body['options']['include_optional_metadata'], true);

        return http.Response(jsonEncode(mockInstitutionsJson), 200);
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final result = await adapter.getInstitutions(
        clientId: 'test_client_id',
        secret: 'test_secret',
        count: 10,
        offset: 0,
        countryCodes: const ['US'],
        products: const ['investments'],
        includeOptionalMetadata: true,
      );

      expect(result is Success<PlaidInstitutionsResponse>, true);
      final data = (result as Success<PlaidInstitutionsResponse>).data;
      expect(data.total, 11384);
      expect(data.requestId, 'tbFyCEqkU774ZGG');
      expect(data.institutions.length, 1);

      final inst = data.institutions.first;
      expect(inst.id, 'ins_1');
      expect(inst.name, 'Bank of America');
      expect(inst.products.contains('investments'), true);
      expect(inst.routingNumbers, ['011000138', '011200365', '011400495']);
      expect(inst.dtcNumbers, ['2236', '0955', '1367']);
      expect(inst.oauth, false);
      expect(inst.connectionAvailability, 'SUPPORTED');
      expect(inst.url, 'https://www.bankofamerica.com');
      expect(inst.primaryColor, '#0055b8');
      expect(inst.logo, 'base64_logo_data');
    });

    test('fetchInstitutions convenience method returns unwrapped list of PlaidInstitution entities', () async {
      final mockInstitutionsJson = {
        'institutions': [
          {
            'institution_id': 'ins_20',
            'name': 'Charles Schwab',
            'products': ['investments', 'transactions'],
            'country_codes': ['US'],
          },
          {
            'institution_id': 'ins_3',
            'name': 'Chase',
            'products': ['investments', 'auth', 'balance'],
            'country_codes': ['US'],
          }
        ],
        'request_id': 'req_inst_test',
        'total': 2,
      };

      final client = MockHttpClient((request) async {
        return http.Response(jsonEncode(mockInstitutionsJson), 200);
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final result = await adapter.fetchInstitutions(
        clientId: 'test_id',
        secret: 'test_sec',
        products: const ['investments'],
      );

      expect(result is Success<List<PlaidInstitution>>, true);
      final list = (result as Success<List<PlaidInstitution>>).data;
      expect(list.length, 2);
      expect(list[0].id, 'ins_20');
      expect(list[0].name, 'Charles Schwab');
      expect(list[1].id, 'ins_3');
      expect(list[1].name, 'Chase');
    });

    test('getInstitutions fails when client_id and secret are missing', () async {
      final adapter = PlaidBrokerageAdapter();
      final result = await adapter.getInstitutions();

      expect(result is Failure<PlaidInstitutionsResponse>, true);
      expect(
        (result as Failure).errorMessage,
        contains('client_id and secret are required'),
      );
    });

    test('getInstitutions handles Plaid API errors', () async {
      final client = MockHttpClient((request) async {
        return http.Response(
          jsonEncode({
            'error_type': 'INVALID_REQUEST',
            'error_code': 'INVALID_FIELD',
            'display_message': 'Invalid country code specified.',
          }),
          400,
        );
      });

      final adapter = PlaidBrokerageAdapter(client: client);
      final result = await adapter.getInstitutions(
        clientId: 'test_id',
        secret: 'test_sec',
      );

      expect(result is Failure<PlaidInstitutionsResponse>, true);
      expect(
        (result as Failure).errorMessage,
        contains('INVALID_FIELD'),
      );
    });
  });
}


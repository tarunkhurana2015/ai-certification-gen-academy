import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/holding_position.dart';
import '../../domain/entities/investment_transaction.dart';
import '../../domain/entities/plaid_institution.dart';
import '../../domain/entities/portfolio_summary.dart';
import '../../domain/entities/result.dart';
import '../../domain/repositories/brokerage_repository.dart';
import '../datasources/local_portfolio_storage.dart';

/// Plaid Investments API Adapter
/// Implements [IBrokerageRepository] following official Plaid Investments documentation:
/// https://plaid.com/docs/investments/
///
/// Flow:
/// 1. User enters client_id and secret (held strictly in memory; zero disk persistence).
/// 2. POST /link/token/create to generate link_token for Investments product.
/// 3. User completes Link to get temporary public_token (or /sandbox/public_token/create in sandbox).
/// 4. POST /item/public_token/exchange to exchange public_token for in-memory access_token & item_id.
/// 5. POST /investments/holdings/get and POST /investments/transactions/get using in-memory access_token.
class PlaidBrokerageAdapter implements IBrokerageRepository {
  final http.Client _client;
  final LocalPortfolioStorage _storage;

  // Strict In-Memory Session Variables - Never persisted to disk or code
  String? _accessToken;
  String? _itemId;
  String? _clientId;
  String? _secret;
  String? _linkToken;
  String? _publicToken;
  String? _accountIdentifier;
  String? _institutionName;
  String _environment = 'sandbox'; // 'sandbox' or 'production'
  bool _isSandbox = false;
  DateTime? _lastSync;
  List<HoldingPosition> _cachedHoldings = [];
  List<InvestmentTransaction> _cachedTransactions = [];

  PlaidBrokerageAdapter({
    http.Client? client,
    LocalPortfolioStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const LocalPortfolioStorage();

  static const String sandboxBaseUrl = 'https://sandbox.plaid.com';
  static const String productionBaseUrl = 'https://production.plaid.com';

  String get baseUrl =>
      _environment == 'production' ? productionBaseUrl : sandboxBaseUrl;

  @override
  bool get isConnectedToLiveBrokerage =>
      _isSandbox || (_accessToken != null && _accessToken!.isNotEmpty);

  @override
  String? get accountIdentifier => _accountIdentifier;

  @override
  String? get institutionName => _institutionName;

  @override
  bool get isSandboxMode => _isSandbox;

  @override
  DateTime? get lastSyncTime => _lastSync;

  String? get itemId => _itemId;
  String? get linkToken => _linkToken;
  String? get publicToken => _publicToken;
  String? get accessToken => _accessToken;
  String get environment => _environment;

  /// Default Sandbox Investment Holdings simulating Plaid's First Platypus Bank item
  static List<HoldingPosition> get simulatedPlaidHoldings => [
        HoldingPosition(
          id: 'plaid_hld_voo_1',
          symbol: 'VOO',
          companyName: 'Vanguard S&P 500 ETF',
          shares: 50.0,
          avgCostBasis: 485.20,
          currentPrice: 532.40,
          sector: 'Financial Services',
          purchaseDate: DateTime(2025, 1, 15),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'plaid_hld_aapl_2',
          symbol: 'AAPL',
          companyName: 'Apple Inc.',
          shares: 40.0,
          avgCostBasis: 195.00,
          currentPrice: 232.50,
          sector: 'Technology',
          purchaseDate: DateTime(2025, 2, 10),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'plaid_hld_nvda_3',
          symbol: 'NVDA',
          companyName: 'NVIDIA Corporation',
          shares: 30.0,
          avgCostBasis: 108.50,
          currentPrice: 139.75,
          sector: 'Technology',
          purchaseDate: DateTime(2025, 3, 5),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'plaid_hld_amzn_4',
          symbol: 'AMZN',
          companyName: 'Amazon.com, Inc.',
          shares: 35.0,
          avgCostBasis: 175.80,
          currentPrice: 215.20,
          sector: 'Consumer Cyclical',
          purchaseDate: DateTime(2025, 4, 18),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'plaid_hld_msft_5',
          symbol: 'MSFT',
          companyName: 'Microsoft Corporation',
          shares: 25.0,
          avgCostBasis: 395.00,
          currentPrice: 428.60,
          sector: 'Technology',
          purchaseDate: DateTime(2025, 5, 2),
          lastUpdated: DateTime.now(),
        ),
        HoldingPosition(
          id: 'plaid_hld_jpm_6',
          symbol: 'JPM',
          companyName: 'JPMorgan Chase & Co.',
          shares: 45.0,
          avgCostBasis: 198.30,
          currentPrice: 224.90,
          sector: 'Financial Services',
          purchaseDate: DateTime(2025, 6, 12),
          lastUpdated: DateTime.now(),
        ),
      ];

  /// Default Sandbox Investment Transactions simulating Plaid test item transactions
  static List<InvestmentTransaction> get simulatedPlaidTransactions => [
        InvestmentTransaction(
          id: 'tx_voo_1',
          accountId: 'acc_plaid_inv_1',
          securityId: 'sec_voo',
          symbol: 'VOO',
          name: 'BUY VOO Vanguard S&P 500 ETF',
          date: DateTime(2025, 1, 15),
          quantity: 50.0,
          amount: 24260.00,
          price: 485.20,
          fees: 0.0,
          type: 'buy',
          subtype: 'buy',
        ),
        InvestmentTransaction(
          id: 'tx_aapl_2',
          accountId: 'acc_plaid_inv_1',
          securityId: 'sec_aapl',
          symbol: 'AAPL',
          name: 'BUY AAPL Apple Inc.',
          date: DateTime(2025, 2, 10),
          quantity: 40.0,
          amount: 7800.00,
          price: 195.00,
          fees: 0.0,
          type: 'buy',
          subtype: 'buy',
        ),
        InvestmentTransaction(
          id: 'tx_nvda_3',
          accountId: 'acc_plaid_inv_1',
          securityId: 'sec_nvda',
          symbol: 'NVDA',
          name: 'BUY NVDA NVIDIA Corporation',
          date: DateTime(2025, 3, 5),
          quantity: 30.0,
          amount: 3255.00,
          price: 108.50,
          fees: 0.0,
          type: 'buy',
          subtype: 'buy',
        ),
      ];

  /// Plaid Step 2: Make the POST /link/token/create API call to obtain link_token
  /// Docs: https://plaid.com/docs/api/tokens/#linktokencreate
  Future<Result<String>> createLinkToken({
    required String clientId,
    required String secret,
    String environment = 'sandbox',
    String? clientUserId,
  }) async {
    _environment = environment;
    _clientId = clientId.trim();
    _secret = secret.trim();

    final uri = Uri.parse('$baseUrl/link/token/create');
    final Map<String, dynamic> requestBody = {
      'client_id': _clientId,
      'secret': _secret,
      'client_name': 'GenStockFolio Stock Analyzer',
      'country_codes': ['US'],
      'language': 'en',
      'user': {
        'client_user_id': clientUserId ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      },
      'products': ['investments'],
    };

    final headers = {
      'Content-Type': 'application/json',
      'PLAID-CLIENT-ID': _clientId!,
      'PLAID-SECRET': _secret!,
    };

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("RESPONSE ==== ${uri} ${headers} ${requestBody} ${response} ${response.statusCode}");

      if (response.statusCode != 200) {
        return _handlePlaidErrorResponse<String>(response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final linkToken = data['link_token']?.toString();
      if (linkToken == null || linkToken.isEmpty) {
        return const Failure('Plaid response did not contain link_token');
      }

      _linkToken = linkToken;
      return Success(linkToken);
    } catch (e, st) {
      return Failure('Network error during /link/token/create: $e', e, st);
    }
  }

  /// Plaid Sandbox Step 3 Helper: POST /sandbox/public_token/create
  /// Docs: https://plaid.com/docs/api/sandbox/#sandboxpublic_tokencreate
  Future<Result<String>> createSandboxPublicToken({
    required String clientId,
    required String secret,
    String institutionId = 'ins_1',
    String environment = 'sandbox',
  }) async {
    _environment = environment;
    _clientId = clientId.trim();
    _secret = secret.trim();

    final uri = Uri.parse('$baseUrl/sandbox/public_token/create');
    final Map<String, dynamic> requestBody = {
      'client_id': _clientId,
      'secret': _secret,
      'institution_id': institutionId,
      'initial_products': ['investments'],
    };

    final headers = {
      'Content-Type': 'application/json',
      'PLAID-CLIENT-ID': _clientId!,
      'PLAID-SECRET': _secret!,
    };

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );
      print("============================");
      print("RESPONSE ==== ${uri} ${headers} ${requestBody} ${response} ${response.statusCode}");


      if (response.statusCode != 200) {
        return _handlePlaidErrorResponse<String>(response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final publicToken = data['public_token']?.toString();
      if (publicToken == null || publicToken.isEmpty) {
        return const Failure('Plaid Sandbox response did not contain public_token');
      }
      print("RESPONSE ==== publicToken -- ${publicToken}");


      _publicToken = publicToken;
      return Success(publicToken);
    } catch (e, st) {
      return Failure('Network error during /sandbox/public_token/create: $e', e, st);
    }
  }

  /// Plaid Step 4: Call POST /item/public_token/exchange
  /// Exchanges temporary public_token for permanent access_token and item_id
  /// Docs: https://plaid.com/docs/api/items/#itempublic_tokenexchange
  Future<Result<Map<String, String>>> exchangePublicToken({
    required String clientId,
    required String secret,
    required String publicToken,
    String environment = 'sandbox',
  }) async {
    _environment = environment;
    _clientId = clientId.trim();
    _secret = secret.trim();
    _publicToken = publicToken.trim();

    final uri = Uri.parse('$baseUrl/item/public_token/exchange');
    final Map<String, dynamic> requestBody = {
      'client_id': _clientId,
      'secret': _secret,
      'public_token': _publicToken,
    };

    final headers = {
      'Content-Type': 'application/json',
      'PLAID-CLIENT-ID': _clientId!,
      'PLAID-SECRET': _secret!,
    };

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("============================+++++++++++++++++++++++");
      print("RESPONSE ==== ${uri} ${headers} ${requestBody} ${response} ${response.statusCode}");

      if (response.statusCode != 200) {
        return _handlePlaidErrorResponse<Map<String, String>>(response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = data['access_token']?.toString();
      final itemId = data['item_id']?.toString() ?? '';

      if (accessToken == null || accessToken.isEmpty) {
        return const Failure('Plaid response did not contain access_token');
      }

      // Step 5: Store the access_token in memory ONLY
      _accessToken = accessToken;
      _itemId = itemId;

      print("ACCESS TOKEN = ${_accessToken}}");

      return Success({
        'access_token': accessToken,
        'item_id': itemId,
      });
    } catch (e, st) {
      return Failure('Network error during /item/public_token/exchange: $e', e, st);
    }
  }

  /// Plaid: POST /institutions/get
  /// Returns a JSON response containing details on all financial institutions currently supported by Plaid.
  /// Docs: https://plaid.com/docs/api/institutions/#institutionsget
  ///
  /// Request fields:
  /// - [clientId]: Required Plaid client_id (falls back to in-memory _clientId).
  /// - [secret]: Required Plaid secret (falls back to in-memory _secret).
  /// - [count]: Total number of institutions to return (1..500). Defaults to 25.
  /// - [offset]: Number of institutions to skip (>= 0). Defaults to 0.
  /// - [countryCodes]: ISO-3166-1 alpha-2 country codes (e.g. ['US']). Defaults to ['US'].
  /// - [products]: Filter institutions by supported products (e.g. ['investments']).
  /// - [routingNumbers]: Filter institutions matching all listed 9-digit routing numbers.
  /// - [oauth]: Limit results to institutions with/without OAuth login flow.
  /// - [includeOptionalMetadata]: When true, returns homepage URL, logo, and brand color. Defaults to true.
  /// - [includeAuthMetadata]: When true, returns Auth product metadata. Defaults to false.
  /// - [includePaymentInitiationMetadata]: When true, returns Payment Initiation metadata. Defaults to false.
  /// - [environment]: 'sandbox' or 'production' (defaults to active session environment).
  Future<Result<PlaidInstitutionsResponse>> getInstitutions({
    String? clientId,
    String? secret,
    int count = 25,
    int offset = 0,
    List<String> countryCodes = const ['US'],
    List<String>? products = const ['investments'],
    List<String>? routingNumbers,
    bool? oauth,
    bool includeOptionalMetadata = true,
    bool includeAuthMetadata = false,
    bool includePaymentInitiationMetadata = false,
    String? environment,
  }) async {
    final activeEnv = environment ?? _environment;
    final targetBaseUrl = activeEnv == 'production' ? productionBaseUrl : sandboxBaseUrl;

    final resolvedClientId = (clientId != null && clientId.trim().isNotEmpty)
        ? clientId.trim()
        : (_clientId ?? '');
    final resolvedSecret = (secret != null && secret.trim().isNotEmpty)
        ? secret.trim()
        : (_secret ?? '');

    if (resolvedClientId.isEmpty || resolvedSecret.isEmpty) {
      return const Failure(
        'Plaid client_id and secret are required to query /institutions/get.',
      );
    }

    final uri = Uri.parse('$targetBaseUrl/institutions/get');

    final Map<String, dynamic> requestBody = {
      'client_id': resolvedClientId,
      'secret': resolvedSecret,
      'count': count.clamp(1, 500),
      'offset': offset < 0 ? 0 : offset,
      'country_codes': countryCodes.isEmpty ? ['US'] : countryCodes,
    };

    final Map<String, dynamic> options = {};
    if (products != null && products.isNotEmpty) {
      options['products'] = products;
    }
    if (routingNumbers != null && routingNumbers.isNotEmpty) {
      options['routing_numbers'] = routingNumbers;
    }
    if (oauth != null) {
      options['oauth'] = oauth;
    }
    if (includeOptionalMetadata) {
      options['include_optional_metadata'] = true;
    }
    if (includeAuthMetadata) {
      options['include_auth_metadata'] = true;
    }
    if (includePaymentInitiationMetadata) {
      options['include_payment_initiation_metadata'] = true;
    }

    if (options.isNotEmpty) {
      requestBody['options'] = options;
    }

    final headers = {
      'Content-Type': 'application/json',
      'PLAID-CLIENT-ID': resolvedClientId,
      'PLAID-SECRET': resolvedSecret,
    };

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        return _handlePlaidErrorResponse<PlaidInstitutionsResponse>(response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final institutionsResponse = PlaidInstitutionsResponse.fromJson(data);
      return Success(institutionsResponse);
    } catch (e, st) {
      return Failure('Network error during /institutions/get: $e', e, st);
    }
  }

  /// Convenience method that fetches institutions and unwraps the list of [PlaidInstitution] entities.
  Future<Result<List<PlaidInstitution>>> fetchInstitutions({
    String? clientId,
    String? secret,
    int count = 25,
    int offset = 0,
    List<String> countryCodes = const ['US'],
    List<String>? products = const ['investments'],
    List<String>? routingNumbers,
    bool? oauth,
    bool includeOptionalMetadata = true,
    bool includeAuthMetadata = false,
    bool includePaymentInitiationMetadata = false,
    String? environment,
  }) async {
    final result = await getInstitutions(
      clientId: clientId,
      secret: secret,
      count: count,
      offset: offset,
      countryCodes: countryCodes,
      products: products,
      routingNumbers: routingNumbers,
      oauth: oauth,
      includeOptionalMetadata: includeOptionalMetadata,
      includeAuthMetadata: includeAuthMetadata,
      includePaymentInitiationMetadata: includePaymentInitiationMetadata,
      environment: environment,
    );

    if (result is Success<PlaidInstitutionsResponse>) {
      return Success(result.data.institutions);
    }
    return Failure(result.errorOrNull ?? 'Failed to fetch institutions from Plaid');
  }

  /// Orchestrates the entire 5-Step Plaid Flow securely:
  /// 1. Verifies in-memory credentials.
  /// 2. Calls /link/token/create to obtain link_token.
  /// 3. Obtains public_token (from parameter if provided via Link onSuccess, or via Sandbox API).
  /// 4. Calls /item/public_token/exchange to obtain permanent in-memory access_token.
  /// 5. Stores access_token in memory and calls /investments/holdings/get to fetch holdings.
  Future<Result<bool>> completePlaidFlow({
    required String clientId,
    required String secret,
    String? publicToken,
    String environment = 'sandbox',
    String institutionId = 'ins_1',
    String? institutionName,
  }) async {
    // Step 2: Create Link Token
    final linkResult = await createLinkToken(
      clientId: clientId,
      secret: secret,
      environment: environment,
    );
    if (linkResult is Failure<String>) {
      return Failure(linkResult.errorOrNull ?? 'Failed to create link_token');
    }

    // Step 3: Obtain public_token
    String tokenToExchange = publicToken?.trim() ?? '';
    if (tokenToExchange.isEmpty) {
      if (environment == 'sandbox') {
        final pubRes = await createSandboxPublicToken(
          clientId: clientId,
          secret: secret,
          institutionId: institutionId,
          environment: environment,
        );
        if (pubRes is Failure<String>) {
          return Failure(pubRes.errorOrNull ?? 'Failed to obtain sandbox public_token');
        }
        tokenToExchange = (pubRes as Success<String>).data;
      } else {
        return const Failure(
          'In production mode, the public_token returned by Plaid Link onSuccess is required.',
        );
      }
    }

    print("TOKEN TO EXCHANGE = ${tokenToExchange}");
    // Step 4: Exchange public_token for access_token
    final exchangeResult = await exchangePublicToken(
      clientId: clientId,
      secret: secret,
      publicToken: tokenToExchange,
      environment: environment,
    );
    if (exchangeResult is Failure<Map<String, String>>) {
      return Failure(exchangeResult.errorOrNull ?? 'Failed to exchange public_token');
    }

    // Step 5: Store in memory and fetch investment holdings
    _isSandbox = (environment == 'sandbox');
    _institutionName = institutionName ?? (_isSandbox ? 'First Platypus Bank' : 'Plaid Institution');
    _accountIdentifier = 'Plaid (${environment.toUpperCase()})';

    print("ACCESS TOKEN ==****=== ${_accessToken}");

    final holdingsResult = await _syncLiveHoldingsFromApi();
    if (holdingsResult is Success<List<HoldingPosition>>) {
      _cachedHoldings = holdingsResult.data;
      await _storage.savePositions(_cachedHoldings);
      _lastSync = DateTime.now();
      return const Success(true);
    } else {
      return Failure(holdingsResult.errorOrNull ?? 'Failed to retrieve holdings from Plaid');
    }
  }

  @override
  Future<Result<bool>> connectBrokerageAccount({
    required String authToken,
    String? clientId,
    String? secret,
    String? accountIdentifier,
    String? institutionName,
    String environment = 'sandbox',
    bool isSandbox = false,
  }) async {
    _isSandbox = isSandbox;
    _environment = environment;
    _accountIdentifier = accountIdentifier ??
        (isSandbox ? 'Plaid Sandbox (First Platypus Bank)' : 'Plaid Account');
    _institutionName =
        institutionName ?? (isSandbox ? 'First Platypus Bank' : 'Connected Institution');

    if (isSandbox && (clientId == null || clientId.isEmpty || authToken == 'access-sandbox-plaid-demo')) {
      _accessToken = 'access-sandbox-plaid-demo';
      _lastSync = DateTime.now();
      _cachedHoldings = simulatedPlaidHoldings;
      _cachedTransactions = simulatedPlaidTransactions;
      await _storage.savePositions(_cachedHoldings);
      return const Success(true);
    }

    // Live Plaid session with in-memory tokens
    if (authToken.isNotEmpty && authToken != 'live-token') {
      _accessToken = authToken.trim();
    }
    _clientId = clientId?.trim();
    _secret = secret?.trim();

    try {
      final syncResult = await _syncLiveHoldingsFromApi();
      if (syncResult is Success<List<HoldingPosition>>) {
        _cachedHoldings = syncResult.data;
        await _storage.savePositions(_cachedHoldings);
        _lastSync = DateTime.now();
        return const Success(true);
      } else {
        _accessToken = null;
        return Failure(
            syncResult.errorOrNull ?? 'Failed to authenticate with Plaid API');
      }
    } catch (e, st) {
      _accessToken = null;
      return Failure('Plaid Connection Error: $e', e, st);
    }
  }

  /// Calls Plaid POST /investments/holdings/get
  /// Docs: https://plaid.com/docs/api/products/investments/#investments-holdings-get
  Future<Result<List<HoldingPosition>>> _syncLiveHoldingsFromApi() async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      return const Failure('No Plaid access token configured in memory.');
    }

    final uri = Uri.parse('$baseUrl/investments/holdings/get');
    final Map<String, dynamic> requestBody = {
      'access_token': _accessToken,
    };

    if (_clientId != null && _clientId!.isNotEmpty) {
      requestBody['client_id'] = _clientId;
    }
    if (_secret != null && _secret!.isNotEmpty) {
      requestBody['secret'] = _secret;
    }

    final headers = {
      'Content-Type': 'application/json',
      if (_clientId != null && _clientId!.isNotEmpty) 'PLAID-CLIENT-ID': _clientId!,
      if (_secret != null && _secret!.isNotEmpty) 'PLAID-SECRET': _secret!,
    };

    print("REQUEST ==== ${uri} ${headers} ${requestBody}");


    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print("============================************************");
      print("RESPONSE ==== ${uri} ${headers} ${requestBody} ${response} ${response.statusCode}");

      if (response.statusCode != 200) {
        return _handlePlaidErrorResponse<List<HoldingPosition>>(response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parsePlaidHoldingsPayload(data);
    } catch (e, st) {
      return Failure('Network error during Plaid holdings sync: $e', e, st);
    }
  }

  /// Calls Plaid POST /investments/transactions/get
  /// Docs: https://plaid.com/docs/api/products/investments/#investmentstransactionsget
  @override
  Future<Result<List<InvestmentTransaction>>> fetchTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_isSandbox &&
        (_accessToken == null ||
            _accessToken == 'access-sandbox-plaid-demo' ||
            _accessToken!.isEmpty)) {
      _cachedTransactions = simulatedPlaidTransactions;
      return Success(_cachedTransactions);
    }

    if (_accessToken == null || _accessToken!.isEmpty) {
      return const Failure('No active Plaid access token in memory.');
    }

    final now = DateTime.now();
    final start = startDate ?? now.subtract(const Duration(days: 365));
    final end = endDate ?? now;

    final uri = Uri.parse('$baseUrl/investments/transactions/get');
    final Map<String, dynamic> requestBody = {
      'access_token': _accessToken,
      'start_date':
          '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}',
      'end_date':
          '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}',
    };

    if (_clientId != null && _clientId!.isNotEmpty) {
      requestBody['client_id'] = _clientId;
    }
    if (_secret != null && _secret!.isNotEmpty) {
      requestBody['secret'] = _secret;
    }

    final headers = {
      'Content-Type': 'application/json',
      if (_clientId != null && _clientId!.isNotEmpty) 'PLAID-CLIENT-ID': _clientId!,
      if (_secret != null && _secret!.isNotEmpty) 'PLAID-SECRET': _secret!,
    };

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        return _handlePlaidErrorResponse<List<InvestmentTransaction>>(response);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parsePlaidTransactionsPayload(data);
    } catch (e, st) {
      return Failure('Network error during Plaid transactions sync: $e', e, st);
    }
  }

  /// Parses Plaid Investments Holdings response
  Result<List<HoldingPosition>> _parsePlaidHoldingsPayload(Map<String, dynamic> json) {
    try {
      final rawHoldings = (json['holdings'] as List<dynamic>?) ?? [];
      final rawSecurities = (json['securities'] as List<dynamic>?) ?? [];

      final Map<String, Map<String, dynamic>> securitiesMap = {};
      for (final sec in rawSecurities) {
        if (sec is Map<String, dynamic>) {
          final id = sec['security_id']?.toString() ?? '';
          if (id.isNotEmpty) {
            securitiesMap[id] = sec;
          }
        }
      }

      final List<HoldingPosition> positions = [];
      for (int i = 0; i < rawHoldings.length; i++) {
        final holding = rawHoldings[i] as Map<String, dynamic>;
        final securityId = holding['security_id']?.toString() ?? '';
        final security = securitiesMap[securityId] ?? {};

        final rawQuantity = holding['quantity'];
        final shares = (rawQuantity is num)
            ? rawQuantity.toDouble()
            : (double.tryParse(rawQuantity?.toString() ?? '') ?? 0.0);
        if (shares <= 0) continue;

        final rawPrice = holding['institution_price'] ?? security['close_price'];
        final currentPrice = (rawPrice is num)
            ? rawPrice.toDouble()
            : (double.tryParse(rawPrice?.toString() ?? '') ?? 1.0);

        final rawCostBasis = holding['cost_basis'];
        final totalCostBasis = (rawCostBasis is num)
            ? rawCostBasis.toDouble()
            : double.tryParse(rawCostBasis?.toString() ?? '');
        final avgCostBasis = (totalCostBasis != null && shares > 0)
            ? (totalCostBasis / shares)
            : currentPrice;

        final tickerSymbol =
            (security['ticker_symbol']?.toString() ?? '').trim().toUpperCase();
        final symbol = tickerSymbol.isNotEmpty
            ? tickerSymbol
            : (securityId.isNotEmpty ? securityId : 'ASSET_${i + 1}');
        final companyName = (security['name']?.toString() ?? '').trim().isNotEmpty
            ? security['name'].toString().trim()
            : 'Plaid Security $symbol';

        final sector = _inferSector(symbol, security['type']?.toString());

        positions.add(HoldingPosition(
          id: 'plaid_pos_${securityId}_$i',
          symbol: symbol,
          companyName: companyName,
          shares: shares,
          avgCostBasis: avgCostBasis,
          currentPrice: currentPrice,
          sector: sector,
          purchaseDate: DateTime.now().subtract(Duration(days: 30 * (i + 1))),
          lastUpdated: DateTime.now(),
        ));
      }

      return Success(positions);
    } catch (e, st) {
      return Failure('Failed to parse Plaid holdings payload: $e', e, st);
    }
  }

  /// Parses Plaid Investments Transactions response
  Result<List<InvestmentTransaction>> _parsePlaidTransactionsPayload(
      Map<String, dynamic> json) {
    try {
      final rawTransactions =
          (json['investment_transactions'] as List<dynamic>?) ?? [];
      final rawSecurities = (json['securities'] as List<dynamic>?) ?? [];

      final Map<String, Map<String, dynamic>> securitiesMap = {};
      for (final sec in rawSecurities) {
        if (sec is Map<String, dynamic>) {
          final id = sec['security_id']?.toString() ?? '';
          if (id.isNotEmpty) {
            securitiesMap[id] = sec;
          }
        }
      }

      final List<InvestmentTransaction> transactions = [];
      for (final raw in rawTransactions) {
        if (raw is Map<String, dynamic>) {
          transactions.add(InvestmentTransaction.fromJson(raw, securitiesMap));
        }
      }

      _cachedTransactions = transactions;
      return Success(transactions);
    } catch (e, st) {
      return Failure('Failed to parse Plaid transactions payload: $e', e, st);
    }
  }

  Result<T> _handlePlaidErrorResponse<T>(http.Response response) {
    try {
      final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
      final errorType = errorJson['error_type']?.toString() ?? 'API_ERROR';
      final errorCode =
          errorJson['error_code']?.toString() ?? 'ERROR_${response.statusCode}';
      final errorMessage = errorJson['display_message']?.toString() ??
          (errorJson['error_message']?.toString() ??
              'HTTP ${response.statusCode}');

      return Failure('Plaid [$errorType / $errorCode]: $errorMessage');
    } catch (_) {
      return Failure(
          'Plaid request failed with HTTP status ${response.statusCode}');
    }
  }

  static String _inferSector(String ticker, String? securityType) {
    switch (ticker) {
      case 'AAPL':
      case 'MSFT':
      case 'NVDA':
      case 'GOOGL':
      case 'GOOG':
      case 'AMD':
      case 'INTC':
      case 'CRM':
      case 'ADBE':
        return 'Technology';
      case 'JPM':
      case 'BAC':
      case 'GS':
      case 'MS':
      case 'V':
      case 'MA':
      case 'VOO':
      case 'SPY':
      case 'IVV':
      case 'QQQ':
        return 'Financial Services';
      case 'AMZN':
      case 'TSLA':
      case 'HD':
      case 'NKE':
      case 'MCD':
        return 'Consumer Cyclical';
      case 'META':
      case 'NFLX':
      case 'DIS':
      case 'CMCSA':
        return 'Communication Services';
      case 'JNJ':
      case 'PFE':
      case 'UNH':
      case 'ABBV':
      case 'LLY':
        return 'Healthcare';
      case 'XOM':
      case 'CVX':
      case 'COP':
        return 'Energy';
      case 'PG':
      case 'KO':
      case 'PEP':
      case 'WMT':
      case 'COST':
        return 'Consumer Defensive';
      case 'CAT':
      case 'BA':
      case 'HON':
      case 'GE':
        return 'Industrials';
      default:
        if (securityType == 'etf' || securityType == 'mutual fund') {
          return 'Financial Services';
        }
        return 'Other';
    }
  }

  @override
  Future<Result<List<HoldingPosition>>> fetchHoldings() async {
    if (_cachedHoldings.isNotEmpty) {
      return Success(_cachedHoldings);
    }
    if (_accessToken != null && _accessToken!.isNotEmpty && !_isSandbox) {
      return _syncLiveHoldingsFromApi();
    }
    try {
      final stored = await _storage.loadPositions();
      _cachedHoldings = stored;
      return Success(stored);
    } catch (e, st) {
      return Failure('Failed to load stored positions: $e', e, st);
    }
  }

  @override
  Future<Result<PortfolioSummary>> fetchPortfolioSummary() async {
    final holdingsResult = await fetchHoldings();
    if (holdingsResult is Success<List<HoldingPosition>>) {
      return Success(PortfolioSummary.fromHoldings(holdingsResult.data));
    }
    return Failure(
        holdingsResult.errorOrNull ?? 'Failed to compute portfolio summary');
  }

  /// Disconnects account and wipes all credentials from RAM completely
  @override
  Future<Result<void>> disconnectBrokerageAccount() async {
    _accessToken = null;
    _itemId = null;
    _clientId = null;
    _secret = null;
    _linkToken = null;
    _publicToken = null;
    _accountIdentifier = null;
    _institutionName = null;
    _isSandbox = false;
    _lastSync = null;
    _cachedTransactions = [];
    return const Success(null);
  }

  @override
  Future<Result<void>> saveCustomPositions(List<HoldingPosition> positions) async {
    try {
      _cachedHoldings = List.from(positions);
      await _storage.savePositions(positions);
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to persist positions: $e', e, st);
    }
  }

  @override
  Future<Result<void>> clearPortfolio() async {
    try {
      _cachedHoldings = [];
      _cachedTransactions = [];
      await _storage.clearAll();
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to clear portfolio: $e', e, st);
    }
  }

  @override
  Future<Result<List<HoldingPosition>>> generateDemoPortfolio() async {
    try {
      final demo = simulatedPlaidHoldings;
      await _storage.savePositions(demo);
      _cachedHoldings = List.from(demo);
      return Success(demo);
    } catch (e, st) {
      return Failure('Failed to generate demo portfolio: $e', e, st);
    }
  }
}

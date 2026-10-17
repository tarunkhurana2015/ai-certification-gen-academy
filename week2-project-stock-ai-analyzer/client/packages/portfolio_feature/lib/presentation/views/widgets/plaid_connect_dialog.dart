import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/portfolio_viewmodel.dart';
import '../../../domain/entities/plaid_institution.dart';
import '../../../domain/entities/result.dart';
import '../../../l10n/portfolio_localizations.dart';

class PlaidConnectDialog extends ConsumerStatefulWidget {
  const PlaidConnectDialog({super.key});

  @override
  ConsumerState<PlaidConnectDialog> createState() => _PlaidConnectDialogState();
}

class _PlaidConnectDialogState extends ConsumerState<PlaidConnectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _secretController = TextEditingController();
  final _publicTokenController = TextEditingController();

  int _selectedModeIndex = 0; // 0: Plaid Sandbox, 1: Live API Credentials
  String _selectedEnv = 'sandbox'; // 'sandbox' or 'production'
  String _selectedInstitutionId = 'ins_1';
  String _selectedInstitutionName = 'First Platypus Bank (Plaid Sandbox)';
  bool _obscureSecret = true;
  bool _isLoading = false;
  String? _stepStatus;
  String? _errorMessage;
  bool _showAdvancedSteps = false;
  String? _linkTokenCreated;
  List<PlaidInstitution> _fetchedInstitutions = [];
  bool _isFetchingInstitutions = false;
  String? _institutionsFetchError;

  static const Map<String, String> sandboxInstitutions = {
    'ins_1': 'First Platypus Bank (Plaid Sandbox)',
    'ins_2': 'First Gingham Bank (Plaid Sandbox)',
    'ins_3': 'Chase (via Plaid Sandbox)',
    'ins_4': 'Bank of America (via Plaid Sandbox)',
    'ins_5': 'Wells Fargo (via Plaid Sandbox)',
    'ins_20': 'Charles Schwab (via Plaid Sandbox)',
  };

  @override
  void dispose() {
    _clientIdController.dispose();
    _secretController.dispose();
    _publicTokenController.dispose();
    super.dispose();
  }

  /// Handles 5-Step Plaid Flow:
  /// 1. Enter Client ID & Secret
  /// 2. POST /link/token/create
  /// 3. Obtain public_token (via Link onSuccess or /sandbox/public_token/create)
  /// 4. POST /item/public_token/exchange
  /// 5. Store access_token in RAM and call /investments/holdings/get
  Future<void> _handleConnect() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _stepStatus = null;
    });

    final notifier = ref.read(portfolioViewModelProvider.notifier);
    final adapter = ref.read(plaidBrokerageAdapterProvider);

    if (_selectedModeIndex == 0) {
      // Mode 0: Plaid Sandbox
      final success = await notifier.connectPlaid(
        authToken: 'access-sandbox-plaid-demo',
        institutionName: _selectedInstitutionName,
        accountIdentifier: 'Plaid: $_selectedInstitutionName',
        isSandbox: true,
        environment: 'sandbox',
      );

      if (!mounted) return;
      if (success) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load simulated sandbox holdings.';
        });
      }
      return;
    }

    // Mode 1: Official Plaid API Flow
    if (!_formKey.currentState!.validate()) {
      setState(() => _isLoading = false);
      return;
    }

    final clientId = _clientIdController.text.trim();
    final secret = _secretController.text.trim();
    final userPublicToken = _publicTokenController.text.trim();

    try {
      // Step 2: Make the /link/token/create API call
      setState(() => _stepStatus = 'Step 2/5: Creating link_token via /link/token/create...');
      final linkResult = await adapter.createLinkToken(
        clientId: clientId,
        secret: secret,
        environment: _selectedEnv,
      );

      if (linkResult.isFailure) {
        setState(() {
          _isLoading = false;
          _stepStatus = null;
          _errorMessage = linkResult.errorOrNull ?? 'Failed to create link_token';
        });
        return;
      }

      _linkTokenCreated = (linkResult as dynamic).data;

      // Step 3: Obtain public_token
      String tokenToExchange = userPublicToken;
      if (tokenToExchange.isEmpty) {
        if (_selectedEnv == 'sandbox') {
          setState(() => _stepStatus =
              'Step 3/5: Generating test public_token via /sandbox/public_token/create...');
          final pubRes = await adapter.createSandboxPublicToken(
            clientId: clientId,
            secret: secret,
            institutionId: _selectedInstitutionId,
            environment: _selectedEnv,
          );

          if (pubRes.isFailure) {
            setState(() {
              _isLoading = false;
              _stepStatus = null;
              _errorMessage = pubRes.errorOrNull ?? 'Failed to generate sandbox public_token';
            });
            return;
          }
          tokenToExchange = (pubRes as dynamic).data;
        } else {
          setState(() {
            _isLoading = false;
            _stepStatus = null;
            _errorMessage =
                'In Production environment, public_token from Plaid Link onSuccess is required.';
          });
          return;
        }
      }

      // Step 4: Call /item/public_token/exchange
      setState(() => _stepStatus =
          'Step 4/5: Exchanging public_token for access_token via /item/public_token/exchange...');
      final exchangeResult = await adapter.exchangePublicToken(
        clientId: clientId,
        secret: secret,
        publicToken: tokenToExchange,
        environment: _selectedEnv,
      );

      if (exchangeResult.isFailure) {
        setState(() {
          _isLoading = false;
          _stepStatus = null;
          _errorMessage = exchangeResult.errorOrNull ?? 'Failed to exchange public_token';
        });
        return;
      }

      final exchangeData = (exchangeResult as dynamic).data as Map<String, dynamic>?;
      final realAccessToken = exchangeData?['access_token']?.toString() ??
          adapter.accessToken ??
          '';

      // Step 5: Store access_token in memory and call /investments/holdings/get
      setState(() => _stepStatus =
          'Step 5/5: In-memory session active. Fetching holdings via /investments/holdings/get...');
      final success = await notifier.connectPlaid(
        authToken: realAccessToken,
        clientId: clientId,
        secret: secret,
        institutionName: _selectedInstitutionName,
        accountIdentifier: 'Plaid (${_selectedEnv.toUpperCase()})',
        environment: _selectedEnv,
        isSandbox: (_selectedEnv == 'sandbox'),
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
      } else {
        final state = ref.read(portfolioViewModelProvider);
        setState(() {
          _isLoading = false;
          _stepStatus = null;
          _errorMessage = state.errorMessage ?? 'Failed to fetch investment holdings.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _stepStatus = null;
        _errorMessage = 'Plaid Integration Error: $e';
      });
    }
  }

  /// Helper for Step 2 manual button in advanced section
  Future<void> _handleGenerateLinkTokenOnly() async {
    if (_clientIdController.text.trim().isEmpty || _secretController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter both client_id and secret first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _stepStatus = 'Calling /link/token/create...';
    });

    final adapter = ref.read(plaidBrokerageAdapterProvider);
    final res = await adapter.createLinkToken(
      clientId: _clientIdController.text.trim(),
      secret: _secretController.text.trim(),
      environment: _selectedEnv,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _stepStatus = null;
      if (res.isSuccess) {
        _linkTokenCreated = (res as dynamic).data;
      } else {
        _errorMessage = res.errorOrNull ?? 'Failed to create link_token';
      }
    });
  }

  /// Helper for Step 3 manual button in advanced section
  Future<void> _handleGenerateSandboxPublicTokenOnly() async {
    if (_clientIdController.text.trim().isEmpty || _secretController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter both client_id and secret first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _stepStatus = 'Calling /sandbox/public_token/create...';
    });

    final adapter = ref.read(plaidBrokerageAdapterProvider);
    final res = await adapter.createSandboxPublicToken(
      clientId: _clientIdController.text.trim(),
      secret: _secretController.text.trim(),
      institutionId: _selectedInstitutionId,
      environment: _selectedEnv,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _stepStatus = null;
      if (res.isSuccess) {
        _publicTokenController.text = (res as dynamic).data;
      } else {
        _errorMessage = res.errorOrNull ?? 'Failed to create sandbox public_token';
      }
    });
  }

  /// Queries Plaid POST /institutions/get dynamically
  Future<void> _handleFetchInstitutions() async {
    final clientId = _clientIdController.text.trim();
    final secret = _secretController.text.trim();
    if (clientId.isEmpty || secret.isEmpty) {
      setState(() => _errorMessage = 'Please enter client_id and secret to query /institutions/get.');
      return;
    }

    setState(() {
      _isFetchingInstitutions = true;
      _institutionsFetchError = null;
      _errorMessage = null;
    });

    final adapter = ref.read(plaidBrokerageAdapterProvider);
    final result = await adapter.fetchInstitutions(
      clientId: clientId,
      secret: secret,
      environment: _selectedEnv,
      products: const ['investments'],
      count: 25,
      includeOptionalMetadata: true,
    );

    if (!mounted) return;
    setState(() {
      _isFetchingInstitutions = false;
      if (result is Success<List<PlaidInstitution>>) {
        _fetchedInstitutions = result.data;
        if (_fetchedInstitutions.isNotEmpty) {
          _selectedInstitutionId = _fetchedInstitutions.first.id;
          _selectedInstitutionName = _fetchedInstitutions.first.name;
        }
      } else {
        _institutionsFetchError = result.errorOrNull ?? 'Failed to load institutions';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = PortfolioLocalizations.of(context);
    const plaidBlue = Color(0xFF0A85EA);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: plaidBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance, color: plaidBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.plaidConnectTitle ?? 'Link Brokerage via Plaid',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Plaid Investments API (/link/token, /item/exchange, /investments/holdings)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Security & Privacy Guarantee Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 20, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Zero Credential Persistence: API keys & tokens are stored strictly in-memory (RAM) and cleared upon disconnect. No keys are written to code or disk.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mode selector
              SegmentedButton<int>(
                segments: [
                  ButtonSegment<int>(
                    value: 0,
                    icon: const Icon(Icons.science_outlined),
                    label: Text(l10n?.plaidModeSandbox ?? 'Plaid Sandbox'),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    icon: const Icon(Icons.vpn_key_outlined),
                    label: Text(l10n?.plaidModeLive ?? 'API Credentials'),
                  ),
                ],
                selected: {_selectedModeIndex},
                onSelectionChanged: _isLoading
                    ? null
                    : (set) {
                        setState(() {
                          _selectedModeIndex = set.first;
                          _errorMessage = null;
                        });
                      },
              ),
              const SizedBox(height: 16),

              if (_selectedModeIndex == 0) ...[
                // Mode 0: Plaid Sandbox
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Instant Simulated Plaid Item',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simulates Plaid\'s official First Platypus Bank test item containing 6 diversified positions (VOO, AAPL, NVDA, AMZN, MSFT, JPM) and test investment transactions matching Plaid sample payloads.',
                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedInstitutionName,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Test Brokerage Institution',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.account_balance),
                    helperText: 'Simulates Plaid Item with investments product',
                  ),
                  items: [
                    'First Platypus Bank (Plaid Sandbox)',
                    'Fidelity Investments (via Plaid)',
                    'Charles Schwab (via Plaid)',
                    'Vanguard Group (via Plaid)',
                  ]
                      .map((name) => DropdownMenuItem(value: name, child: Text(name, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedInstitutionName = val);
                  },
                ),
              ] else ...[
                // Mode 1: Official Plaid API Flow
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Environment & Client ID Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedEnv,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Environment',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'sandbox', child: Text('Sandbox')),
                                DropdownMenuItem(value: 'production', child: Text('Production')),
                              ],
                              onChanged: _isLoading
                                  ? null
                                  : (val) {
                                      if (val != null) setState(() => _selectedEnv = val);
                                    },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _clientIdController,
                              enabled: !_isLoading,
                              decoration: const InputDecoration(
                                labelText: '1. client_id',
                                hintText: 'Plaid client_id',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty) ? 'client_id is required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Plaid Secret
                      TextFormField(
                        controller: _secretController,
                        obscureText: _obscureSecret,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          labelText: '1. Plaid Secret',
                          hintText: 'Sandbox or Production secret',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureSecret ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => _obscureSecret = !_obscureSecret),
                          ),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'Secret is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Institution Picker (supports dynamic /institutions/get from Plaid API)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _fetchedInstitutions.isNotEmpty
                                        ? '${_fetchedInstitutions.length} Institutions loaded via /institutions/get'
                                        : 'Financial Institution (${_selectedEnv.toUpperCase()})',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onPressed: (_isLoading || _isFetchingInstitutions)
                                      ? null
                                      : _handleFetchInstitutions,
                                  icon: _isFetchingInstitutions
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.sync, size: 16),
                                  label: Text(
                                    _isFetchingInstitutions
                                        ? 'Loading...'
                                        : 'Query /institutions/get',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            if (_institutionsFetchError != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _institutionsFetchError!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              key: ValueKey(
                                  'inst_dropdown_${_fetchedInstitutions.length}_$_selectedInstitutionId'),
                              initialValue: _selectedInstitutionId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: _selectedEnv == 'sandbox'
                                    ? 'Sandbox Test Institution (Step 3)'
                                    : 'Selected Institution',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.business),
                                helperText: _fetchedInstitutions.isNotEmpty
                                    ? 'Filtered by products: [investments]'
                                    : 'Default test list or query Plaid API for live institutions',
                              ),
                              items: _fetchedInstitutions.isNotEmpty
                                  ? _fetchedInstitutions
                                      .map((inst) => DropdownMenuItem(
                                            value: inst.id,
                                            child: Text(
                                              '${inst.name} (${inst.id})',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList()
                                  : sandboxInstitutions.entries
                                      .map((entry) => DropdownMenuItem(
                                            value: entry.key,
                                            child: Text(entry.value,
                                                overflow: TextOverflow.ellipsis),
                                          ))
                                      .toList(),
                              onChanged: _isLoading
                                  ? null
                                  : (val) {
                                      if (val != null) {
                                        setState(() {
                                          _selectedInstitutionId = val;
                                          if (_fetchedInstitutions.isNotEmpty) {
                                            final match = _fetchedInstitutions
                                                .where((i) => i.id == val)
                                                .firstOrNull;
                                            _selectedInstitutionName =
                                                match?.name ?? val;
                                          } else {
                                            _selectedInstitutionName =
                                                sandboxInstitutions[val] ?? val;
                                          }
                                        });
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Advanced Plaid Step Controls Toggle
                      InkWell(
                        onTap: () => setState(() => _showAdvancedSteps = !_showAdvancedSteps),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                _showAdvancedSteps ? Icons.expand_less : Icons.expand_more,
                                size: 20,
                                color: plaidBlue,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _showAdvancedSteps
                                      ? 'Hide Advanced Token Controls'
                                      : 'Show Advanced / Custom Link Token Controls',
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: plaidBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_showAdvancedSteps) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _linkTokenCreated != null
                                          ? 'Link Token: ${_linkTokenCreated!.substring(0, 15)}...'
                                          : 'Step 2: /link/token/create',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: _isLoading ? null : _handleGenerateLinkTokenOnly,
                                    child: const Text('Get link_token'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _publicTokenController,
                                enabled: !_isLoading,
                                decoration: InputDecoration(
                                  labelText: '3. public_token (Link onSuccess callback)',
                                  hintText: 'public-sandbox-... or paste from Link',
                                  border: const OutlineInputBorder(),
                                  suffixIcon: _selectedEnv == 'sandbox'
                                      ? TextButton(
                                          onPressed: _isLoading ? null : _handleGenerateSandboxPublicTokenOnly,
                                          child: const Text('Simulate Link'),
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Loading / Progress Step Indicator
              if (_isLoading && _stepStatus != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: plaidBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: plaidBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: plaidBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _stepStatus!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: plaidBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Error banner
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(l10n?.cancelButton ?? 'Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: plaidBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _handleConnect,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.link),
                    label: Text(
                      _isLoading
                          ? 'Connecting...'
                          : (l10n?.plaidConnectAction ?? 'Connect Account'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

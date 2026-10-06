import 'package:flutter/material.dart';
import 'package:portfolio_feature/domain/entities/holding_position.dart';
import 'package:portfolio_feature/l10n/portfolio_localizations.dart';

class ManualPositionDialog extends StatefulWidget {
  final HoldingPosition? initialPosition;
  final ValueChanged<HoldingPosition> onSave;

  const ManualPositionDialog({
    super.key,
    this.initialPosition,
    required this.onSave,
  });

  @override
  State<ManualPositionDialog> createState() => _ManualPositionDialogState();
}

class _ManualPositionDialogState extends State<ManualPositionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _symbolController;
  late final TextEditingController _sharesController;
  late final TextEditingController _priceController;
  late final TextEditingController _nameController;
  String _selectedSector = 'Technology';

  final List<String> _sectors = [
    'Technology',
    'Communication Services',
    'Consumer Cyclical',
    'Healthcare',
    'Financial Services',
    'Energy',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.initialPosition;
    _symbolController = TextEditingController(text: p?.symbol ?? '');
    _sharesController = TextEditingController(text: p?.shares.toString() ?? '');
    _priceController = TextEditingController(text: p?.avgCostBasis.toString() ?? '');
    _nameController = TextEditingController(text: p?.companyName ?? '');
    if (p != null && _sectors.contains(p.sector)) {
      _selectedSector = p.sector;
    }
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _sharesController.dispose();
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = PortfolioLocalizations.of(context);

    return AlertDialog(
      title: Text(widget.initialPosition == null
          ? (l10n?.addPositionButton ?? 'Add Position Manually')
          : 'Edit Position'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _symbolController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n?.symbol ?? 'Ticker Symbol (e.g. AAPL)',
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a ticker symbol';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n?.companyName ?? 'Company Name (Optional)',
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sharesController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n?.shares ?? 'Shares Quantity',
                  prefixIcon: const Icon(Icons.numbers),
                ),
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid shares > 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n?.costBasis ?? 'Average Cost Basis (\$/share)',
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (val) {
                  final parsed = double.tryParse(val ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid price > 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedSector,
                decoration: InputDecoration(
                  labelText: l10n?.sector ?? 'Sector',
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _sectors
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSector = val);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final symbol = _symbolController.text.trim().toUpperCase();
              final shares = double.parse(_sharesController.text.trim());
              final price = double.parse(_priceController.text.trim());
              final name = _nameController.text.trim().isEmpty
                  ? '$symbol Corp.'
                  : _nameController.text.trim();

              final newPos = HoldingPosition(
                id: widget.initialPosition?.id ?? 'manual_${symbol}_${DateTime.now().millisecondsSinceEpoch}',
                symbol: symbol,
                companyName: name,
                shares: shares,
                avgCostBasis: price,
                currentPrice: widget.initialPosition?.currentPrice ?? (price * 1.05),
                sector: _selectedSector,
                purchaseDate: widget.initialPosition?.purchaseDate ?? DateTime.now(),
                lastUpdated: DateTime.now(),
              );

              widget.onSave(newPos);
              Navigator.of(context).pop();
            }
          },
          child: Text(l10n?.save ?? 'Save'),
        ),
      ],
    );
  }
}

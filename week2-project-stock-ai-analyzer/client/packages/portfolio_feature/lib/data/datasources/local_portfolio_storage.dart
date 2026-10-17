import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/holding_position.dart';

class LocalPortfolioStorage {
  static const String _storageKey = 'gen_stock_folio_holdings_v1';

  const LocalPortfolioStorage();

  Future<List<HoldingPosition>> loadPositions() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJsonList = prefs.getStringList(_storageKey);
    if (rawJsonList == null || rawJsonList.isEmpty) {
      return [];
    }

    final List<HoldingPosition> positions = [];
    for (final str in rawJsonList) {
      try {
        final map = jsonDecode(str) as Map<String, dynamic>;
        positions.add(HoldingPosition.fromJson(map));
      } catch (_) {
        // Skip corrupt entry
      }
    }
    return positions;
  }

  Future<void> savePositions(List<HoldingPosition> positions) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = positions.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

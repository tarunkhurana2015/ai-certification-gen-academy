import 'package:flutter/foundation.dart';

@immutable
class SectorAllocation {
  final String sector;
  final double dollarValue;
  final double percentage;
  final int holdingCount;
  final int colorValue;

  const SectorAllocation({
    required this.sector,
    required this.dollarValue,
    required this.percentage,
    required this.holdingCount,
    required this.colorValue,
  });
}

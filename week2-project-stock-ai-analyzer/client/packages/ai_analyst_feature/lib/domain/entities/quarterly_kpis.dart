/// Domain entities representing the 18+ standardized financial KPIs extracted
/// from quarterly corporate earnings reports (SEC 10-Q / Shareholder Updates).

class ProfitabilityMetrics {
  final double totalRevenueMillions;
  final double? revenueGrowthYoYPct;
  final double grossProfitMillions;
  final double grossMarginPct;
  final double operatingIncomeMillions;
  final double operatingMarginPct;
  final double netIncomeMillions;
  final double netMarginPct;
  final double epsDilutedGaap;
  final double? epsDilutedNonGaap;

  const ProfitabilityMetrics({
    required this.totalRevenueMillions,
    this.revenueGrowthYoYPct,
    required this.grossProfitMillions,
    required this.grossMarginPct,
    required this.operatingIncomeMillions,
    required this.operatingMarginPct,
    required this.netIncomeMillions,
    required this.netMarginPct,
    required this.epsDilutedGaap,
    this.epsDilutedNonGaap,
  });

  factory ProfitabilityMetrics.fromJson(Map<String, dynamic> json) {
    return ProfitabilityMetrics(
      totalRevenueMillions: (json['total_revenue_millions'] as num).toDouble(),
      revenueGrowthYoYPct: (json['revenue_growth_yoy_pct'] as num?)?.toDouble(),
      grossProfitMillions: (json['gross_profit_millions'] as num).toDouble(),
      grossMarginPct: (json['gross_margin_pct'] as num).toDouble(),
      operatingIncomeMillions: (json['operating_income_millions'] as num).toDouble(),
      operatingMarginPct: (json['operating_margin_pct'] as num).toDouble(),
      netIncomeMillions: (json['net_income_millions'] as num).toDouble(),
      netMarginPct: (json['net_margin_pct'] as num).toDouble(),
      epsDilutedGaap: (json['eps_diluted_gaap'] as num).toDouble(),
      epsDilutedNonGaap: (json['eps_diluted_nongaap'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_revenue_millions': totalRevenueMillions,
    'revenue_growth_yoy_pct': revenueGrowthYoYPct,
    'gross_profit_millions': grossProfitMillions,
    'gross_margin_pct': grossMarginPct,
    'operating_income_millions': operatingIncomeMillions,
    'operating_margin_pct': operatingMarginPct,
    'net_income_millions': netIncomeMillions,
    'net_margin_pct': netMarginPct,
    'eps_diluted_gaap': epsDilutedGaap,
    'eps_diluted_nongaap': epsDilutedNonGaap,
  };
}

class CashFlowMetrics {
  final double operatingCashFlowMillions;
  final double capitalExpendituresMillions;
  final double freeCashFlowMillions;
  final double? fcfConversionRatePct;

  const CashFlowMetrics({
    required this.operatingCashFlowMillions,
    required this.capitalExpendituresMillions,
    required this.freeCashFlowMillions,
    this.fcfConversionRatePct,
  });

  factory CashFlowMetrics.fromJson(Map<String, dynamic> json) {
    return CashFlowMetrics(
      operatingCashFlowMillions: (json['operating_cash_flow_millions'] as num).toDouble(),
      capitalExpendituresMillions: (json['capital_expenditures_millions'] as num).toDouble(),
      freeCashFlowMillions: (json['free_cash_flow_millions'] as num).toDouble(),
      fcfConversionRatePct: (json['fcf_conversion_rate_pct'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'operating_cash_flow_millions': operatingCashFlowMillions,
    'capital_expenditures_millions': capitalExpendituresMillions,
    'free_cash_flow_millions': freeCashFlowMillions,
    'fcf_conversion_rate_pct': fcfConversionRatePct,
  };
}

class BalanceSheetMetrics {
  final double cashAndEquivalentsMillions;
  final double totalDebtMillions;
  final double netCashMillions;
  final double totalAssetsMillions;
  final double totalLiabilitiesMillions;
  final double shareholdersEquityMillions;
  final double? debtToEquityRatio;
  final double? currentRatio;

  const BalanceSheetMetrics({
    required this.cashAndEquivalentsMillions,
    required this.totalDebtMillions,
    required this.netCashMillions,
    required this.totalAssetsMillions,
    required this.totalLiabilitiesMillions,
    required this.shareholdersEquityMillions,
    this.debtToEquityRatio,
    this.currentRatio,
  });

  factory BalanceSheetMetrics.fromJson(Map<String, dynamic> json) {
    return BalanceSheetMetrics(
      cashAndEquivalentsMillions: (json['cash_and_equivalents_millions'] as num).toDouble(),
      totalDebtMillions: (json['total_debt_millions'] as num).toDouble(),
      netCashMillions: (json['net_cash_millions'] as num).toDouble(),
      totalAssetsMillions: (json['total_assets_millions'] as num).toDouble(),
      totalLiabilitiesMillions: (json['total_liabilities_millions'] as num).toDouble(),
      shareholdersEquityMillions: (json['shareholders_equity_millions'] as num).toDouble(),
      debtToEquityRatio: (json['debt_to_equity_ratio'] as num?)?.toDouble(),
      currentRatio: (json['current_ratio'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'cash_and_equivalents_millions': cashAndEquivalentsMillions,
    'total_debt_millions': totalDebtMillions,
    'net_cash_millions': netCashMillions,
    'total_assets_millions': totalAssetsMillions,
    'total_liabilities_millions': totalLiabilitiesMillions,
    'shareholders_equity_millions': shareholdersEquityMillions,
    'debt_to_equity_ratio': debtToEquityRatio,
    'current_ratio': currentRatio,
  };
}

class QuarterlyKpis {
  final String documentId;
  final String ticker;
  final String companyName;
  final int fiscalYear;
  final String fiscalQuarter;
  final String reportDate;
  final List<String> summaryBullets;
  final ProfitabilityMetrics profitability;
  final CashFlowMetrics cashFlow;
  final BalanceSheetMetrics balanceSheet;

  const QuarterlyKpis({
    required this.documentId,
    required this.ticker,
    required this.companyName,
    required this.fiscalYear,
    required this.fiscalQuarter,
    required this.reportDate,
    required this.summaryBullets,
    required this.profitability,
    required this.cashFlow,
    required this.balanceSheet,
  });

  String get fiscalPeriodDisplay => '$fiscalQuarter $fiscalYear';

  factory QuarterlyKpis.fromJson(Map<String, dynamic> json) {
    return QuarterlyKpis(
      documentId: json['document_id'] as String,
      ticker: json['ticker'] as String,
      companyName: json['company_name'] as String? ?? json['ticker'] as String,
      fiscalYear: json['fiscal_year'] as int? ?? 2026,
      fiscalQuarter: json['fiscal_quarter'] as String? ?? 'Q2',
      reportDate: json['report_date'] as String? ?? '',
      summaryBullets: (json['summary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      profitability: ProfitabilityMetrics.fromJson(
        json['profitability'] as Map<String, dynamic>,
      ),
      cashFlow: CashFlowMetrics.fromJson(
        json['cash_flow'] as Map<String, dynamic>,
      ),
      balanceSheet: BalanceSheetMetrics.fromJson(
        json['balance_sheet'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'document_id': documentId,
    'ticker': ticker,
    'company_name': companyName,
    'fiscal_year': fiscalYear,
    'fiscal_quarter': fiscalQuarter,
    'report_date': reportDate,
    'summary': summaryBullets,
    'profitability': profitability.toJson(),
    'cash_flow': cashFlow.toJson(),
    'balance_sheet': balanceSheet.toJson(),
  };
}

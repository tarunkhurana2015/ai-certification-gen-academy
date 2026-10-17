import '../../domain/entities/quarterly_kpis.dart';

/// Pre-populated benchmark datasets directly matching Tesla Q2 2026 update
/// and multi-quarter comparison data specified in the project PRD and Architecture.
class MockKpiDataSource {
  static final List<QuarterlyKpis> benchmarkReports = [
    const QuarterlyKpis(
      documentId: 'doc_tsla_2026_q2',
      ticker: 'TSLA',
      companyName: 'Tesla, Inc.',
      fiscalYear: 2026,
      fiscalQuarter: 'Q2',
      reportDate: '2026-07-23',
      summaryBullets: [
        'Total revenue expanded +2.1% YoY to \$25.50B, supported by Energy Storage deployment growth (+158% YoY).',
        'Operating margin compressed to 6.30% due to reduced vehicle ASPs, restructuring costs, and increased AI compute investments.',
        'Free Cash Flow surged to \$1.34B (+52% QoQ) with balance sheet liquidity remaining fortress-strong at \$30.72B in cash.',
      ],
      profitability: ProfitabilityMetrics(
        totalRevenueMillions: 25500.0,
        revenueGrowthYoYPct: 2.1,
        grossProfitMillions: 4578.0,
        grossMarginPct: 17.95,
        operatingIncomeMillions: 1605.0,
        operatingMarginPct: 6.30,
        netIncomeMillions: 1478.0,
        netMarginPct: 5.80,
        epsDilutedGaap: 0.52,
        epsDilutedNonGaap: 0.60,
      ),
      cashFlow: CashFlowMetrics(
        operatingCashFlowMillions: 3238.0,
        capitalExpendituresMillions: 1898.0,
        freeCashFlowMillions: 1340.0,
        fcfConversionRatePct: 90.66,
      ),
      balanceSheet: BalanceSheetMetrics(
        cashAndEquivalentsMillions: 30720.0,
        totalDebtMillions: 5350.0,
        netCashMillions: 25370.0,
        totalAssetsMillions: 110450.0,
        totalLiabilitiesMillions: 44820.0,
        shareholdersEquityMillions: 65630.0,
        debtToEquityRatio: 0.082,
        currentRatio: 1.74,
      ),
    ),
    const QuarterlyKpis(
      documentId: 'doc_tsla_2026_q1',
      ticker: 'TSLA',
      companyName: 'Tesla, Inc.',
      fiscalYear: 2026,
      fiscalQuarter: 'Q1',
      reportDate: '2026-04-23',
      summaryBullets: [
        'Total revenues reached \$21.30B, impacted by factory retooling for updated Model 3 in Fremont and Shanghai.',
        'Gross margin registered at 17.38% with operating margin of 5.48%.',
        'Free cash flow of \$881M, impacted by seasonal working capital build and initial CapEx for Cortex AI cluster.',
      ],
      profitability: ProfitabilityMetrics(
        totalRevenueMillions: 21301.0,
        revenueGrowthYoYPct: -8.7,
        grossProfitMillions: 3696.0,
        grossMarginPct: 17.38,
        operatingIncomeMillions: 1171.0,
        operatingMarginPct: 5.48,
        netIncomeMillions: 1129.0,
        netMarginPct: 5.30,
        epsDilutedGaap: 0.34,
        epsDilutedNonGaap: 0.45,
      ),
      cashFlow: CashFlowMetrics(
        operatingCashFlowMillions: 2423.0,
        capitalExpendituresMillions: 1542.0,
        freeCashFlowMillions: 881.0,
        fcfConversionRatePct: 78.03,
      ),
      balanceSheet: BalanceSheetMetrics(
        cashAndEquivalentsMillions: 26863.0,
        totalDebtMillions: 5410.0,
        netCashMillions: 21453.0,
        totalAssetsMillions: 106520.0,
        totalLiabilitiesMillions: 43210.0,
        shareholdersEquityMillions: 63310.0,
        debtToEquityRatio: 0.085,
        currentRatio: 1.68,
      ),
    ),
    const QuarterlyKpis(
      documentId: 'doc_aapl_2026_q2',
      ticker: 'AAPL',
      companyName: 'Apple Inc.',
      fiscalYear: 2026,
      fiscalQuarter: 'Q2',
      reportDate: '2026-05-02',
      summaryBullets: [
        'Revenue was \$90.75B, driven by all-time high Services revenue of \$23.87B (+14.2% YoY).',
        'Gross margin hit a record 46.6% with EPS reaching \$1.53.',
        'Generated \$22.7B in Operating Cash Flow, returning over \$27B to shareholders through dividends and buybacks.',
      ],
      profitability: ProfitabilityMetrics(
        totalRevenueMillions: 90753.0,
        revenueGrowthYoYPct: 4.3,
        grossProfitMillions: 42271.0,
        grossMarginPct: 46.58,
        operatingIncomeMillions: 27900.0,
        operatingMarginPct: 30.74,
        netIncomeMillions: 23636.0,
        netMarginPct: 26.04,
        epsDilutedGaap: 1.53,
        epsDilutedNonGaap: 1.53,
      ),
      cashFlow: CashFlowMetrics(
        operatingCashFlowMillions: 22699.0,
        capitalExpendituresMillions: 2110.0,
        freeCashFlowMillions: 20589.0,
        fcfConversionRatePct: 87.11,
      ),
      balanceSheet: BalanceSheetMetrics(
        cashAndEquivalentsMillions: 67150.0,
        totalDebtMillions: 104590.0,
        netCashMillions: -37440.0,
        totalAssetsMillions: 337411.0,
        totalLiabilitiesMillions: 263200.0,
        shareholdersEquityMillions: 74211.0,
        debtToEquityRatio: 1.409,
        currentRatio: 1.04,
      ),
    ),
  ];

  static Future<List<QuarterlyKpis>> getAvailableReports() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return benchmarkReports;
  }

  static Future<QuarterlyKpis?> getKpisByDocumentId(String documentId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return benchmarkReports.firstWhere((r) => r.documentId == documentId);
    } catch (_) {
      return benchmarkReports.first;
    }
  }
}

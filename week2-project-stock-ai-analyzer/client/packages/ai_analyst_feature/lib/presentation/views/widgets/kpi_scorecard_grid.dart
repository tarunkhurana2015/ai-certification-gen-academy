import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/quarterly_kpis.dart';
import 'kpi_metric_card.dart';

class KpiScorecardGrid extends StatelessWidget {
  final QuarterlyKpis kpis;

  const KpiScorecardGrid({
    super.key,
    required this.kpis,
  });

  String _formatCurrency(double millions) {
    if (millions >= 1000) {
      final billions = millions / 1000.0;
      return '\$${billions.toStringAsFixed(2)}B';
    } else {
      final f = NumberFormat('#,##0', 'en_US');
      return '\$${f.format(millions)}M';
    }
  }

  String _formatPct(double pct) => '${pct.toStringAsFixed(2)}%';

  @override
  Widget build(BuildContext context) {
    final prof = kpis.profitability;
    final cf = kpis.cashFlow;
    final bs = kpis.balanceSheet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------------------------------------------------------------------
        // PILLAR 1: PROFITABILITY & EARNINGS
        // ---------------------------------------------------------------------
        _buildSectionHeader(
          context,
          title: 'Profitability & Earnings Power',
          icon: Icons.monetization_on_outlined,
          color: Colors.blue,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return _buildSingleRowCategory(
              context,
              constraints: constraints,
              cards: [
                KpiMetricCard(
                  title: 'Total Revenue',
                  description: 'Gross receipts from automotive sales, energy products, and service contracts.',
                  value: _formatCurrency(prof.totalRevenueMillions),
                  badgeText: prof.revenueGrowthYoYPct != null
                      ? '${prof.revenueGrowthYoYPct! >= 0 ? '+' : ''}${prof.revenueGrowthYoYPct!.toStringAsFixed(1)}% YoY'
                      : null,
                  isPositiveBadge: (prof.revenueGrowthYoYPct ?? 0) >= 0,
                  subtitle: 'Top-line sales volume',
                  icon: Icons.trending_up,
                  accentColor: Colors.blue,
                ),
                KpiMetricCard(
                  title: 'Gross Margin',
                  description: 'Percentage of revenue retained after deducting direct production and delivery costs.',
                  value: _formatPct(prof.grossMarginPct),
                  subtitle: 'Gross Profit: ${_formatCurrency(prof.grossProfitMillions)}',
                  icon: Icons.pie_chart,
                  accentColor: Colors.indigo,
                ),
                KpiMetricCard(
                  title: 'Operating Margin',
                  description: 'Operating efficiency reflecting core business profitability before taxes and interest.',
                  value: _formatPct(prof.operatingMarginPct),
                  subtitle: 'EBIT: ${_formatCurrency(prof.operatingIncomeMillions)}',
                  icon: Icons.settings_suggest,
                  accentColor: Colors.teal,
                ),
                KpiMetricCard(
                  title: 'Net Margin',
                  description: 'Bottom-line percentage of total revenue remaining as net profit after all expenses.',
                  value: _formatPct(prof.netMarginPct),
                  subtitle: 'Net Income: ${_formatCurrency(prof.netIncomeMillions)}',
                  icon: Icons.stacked_line_chart,
                  accentColor: Colors.purple,
                ),
                KpiMetricCard(
                  title: 'Diluted EPS (GAAP)',
                  description: 'Net profit attributed to each share of common stock accounting for full dilution.',
                  value: '\$${prof.epsDilutedGaap.toStringAsFixed(2)}',
                  subtitle: prof.epsDilutedNonGaap != null
                      ? 'Non-GAAP: \$${prof.epsDilutedNonGaap!.toStringAsFixed(2)}'
                      : 'Per diluted share',
                  badgeText: 'GAAP',
                  icon: Icons.calculate_outlined,
                  accentColor: Colors.cyan,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // ---------------------------------------------------------------------
        // PILLAR 2: CASH FLOW & CAPITAL ALLOCATION
        // ---------------------------------------------------------------------
        _buildSectionHeader(
          context,
          title: 'Cash Flow & Reinvestment',
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF059669),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return _buildSingleRowCategory(
              context,
              constraints: constraints,
              cards: [
                KpiMetricCard(
                  title: 'Operating Cash Flow',
                  description: 'Actual liquid cash generated from regular business operations and working capital.',
                  value: _formatCurrency(cf.operatingCashFlowMillions),
                  subtitle: 'Core operational inflow',
                  icon: Icons.account_balance,
                  accentColor: Colors.green,
                ),
                KpiMetricCard(
                  title: 'Capital Expenditures (CapEx)',
                  description: 'Capital invested in Gigafactory scaling, manufacturing equipment, and AI compute.',
                  value: _formatCurrency(cf.capitalExpendituresMillions),
                  subtitle: 'Factories & AI hardware',
                  icon: Icons.factory_outlined,
                  accentColor: Colors.orange,
                ),
                KpiMetricCard(
                  title: 'Free Cash Flow (FCF)',
                  description: 'Discretionary cash generated (OCF - CapEx) available for dividends, buybacks, or debt.',
                  value: _formatCurrency(cf.freeCashFlowMillions),
                  badgeText: cf.fcfConversionRatePct != null
                      ? '${cf.fcfConversionRatePct!.toStringAsFixed(0)}% Conversion'
                      : null,
                  isPositiveBadge: cf.freeCashFlowMillions > 0,
                  subtitle: 'Operating Cash minus CapEx',
                  icon: Icons.savings_outlined,
                  accentColor: const Color(0xFF059669),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // ---------------------------------------------------------------------
        // PILLAR 3: BALANCE SHEET & SOLVENCY
        // ---------------------------------------------------------------------
        _buildSectionHeader(
          context,
          title: 'Balance Sheet & Solvency',
          icon: Icons.shield_outlined,
          color: Colors.deepPurple,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return _buildSingleRowCategory(
              context,
              constraints: constraints,
              cards: [
                KpiMetricCard(
                  title: 'Cash & Equivalents',
                  description: 'Liquid reserves in bank accounts, money market funds, and US government bills.',
                  value: _formatCurrency(bs.cashAndEquivalentsMillions),
                  subtitle: 'Fortress liquidity buffer',
                  icon: Icons.account_balance_wallet_outlined,
                  accentColor: Colors.purple,
                ),
                KpiMetricCard(
                  title: 'Total Debt',
                  description: 'Combined liabilities from short-term loans, credit notes, and long-term debt.',
                  value: _formatCurrency(bs.totalDebtMillions),
                  subtitle: 'Short & long-term borrowings',
                  icon: Icons.credit_card_outlined,
                  accentColor: Colors.deepOrange,
                ),
                KpiMetricCard(
                  title: 'Net Cash / (Debt)',
                  description: 'Cash reserves minus total debt; indicates financial resilience and buffer.',
                  value: (bs.netCashMillions >= 0 ? '+' : '') +
                      _formatCurrency(bs.netCashMillions.abs()),
                  badgeText: bs.netCashMillions >= 0 ? 'Net Cash' : 'Net Debt',
                  isPositiveBadge: bs.netCashMillions >= 0,
                  subtitle: 'Total Cash - Total Debt',
                  icon: Icons.balance,
                  accentColor: bs.netCashMillions >= 0 ? Colors.green : Colors.red,
                ),
                KpiMetricCard(
                  title: 'Debt-to-Equity Ratio',
                  description: 'Leverage index evaluating total debt against equity book value.',
                  value: bs.debtToEquityRatio != null
                      ? bs.debtToEquityRatio!.toStringAsFixed(3)
                      : 'N/A',
                  subtitle: bs.currentRatio != null
                      ? 'Current Ratio: ${bs.currentRatio!.toStringAsFixed(2)}x'
                      : 'Solvency leverage',
                  badgeText: (bs.debtToEquityRatio ?? 1.0) < 0.5 ? 'Conservative' : 'Leveraged',
                  icon: Icons.security,
                  accentColor: Colors.indigo,
                ),
                KpiMetricCard(
                  title: "Shareholders' Equity",
                  description: 'Net balance sheet value of the business owned by shareholders (Assets - Liabilities).',
                  value: _formatCurrency(bs.shareholdersEquityMillions),
                  subtitle: 'Assets: ${_formatCurrency(bs.totalAssetsMillions)}',
                  icon: Icons.account_balance_outlined,
                  accentColor: Colors.blueGrey,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSingleRowCategory(
    BuildContext context, {
    required List<Widget> cards,
    required BoxConstraints constraints,
  }) {
    // On wider screens (>= 700), stretch all cards into a single row using Expanded.
    // On compact screens (< 700), keep all cards in a single row with horizontal scrolling.
    final isWide = constraints.maxWidth >= 700;

    if (isWide) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 104,
                child: cards[i],
              ),
            ),
          ],
        ],
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              SizedBox(
                width: 165,
                height: 104,
                child: cards[i],
              ),
            ],
          ],
        ),
      );
    }
  }
}

extension ColorExtension on Colors {
  static Color? get emeraldGreen => const Color(0xFF059669);
}

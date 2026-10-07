# 07 - Phased Implementation Plan & Definition of Done: GenStockFolio

## 1. Phased Execution Roadmap

### Phase 1: Monorepo & Application Shell Scaffolding
- [x] Initialize monorepo workspace structure via `flutter-scaffold-project` separating `apps/gen_stock_folio` from `packages/`.
- [x] Scaffold primary executable application (`apps/gen_stock_folio`) supporting macOS Desktop, Web, and iOS Mobile targets.
- [x] Implement fintech Material 3 dark/light design system in `apps/gen_stock_folio/lib/core/theme/app_theme.dart` with seed color `#00C805`, semantic profit/loss tokens, and tabular numeric typography.
- [x] Configure declarative multi-branch router in `apps/gen_stock_folio/lib/core/router/app_router.dart` utilizing `StatefulShellRoute.indexedStack` with adaptive responsive shell (`NavigationBar` on mobile, `NavigationRail` on desktop/web).

### Phase 2: Tab 1 Data Ingestion & CSV Engine (`packages/portfolio_feature`)
- [x] Scaffold `packages/portfolio_feature` with `pubspec.yaml`, `l10n.yaml`, `docs/`, and `test/`.
- [x] Implement strongly typed domain entities: `HoldingPosition`, `PortfolioSummary`, `CsvParseResult`, `CsvRowError`, `InvestmentTransaction`, `PlaidInstitution`, and `StockQuote`.
- [x] Implement RFC 4180 streaming `CsvParserService` with flexible column normalizer matching common broker exports (Schwab, Fidelity, Vanguard, standard) and 50-holding datasets.
- [x] Implement `MockBrokerageRepository` providing instant 1-click demo portfolio generation and local `SharedPreferences` persistence.
- [x] Implement `PlaidBrokerageAdapter` providing full 5-step Plaid Investments API integration (`/link/token/create`, `/sandbox/public_token/create`, `/item/public_token/exchange`, `/investments/holdings/get`, `/investments/transactions/get`) with sandbox and live account links and zero-disk credential security.
- [x] Implement `YahooFinancePriceService` (`IStockPriceService`) providing real-time batch price fetching and live streaming ticker updates.
- [x] Implement `PortfolioViewModel` (`Notifier<PortfolioState>`) handling import, CSV parsing, validation modal states, Plaid connection, live price streaming, manual position editing, and deletion.
- [x] Build `PortfolioIngestView` with Welcome Onboarding Card, drag-and-drop / file-picker CSV upload, Plaid connection modal, and live quote indicators.
- [x] Author unit and adapter tests in `packages/portfolio_feature/test/` achieving $\ge 80\%$ logic coverage.

### Phase 3: Tab 2 Allocation & Tab 3 Lifetime Analytics
- [x] **Tab 2: Asset Allocation (`packages/allocation_feature`)**:
  - [x] Scaffold `packages/allocation_feature` module with `pubspec.yaml` and `l10n.yaml`.
  - [x] Implement `AllocationViewModel` computing sector and equity percentage weights from core holdings state.
  - [x] Build `AllocationPieChart` utilizing hardware-accelerated animated donut charts with interactive slice touch detection, radial explosion displacement, and central value callouts.
  - [x] Implement two-way cross-filtering: tapping pie slice filters the `HoldingsBreakdownTable` below; tapping table row opens `PositionDetailSheet`.
  - [x] Author unit tests for slice selection, cross-filtering, and column sorting.
- [x] **Tab 3: Historical Performance & Risk (`packages/analytics_feature`)**:
  - [x] Scaffold `packages/analytics_feature` module with `pubspec.yaml` and `l10n.yaml`.
  - [x] Implement `AnalyticsViewModel` calculating lifetime invested capital, current valuation, net dollar profit/loss, and percentage return.
  - [x] Build `PerformanceSummaryCards` with high-contrast profit/loss styling.
  - [x] Implement `EquityCurveChart` rendering interactive historical portfolio trajectories with time filter chips (`1M`, `6M`, `1Y`, `ALL`).
  - [x] Implement `RiskIndicatorsGrid` calculating Beta vs S&P 500, Sharpe Ratio, and 0–100 Diversification Health Score.
  - [x] Author unit tests for portfolio math, performance compounding, and risk metric algorithms.

### Phase 4: Integration, Cross-Platform Verification & Quality Hardening
- [x] Mount package routes and barrel exports in `apps/gen_stock_folio`.
- [x] Wire package localization delegates into `MaterialApp.router` in `apps/gen_stock_folio/lib/app.dart`.
- [x] Execute `flutter analyze --fatal-infos` across all packages and the host application (enforcing 0 errors, 0 warnings).
- [x] Execute complete `flutter test` test suites across all packages and host app (all passing).
- [x] Execute platform smoke tests:
  - macOS Desktop: `flutter run -d macos` (verifying widescreen table, keyboard shortcuts, window resizing).
  - Chrome Web: `flutter run -d chrome` (verifying CanvasKit rendering, browser file picker, responsive layout).
  - iOS Simulator: `flutter run -d <iOS_Device>` (verifying touch interactions, bottom navigation bar, haptics).

---

## 2. Definition of Done (DoD)
A feature or milestone is considered **Done** only when all 6 strict criteria are met:
1. **Spec Alignment**: Implementation matches Gherkin scenarios defined in `02_user_journeys_and_features.md`.
2. **Localization (l10n)**: All visible UI strings reside in `.arb` localization files; zero hardcoded user-facing strings in widget trees.
3. **Responsive Adaptation**: UI adapts smoothly between Mobile (<600dp), Tablet (600–840dp), and Desktop/Web (≥840dp) with zero `RenderFlex` overflow errors.
4. **Test Coverage**: Business logic across ViewModels, CSV stream parsers, portfolio mathematical models, and risk algorithms achieves $\ge 80\%$ test coverage.
5. **Static Analysis**: `flutter analyze --fatal-infos` completes with zero errors and zero warnings.
6. **Cross-Platform Verification**: App launches and runs cleanly on macOS Desktop, Chrome Web, and iOS Mobile targets.

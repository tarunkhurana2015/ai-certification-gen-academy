# 07 - Phased Implementation Plan & Definition of Done: GenStockFolio

## 1. Phased Execution Roadmap

### Phase 1: Monorepo & Application Shell Scaffolding
- [ ] Initialize monorepo workspace structure via `flutter-scaffold-project` separating `apps/gen_stock_folio` from `packages/`.
- [ ] Scaffold primary executable application (`apps/gen_stock_folio`) supporting macOS Desktop, Web, and iOS Mobile targets.
- [ ] Implement fintech Material 3 dark/light design system in `apps/gen_stock_folio/lib/core/theme/app_theme.dart` with seed color `#00C805`, semantic profit/loss tokens, and tabular numeric typography.
- [ ] Configure declarative multi-branch router in `apps/gen_stock_folio/lib/core/router/app_router.dart` utilizing `StatefulShellRoute.indexedStack` with adaptive responsive shell (`NavigationBar` on mobile, `NavigationRail` on desktop/web).

### Phase 2: Tab 1 Data Ingestion & CSV Engine (`packages/portfolio_feature`)
- [ ] Scaffold `packages/portfolio_feature` with `pubspec.yaml`, `l10n.yaml`, `docs/`, and `test/`.
- [ ] Implement strongly typed domain entities: `HoldingPosition`, `PortfolioSummary`, `CsvParseResult`, and `CsvRowError`.
- [ ] Implement RFC 4180 streaming `CsvParserService` with flexible column normalizer matching common aliases (`Symbol`/`Ticker`, `Shares`/`Quantity`, `Price`/`CostBasis`, `Date`).
- [ ] Implement `MockBrokerageRepository` providing instant 1-click 6-stock demo portfolio generation and local `SharedPreferences` persistence.
- [ ] Define abstract `IBrokerageRepository` interface and establish Phase 2 `RobinhoodBrokerageAdapter` stub.
- [ ] Implement `PortfolioViewModel` (`Notifier<PortfolioState>`) handling import, CSV parsing, validation modal states, manual position editing, and deletion.
- [ ] Build `PortfolioIngestView` with Welcome Onboarding Card, drag-and-drop / file-picker CSV upload, and Validation Preview Modal.
- [ ] Author unit tests in `packages/portfolio_feature/test/` achieving $\ge 80\%$ logic coverage.

### Phase 3: Tab 2 Allocation & Tab 3 Lifetime Analytics
- [ ] **Tab 2: Asset Allocation (`packages/allocation_feature`)**:
  - Scaffold `packages/allocation_feature` module with `pubspec.yaml` and `l10n.yaml`.
  - Implement `AllocationViewModel` computing sector and equity percentage weights from core holdings state.
  - Build `AllocationPieChart` utilizing hardware-accelerated animated donut charts with interactive slice touch detection, radial explosion displacement, and central value callouts.
  - Implement two-way cross-filtering: tapping pie slice filters the `HoldingsBreakdownTable` below; tapping table row opens `PositionDetailSheet`.
  - Author unit tests for slice selection, cross-filtering, and column sorting.
- [ ] **Tab 3: Historical Performance & Risk (`packages/analytics_feature`)**:
  - Scaffold `packages/analytics_feature` module with `pubspec.yaml` and `l10n.yaml`.
  - Implement `AnalyticsViewModel` calculating lifetime invested capital, current valuation, net dollar profit/loss, and percentage return.
  - Build `PerformanceSummaryCards` with high-contrast profit/loss styling.
  - Implement `EquityCurveChart` rendering interactive historical portfolio trajectories with time filter chips (`1M`, `6M`, `1Y`, `ALL`).
  - Implement `RiskIndicatorsGrid` calculating Beta vs S&P 500, Sharpe Ratio, and 0–100 Diversification Health Score.
  - Author unit tests for portfolio math, performance compounding, and risk metric algorithms.

### Phase 4: Integration, Cross-Platform Verification & Quality Hardening
- [ ] Mount package routes and barrel exports in `apps/gen_stock_folio`.
- [ ] Wire package localization delegates into `MaterialApp.router` in `apps/gen_stock_folio/lib/app.dart`.
- [ ] Execute `flutter analyze --fatal-infos` across all packages and the host application (enforcing 0 errors, 0 warnings).
- [ ] Execute complete `flutter test` test suites across all packages and host app.
- [ ] Execute platform smoke tests:
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

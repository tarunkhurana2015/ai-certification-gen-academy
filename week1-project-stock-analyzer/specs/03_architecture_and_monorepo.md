# 03 - Architecture & Monorepo Specification: GenStockFolio

## 1. Monorepo Workspace Structure
This project follows the **Flutter Workspace / Monorepo pattern** dividing the executable host application shell from modular, reusable feature packages:

```text
week1-project-stock-analyzer/
├── apps/
│   └── gen_stock_folio/                   # Executable application shell (ios, macos, web)
│       ├── pubspec.yaml                   # Host pubspec with path dependencies to packages/
│       ├── l10n.yaml                      # Host root localization config
│       ├── macos/                         # Native macOS desktop runner & entitlements
│       ├── web/                           # Web index.html & CanvasKit/Wasm runner
│       ├── ios/                           # iOS runner & Xcode project
│       └── lib/
│           ├── main.dart                  # App entrypoint (runApp with ProviderScope)
│           ├── app.dart                   # MaterialApp.router with combined localizationsDelegates
│           └── core/
│               ├── router/                # Central StatefulShellRoute with IndexedStack
│               ├── theme/                 # Material 3 dark/light themes & color tokens
│               └── constants/             # App-wide asset paths and branding
│
└── packages/
    ├── portfolio_feature/                 # Tab 1: Data Ingestion & CSV Import
    │   ├── pubspec.yaml                   # Feature dependencies (csv, shared_preferences, riverpod)
    │   ├── l10n.yaml                      # Package localization config
    │   ├── docs/README.md                 # Package architecture documentation
    │   ├── test/                          # Unit and widget tests for CSV & ingestion
    │   └── lib/
    │       ├── portfolio_feature.dart     # Public barrel export
    │       ├── presentation/
    │       │   ├── router/router.config.dart
    │       │   ├── state/portfolio_state.dart
    │       │   ├── viewmodel/portfolio_viewmodel.dart
    │       │   └── views/
    │       │       ├── portfolio_ingest_view.dart
    │       │       ├── widgets/csv_preview_dialog.dart
    │       │       └── widgets/manual_position_dialog.dart
    │       ├── domain/
    │       │   ├── entities/holding_position.dart
    │       │   ├── entities/portfolio_summary.dart
    │       │   └── repositories/brokerage_repository.dart
    │       └── data/
    │           ├── datasources/local_portfolio_storage.dart
    │           ├── datasources/csv_parser_service.dart
    │           └── repositories/
    │               ├── mock_brokerage_repository.dart
    │               └── robinhood_brokerage_adapter.dart
    │
    ├── allocation_feature/                # Tab 2: Asset Allocation & Holdings Breakdown
    │   ├── pubspec.yaml                   # Feature dependencies (fl_chart, riverpod)
    │   ├── l10n.yaml                      # Package localization config
    │   ├── docs/README.md                 # Package documentation
    │   ├── test/                          # Allocation tests (cross-filtering, sorting)
    │   └── lib/
    │       ├── allocation_feature.dart    # Public barrel export
    │       ├── presentation/
    │       │   ├── router/router.config.dart
    │       │   ├── state/allocation_state.dart
    │       │   ├── viewmodel/allocation_viewmodel.dart
    │       │   └── views/
    │       │       ├── allocation_view.dart
    │       │       ├── widgets/allocation_pie_chart.dart
    │       │       ├── widgets/holdings_breakdown_table.dart
    │       │       └── widgets/position_detail_sheet.dart
    │       └── domain/
    │           └── entities/sector_allocation.dart
    │
    └── analytics_feature/                 # Tab 3: Historical Performance & Risk
        ├── pubspec.yaml                   # Feature dependencies (fl_chart, riverpod)
        ├── l10n.yaml                      # Package localization config
        ├── docs/README.md                 # Package documentation
        ├── test/                          # Analytics tests (Beta, Sharpe, equity curve)
        └── lib/
            ├── analytics_feature.dart     # Public barrel export
            ├── presentation/
            │   ├── router/router.config.dart
            │   ├── state/analytics_state.dart
            │   ├── viewmodel/analytics_viewmodel.dart
            │   └── views/
            │       ├── analytics_view.dart
            │       ├── widgets/performance_summary_cards.dart
            │       ├── widgets/equity_curve_chart.dart
            │       └── widgets/risk_indicators_grid.dart
            └── domain/
                └── entities/performance_metrics.dart
```

---

## 2. Presentation Pattern: Model-View-ViewModel (MVVM)

Within each feature package in `packages/<name>/lib/presentation/`:
- **`router/router.config.dart`**: Declares package route branches using `RouteBase` / `GoRoute` mounted by the host shell.
- **`state/`**: Immutable UI State classes annotated with `@immutable`, containing strongly typed fields and explicit `copyWith` methods.
- **`viewmodel/`**: Riverpod `Notifier<State>` (or `AsyncNotifier<State>`) holding business logic and mutating state via predictable reductions.
- **`views/`**: `ConsumerWidget` or `ConsumerStatefulWidget` observing ViewModels via `ref.watch(provider)` and dispatching actions via `ref.read(provider.notifier)`.

---

## 3. Technology Stack & Dependencies

| Layer | Library / Tool | Version | Rationale |
|---|---|---|---|
| **Language & SDK** | Dart 3.11.4 / Flutter 3.41.6 | Stable channel | Latest language features: records, pattern matching, class modifiers. |
| **State Management** | `flutter_riverpod` | `^3.3.2` | Compile-time safety, seamless testing overrides, zero global mutable state. |
| **Routing** | `go_router` | `^17.5.0` | Deep linking, declarative web URL management, `StatefulShellRoute` tab persistence. |
| **Local Persistence** | `shared_preferences` | `^2.5.4` | Clean cross-platform key-value JSON serialization across Web, macOS, and iOS without native C++ compilation overhead. |
| **CSV Processing** | `csv` | `^6.0.0` | High-performance RFC 4180 compliant CSV stream parsing and row sanitization. |
| **Charting Engine** | `fl_chart` | `^1.1.1` | Highly customizable hardware-accelerated animated Pie Charts and Line/Spline charts. |
| **Localization & Formatting** | `intl` | `^0.20.2` | Currency formatting, percentage precision, and date formatting. |
| **File Selection** | `file_picker` | `^10.3.1` | Native file picker on macOS desktop, Web browser file upload, and iOS document picker. |
| **Testing** | `flutter_test`, `flutter_riverpod` | SDK | Component widget testing, Riverpod provider testing, and container verification. |

---

## 4. Routing Architecture

- **Central Host Router**: Resides in `apps/gen_stock_folio/lib/core/router/app_router.dart`.
- **Tab State Preservation**: Implements `StatefulShellRoute.indexedStack` with 3 separate navigation branches:
  - Branch 0 (`/import`): Ingestion, mock generator, and CSV upload.
  - Branch 1 (`/allocation`): Allocation pie chart and holdings table.
  - Branch 2 (`/analytics`): Lifetime performance, equity curve, and risk metrics.
- **Package Route Decoupling**: Each package in `packages/` exports its branch configuration in `router.config.dart`.
- **Adaptive Shell Scaffold**: On Mobile (`width < 600dp`), renders a bottom `NavigationBar`. On Desktop/Web (`width >= 600dp`), renders an adaptive side `NavigationRail` or header navigation.

---

## 5. Brokerage Integration Architecture Bridge

To satisfy the requirement of supporting mock/CSV data today while preparing for Robinhood account linking in Phase 2, the data layer enforces the **Abstract Repository Pattern**:

```dart
// packages/portfolio_feature/lib/domain/repositories/brokerage_repository.dart
abstract class IBrokerageRepository {
  Future<List<HoldingPosition>> fetchHoldings();
  Future<PortfolioSummary> fetchPortfolioSummary();
  Future<void> saveCustomPositions(List<HoldingPosition> positions);
  Future<bool> connectBrokerageAccount({required String authToken});
  bool get isConnectedToLiveBrokerage;
}
```

- **Active Provider**: Defaults to `MockBrokerageRepository` which integrates local mock generation and CSV import via `SharedPreferences`.
- **Phase 2 Extensibility**: `RobinhoodBrokerageAdapter` implements `IBrokerageRepository`, encapsulating secure OAuth token exchange and portfolio REST endpoints without requiring refactoring of UI or ViewModels.

---

## 6. State Management & Lifecycle Guidelines

1. **No Global Mutables**: All state resides within Riverpod Notifiers managed by `ProviderScope`.
2. **State Immutability**: All State classes are immutable data objects with explicit `copyWith` copy constructors.
3. **Async Error Boundaries**: All async operations (file reading, parsing, persistence) produce explicit typed States: `AsyncLoading`, `AsyncData`, or `AsyncError`.
4. **Reactive Decoupling**: Tab 2 and Tab 3 reactively watch the core portfolio provider (`portfolioProvider`); any CSV import or position change in Tab 1 immediately triggers recalculated allocation weights and performance curves in Tabs 2 and 3 without manual refresh callbacks.

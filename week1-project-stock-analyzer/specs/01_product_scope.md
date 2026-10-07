# 01 - Product Concept & Scope Specification: GenStockFolio

## 1. Overview & Vision
- **App Name**: GenStockFolio
- **Tagline**: Intelligent multi-platform portfolio analyzer delivering instant allocation insights, CSV imports, and lifetime performance tracking.
- **Target Audience & Personas**:
  - **Primary User**: Individual equity investors, retail traders, and portfolio managers who need a fast, privacy-focused, cross-platform dashboard across macOS Desktop, Web, and iOS to track asset allocations, cost basis, and lifetime returns.
  - **Secondary User**: Casual retail investors seeking simple one-click fake portfolio loading and CSV import without upfront brokerage API credential friction.
- **Core Value Proposition**: GenStockFolio eliminates manual spreadsheet tracking by combining automated mock data generation, flexible CSV portfolio imports, rich visual allocation analytics (interactive pie charts), detailed position-by-position gain/loss attribution, and lifetime return analytics into a unified, responsive Flutter app running seamlessly across iOS, macOS, and the Web.

---

## 2. Platform Matrix
Define target platforms and prioritize the initial release targets:

| Platform | Tier | Priority | Notes |
|---|---|---|---|
| **macOS Desktop** | Tier 1 | High | Native Apple Silicon + Intel desktop build, optimized for widescreen charts, multi-column tables, keyboard shortcuts, and file drag-and-drop CSV import. |
| **Web** | Tier 1 | High | CanvasKit/Wasm responsive web app running in Chrome, Safari, and Edge with browser file picker for CSV ingestion and zero-install accessibility. |
| **iOS Mobile** | Tier 1 | High | Native iOS 16+ experience with touch-optimized cards, bottom navigation bar, and responsive layout for iPhone and iPad. |
| **Android** | Tier 2 | Low | Secondary target; standard Flutter responsive codebase supports future compilation once cmdline-tools are enabled. |
| **Windows / Linux** | Out of Scope | Low | Deferred; cross-platform architecture enables future compilation if required. |

- **Primary Form Factor**: Responsive-Universal (adaptive navigation transitions from Mobile BottomNavigationBar `<600dp` to Desktop/Web NavigationRail and multi-pane dashboard `≥840dp`).

---

## 3. MVP Scope Guardrails

### 3-Tab Core Architecture

#### Tab 1: Portfolio Ingestion & Data Management (Import & Manage)
1. **Mock Portfolio Generator**: One-click generation of realistic diversified tech/dividend portfolios with customizable initial capital for immediate instant testing.
2. **CSV File Import & Ingestion**: Robust parser for CSV portfolio files supporting ticker symbol, share quantity, purchase date, and average purchase price / cost basis.
3. **Manual Position Editor**: Ability to manually add, edit, or remove stock positions with input validation.
4. **Multi-Brokerage Architecture Bridge**: Production-ready [Plaid Investments API](https://plaid.com/docs/investments/) integration supporting 12,000+ financial institutions (Robinhood, Fidelity, Schwab, Vanguard, etc.) with Sandbox and Live credential modes, zero-disk credential security, holdings synchronization, and investment transaction history.
5. **Live Market Price Streaming Engine**: Real-time ticker and batch price integration via Yahoo Finance (`YahooFinancePriceService`), supplementing local mock pricing with live market updates and streaming toggles.

#### Tab 2: Asset Allocation & Holdings Breakdown (Allocation & Positions)
1. **Interactive Allocation Pie Chart**: Sector and equity weight visualizer displaying percentage share of total portfolio value with animated slice selection.
2. **Comprehensive Holdings Table / Card View**:
   - Ticker Symbol & Company Name
   - Current Share Quantity
   - Average Cost Basis (per share & total invested)
   - Current Market Price (live simulated or live market quotes)
   - Total Position Market Value
   - Unrealized Profit & Loss (dollar gain/loss and percentage return)
3. **Sorting & Filtering**: Instant sorting by position size, percentage gain, ticker, and asset weight.

#### Tab 3: Historical Performance & Lifetime Analytics (Performance & Returns)
1. **Portfolio Lifetime Summary Metrics**:
   - Total Lifetime Investment (cumulative cost basis / capital deployed)
   - Lifetime Proceeds / Current Portfolio Valuation
   - Net Profit & Cumulative Return ($ and %)
2. **Historical Equity Curve**: Visual trajectory chart comparing portfolio growth over time against market benchmarks.
3. **Core Risk & Performance Indicators**: Portfolio Beta (market sensitivity), diversification health score, and risk-adjusted return indicator.

---

### In-Scope (Must Have for Initial Release)
1. **Three-Tab Primary Architecture**: Tab 1 (Data Ingestion / Mock / CSV / Plaid), Tab 2 (Allocation Pie Chart & Holdings Breakdown), Tab 3 (Lifetime Performance & Returns).
2. **Local Persistence Engine**: Offline-first storage saving user holdings, imported CSVs, and portfolio configurations locally across app restarts.
3. **Live & Pluggable Market Engine**: Hybrid engine providing realistic baseline pricing, micro-volatility, and live real-time price streaming via Yahoo Finance.
4. **Universal Responsive Layout**: Adaptive layout dynamically adjusting between Mobile (<600dp), Tablet (600–840dp), and Desktop/Web (≥840dp).
5. **CSV Import Parser**: Validated ingestion of standard CSV formats (Schwab, Fidelity, Vanguard, generic) with flexible header aliases and error handling for malformed rows.
6. **Plaid Multi-Brokerage Integration**: Complete 5-step Plaid Investments API workflow (`/link/token/create`, `/sandbox/public_token/create`, `/item/public_token/exchange`, `/investments/holdings/get`, `/investments/transactions/get`), supporting Sandbox testing and live bank links.

---

### Out-of-Scope (Deferred to v2 / Post-MVP)
- **Automated Trade Execution**: Rationale: GenStockFolio is strictly an analytical viewer and planner in MVP, not a broker-dealer executing orders.
- **Options, Futures, & Derivative Tracking**: Rationale: Scope guardrail to maintain focus on common stocks and ETFs.
- **Multi-Currency FX Hedging**: Rationale: Base currency fixed to USD for MVP simplicity.
- **Multi-User Cloud Sync with Relational Database**: Rationale: Prioritizing local-first privacy, zero server dependency, and client-side security.

---

## 4. Key Constraints & Non-Functional Requirements
- **Offline Capability**: Full offline-first capability. All charts, metrics, and imported holdings function seamlessly without an active internet connection.
- **Authentication**: Zero-login local-first access for MVP. User begins analyzing portfolios immediately without mandatory account registration.
- **Performance Budget**:
  - Target frame rate: Smooth 60fps animations (120fps ProMotion on supported Apple hardware) for chart rendering and table scrolling.
  - Cold startup time: Under 1.5 seconds to interactive dashboard.
  - CSV parsing speed: Less than 200ms for portfolios up to 500 positions.
- **Localization Requirement**: English (`en`) for MVP with structured `l10n.yaml` and `.arb` files to support future internationalization.
- **Accessibility (a11y)**: WCAG 2.1 AA compliant color contrast ratios (≥4.5:1 for text, distinct chart color palettes with text value labels), full keyboard navigation for macOS/Web, and Flutter `Semantics` tags on all interactive cards and chart elements.

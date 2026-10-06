# 02 - User Journeys & Functional Specifications: GenStockFolio

## 1. Primary User Journeys
The following end-to-end user journeys illustrate how equity investors achieve their core analytical goals across macOS Desktop, Web, and iOS.

### Journey 1: First-Time Onboarding & Portfolio Initialization (Tab 1)
1. User launches **GenStockFolio** for the first time.
2. The system detects an empty portfolio and displays the **Welcome Onboarding Card** in Tab 1 (Data Ingestion & Management).
3. The user is presented with three clear action pathways:
   - **Load Demo Portfolio**: Instant diversified 6-stock portfolio (e.g. AAPL, MSFT, GOOGL, AMZN, NVDA, TSLA) to immediately explore capabilities.
   - **Upload CSV File**: Drag-and-drop or file picker ingestion of existing holdings.
   - **Add Position Manually**: Step-by-step modal to enter custom positions.
4. User clicks "Load Demo Portfolio".
5. The portfolio is instantly populated with calculated metrics, cached locally, and auto-navigates to Tab 2 (Allocation & Breakdown).

### Journey 2: CSV Portfolio Ingestion & Validation Preview (Tab 1)
1. User navigates to Tab 1 and selects "Upload CSV File" (or drags a `.csv` file onto the upload dropzone on macOS/Web).
2. The system reads and parses the CSV headers flexibly matching aliases (e.g., `Ticker` / `Symbol`, `Shares` / `Quantity`, `CostBasis` / `Price`, `Date`).
3. The system opens the **CSV Validation Preview Modal** displaying:
   - Summary count of detected valid rows and invalid rows.
   - Data table previewing parsed ticker, quantity, cost basis, and calculated position cost.
   - Clear inline flags on any row with formatting issues (e.g., non-numeric quantity, missing symbol).
4. User reviews the preview and clicks "Confirm Import".
5. The system saves the positions into local storage, reconciles duplicate tickers by calculating the weighted average cost basis, and emits a toast notification confirming successful import.

### Journey 3: Asset Allocation & Interactive Two-Way Holdings Exploration (Tab 2)
1. User navigates to Tab 2 (Asset Allocation & Holdings Breakdown).
2. The user views the dynamic **Asset Allocation Pie Chart** displaying percentage weights by sector and stock, alongside the comprehensive Holdings Table/Card list.
3. User taps/clicks on a specific slice of the pie chart (e.g., "Technology" or "AAPL").
4. The system animates the selected slice outward, updates the central label with the exact allocation percentage and dollar value, and filters the holdings list below to highlight the selected asset.
5. User taps on a holding row in the table.
6. The system presents the **Position Detail Sheet** displaying ticker symbol, company name, current shares, average cost basis, live simulated price, total market value, unrealized dollar P&L, percentage return, and a mini 30-day simulated price trendline.
7. User can toggle sorting on the holdings table by Position Size, Gain/Loss ($), Return (%), or Ticker Symbol.

### Journey 4: Lifetime Performance Tracking & Risk Analytics (Tab 3)
1. User navigates to Tab 3 (Historical Performance & Returns).
2. The user reviews the **Executive Performance Summary Cards**:
   - Total Lifetime Investment (cumulative capital deployed / total cost basis)
   - Current Portfolio Valuation (total current market value)
   - Lifetime Proceeds & Net P&L (total dollar return)
   - Cumulative Portfolio Return (%)
3. The user interacts with the **Historical Equity Curve Chart**, toggling time-filter chips: `1M`, `6M`, `1Y`, and `ALL`.
4. The equity curve smoothly animates to reflect the historical portfolio growth trajectory over the selected period.
5. The user reviews the **Risk & Health Indicators**:
   - **Portfolio Beta**: Volatility sensitivity relative to the S&P 500 benchmark.
   - **Sharpe Ratio**: Risk-adjusted excess return metric.
   - **Diversification Score**: Concentration health rating (0 to 100) based on sector entropy and position weighting.

---

## 2. Feature Specifications with Gherkin Acceptance Criteria

### Feature 1: Portfolio Data Ingestion & CSV Import
- **Package Module**: `packages/portfolio_feature`
- **User Story**:
  - *As an* investor
  - *I want to* load a sample portfolio, upload a CSV file, or add manual holdings
  - *So that* I can instantly inspect my investment positions without manual spreadsheet math.

#### Scenario 1.1: Instant Demo Portfolio Generation
```gherkin
Given the user has zero existing portfolio holdings in local storage
When the user taps the "Load Demo Portfolio" button on the onboarding card
Then the system should generate a diversified 6-asset portfolio in memory
And the system should persist the demo positions to local storage
And the system should navigate the user to Tab 2 with updated total valuation
```

#### Scenario 1.2: Valid CSV Ingestion with Flexible Header Aliases
```gherkin
Given the user selects a CSV file containing columns "Symbol,Quantity,Price,Date"
When the system parses the CSV content
Then the flexible column mapper should normalize "Symbol" to ticker, "Quantity" to shares, and "Price" to cost basis
And the CSV Validation Preview Modal should display all rows with status "Valid"
When the user taps "Confirm Import"
Then the holdings should be merged into local persistence
And a success snackbar should display "Successfully imported N positions"
```

#### Scenario 1.3: Handling Malformed CSV Rows with Selective Ingestion
```gherkin
Given the user uploads a CSV file where row 3 has an empty ticker and row 5 has a negative share quantity
When the CSV parser processes the file
Then the validation preview modal should flag row 3 and row 5 as "Invalid" with specific error reasons
And the modal should show a badge "Valid Rows: N | Issues: 2"
When the user taps "Import Valid Rows Only"
Then the system should import only the valid rows into the portfolio
And the system should ignore the malformed rows without crashing
```

#### Scenario 1.4: Manual Position Addition with Validation
```gherkin
Given the user opens the "Add Position Manually" dialog
When the user inputs ticker "NVDA", shares "15.5", and cost basis "120.00"
And the user taps "Save Position"
Then the system should validate that shares > 0 and cost basis > 0
And the position should be added to the portfolio state
And the dialog should close with an updated portfolio total
```

---

### Feature 2: Asset Allocation & Holdings Breakdown
- **Package Module**: `packages/allocation_feature`
- **User Story**:
  - *As an* active investor
  - *I want to* view an interactive allocation pie chart and a detailed holdings breakdown table
  - *So that* I can monitor portfolio concentration and identify top gaining and losing positions.

#### Scenario 2.1: Allocation Pie Chart Dynamic Computation
```gherkin
Given a portfolio containing AAPL ($4,000) and MSFT ($6,000) with a total value of $10,000
When the user views Tab 2 (Asset Allocation)
Then the pie chart should render two distinct color-coded sectors
And AAPL slice should represent exactly 40.0% of the total circle
And MSFT slice should represent exactly 60.0% of the total circle
And the center badge should display the total portfolio value "$10,000.00"
```

#### Scenario 2.2: Two-Way Cross-Filtering on Slice Selection
```gherkin
Given the allocation pie chart is displayed with 5 stock slices
When the user clicks or taps the "AAPL" slice
Then the "AAPL" slice should animate with an exploded radial offset
And the holdings table below should filter to highlight the AAPL position card
When the user taps the selected slice again or a "Clear Filter" button
Then all slices should return to normal radius and the full holdings table should be displayed
```

#### Scenario 2.3: Position Detail Inspection Modal
```gherkin
Given the user is viewing the holdings table in Tab 2
When the user taps on the "GOOGL" position row
Then the system should present the Position Detail Sheet
And the sheet should display current shares, average cost basis, current market price, and total unrealized gain/loss
And positive unrealized gains should be styled with semantic profit green
And negative unrealized losses should be styled with semantic loss red
```

#### Scenario 2.4: Multi-Column Sorting
```gherkin
Given a holdings table with multiple stock positions
When the user selects the "Sort by Gain/Loss %" dropdown option
Then the holdings table should sort positions in descending order of unrealized percentage return
And the order should persist across tab navigation
```

---

### Feature 3: Lifetime Performance & Historical Analytics
- **Package Module**: `packages/analytics_feature`
- **User Story**:
  - *As a* long-term wealth builder
  - *I want to* inspect lifetime capital invested, total proceeds, and risk metrics
  - *So that* I can evaluate whether my investment strategy is outperforming cash and benchmarks.

#### Scenario 3.1: Lifetime Performance Computation
```gherkin
Given a portfolio with total invested capital of $50,000 and current market valuation of $65,000
When the user opens Tab 3 (Historical Performance)
Then the "Total Lifetime Invested" card should show "$50,000.00"
And the "Current Valuation" card should show "$65,000.00"
And the "Lifetime Net Profit" card should display "+$15,000.00" with a positive profit badge
And the "Total Return" card should display "+30.00%"
```

#### Scenario 3.2: Interactive Historical Equity Curve Time-Range Filtering
```gherkin
Given the historical performance curve is displaying 1-Year historical data by default
When the user taps the "6M" time filter chip
Then the chart should re-render within 150ms showing the 6-month equity trajectory
And the starting and ending portfolio value tooltips should correspond to the 6-month boundaries
```

#### Scenario 3.3: Risk & Health Metrics Computation
```gherkin
Given a diversified equity portfolio with calculated returns
When the user views the Risk Analytics section in Tab 3
Then the system should compute and display Portfolio Beta (e.g., 1.12 vs S&P 500)
And the Sharpe Ratio should be displayed with an interpretive rating (e.g. Good, Excellent)
And the Diversification Score should be rendered as a radial progress meter between 0 and 100
```

---

## 3. Edge Cases & Boundary Conditions

| Scenario | Condition | System Behavior |
|---|---|---|
| **Zero Positions / Empty State** | Portfolio contains 0 holdings | Show illustrated empty state in Tab 1, 2, and 3 with prominent "Load Demo Portfolio" and "Upload CSV" action buttons. |
| **Network Loss / Offline Mode** | Device has no internet connection | Seamless offline operation. App uses locally cached positions and market simulator engine with no blocking network dialogs. |
| **Malformed / Corrupted CSV Data** | User uploads non-CSV file, missing columns, or corrupt text | Parser rejects gracefully; validation modal flags bad lines with explanatory reasons; app does not crash. |
| **Fractional Share Quantities** | User holds 0.432 shares of a high-value stock | System supports 4 decimal places of share precision and calculates exact fractional values. |
| **Negative Portfolio Return** | Total valuation is less than cost basis | Summary cards, chart gradients, and percentage indicators switch to semantic loss red with minus sign formatting. |
| **Duplicate Tickers in CSV Import** | CSV has multiple purchase lots for the same ticker | System calculates cumulative shares and weighted average cost basis: `TotalCost / TotalShares`. |
| **Extreme Screen Resizing** | User resizes window from Desktop widescreen (1400dp) to mobile window (400dp) on Web/macOS | Responsive layout seamlessly shifts between multi-column master-detail layout and single-column tab views with no RenderFlex overflow. |

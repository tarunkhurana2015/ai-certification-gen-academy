# 04 - Design System & Responsive Layout Specification: GenStockFolio

## 1. Design Philosophy & Material 3
- Design Language: **Material 3 (M3)** with custom fintech aesthetic tokens.
- **Theme Modes**: **Dark Mode as Default** (engineered for high-contrast financial data visualization, chart readability, and extended battery efficiency on OLED displays), with an immediate toggle in the top app bar for **Light Mode** and **System Mode**.
- High Aesthetic Standard: Sleek dark surfaces, vibrant emerald growth indicators, crisp financial typography with tabular numbers, subtle glassmorphism card elevation, and smooth 60fps/120fps hardware-accelerated transitions.

---

## 2. Color Palette & Brand Tokens

### Theme Tokens
| Token Name | Light Value | Dark Value | Purpose |
|---|---|---|---|
| `colorSchemeSeed` | `#00C805` | `#00C805` | M3 dynamic seed generating balanced palette |
| `primary` | `#008703` | `#00C805` | Primary buttons, active tab indicators, key accents |
| `onPrimary` | `#FFFFFF` | `#003901` | Contrast text on primary elements |
| `surface` | `#FFFFFF` | `#121820` | Card surfaces, modal sheets, container cards |
| `surfaceContainer` | `#F0F2F5` | `#1A222D` | Elevated cards, dialog backgrounds, table headers |
| `background` | `#F8F9FA` | `#0C1017` | Root scaffold canvas background |
| `outline` | `#D1D5DB` | `#2D3748` | Subtle borders, table dividers, card outlines |
| `semanticProfit` | `#008703` | `#00C805` | Positive P&L text, gain chips, upward trendlines |
| `semanticLoss` | `#D70015` | `#FF3B30` | Negative P&L text, loss chips, downward trendlines |

### Sector & Allocation Chart Palette (High-Contrast Categorical Colors)
To ensure distinct readability in both Light and Dark modes without visual ambiguity:
- **Technology**: `#00C805` (Emerald Green)
- **Communication Services**: `#0A84FF` (Electric Blue)
- **Consumer Cyclical**: `#FF9500` (Vibrant Amber)
- **Healthcare**: `#AF52DE` (Purple)
- **Financial Services**: `#FF2D55` (Pink / Magenta)
- **Energy & Industrials**: `#5AC8FA` (Sky Cyan)
- **Cash / Other**: `#8E8E93` (Neutral Slate)

---

## 3. Typography Hierarchy
- **Font Family**: System Platform Font (SF Pro on Apple macOS/iOS, Roboto/system-ui on Web).
- **Tabular Numerics**: All numeric values (prices, percentages, dollar amounts, share quantities) enforce `fontFeatures: [FontFeature.tabularFigures()]` to ensure monospaced numeric column alignment without jitter during live updates.

| Style | Size | Weight | Line Height | Usage |
|---|---|---|---|---|
| `displayLarge` | 44px | Bold | 52px | Hero portfolio valuation ($148,290.45) |
| `headlineMedium` | 26px | SemiBold | 32px | Screen headers (Allocation, Lifetime Performance) |
| `titleLarge` | 20px | SemiBold | 26px | Card titles, section headers, dialog titles |
| `titleMedium` | 16px | Medium | 22px | Holding ticker symbols (e.g. AAPL, NVDA) |
| `bodyLarge` | 16px | Regular | 24px | Primary descriptions, table row values |
| `bodyMedium` | 14px | Regular | 20px | Subtitles, company names, secondary metadata |
| `labelLarge` | 14px | SemiBold | 20px | Primary button labels, action chips |
| `labelSmall` | 11px | Medium | 16px | Percentage change badges (+4.25%), table column headers |

---

## 4. Responsive Breakpoints & Multi-Platform Adaptation

| Form Factor | Breakpoint Window | Navigation Paradigm | Layout Strategy |
|---|---|---|---|
| **Compact (iOS Mobile / Small Window)** | Width < 600dp | Bottom `NavigationBar` | Single-column vertical scroll (`ListView`), full-width cards, bottom sheets for position details. |
| **Medium (Tablet / iPad / Foldable)** | 600dp ≤ Width < 840dp | Collapsible `NavigationRail` | Adaptive two-column grid for summary metric cards, side-by-side chart and summary list. |
| **Expanded (macOS Desktop / Chrome Web)** | Width ≥ 840dp | Extended `NavigationRail` with labels | Master-detail split layout: Left pane for interactive allocation pie chart / equity curve, Right pane for full interactive holdings table. |

### Maximum Content Width Constraint
On expanded desktop/web viewports, content views wrap the primary dashboard inside:
```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1200),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: content,
    ),
  ),
)
```
This guarantees that wide monitors (e.g. 1440p or 4K displays) maintain an optimal, readable layout without stretched card elements.

---

## 5. Micro-Interactions & Transitions
1. **Interactive Pie Chart**: Tapping any slice animates with a 250ms ease-out radial displacement (+12dp) and dynamically updates the central donut label displaying ticker, percentage weight, and market value.
2. **Tab Transitions**: Screen navigation uses smooth cross-fade `PageTransition` preserving tab scroll offsets via `StatefulShellRoute.indexedStack`.
3. **Desktop Hover States**: Holding rows on macOS Desktop and Web subtly highlight with `surfaceContainer` tint and cursor pointer on mouse enter.
4. **Haptic Feedback**: On iOS mobile devices, triggering demo load, CSV import, or tapping pie slices dispatches `HapticFeedback.lightImpact()`.
5. **Accessibility (a11y)**:
   - All color pairings exceed WCAG 2.1 AA 4.5:1 contrast requirements.
   - All interactive icons, chips, and table rows include descriptive `Semantics(label: "...", button: true)` tags for VoiceOver and screen reader compliance.

# Stage 4: Movies — Design System and Responsive Layout

Status: Approved by the developer.
Approval recorded: November 1, 2026 (America/Chicago), from the developer reply “approved”.
Visual direction selected: **A — After Hours**, from the developer reply “A”.
Date: November 1, 2026 (America/Chicago).
Prerequisites: [Stage 1 scope](01_product_scope.md), [Stage 2 acceptance criteria](02_user_journeys_and_features.md), and [Stage 3 architecture](03_architecture_and_monorepo.md), all approved.
Target: iOS Simulator, with portrait, landscape, and the platform's accessibility text settings.

## 1. Decision and scope

After Hours uses charcoal surfaces, restrained violet accents, native iOS typography, generous artwork, and clear labels. Movie artwork provides most of the color. The selected [visual reference](../docs/design/after-hours-reference.png) establishes the direction for Home and movie details; the rules below resolve production layouts and states that the browser prototype only illustrated.

| Decision | Provenance |
| --- | --- |
| After Hours, option A | Explicit developer selection after comparing three browser mockups. |
| Four persistent tabs and deep movie/person navigation | Approved Stages 1–3. |
| Dark default, native typography, responsive and accessible layouts | Proposed in Stage 4 discovery; made concrete here for approval. |
| Exact tokens, dimensions, companion light palette, motion, component states | Engineering defaults proposed by this Stage 4 specification. |

The reference contains illustrative titles and metadata. Production screens obtain movie content from the approved TMDB integration; mockup values are not live data. Browser styling, tiny presentation-scale text, and simulated device chrome are not production requirements. See the [reference notes and artwork provenance](../docs/design/README.md).

This stage specifies presentation. Data contracts, test strategy, and implementation sequencing remain in Stages 5–7. It does not authorize Flutter scaffolding before those gates are approved.

## 2. Theme and color tokens

The application launches in **After Hours dark mode** using Material 3. The host owns the theme definitions; `movies_ui` and features consume semantic tokens as required by Stage 3. The brand seed is violet `#B69AFF`; explicit role values below take precedence over generated seed variations.

Both dark and companion light theme definitions are specified for the required scaffolding. The first release uses dark mode regardless of system appearance; there is no theme selector. The companion palette retains the After Hours brand and does not select the separate Daylight design.

| Token / intended role | After Hours dark | Companion light |
| --- | --- | --- |
| `background` / scaffold | `#111015` | `#F8F7FC` |
| `surface` / cards, navigation, messages | `#1C1A23` | `#FFFFFF` |
| `surfaceHigh` / raised panels | `#25222E` | `#F0ECF8` |
| `textPrimary` / on-surface | `#F8F7FC` | `#1B1823` |
| `textSecondary` / on-surface-variant | `#B8B2C5` | `#5F596B` |
| `primary` / selected state, links, filled action | `#B69AFF` | `#5B36B4` |
| `onPrimary` / filled action text and icons | `#181122` | `#FFFFFF` |
| `primaryContainer` / subtle selected backing | `#2A2338` | `#E9DEFF` |
| `onPrimaryContainer` | `#F8F7FC` | `#281547` |
| `outlineDecorative` / nonessential separators | `#332E40` | `#DED8E7` |
| `outlineStrong` / essential field and control boundary | `#9186A3` | `#7D738F` |
| `focus` / visible accessibility or keyboard focus | `#D6C5FF` | `#5B36B4` |
| `rating` / rating accent | `#EFCD87` | `#745000` |
| `error` / failure text and icon on surface | `#FFB4AB` | `#9F1F2D` |
| `success` / confirmed outcome on surface | `#A6DAB2` | `#216A3A` |
| Artwork text backing / scrim | Opaque dark background beneath text; gradient above | Same dark artwork treatment, with dark-theme text |

Use text plus an icon or semantic state for selection, favorite state, failures, and success. Color alone never conveys the outcome. Decorative separators cannot be the only indication of a field or action. Inactive favorite controls retain a readable explanation such as “Loading favorites”; do not make their state depend on a faint heart alone.

**Contrast targets:** normal text at least 4.5:1; essential control boundaries and focus indicators at least 3:1 against adjacent colors. These adopt [W3C contrast guidance](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) as design targets, without asserting a completed accessibility certification.

Calculated solid-color examples, using sRGB relative luminance:

| Foreground / background | Dark ratio | Light ratio |
| --- | --- | --- |
| Primary text / surface | 16.13:1 | 17.48:1 |
| Secondary text / surface | 8.36:1 | 6.71:1 |
| Primary accent / surface | 7.41:1 | 7.98:1 |
| Filled action text / primary | 7.93:1 | 7.98:1 |
| Error / surface | 10.13:1 | 7.75:1 |
| Rating / surface | 11.26:1 | 7.27:1 |
| Strong outline / surface | 5.03:1 | 4.45:1 |

These calculations cover the listed solid pairs. Artwork, opacity, pressed states, focus, and other compositions require inspection in the implemented app. Put essential text and image-overlay controls on opaque token-colored backing so unpredictable artwork cannot defeat their contrast.

## 3. Typography and content

Use the platform system font provided by Flutter's iOS/Cupertino text theme, applied consistently to Material components. The installed Flutter SDK exposes platform font aliases; derive the family from the SDK theme rather than guessing Apple PostScript names. Do not bundle Apple font files, download fonts at runtime, or add a font dependency.

Sizes are Flutter logical units before the platform text scaler. Line-height values describe the default presentation, not fixed-height containers.

| Style | Size / line height | Weight | Typical use |
| --- | --- | --- | --- |
| Display | 34 / 40 | 700 | Movies wordmark, featured title where space permits |
| Page title | 28 / 34 | 700 | Movie, person, and tab titles |
| Section title | 20 / 26 | 600 | Cast, The story, Trending |
| Card title | 16 / 22 | 600 | Movie and person list items |
| Body | 16 / 24 | 400 | Synopsis, biography, review text, error explanation |
| Supporting | 14 / 20 | 400 | Year, runtime, character, recommendation explanation |
| Action | 14 / 20 | 600 | Explore movie, Retry, Undo, Full cast & credits |
| Caption | 12 / 16 | 400–600 | TMDB badge, vote count, supplementary metadata |
| Tab label | 12 / 16 | 600 selected; 400 otherwise | Home, Browse, Search, Library |

Preserve the platform's text scaling, including nonlinear scaling where provided; do not globally clamp it or use shrink-to-fit to conceal overflow. Essential text wraps and its container grows. Page titles, full synopsis, biography, errors, and actions cannot be lost to fixed-height clipping. Card titles may use two lines at normal size with the full title in semantics and on details; enlarged-text layouts grow or use list rows rather than losing the title.

Use sentence case for actions and sections. Keep letter spacing normal for body text; a small editorial eyebrow is optional and cannot carry essential facts. Format dates and numbers through approved localization facilities. Production ratings identify **TMDB** and the ten-point scale; details include available vote count. A supplied zero with no votes is “Not rated,” not a confident 0/10 review. Missing runtime, biography, or overview uses an honest unavailable label. No invented review, recommendation explanation, cast member, or availability claim fills a gap.

## 4. Spacing, geometry, artwork, and icons

| Primitive | Rule |
| --- | --- |
| Spacing scale | 4, 8, 12, 16, 24, 32, 40, 48 logical units. |
| Card and hero corners | 20; raised panels 16; small chips 8; pills fully rounded. |
| Section separation | 32 normally; 24 within a dense detail group. |
| Minimum interactive target | **48 × 48** logical units, including back, clear, favorite, tab, and carousel controls. Visible icons may be 20–24. |
| Primary action | Minimum height 48; horizontal padding 20; grows for wrapping text. |
| Divider | One logical unit, decorative token; stronger outline where a boundary is essential. |
| Elevation | Rely primarily on surface contrast and spacing. No heavy glow, glass blur, or permanent shimmer. |
| Poster | 2:3 crop, no stretching; stable placeholder of the same aspect ratio. |
| Backdrop | 16:9 source presentation or intentional hero crop; do not stretch to fill arbitrary space. |
| Cast portrait | 1:1 circle or rounded crop, name and character in separate text below. |
| Gallery | Preserve full image aspect ratio when opened; thumbnails may crop. |

Use one consistent built-in icon family: home, browse grid, search, library/bookmark, chevron, back, heart, information, retry, and external link. Selected tabs combine an indicator, icon treatment, text weight, and semantic selection. Favorite buttons use outlined/filled hearts plus accessible action labels. A poster's open action and favorite action are separate hit targets and separate accessible actions.

Network image loading and failure preserve layout, title, metadata, and navigation. The fallback uses a neutral movie/person icon with an appropriate label. Repeated decorative artwork does not repeat the same spoken title. No movie poster or portrait is a required bundled production asset; provider image sizing and URL rules belong to Stage 5.

## 5. Responsive rules

`W` is the usable content viewport after device safe-area insets and the maximum-width constraint. All dimensions below are logical units. The bands adapt the selected iOS app to phone orientation and available space; they do not add an iPad, desktop, web, or Android delivery target.

| Band | Available width | Horizontal page padding | Layout |
| --- | --- | --- | --- |
| Compact | Below 600 | 16 below 360; otherwise 24 | Single-column details; horizontal hero and shelves; adaptive movie grid. |
| Medium | 600–839 | 32 | Wider grid; optional side-by-side artwork and introduction when usable space allows. |
| Expanded | 840 and above | 40 | Same navigation; content centered with maximum width 1120. Wider introduction and more grid columns. |

The **bottom tab bar remains present in every band** in this release. Do not switch to a rail or drawer in landscape. Respect notch, home-indicator, keyboard, and landscape side insets. Bottom navigation has a minimum content height of 64 plus the safe-area inset; it grows when scaled labels require more space. Labels remain visible and may wrap. Do not force a fixed 64-unit height at accessibility sizes.

- **Hero carousel:** user controlled, with leading page padding, 12-unit gaps, and snapping aligned to the card's leading edge. Card width is the smaller of 560 and `W − page padding − 32`, leaving at least 20 units of the next card visible when it exists. Never auto-advance. Provide accessible previous/next actions and announce position. Minimum hero height is 400 in ordinary portrait; its content can grow. The movie title wraps, followed by TMDB rating context, a short synopsis excerpt, and Explore movie.
- **Poster shelves:** normal poster width 120 in Compact and 144 in wider bands, with 12-unit gaps. Card height follows artwork plus wrapped text. Larger text may widen cards or switch a shelf to a horizontal sequence of full-title list cards; navigation and section identity stay the same.
- **Browse and results grids:** normal minimum card width 136 with 12-unit gaps; compute columns from available width rather than device name. Reduce to one-column rows if scaled titles or controls need the space. Never squeeze a target below 48 or show a horizontal overflow error.
- **Short landscape:** below 500 usable height, reduce decorative header space; use artwork beside introduction at width 600 or above. All body sections remain in vertical scrolling content. Do not let hero minimum height prevent access to sections, tabs, or Back. With accessibility text, prefer a single readable column over the two-column introduction.
- **Large text:** reflow metadata and action groups to multiple rows. Section-heading actions move below the heading if needed. Text is never overlaid across an unpredictable image region to save height. The page can scroll to every control while tabs remain reachable.
- **Keyboard:** Search results resize above it; tabs remain reachable. Status/Undo content sits above the tabs and keyboard-obstructed region, with wrapping and scrolling as needed rather than obscured actions.

The reference's 393-unit portrait frame is an example, not a fixed canvas. Final layout checks will include a small phone, the detected larger phone simulators, landscape, and enlarged accessibility text, as refined in Stage 6.

## 6. Screen composition and navigation

### 6.1 Shared shell

Keep tabs in this order: **Home · Browse · Search · Library**. Home is the initial selection. Each branch retains its screen, loaded content, query/category, and useful scroll position. Deep catalog screens remain inside the originating tab. Back and the native back gesture follow the actual traversal, including a second visit to an earlier movie; they do not jump to the tab root. Selecting another tab exposes that branch's retained view.

Use a visible title, native back affordance on pushed screens, appropriate system-status-bar contrast, and a safe-area-aware bottom bar. On artwork headers, Back and Favorite have solid dark backing. Keep the current title and Back reachable after the hero scrolls away. Home's information action opens About/Credits within its branch, leaving tabs available.

### 6.2 Home

Top header: Movies wordmark and About/Credits information action. Follow it with the horizontal featured carousel, then shelves in this order: **Recommended for you, Trending, Now Playing, Top Rated, Upcoming**. Each shelf has a clear heading and an actionable See all only when its destination is implemented. Featured tiles show the movie title, available TMDB rating, description excerpt, and Explore movie. The card opens that movie; do not use Watch now or an in-app playback affordance.

Recommendations explain the real basis: general discovery initially, or “Because you liked [movie]” when seeded from a favorite. A failed seeded request can retain earlier content only with the earlier basis visible. Section failures stay within their section when others succeed.

### 6.3 Browse, Search, and Library

| Screen | Composition and behavior |
| --- | --- |
| Browse | Title, selectable Now Playing / Upcoming / Popular / Top Rated categories, movie grid, continuation footer. Start with Now Playing. Categories wrap or scroll accessibly without hiding their selected state. |
| Search | Title, persistent labeled search field, clear action, then untouched prompt / loading / results / empty / error state. Search after **350 ms** without a new edit; keyboard Search is immediate and does not duplicate the pending request. Clearing returns to the untouched state. |
| Library | Title and locally saved movie list, newest additions first. Each entry opens details and has an explicit Remove action. A successful empty read shows how to add favorites. A storage failure shows Retry. Do not show sign-in, cloud synchronization, or a failed read as an empty Library. |

All movie cards expose the shared favorite state. Until the initial favorites read succeeds, mutation controls are unavailable with a loading or retry explanation while the catalog remains usable. Pending writes may show an unobtrusive progress state; do not announce a durable “Saved” before storage acknowledges it.

If Search for a new query fails while older results remain, show **“Showing results for ‘old query’”** with those results and a distinct **“Couldn’t search for ‘new query’ — Retry”** message. Preserve equivalent requested/displayed identity for Browse categories, detail entities, and recommendation seeds. A new heading must not relabel stale content as its own success.

### 6.4 Catalog and deeper screens

Movie details present: backdrop/title, favorite action, year/runtime/genres, TMDB score and vote context, full synopsis, external trailer link when available, cast preview with Full cast & credits, related movies, and available collection, images, and reviews. Long sections can lead to their own screens rather than creating an unreadable wall of text. Their exact data availability follows Stage 5.

| Destination | Presentation and next action |
| --- | --- |
| Full cast & credits | Movie title context, ordered people with portrait/name/character or job; person opens their profile. |
| Person | Name and image, biography and available career information, Filmography action, available images. |
| Filmography | Person context, movie credits with year/role, supplied ordering explained; each movie opens its own details. |
| Collection | Collection name/overview and supplied members; each opens details. |
| Related movies | Source movie identified above the grid; each opens details. |
| Images and reviews | Clear parent title, accessible gallery or review list; long review text readable on a dedicated view. |
| Trailer | Clearly labeled external destination; open through the approved launcher. Failure stays recoverable with Back and tabs available. |

The demonstration path is **Movie → Full cast → Person → Filmography → Another movie → Collection or Related movies**: five additional steps after entering the first movie. These are genuine route pushes with ordinary screen titles, not artificial “Level 1/2” labels. Missing optional content has a truthful message or an omitted unavailable action; do not invent a collection or create a dead control to fill the path.

### 6.5 About/Credits

Present Movies, the approved TMDB source acknowledgement, approved TMDB logo, exact required notice from Stage 1, and accessible source links. Place it below primary product actions. Do not imply TMDB endorsement. The selected reference is design-only artwork and is not a license grant for another use.

## 7. Reusable states and feedback

| State | Presentation and available action |
| --- | --- |
| First content load | Stable poster/text placeholders or a labeled progress indicator. Navigation stays usable. Disable decorative shimmer for reduced motion. |
| Initial content failure | Plain-language explanation, Retry for the same request, and usable Back/tabs. No empty-result illustration masquerading as failure. |
| Refresh or new-request failure with retained content | Keep usable content and its source identity; show an inline failure and Retry for the attempted request. Do not replace the page with a blocking dialog. |
| Supplementary section failure | Section-scoped explanation and Retry; retain main movie/person details and other successful sections. |
| Continuation loading/failure | Footer loading or Retry beneath existing items. Retain loaded items and cursor; completed lists have no misleading loading spinner. |
| Genuine empty result | Specific copy: no matches for query, no related titles, no biography supplied, or empty Library only after successful read. |
| Artwork failure | Stable placeholder; title, favorite control, and opening action still work. |
| Favorites read failure | Library storage explanation and Retry; unavailable mutation controls elsewhere; no assumed empty baseline. |
| Favorite write failure | Restore the affected item's correct state under Stage 3's revision rules; show a named, actionable inline error on its visible screen or Library. Other favorites remain intact. |

**Removal and Undo:** remove the movie immediately and show a global message naming it, with Undo for **five seconds while the app is active**. Place this surface above the tab bar and any keyboard obstruction. It can grow for large text; keep its action reachable. Tab changes do not dismiss it or reset its timer. A new removal replaces the previous offer. Backgrounding or termination ends the offer immediately; returning does not revive it. Undo must not reverse newer user intent. A pending or failed database write follows the approved acknowledgement and rollback rules.

Use the transient region for the current Undo offer. Write failures also appear in a persistent inline error region for the affected resource; they cannot silently replace Undo or vanish when the next removal arrives. Announce these outcomes without stealing navigation focus. The fixed Undo timing is inherited from Stage 2; a broader timing-accessibility claim is not made by this design spec.

User-facing messages describe the problem and next action. Do not display stack traces, request headers, API credentials, route implementation names, or internal state-machine details.

## 8. Motion and accessibility

Use restrained transitions: pressed feedback about 100 ms, content fade about 160 ms, carousel settle about 220 ms, and route transition about 250 ms. Native back-gesture interaction takes precedence over a fixed animation duration. Do not auto-play trailers, auto-advance carousels, or animate decorative backgrounds. Respect the platform's reduced-motion setting by removing decorative movement and using an immediate change or short fade. These presentation durations do not change the 350 ms search debounce or five-second Undo policy.

Accessibility requirements follow [Flutter's accessibility guidance](https://docs.flutter.dev/ui/accessibility), with implementation checks deferred to Stage 6:

- VoiceOver can identify screen titles/headings, selected tab/category, movie/person name, button action, favorite state, rating source/scale, loading, and errors. Do not convey state with color alone.
- Focus order follows the visual reading order. Returning with Back restores a useful focus target where possible. Announcements for search completion, removal, and failure do not move focus away from the current interaction.
- Retained offstage tab branches contribute no duplicate actionable semantics. A card and its Favorite/Remove action remain independently discoverable; do not merge away the secondary action.
- A search field has a persistent accessible label, a labeled clear action, and an appropriate keyboard Search action. Search completion does not dismiss the keyboard or navigate automatically.
- All actions meet the 48-unit target rule, including text links, tab destinations, Undo, Retry, and information. Target padding cannot intercept neighboring actions.
- Respect large text, display scaling, reduced motion, safe areas, and readable contrast. Metadata, errors, Back, Favorite, Remove, Undo, and tabs remain reachable without font downscaling.
- Galleries describe useful image identity and position; decorative duplicate art is excluded. External links announce that they open outside Movies.

Stable automation identifiers complement native semantics: include the screen/section, action, and entity ID where relevant. The same title can appear in several shelves, so section context distinguishes controls. Public identifiers must not depend only on translated labels, list indexes, random IDs, or current visual color. Internal page-entry keys still distinguish repeated navigation instances as required by Stage 3; they are separate from public action identifiers. Exact identifier inventory belongs to the later testing specification.

## 9. Stage 4 review and implementation handoff

Approval of this stage accepts After Hours dark as the launch theme, the companion palette, native typography, dimension tokens, persistent-bottom-tab responsive rules, and the presentation states above. It does not alter the approved scope, persistence behavior, navigation lifetime, search timing, or Undo timing.

Before implementation is called complete, the later plan must verify real Flutter rendering in portrait and landscape, large-text reflow, image-overlay contrast, safe-area/keyboard placement, VoiceOver focus, independent card/favorite actions, and the five-step navigation path. The browser reference and calculated contrast pairs are design evidence; they are not a Flutter build, a simulator run, a storage test, or a completed accessibility audit.

**Approval record:** the developer reviewed this document and replied “approved” on November 1, 2026. Stage 5 discovery is unlocked. Stages 5–7 and application scaffolding remain pending.

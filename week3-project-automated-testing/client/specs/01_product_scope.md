# Stage 1: Movies — Product Concept and Scope

Status: Approved by the developer.
Approval recorded: October 31, 2026 (America/Chicago), from the developer reply “approved”.
Date: October 31, 2026 (America/Chicago).
Release: First client release, targeting iOS Simulator only.

## 1. Product concept

Movies is a modern Flutter movie-discovery app with four tabs: Home, Browse, Search, and Library. Users explore a real movie catalog through artwork, ratings, rich movie details, cast, biographies, filmographies, and related titles. Favorites are saved locally without sign-in.

The client also serves as a realistic application for a later agentic testing system. It must support meaningful navigation depth, persistent user state, and observable UI outcomes. The current delivery is the movie-browsing client; the testing agent is a subsequent project phase.

## 2. Confirmed requirements and decision provenance

| Decision | Source | Scope consequence |
| --- | --- | --- |
| Product name is Movies | Original client request | Use Movies as the user-facing application name. |
| Four tabs: Home, Browse, Search, Library | Original client request | All four tabs are required in the first release. |
| Large horizontally scrollable Home carousel with title, rating, and description | Original client request | Featured content is a primary Home experience. |
| Recommended for you, Trending, and additional discovery sections | Original client request | Include multiple distinct movie-discovery shelves. |
| Real third-party movie API | Original client request | Production catalog screens must integrate live provider data. |
| Rich movie details and at least five further navigation levels | Original client request | Include cast, people, filmographies, and connected movies as separate destinations. |
| Initial platform: iOS Simulator only | Developer discovery response | Desktop, Web, Android, and physical-iPhone delivery are deferred. |
| Local favorites, no sign-in | Developer discovery response | Library persists on the installation and does not require an account or server. |
| Movie → Cast → Person → Filmography → Another Movie → Collection or Related Movies | Developer discovery response | This relationship traversal is the agreed navigation scope. |
| Biography, credits, images, reviews, and trailer links where available | Developer accepted the proposed discovery scope | Display available provider content and handle missing fields honestly. |

The developer approved this scope after reviewing the Stage 1 document. The recommendations included below are accepted within this scope; implementation details reserved for later stages remain undecided.

## 3. Users and product value

### Primary user: movie browser

A person who wants to discover something interesting, investigate its story and cast, follow connections to other titles, and save favorites for later. They should reach useful information without registration or learning a complicated interface.

### Secondary user: developer or QA practitioner

A person who needs a realistic client with multi-step journeys, scrollable collections, tab changes, search, saved state, and recoverable errors. Future automated tests should be able to observe actual product outcomes through the app's UI.

## 4. Platform scope and verified environment

| Target | First-release priority | Scope |
| --- | --- | --- |
| iOS Simulator on the development Mac | Required | Build, launch, and validate the first client release here. |
| Physical iPhone / iPad | Deferred | No signing, provisioning, installation, or hardware-specific acceptance commitment in this release. |
| Android | Deferred | Missing Android command-line tools and unknown license status do not block the selected iOS-only release. |
| macOS desktop and Web | Deferred | Toolchains are available but these are not current delivery targets. |

Stage 0 verified Flutter 3.41.6, Dart 3.11.4, Xcode 27.0, CocoaPods 1.16.2, and available iOS 27.0 simulators. Simulator builds use the development/debug configuration. A successful Movies build and launch must be demonstrated after implementation; toolchain verification alone does not establish application compatibility.

See [environment verification](../../docs/environment-verification.md). Dependency and SDK compatibility choices belong to Stage 3 and must use the observed SDK rather than assume that the skill's example dependency versions will resolve.

## 5. First-release feature pillars

### 5.1 Home: cinematic discovery

- A prominent carousel of large, horizontally scrollable artwork tiles, each showing the movie title, provider rating, and a readable description.
- Recommended for you and Trending sections, plus additional shelves for discovery. The approved additional shelves are Now Playing, Top Rated, and Upcoming.
- Movie cards open movie details; collection-level actions can open a larger listing for the selected shelf.
- A polished visual hierarchy, readable artwork overlays, consistent interaction states, and clear loading, error, and empty states.
- The exact design tokens, typography, motion, and theme choices will be specified at Stage 4.

Approved recommendation behavior: before any favorites exist, show an explicitly described general discovery selection. After favorites exist, use provider movie recommendations seeded from locally favorited titles and explain the relationship with wording such as “Because you liked …”. Do not claim account-based or AI personalization that has not been implemented.

### 5.2 Browse: explore the catalog

- Browse new and released movies with clear category labels.
- Approved initial categories: Now Playing, Upcoming, Popular, and Top Rated; Upcoming must remain visibly distinct from released movies.
- Expand available results through pagination rather than imply that one screen contains the entire provider catalog.
- Open any displayed movie into the same rich movie-details experience.
- Region and release-window rules will be made explicit in Stage 5 so “new” does not ambiguously mix theatrical, digital, and future releases.

### 5.3 Search: find a movie

- Search the live catalog using a movie title or title fragment.
- Display recognizable results with title, artwork, rating, and release information where supplied.
- Support clearing the query, loading more results, opening a result, and returning to the query/results state.
- Distinguish an untouched search screen, no matches, loading, and failed requests.

### 5.4 Library: local favorites

- Add or remove a movie from favorites from relevant movie surfaces.
- Keep favorite state consistent when the same movie is reached through different navigation paths or tabs.
- Persist favorites across app restarts on the same simulator installation, unless app data is explicitly cleared or the app is uninstalled.
- Display favorites in Library, with a useful empty state and direct navigation into movie details.
- No login, TMDB user account, backend account, or cross-device synchronization is required.

### 5.5 Movie, cast, and person exploration

Movie details present available artwork, synopsis, rating and vote context, release information, runtime, genres, credits, cast, images, reviews, trailer links, related titles, and collection membership. Ratings must identify their provider and scale; they must not be labeled as IMDb ratings when sourced from TMDB.

Cast entries lead to person details with biography, supplied profile images and public career information. A separate filmography destination lists the person's movie credits and lets the user open another movie. Collection and related-movie destinations continue exploration when those relationships exist.

Movie streaming, ticket purchasing, and an embedded trailer player are not part of this release. Trailer links may open an external destination through the supported simulator flow.

## 6. Required navigation depth

The agreed route family provides five additional navigation steps after the first movie-detail screen:

| Depth relative to initial movie details | Destination | User action |
| --- | --- | --- |
| 0 | Initial movie details | Open a movie from any tab or listing. |
| 1 | Full cast and credits | Open the movie's cast section. |
| 2 | Person details | Select a cast member. |
| 3 | Person filmography | Open that person's movie credits. |
| 4 | Another movie's details | Select another credited movie. |
| 5 | Collection or related-movie listing | Follow an available collection or related-title relationship. |
| Further exploration | A listed movie and its connected content | Continue through real provider relationships. |

Back navigation must preserve the visited path and useful preceding state. Switching tabs should preserve each tab's current browsing context. The same entity must remain usable when reached by multiple paths; a visited-movie cycle must not corrupt favorite state or back navigation.

Provider content is not guaranteed to contain every relationship. Empty filmographies, unavailable biographies, missing reviews, absent trailers, and null collection membership must produce honest UI states. The acceptance journey must use a suitable data-backed example rather than fabricate relationships or assume every movie has a collection. Detailed user journeys and Gherkin acceptance criteria belong to Stage 2.

## 7. Third-party data strategy

TMDB is the approved provider because its documented API supports discovery, search, movie details, credits, people, person movie credits, recommendations, similar titles, and collections. The provider choice was proposed within the requested real-API scope and accepted through Stage 1 approval; exact endpoint contracts belong to Stage 5.

- The developer supplies an application API credential through a local, uncommitted configuration mechanism. Do not request secrets in specifications or commit them to source control.
- Ordinary movie readers do not need a TMDB account for the app's catalog-reading endpoints.
- Local favorites are maintained by Movies rather than TMDB account APIs.
- Movie titles, artwork, descriptions, ratings, and discovery feeds come from the provider in the live app. Test fixtures may be used separately for automated tests.
- Include the required provider attribution and approved logo in an About/Credits surface reachable from the app.
- The required TMDB notice is: “This product uses the TMDB API but is not endorsed or certified by TMDB.”
- API use is planned for this noncommercial learning/demo project. Reassess the provider's terms before commercial distribution.
- Missing data, invalid credentials, rate limits, network failures, and unavailable external links require clear product states; API failures must not be disguised as empty successful results.

Official references:

- [Getting started and credentials](https://developer.themoviedb.org/docs/getting-started)
- [API usage and attribution FAQ](https://developer.themoviedb.org/docs/faq)
- [Movie details](https://developer.themoviedb.org/reference/movie-details)
- [Movie credits](https://developer.themoviedb.org/reference/movie-credits)
- [Person movie credits](https://developer.themoviedb.org/reference/person-movie-credits)
- [Movie recommendations](https://developer.themoviedb.org/reference/movie-recommendations)
- [Collection details](https://developer.themoviedb.org/reference/collection-details)

## 8. Readiness for later agentic testing

The first client release must expose meaningful accessibility labels and stable identifiers for important controls, movie/person cards, tab destinations, and outcome values. Flutter widget keys and native semantics identifiers serve different automation approaches; their implementation policy will be specified with the architecture and testing strategy.

Navigation, favorite changes, searches, loading, errors, and empty states must have observable outcomes. These client qualities prepare the app for later automation without adding LangGraph, MCP, memory stores, Jev, or an autonomous test runner to the current client scope.

This release should not hide special test-only instructions or infrastructure details in normal product flows. Live-data use must remain explicit, and later deterministic agent evaluations will need a controlled data mode rather than rely on current Trending rankings.

## 9. Explicit exclusions and deferred work

- Android, Web, desktop, physical-device deployment, App Store submission, and production hosting.
- TV shows, seasons, episodes, and a combined movie/TV catalog.
- User registration, sign-in, profiles, cloud-synchronized favorites, and social features.
- Movie playback, ticketing, rentals, purchases, subscriptions, and in-app payments.
- Embedded trailer playback and third-party streaming-account integration.
- An AI recommender, conversational assistant, or claims of learned personal taste.
- A custom movie backend, FastAPI server, Docker deployment, or agentic testing service.
- MCP orchestration, LangGraph workflows, session/episodic/procedural memory infrastructure, Jev integration, and the agent-evaluation harness. These remain the long-term project objective.
- Full offline catalog browsing, cloud backups, and sharing favorites across devices.

Lightweight on-device handling of library state and recoverable display of already available data do not imply a complete offline-catalog feature.

## 10. Product success criteria

1. A user can navigate all four tabs and open real provider-backed movie content.
2. Home includes the requested hero carousel and discovery sections.
3. A user can search, inspect a movie and its cast, follow a person into their filmography, open another movie, and reach an available collection or related-movie listing.
4. That journey demonstrates five additional steps after the first movie-detail screen and supports correct back navigation.
5. Favorites remain consistent across navigation paths and survive an app restart.
6. Missing content and request failures have understandable, recoverable states.
7. Important product controls and outcomes are accessible and identifiable for subsequent automation.
8. The implemented client runs on an agreed local iOS simulator; other platforms are not required for this release.

## 11. Assumptions and remaining stage boundaries

- The project is currently a noncommercial learning/demo application.
- The developer can obtain a TMDB application credential before live API integration is validated. No credential availability is assumed today.
- The first-release audience is English-speaking; precise provider language, market, and fallback configuration are Stage 5 decisions.
- “Modern” means an artwork-led, readable and polished movie-browsing experience. A specific visual system has not yet been approved.
- The existing Stage 0 toolchain will be used unless compatibility evidence requires a change; no SDK upgrade or FVM installation is assumed.
- Package architecture, routing mechanics, pinned dependencies, visual design, data contracts, test coverage, and implementation milestones are intentionally reserved for their respective SDD stages.

## 12. Stage 1 approval record

The developer reviewed this document and replied “approved” on October 31, 2026. Approval covers the product, platform matrix, five feature pillars, real-data strategy, navigation-depth definition, and exclusions above.

Stage 2 discovery may now proceed. Later specification stages, scaffolding, and application implementation remain gated by the selected Flutter spec-driven-development workflow. This record does not imply approval of specifications that have not yet been written.

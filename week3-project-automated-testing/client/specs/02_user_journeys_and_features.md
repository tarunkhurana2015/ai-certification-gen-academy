# Stage 2: Movies — User Journeys and Feature Acceptance

Status: Approved by the developer.
Approval recorded: October 31, 2026 (America/Chicago), from the developer reply “approved”.
Date: October 31, 2026 (America/Chicago).
Prerequisite: [Stage 1 product scope](01_product_scope.md), approved by the developer.
Target: iOS Simulator only.

## 1. Confirmed discovery decisions and approved defaults

The developer confirmed these Stage 2 behaviors:

| Decision | Confirmed behavior |
| --- | --- |
| Search initiation | Automatically search after a short typing pause. |
| Request failure after content loaded | Keep the previously loaded content and show a Retry message. First-load failure shows an error with Retry. |
| Removing a favorite | Remove immediately and offer Undo. |

The following concrete defaults were proposed and accepted through Stage 2 approval. They refine the approved scope rather than introduce additional platforms or account features:

- Search debounce is 350 milliseconds after the latest query edit. Trim leading/trailing whitespace; an empty normalized query performs no search. Pressing the keyboard Search action may submit immediately without duplicating a pending identical search.
- Home is the initial tab. Browse initially selects Now Playing. Carousel movement is user-controlled; no automatic advancement is required.
- Lists load subsequent pages when the user scrolls to their end. A failed continuation displays a visible Retry control without discarding loaded cards. A completed list stops requesting further pages.
- Library orders favorites by most recently added first. Undo restores a removed movie to its previous relative position when that order remains meaningful.
- Undo is available for five seconds while the app is active. Navigation between tabs does not dismiss it. Backgrounding or terminating the app ends the offer without automatically restoring the movie. A subsequent removal replaces the previous Undo offer; only the latest offer remains actionable.
- A failed local favorite write rolls the affected movie back to its last successfully saved state, leaves unrelated favorites intact, and shows an actionable error. A failed read does not become a successful empty Library.
- A failed request must retain data under its original identity. Old results must never be presented as belonging to a newly selected query, category, movie, person, or recommendation seed.
- Each tab retains its in-process navigation stack, loaded results, selected category/query, and useful scroll position. Only favorites are required to survive process restart; restoring an entire navigation stack after restart is not required.

Exact widget appearance, component placement, dependency choices, API schemas, storage design, retry backoff, and test implementations belong to later stages.

## 2. Actors and acceptance vocabulary

The primary actor is a movie browser who does not sign in. The secondary actor is a developer or QA practitioner validating observable app behavior. Scenarios describe the same normal product UI for both actors.

Each `@MOV-...` tag is a stable acceptance ID for later implementation and test mapping. IDs do not prescribe implementation modules or test tools. Given statements establish data and state, When statements describe user or external events, and Then statements require observable results.

“Back” means the visible back action or supported iOS back gesture for the current branch. “Retry” means a visible, accessible action targeting the failed operation, not an instruction to restart the app. “Saved” means local persistence has acknowledged the favorite change.

Acceptance checks use controlled provider responses and storage outcomes. Live API smoke checks separately establish real TMDB integration; changing rankings or absent live relationships must not change the expected result of a deterministic scenario.

### Controlled narrative fixture

These invented records are test fixtures only and must not be sent as assumed real IDs to TMDB or substituted into the live catalog:

| Fixture | Identity and supplied content |
| --- | --- |
| Primary movie | `900001`, Northbound; rating 7.8/10 from 1,250 votes; synopsis, artwork, release date, runtime, genres, cast, images, review, trailer link, and related titles supplied. |
| Primary person | `910001`, Maya Reed; credited in Northbound; biography, profile image, public career details, and movie filmography supplied. |
| Second movie | `900002`, Afterlight; appears in Maya Reed's filmography and belongs to collection `920001`. |
| Collection | `920001`, Afterlight Collection; includes Afterlight and movie `900003`, Afterlight Again. |
| Missing-content movie | `900004`, Quiet Harbor; missing artwork and rating, null collection membership, and successful empty reviews/trailers; related-movie results can be supplied independently. |
| Alternate search result | `900005`, Ember; used to verify query isolation from Northbound results. |

“Content supplied” is explicit fixture data, not a promise that every live movie has that content. Stage 5 will formalize response payloads; Stage 6 will map these behavioral fixtures to the chosen test layers.

## 3. User stories and end-to-end journeys

| Journey | User story | Route to value |
| --- | --- | --- |
| J01 Discover | As a movie browser, I want useful discovery shelves so I can find a movie without entering a query. | Launch → Home → carousel or shelf → movie details. |
| J02 Browse | As a movie browser, I want clearly categorized releases and more results so I can explore the catalog. | Browse → category → scroll through pages → movie details → Back. |
| J03 Search | As a movie browser, I want results as I type so I can locate a movie quickly. | Search → type → results → movie details → Back to preserved results. |
| J04 Explore connections | As a movie browser, I want to follow cast and filmography connections so I can discover related work. | Movie → Cast → Person → Filmography → Another Movie → Collection/Related. |
| J05 Save | As a movie browser, I want to favorite a movie so I can find it after restarting the app. | Movie details → Favorite → Library → restart → saved movie. |
| J06 Remove and recover | As a movie browser, I want to remove a favorite and undo a mistake. | Library → Remove → Undo → restored movie. |
| J07 Inspect rich information | As a movie browser, I want available images, reviews, and trailer links so I can assess a movie. | Movie details → relevant content → return to the movie. |
| J08 Recover | As a movie browser, I want honest failure and missing-content states so I can retry or continue browsing. | Any affected surface → error/empty state → Retry or Back. |
| J09 Switch context | As a movie browser, I want each tab to remember its place so I can explore without losing progress. | Deep branch → another tab → return → same branch and Back path. |
| J10 Inspect attribution | As a movie browser, I want to identify the data source and rating scale. | Home information action → About/Credits → return. |

## 4. Shell and tab navigation

```gherkin
Feature: Four-tab shell
  @MOV-SHELL-001
  Scenario: First launch opens Home without requiring an account
    Given Movies is installed on the selected iOS simulator
    When I launch Movies
    Then Home is selected
    And Home, Browse, Search, and Library are available and accessibly named
    And no registration or sign-in gate is shown

  @MOV-SHELL-002
  Scenario: Returning to a tab preserves its current journey
    Given I reached Maya Reed's filmography through Home and Northbound
    And I have scrolled within that filmography
    When I switch to Search and then return to Home
    Then Maya Reed's filmography and its useful scroll position are restored
    And Back returns to Maya Reed's person details on the original path

  @MOV-SHELL-003
  Scenario: Background completion does not steal navigation
    Given a request is pending in Home
    When I switch to Library and the Home request completes
    Then Library remains selected
    And the request does not push a destination or replace Library content
```

## 5. Home and recommendation behavior

```gherkin
Feature: Movie discovery on Home
  @MOV-HOME-001
  Scenario: Inspect and open a featured movie
    Given Home's featured response includes Northbound and Afterlight
    When the carousel loads and I scroll it horizontally
    Then I can inspect each movie's title, supplied rating, and description
    And artwork remains readable behind the overlaid content
    When I select Northbound
    Then Northbound's movie details open

  @MOV-HOME-002
  Scenario: Explore a discovery shelf and its larger listing
    Given Home has loaded discovery responses
    Then Recommended for you, Trending, Now Playing, Top Rated, and Upcoming are identifiable sections
    When I open Trending's larger listing and select Northbound
    Then Northbound's details open in Home's navigation branch
    And Back returns to that Trending listing

  @MOV-HOME-003
  Scenario: Recommendations without favorites are described honestly
    Given no movies are favorited
    When Recommended for you loads
    Then it shows the general discovery selection
    And explanatory copy identifies those results as general movie picks
    And it does not claim to have learned my personal taste

  @MOV-HOME-004
  Scenario: Recommendations use the current favorite seed
    Given Northbound is my most recently added favorite
    And its recommendation response includes Afterlight
    When Recommended for you loads
    Then it identifies Northbound as the recommendation source
    And selecting Afterlight opens Afterlight's details

  @MOV-HOME-005
  Scenario: An empty recommendation response uses a labeled fallback
    Given the selected favorite seed has no available recommendations
    And the general discovery response supplies movies
    When Recommended for you loads
    Then the general discovery selection is shown
    And those results are labeled as general picks rather than attributed to the favorite seed

  @MOV-HOME-006
  Scenario: A failing shelf does not replace successful shelves
    Given Trending and Now Playing have loaded
    When the Top Rated request fails
    Then Trending and Now Playing remain usable
    And Top Rated shows its own error and Retry
    And Top Rated is not labeled as a successfully empty result

  @MOV-HOME-007
  Scenario: A successful empty general fallback remains an honest empty state
    Given the selected favorite seed has no recommendations
    And the general discovery response also succeeds with no movies
    When Recommended for you finishes loading
    Then an honest no-recommendations state is shown
    And no invented movie cards or network-failure message appear

  @MOV-HOME-008
  Scenario: Changing the favorite seed isolates late recommendations
    Given recommendations for Northbound are pending
    When I add Afterlight as my most recent favorite
    And the old Northbound response completes
    Then the old response is not labeled as recommendations based on Afterlight
    And the current recommendation source and displayed results remain consistent
```

## 6. Browse and continuation behavior

```gherkin
Feature: Browse movie categories
  @MOV-BROWSE-001
  Scenario: Browse separates released and upcoming categories
    Given Movies has launched without a previously selected Browse category
    When I open Browse for the first time
    Then Now Playing is selected
    And Now Playing, Upcoming, Popular, and Top Rated are available categories
    When I select Upcoming
    Then the heading and results identify Upcoming
    And the app does not label those results as already released

  @MOV-BROWSE-002
  Scenario: Load the next page without duplicates
    Given the current category has a loaded first page and an available next page
    When I scroll to the end of the results
    Then the continuation is loaded for that category
    And new movies append without duplicating existing movie identities
    And the list does not jump back to its beginning

  @MOV-BROWSE-003
  Scenario: Retry a failed continuation without losing loaded results
    Given the first page is visible and the next-page request fails
    Then the existing cards remain visible
    And a continuation Retry is available
    When I activate Retry and the continuation succeeds
    Then the correct next results append once
    And no page is skipped or duplicated

  @MOV-BROWSE-004
  Scenario: Changing category isolates in-flight results
    Given a Popular continuation is pending
    When I select Top Rated and the Popular request completes
    Then Top Rated remains selected
    And Popular results do not append to Top Rated

  @MOV-BROWSE-005
  Scenario: An exhausted list stops requesting continuations
    Given the provider says the final page has been reached
    When I scroll to the end again
    Then an end-of-results state is shown
    And no additional continuation is requested

  @MOV-BROWSE-006
  Scenario: A successful empty category remains distinguishable from a failure
    Given a selected category request is pending
    When its response succeeds with no movies
    Then an empty state identifies that category
    And the other category controls remain available
    And no network-failure message is shown
```

## 7. Search and response ordering

```gherkin
Feature: Search movies as the user types
  @MOV-SEARCH-001
  Scenario: Submit one automatic search after the typing pause
    Given Search is open with an empty query
    When I type "Northbound" and stop editing for 350 milliseconds
    Then a search for the normalized query "Northbound" starts
    And the results identify that query when they arrive

  @MOV-SEARCH-002
  Scenario: Continued typing restarts the debounce interval
    Given I typed "North" fewer than 350 milliseconds ago
    When I edit the query to "Northbound"
    Then an automatic search for the unfinished query does not start during that typing interval
    And one search for "Northbound" starts after the new 350-millisecond pause

  @MOV-SEARCH-003
  Scenario: Explicit submit does not duplicate the same pending search
    Given I have typed "Northbound" and its automatic search has not yet started
    When I submit using the keyboard Search action
    Then the normalized query is searched immediately
    And the pending debounce does not start an identical duplicate search

  @MOV-SEARCH-004
  Scenario Outline: An older response cannot replace a newer query's state
    Given a search for "Northbound" is pending
    And I have changed the query to "Ember" and its results are displayed
    When the old Northbound request completes with <outcome>
    Then Ember's results and query state remain unchanged
    And no Northbound error is attached to Ember

    Examples:
      | outcome |
      | success |
      | failure |

  @MOV-SEARCH-005
  Scenario: Clearing the query invalidates pending requests
    Given a movie search is pending
    When I clear the query and the old request subsequently completes
    Then Search remains in its untouched state with no old results or errors
    And an empty or whitespace-only query does not trigger a provider search

  @MOV-SEARCH-006
  Scenario: No matches differs from a request failure
    Given a nonempty query has been submitted
    When the provider returns a successful empty result for that query
    Then a no-matches state identifies that query
    And the search field remains available for editing
    And no network-failure message is shown

  @MOV-SEARCH-007
  Scenario: Preserve identifiable old results when a new query fails
    Given results for "Northbound" have loaded
    When I search for "Ember" and that request fails
    Then the Northbound results remain identified as previously loaded results for "Northbound"
    And an error and Retry identify the failed Ember query
    And the old results are not presented as Ember matches
    When I activate Retry and Ember succeeds
    Then Ember's results replace the old result set

  @MOV-SEARCH-008
  Scenario: Preserve search context after inspecting a movie
    Given Northbound appears in a loaded search with additional pages and a scrolled position
    When I open Northbound and then use Back
    Then the search query, loaded pages, and useful scroll position are restored

  @MOV-SEARCH-009
  Scenario: Search continuations belong to the displayed result query
    Given Northbound search results are displayed
    And a continuation for those results is pending
    When I submit a different query and the old continuation completes
    Then the old continuation does not append to the new query's results
    And repeated continuation triggers cannot append the same page twice
```

## 8. Rich movie and person information

```gherkin
Feature: Inspect supplied movie information
  @MOV-DETAIL-001
  Scenario: Display rich details with honest rating provenance
    Given Northbound's complete fixture response is available
    When I open Northbound
    Then its title, synopsis, release information, runtime, genres, and available artwork are shown
    And its rating is identified as TMDB 7.8 out of 10 with the supplied vote context
    And cast, images, reviews, trailers, and related-content sections are reachable
    And no IMDb rating is fabricated

  @MOV-DETAIL-002
  Scenario: Missing content does not become fabricated information
    Given Quiet Harbor has missing artwork, an unavailable rating, and no supplied reviews or trailers
    When I open Quiet Harbor
    Then its title and available details remain usable
    And unavailable fields have honest fallbacks or are omitted appropriately
    And no fake rating, review, trailer, or image is invented

  @MOV-DETAIL-003
  Scenario: Supplementary failure preserves core details
    Given Northbound's core details and cast have loaded
    When the reviews request fails
    Then the details and cast remain usable
    And reviews show an error with Retry rather than "No reviews"
    When I retry reviews successfully
    Then only the intended movie's reviews populate that section

  @MOV-DETAIL-004
  Scenario: A previously visited movie cannot populate the current movie
    Given Northbound has a pending detail or supplementary request
    When I navigate to Afterlight and the Northbound request completes
    Then Afterlight remains the current movie
    And Northbound's content is not displayed as Afterlight's content

  @MOV-DETAIL-005
  Scenario: Browse images and read available review content
    Given Northbound supplies multiple images and a long review
    When I open the images and select an image
    Then the selected supplied image can be inspected
    When I return and expand or open the supplied review
    Then its available text and author attribution can be read
    And returning preserves the movie-details context

  @MOV-DETAIL-006
  Scenario: A removed or unavailable movie remains a navigable error state
    Given a movie listed earlier now returns not found
    When I open it
    Then the app explains that its details are unavailable
    And Back remains available without substituting another movie's details

  @MOV-DETAIL-007
  Scenario: Supplied public person details are readable
    Given Maya Reed has a supplied biography, profile image, and public career details
    When I open Maya Reed from Northbound's cast
    Then those supplied details identify Maya Reed
    And a filmography action is available
    And absent optional facts are not inferred or invented
```

## 9. Deep navigation and relationship integrity

```gherkin
Feature: Follow movie and person relationships
  @MOV-DEEP-001
  Scenario: Traverse five additional levels after the initial movie details
    Given the controlled Northbound, Maya Reed, Afterlight, and collection relationships are available
    And I am viewing Northbound's movie details at depth 0
    When I open its full cast and credits
    Then the cast list is depth 1 and includes Maya Reed with the supplied credit
    When I open Maya Reed
    Then person details are depth 2
    When I open Maya Reed's filmography
    Then the filmography is depth 3 and includes Afterlight
    When I select Afterlight
    Then Afterlight's movie details are depth 4
    When I open Afterlight Collection
    Then the collection listing is depth 5 and contains its supplied movies

  @MOV-DEEP-002
  Scenario: Back follows the actual visited path
    Given I have completed the depth-5 collection journey
    When I use Back five times
    Then I visit Afterlight, Maya Reed's filmography, Maya Reed, the Northbound cast list, and Northbound in that order
    And useful preceding scroll positions remain available

  @MOV-DEEP-003
  Scenario: Related movies provide a valid alternative to collection membership
    Given Quiet Harbor has no collection but has supplied related movies
    When I open its related-movie listing
    Then the supplied related titles are shown
    And selecting a title opens that movie's details
    And no collection is fabricated

  @MOV-DEEP-004
  Scenario Outline: An empty relationship does not create a dead navigation branch
    Given the <relationship> response succeeds with no entries
    When I open that relationship
    Then an honest empty state identifies the relationship
    And Back returns to the originating movie or person
    And the app does not invent a person or movie to extend the journey

    Examples:
      | relationship |
      | cast         |
      | filmography  |

  @MOV-DEEP-005
  Scenario: Revisiting a movie preserves path and shared favorite identity
    Given Northbound is favorited and appears again through a later related-movie path
    When I open that occurrence of Northbound
    Then Northbound still shows its favorited state
    And Back returns to the related-movie path I actually followed
    And it does not jump to an unrelated earlier Northbound screen
```

## 10. Favorites, Undo, and local persistence

```gherkin
Feature: Save and remove local favorites
  @MOV-LIBRARY-001
  Scenario: Save a movie and observe it across surfaces
    Given Northbound is not favorited
    When I favorite Northbound and the local save succeeds
    Then its favorite state is active wherever that movie appears
    And Library contains Northbound exactly once
    And no account or sign-in is requested

  @MOV-LIBRARY-002
  Scenario: Favorites survive restart
    Given Northbound was successfully saved as a favorite
    When I terminate and relaunch Movies on the same installation
    Then Library still contains Northbound
    And its favorite state remains active when its details are opened

  @MOV-LIBRARY-003
  Scenario: Remove immediately and undo the removal
    Given Northbound and Afterlight are saved favorites
    When I remove Northbound from Library
    Then Northbound disappears immediately and its visible favorite states update
    And a five-second Undo offer identifies Northbound
    When I activate Undo within that offer and its local save succeeds
    Then Northbound is restored without duplicating it
    And Afterlight remains unchanged
    And Northbound returns to its prior relative position where applicable

  @MOV-LIBRARY-004
  Scenario: An expired removal remains removed after restart
    Given I removed Northbound and the removal was saved
    When the Undo offer expires without activation and I restart Movies
    Then Northbound remains absent from Library
    And the app does not restore the removed favorite automatically

  @MOV-LIBRARY-005
  Scenario: Undo remains coherent across navigation and pending writes
    Given I removed Northbound and its persistence acknowledgement is still pending
    When I switch tabs and activate its still-valid Undo offer
    And the removal and Undo persistence operations both succeed
    Then Northbound is favorited consistently across tabs
    And an older removal completion cannot remove it again
    And unrelated favorite changes remain intact

  @MOV-LIBRARY-006
  Scenario: Only the latest removal offer can be undone
    Given I removed Northbound and then removed Afterlight
    When I activate the current Undo offer
    Then Afterlight is restored
    And Northbound remains removed
    And no obsolete Northbound offer can override a newer intentional change

  @MOV-LIBRARY-007
  Scenario: A failed favorite write restores the affected saved state
    Given Northbound's last successfully saved state is favorited
    When I remove it and the local write fails
    Then its favorite state returns to the last successfully saved state on all surfaces
    And an actionable storage error explains that the removal could not be saved
    And unrelated favorites are not lost
    And the UI does not claim the failed change was persisted

  @MOV-LIBRARY-008
  Scenario: Failed favorite reads do not erase the Library
    Given saved favorites exist but reading them fails
    When I open Library
    Then a recoverable storage error with Retry is shown
    And the app does not label the failure as a successful empty Library
    And saved data is not silently cleared
    When I activate Retry and the local read succeeds
    Then the saved favorites are shown without duplication

  @MOV-LIBRARY-009
  Scenario: A genuinely empty Library explains how to save movies
    Given the local read succeeds with no favorites
    When I open Library
    Then an empty state explains how to favorite a movie
    And I can navigate to discovery without signing in

  @MOV-LIBRARY-010
  Scenario: A successfully undone removal survives restart
    Given I removed Northbound and successfully saved its Undo restoration
    When I restart Movies
    Then Northbound remains in Library exactly once

  @MOV-LIBRARY-011
  Scenario: A failed add does not claim a movie was saved
    Given Northbound is not a saved favorite
    When I favorite Northbound and its local write fails
    Then Northbound is not shown as a saved favorite on any surface
    And an actionable error explains that adding the favorite could not be saved

  @MOV-LIBRARY-012
  Scenario: A failed Undo restoration does not claim persistence succeeded
    Given Northbound's removal has been saved and its Undo offer is available
    When I activate Undo and the restoration write fails
    Then Northbound remains absent from the saved Library
    And an actionable error explains that restoring the favorite could not be saved
    And favorite state is consistent across surfaces

  @MOV-LIBRARY-013
  Scenario: Backgrounding ends the offer without undoing a saved removal
    Given Northbound's removal has been saved and its Undo offer is available
    When Movies enters the background and I later return
    Then the old Undo offer is no longer actionable
    And Northbound remains removed
```

## 11. Failures, offline behavior, and external links

```gherkin
Feature: Recover without misrepresenting available content
  @MOV-RECOVERY-001
  Scenario: A first-load failure exposes an honest retry state
    Given no content has loaded for the requested destination
    When its request fails with a temporary network or service error
    Then a readable error and accessible Retry action appear
    And the failure is not represented as successful empty results
    When I retry and the request succeeds
    Then the requested destination's content is shown

  @MOV-RECOVERY-002
  Scenario: A refresh failure retains correctly identified content
    Given content has loaded for the current destination
    When a subsequent request for that same destination fails
    Then the existing content remains usable with a visible error and Retry
    And Retry targets that destination rather than a different entity or query

  @MOV-RECOVERY-003
  Scenario: Offline Library remains locally useful without promising an offline catalog
    Given Northbound is saved with its last known display metadata
    And network access is unavailable
    When I open Library
    Then its saved entry remains identifiable and can be removed or restored locally
    When I open details that have not been loaded
    Then an offline error and Retry are shown
    And a complete offline movie catalog is not fabricated

  @MOV-RECOVERY-004
  Scenario: Rate limiting is distinguishable from no results
    Given a catalog request is pending
    When the provider temporarily rate-limits that request
    Then the app explains the temporary inability to load that content
    And existing correctly identified content remains visible when available
    And the UI does not enter a rapid uncontrolled retry loop
    And the operation is not described as a successful empty result

  @MOV-RECOVERY-005
  Scenario: A configuration failure does not request credentials in product flows
    Given application API credentials are missing or rejected
    When a live catalog request is attempted
    Then the UI shows a catalog-unavailable state appropriate to the failure
    And it does not expose a token or prompt a movie browser to paste an API secret
    And local Library access and tab navigation remain available

  @MOV-RECOVERY-006
  Scenario: Broken artwork preserves usable movie identity
    Given a movie with an image URL is displayed
    When that image fails to load
    Then a deliberate artwork placeholder is shown
    And the title, available metadata, and movie-opening action remain usable

  @MOV-EXTERNAL-001
  Scenario: Open a supplied trailer link and return
    Given Northbound supplies an allowed trailer destination
    When I select the trailer action
    Then the app requests that external destination through the supported iOS flow
    And no embedded movie-streaming feature is implied
    When I return to Movies
    Then Northbound's details and navigation context remain available

  @MOV-EXTERNAL-002
  Scenario: An unavailable trailer destination does not break navigation
    Given a supplied trailer destination cannot be opened
    When I select its action
    Then a clear failure message is shown
    And I remain able to use the movie-details screen and Back
```

## 12. Accessibility, observable outcomes, and attribution

```gherkin
Feature: Understand controls and data provenance
  @MOV-A11Y-001
  Scenario: Identify important controls and their current states
    Given Movies is running on the selected iOS simulator
    When I inspect the app through its accessibility interface
    Then tabs, search input, movie/person cards, navigation, Favorite, Remove, Undo, and Retry have meaningful labels
    And controls expose applicable selected or favorite states
    And stable identifiers distinguish repeated cards by entity identity and relevant screen context
    And icon-only actions remain understandable without their artwork

  @MOV-A11Y-002
  Scenario: Large text does not hide essential actions
    Given the selected simulator uses a larger supported text size
    When I browse Home, search results, movie details, and Library
    Then essential titles, navigation, and favorite/recovery actions remain readable and reachable
    And content can scroll rather than permanently clip required actions

  @MOV-ABOUT-001
  Scenario: Inspect provider attribution
    Given I am on Home
    When I open About/Credits from Home's information action
    Then the approved TMDB logo and required attribution notice are visible
    And TMDB is identified as the source of provider movie data and ratings
    When I use Back
    Then Home's prior browsing context is available
```

## 13. Coverage and later test mapping

| Approved scope area | Journey coverage | Acceptance family |
| --- | --- | --- |
| Four tabs and preserved context | J01, J09 | MOV-SHELL |
| Featured carousel and discovery shelves | J01 | MOV-HOME |
| New/released catalog categories and pagination | J02 | MOV-BROWSE |
| Automatic title search and result isolation | J03 | MOV-SEARCH |
| Rich movie and public person information | J04, J07 | MOV-DETAIL |
| Five further navigation levels and real relationships | J04, J09 | MOV-DEEP |
| Local favorites, immediate removal, Undo, persistence | J05, J06 | MOV-LIBRARY |
| Failed requests, missing data, and local storage errors | J08 | MOV-RECOVERY, MOV-DETAIL, MOV-LIBRARY |
| External trailer links | J07 | MOV-EXTERNAL |
| Accessible and observable product outcomes | All | MOV-A11Y |
| Provider credit and rating provenance | J10 | MOV-ABOUT, MOV-DETAIL |

Stage 6 will map these IDs to unit, widget, and integration test responsibilities and deterministic failure fixtures. This document does not add an agent runner, MCP setup, memory implementation, or Jev integration to client delivery. An agent reporting “done” is not a substitute for satisfying the applicable observable Then clauses.

## 14. Stage 2 approval record

The developer reviewed this document and replied “approved” on October 31, 2026. Approval covers the user stories, journey coverage, confirmed discovery choices, timing/order defaults, Gherkin outcomes, duplicate-response rules, storage rollback, and tab-restoration boundaries above.

Stage 3 architecture discovery may now proceed. Stage 1 approval is preserved. Later specifications, scaffolding, and application implementation remain gated by the selected Flutter spec-driven-development workflow; this record does not imply approval of specifications that have not yet been written.

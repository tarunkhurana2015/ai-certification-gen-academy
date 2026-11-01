# Stage 5: Movies — Data Models and API Contracts

Status: Approved by the developer.
Approval recorded: November 1, 2026 (America/Chicago), from the developer reply “approved”.
Date: November 1, 2026 (America/Chicago).
Prerequisites: [Stage 1 scope](01_product_scope.md), [Stage 2 behavior](02_user_journeys_and_features.md), [Stage 3 architecture](03_architecture_and_monorepo.md), and [Stage 4 design](04_design_system_and_responsive.md), all approved.
Target: Flutter iOS Simulator client; TMDB catalog reads and local Drift favorites. No custom server.

## 1. Confirmed decisions and boundaries

| Decision | Basis |
| --- | --- |
| TMDB catalog, local favorites, no account | Approved Stages 1–3. |
| English `en-US`, U.S. market `US`, exclude titles flagged adult | Explicit Stage 5 discovery response. |
| Live data normally; deterministic fixtures only through explicit development/test configuration | Explicit Stage 5 discovery response. A failed live request never substitutes fixture data. |
| DTO/domain separation, Freezed, Dio, Drift, injected repositories | Approved Stage 3. Dependency pins remain unchanged. |
| Endpoint selection, nullable mapping, timeouts, ordering, fixture isolation, and schema below | Engineering decisions proposed for Stage 5 approval. |

Approaches considered: live-only data makes the smallest configuration but cannot reliably reproduce the accepted failure/navigation scenarios; a separate fake HTTP server adds an unnecessary process and duplicates API infrastructure. The selected approach uses the live adapter normally and explicit in-process fixture repository bindings for controlled development and tests. Fixture bindings still drive the same Views and ViewModels.

The normal app must demonstrate real third-party integration. This specification was checked against public TMDB documentation and OpenAPI; no authenticated TMDB responses have been captured for this stage. Example records below are explicitly synthetic acceptance fixtures. Live payload compatibility remains an implementation verification task.

## 2. Runtime configuration and request boundary

| Input | Contract |
| --- | --- |
| `MOVIES_DATA_MODE` | `live` by default; accepted alternative `fixture`. Unknown values produce a configuration failure. |
| `TMDB_READ_ACCESS_TOKEN` | Required only in live mode; supplied locally through an ignored build-configuration file, never a specification, committed fixture, or product input field. |
| Language / region | Fixed application defaults `en-US` / `US` for this release. Send region only to endpoints documenting it. |
| Fixture scenario | A deliberate debug/test binding; baseline uses Stage 2's Northbound/Maya Reed/Afterlight records. Unit/widget tests inject their chosen outcomes directly. |

The later scaffold provides a credential-free `config/dev.example.json` and ignores `config/*.local.json`. A developer supplies values with Flutter's `--dart-define-from-file` mechanism. Do not read an unrelated existing `.env`, put credentials in URL query parameters, or add dotenv dependencies. Build-time configuration prevents accidental Git inclusion; it does not turn an embedded client token into a server-held secret.

Live API base: `https://api.themoviedb.org/3`. All catalog operations in this release are **GET**, with `Accept: application/json` and `Authorization: Bearer <API Read Access Token>`. No user session, TMDB account-favorites write, or request body is needed. The token is attached only by the TMDB API client to its fixed HTTPS API host; image requests and external links never receive it. Disable automatic API redirects; do not forward the authorization header to an unvalidated destination. Follow [TMDB application authentication](https://developer.themoviedb.org/docs/authentication-application).

Build request URIs using encoded path/query components. Entity IDs are positive integers; malformed route IDs fail locally without a provider call. Search normalization trims leading/trailing whitespace only; preserve case and internal spaces. An empty normalized query makes no request. Do not introduce a minimum query length beyond nonempty.

Fixture mode is explicitly identified as **Demo data** in its shell/About presentation. It has no TMDB-token requirement, uses bundled/local test artwork, and does not contact the real catalog or image CDN. The fixture app and automated tests both bind a simulated external-link gateway: a trailer/attribution action records the attempted destination and shows “Demo: link opening simulated” without opening a browser. Synthetic video keys therefore never reach YouTube. Live and fixture favorites use separate database files so deterministic development cannot contaminate a real local Library. The baseline fixture catalog date is January 15, 2026, matching its release-window examples; elapsed-time controls such as debounce, deadlines, and Undo still use an advancing monotonic clock. Tests may explicitly control that clock.

## 3. Endpoint inventory

All paths below are relative to the API base. `language` means `en-US`, `region` means `US`, and `page` starts at 1. Do not add global query parameters to endpoints that do not support them. Provider arrays remain ordered unless a mapping rule below explicitly changes the order.

### 3.1 Discovery, search, and configuration

| Use | Path | Query sent | Continuation |
| --- | --- | --- | --- |
| Now Playing | `/movie/now_playing` | `language`, `region`, `page` | Provider pages. |
| Upcoming | `/movie/upcoming` | `language`, `region`, `page` | Provider pages. |
| Popular / initial general recommendations | `/movie/popular` | `language`, `region`, `page` | Provider pages. |
| Top Rated | `/movie/top_rated` | `language`, `region`, `page` | Provider pages. |
| Trending / featured carousel | `/trending/movie/week` | `language` | Available first response only; no undocumented page request. |
| Movie search | `/search/movie` | `query`, `language`, `region`, `include_adult=false`, `page` | Provider pages. |
| Image configuration | `/configuration` | None | Single resource. |
| Genre labels for list/hero metadata | `/genre/movie/list` | `language` | Complete returned genre array. |

Sources: [Now Playing](https://developer.themoviedb.org/reference/movie-now-playing-list), [Upcoming](https://developer.themoviedb.org/reference/movie-upcoming-list), [Popular](https://developer.themoviedb.org/reference/movie-popular-list), [Top Rated](https://developer.themoviedb.org/reference/movie-top-rated-list), [Trending](https://developer.themoviedb.org/reference/trending-movies), [Search](https://developer.themoviedb.org/reference/search-movie), [Configuration](https://developer.themoviedb.org/reference/configuration-details), [Genres](https://developer.themoviedb.org/reference/genre-movie-list).

### 3.2 Catalog and relationships

| Use | Path | Query sent | Result shape |
| --- | --- | --- | --- |
| Movie details | `/movie/{movieId}` | `language` | Single movie. |
| Full cast and crew | `/movie/{movieId}/credits` | `language` | Complete cast/crew arrays. |
| Movie images | `/movie/{movieId}/images` | `language`, `include_image_language=en,null` | Complete returned poster/backdrop arrays. |
| Movie reviews | `/movie/{movieId}/reviews` | `language`, `page` | Provider pages. |
| Trailer candidates | `/movie/{movieId}/videos` | `language` | Complete returned video array. |
| Favorite-seeded recommendations | `/movie/{movieId}/recommendations` | `language`, `page` | Expected provider pages; live shape to verify. |
| Related movies | `/movie/{movieId}/similar` | `language`, `page` | Provider pages. |
| Person details | `/person/{personId}` | `language` | Single person. |
| Person filmography | `/person/{personId}/movie_credits` | `language` | Complete cast/crew movie-credit arrays. |
| Person images | `/person/{personId}/images` | None | Complete returned profile array. |
| Collection | `/collection/{collectionId}` | `language` | Single collection with complete returned parts. |

Sources: [Movie](https://developer.themoviedb.org/reference/movie-details), [Credits](https://developer.themoviedb.org/reference/movie-credits), [Movie images](https://developer.themoviedb.org/reference/movie-images), [Reviews](https://developer.themoviedb.org/reference/movie-reviews), [Videos](https://developer.themoviedb.org/reference/movie-videos), [Recommendations](https://developer.themoviedb.org/reference/movie-recommendations), [Similar](https://developer.themoviedb.org/reference/movie-similar), [Person](https://developer.themoviedb.org/reference/person-details), [Filmography](https://developer.themoviedb.org/reference/person-movie-credits), [Person images](https://developer.themoviedb.org/reference/person-images), [Collection](https://developer.themoviedb.org/reference/collection-details).

Core details load independently. Fetch supplemental sections separately, in bounded parallel requests or on entry to their destination, so a reviews failure cannot erase a successful movie. Do not require `append_to_response` or pretend a failed whole response is a successful empty subsection.

The [published OpenAPI](https://developer.themoviedb.org/openapi/tmdb-api.json) currently declares no Trending `page` query even though its example response has page metadata. The app therefore exposes only that documented available selection; its See all screen has no continuation and does not claim to enumerate all trending titles. The recommendations response schema is currently incomplete in that artifact: the page contract here is an application expectation based on its documented paging parameter, to validate against an authenticated response during integration.

## 4. Discovery and release-date policies

- **Now Playing and Upcoming:** use TMDB's named regional feeds, not a locally invented number of days. The returned `dates.minimum` and `dates.maximum`, when supplied, describe the provider-selected release window. These are theatrical-discovery categories, not streaming availability or a guarantee a title is showing at a particular cinema. Do not classify them by comparing a card's displayed primary release date to the device clock.
- **Dates on cards/details:** preserve the date supplied by that endpoint. It is not automatically an exact U.S. theatrical date; the app does not fetch the separate regional release-history endpoint in this release. Labels say release date/year without claiming a more precise provenance. Unknown dates stay unknown.
- **Popular and Top Rated:** preserve each provider feed's order; these are catalog rankings, not “all new releases.” Trending is TMDB's weekly movie selection, not a U.S.-only ranking; region is unsupported there.
- **Adult filtering:** request `include_adult=false` where supported and exclude explicit `adult=true` movie records from every list, filmography, collection, and recommendation. A directly opened movie flagged adult becomes a navigable content-unavailable state. Do not invent unsupported adult-filter parameters. Missing flags remain unknown metadata; this policy is not an age-rating classifier.
- **Home:** the carousel uses up to five eligible movies from the available weekly Trending selection. Shelves show up to ten eligible entries from their initial response; See all opens that source's listing. Missing image data uses the approved placeholder rather than fabricated artwork.
- **Recommended for you:** with no available favorites baseline or no favorites, use Popular labeled as general discovery. Otherwise choose the highest-order favorite from the current projected favorites state and request its recommendations, excluding the seed itself. If the seeded source **succeeds with no eligible titles and is exhausted**, use Popular and explicitly label general picks. An empty or all-filtered page with further provider pages keeps the seeded source and offers Load more (through See all on Home); do not infer exhaustion or automatically drain pages. Fallback occurs only when the loaded source has no eligible titles and no further pages, not when a later empty page follows usable seeded results. A failure exposes Retry and retains previously loaded content under its real source; it does not silently trigger general or fixture content.
- Seed changes invalidate prior recommendations and continuations. If a favorite write rolls back, seed selection follows the recomputed shared state. A general fallback listing retains its Popular source identity rather than labeling later Popular pages as recommendations for the former seed.

## 5. Canonical typed models

`movies_core` owns shared domain entities and contracts. Implement each named domain model as an immutable Freezed model with `@freezed`, its `_$ModelName` mixin, generated equality/`copyWith`, and `fromJson`/`toJson`. Use the approved Freezed 3.2.5 syntax and pins. Tables specify fields, not implementation code. The domain's camelCase JSON is separate from provider snake_case DTO JSON.

Notation: `T?` is nullable; `List<T>` is immutable and non-null once successfully mapped. IDs are positive `int`. A provider integer-valued JSON number maps to `int`; finite rating/popularity numbers accept JSON integer or decimal forms. No untyped provider map escapes the data package.

### 5.1 Catalog models

| Model | Required fields | Optional fields / invariants |
| --- | --- | --- |
| `CalendarDate` | `year: int`, `month: int`, `day: int` | Valid calendar date; domain JSON object, provider/storage conversion from/to `YYYY-MM-DD`. Never timezone-shift a birthday or release date. |
| `TmdbRating` | `average: double`, `voteCount: int` | Average 0–10; votes positive. Missing/invalid score or zero votes yields no rating, not an invented zero. |
| `Genre` | `id: int`, `name: String` | Nonblank name. |
| `MovieSummary` | `id: int`, `title: String`, `genreIds: List<int>` | `originalTitle: String?`, `overview: String?`, `posterPath: String?`, `backdropPath: String?`, `releaseDate: CalendarDate?`, `rating: TmdbRating?`, `originalLanguage: String?`, `popularity: double?`, `adult: bool?`. Title must be nonblank after title/original-title fallback. |
| `CollectionRef` | `id: int`, `name: String` | `posterPath: String?`, `backdropPath: String?`. |
| `MovieDetails` | `movie: MovieSummary`, `genres: List<Genre>` | `runtimeMinutes: int?` positive, `status: String?`, `tagline: String?`, `collection: CollectionRef?`. Full overview comes from `movie.overview`. |
| `PersonSummary` | `id: int`, `name: String` | `profilePath: String?`, `knownForDepartment: String?`. |
| `CastCredit` | `person: PersonSummary` | `creditId: String?`, `character: String?`, `order: int?`. Different credits for one person are allowed. |
| `CrewCredit` | `person: PersonSummary` | `creditId: String?`, `department: String?`, `job: String?`. |
| `MovieCredits` | `movieId: int`, `cast: List<CastCredit>`, `crew: List<CrewCredit>` | Complete returned resource; no provider page. |
| `PersonDetails` | `person: PersonSummary`, `alsoKnownAs: List<String>` | `biography: String?`, `birthday: CalendarDate?`, `deathday: CalendarDate?`, `placeOfBirth: String?`. Do not derive a live age or assert an unknown date. |
| `CreditRole` | `kind: cast or crew` | `creditId: String?`, `character: String?`, `department: String?`, `job: String?`. |
| `FilmographyEntry` | `movie: MovieSummary`, `roles: List<CreditRole>` | One entry per movie, retaining distinct credited roles. |
| `PersonFilmography` | `personId: int`, `entries: List<FilmographyEntry>` | Complete returned movie-credit resource. |
| `ImageAsset` | `filePath: String`, `kind: poster/backdrop/profile`, `width: int`, `height: int` | Positive dimensions; `language: String?`, `aspectRatio: double?`. |
| `ImageGallery` | `ownerKind: movie or person`, `ownerId: int`, `images: List<ImageAsset>` | Complete returned and mapped image resource. |
| `MovieReview` | `id: String`, `author: String`, `content: String` | `authorRating: double?` 0–10, `createdAtUtc: DateTime?`, `updatedAtUtc: DateTime?`. Author rating is distinct from aggregate TMDB rating. |
| `TrailerLink` | `id: String`, `movieId: int`, `name: String`, `youtubeKey: String`, `url: Uri`, `official: bool` | `publishedAtUtc: DateTime?`; constructed and revalidated under section 8. |
| `MovieCollection` | `collection: CollectionRef`, `movies: List<MovieSummary>` | `overview: String?`; complete returned parts after eligibility filtering. |
| `ImageConfiguration` | `secureBaseUrl: Uri`, `posterSizes: List<String>`, `backdropSizes: List<String>`, `profileSizes: List<String>` | Validated HTTPS provider image base; no API credential. |

Cast uses supplied `order`, with provider position as tie-breaker and unknown order last. Deduplicate identical nonblank credit IDs; when absent use a stable composite of person/role/job rather than person alone. Crew groups by department, then job/name with stable provider-position ties. Filmography combines cast/crew by movie ID and retains all distinct roles; sort release date descending, unknown dates last, then title and ID. Future credits remain visibly dated, not mislabeled as already released. Collection members sort release date ascending, unknown last, then title/ID; label this release order. Galleries preserve provider order and deduplicate file paths; reviews preserve provider order and deduplicate review IDs.

### 5.2 Result, identity, and local models

| Model | Fields / contract |
| --- | --- |
| `RequestKey` | `mode`, `operation`, optional `entityId`, normalized `query`, `category`, `seedMovieId`, `language`, applicable `region`, `filters`, and optional `page`. Include relevant identity values; canonical ordering of filters makes equality stable. Never include credentials. |
| `ReleaseWindow` | `minimum: CalendarDate`, `maximum: CalendarDate`; minimum not after maximum. |
| `PageResult<T>` | `items: List<T>`, `page: int`, `totalPages: int`, `totalResults: int`, `requestKey: RequestKey`, optional `releaseWindow: ReleaseWindow`. Raw provider totals are not a count of eligible displayed items. |
| `TrendingSelection` | `items: List<MovieSummary>`, `timeWindow: week`, `requestKey: RequestKey`; optional provider page/totals for diagnostics only. `canContinue` is always false under the current documented contract. |
| `RecommendationSource` | `kind: general or favoriteSeed`, optional `seedMovieId` and `seedTitle` required for favoriteSeed. Actual displayed source is carried alongside the page. |
| `FavoriteMovieSnapshot` | `movieId: int`, `title: String`; optional `originalTitle`, `posterPath`, `backdropPath`, `releaseDate: CalendarDate`, `rating: TmdbRating`. Sufficient identifying metadata without a network read. |
| `FavoriteEntry` | `movie: FavoriteMovieSnapshot`, `addedOrder: int`, `addedAtUtc: DateTime`. Positive stable order. |
| `FavoritesBaseline` | `entries: List<FavoriteEntry>`, `lastAddedOrder: int`; entries descending by order, high-water mark at least every stored order. |
| `FavoriteWriteCommand` | `intentRevision: int`, `movieId: int`, `desiredEntry: FavoriteEntry?`; null means remove. Entry identity must equal movieId. Desired-state writes are queued; no HTTP writes. |
| `PersistenceAck` | `intentRevision: int`, `movieId: int`, `storedEntry: FavoriteEntry?`, `committedAtUtc: DateTime`. Emitted only after successful transaction. |
| `AppFailure` | `kind`, `operation`, `requestKey: RequestKey?`, `occurredAtUtc: DateTime`, `retryAllowed: bool`; optional `retryNotBeforeUtc`, `httpStatus`, `providerCode`, `intentRevision`. Safe localized copy derives from kind and operation. |
| `Outcome<T>` | Tagged immutable union: success(data), failure(AppFailure), cancelled. Cancellation is silent in the UI. Generic JSON factories take explicit T encoders/decoders; union discriminator is `type`. |

UTC instants serialize as ISO-8601 strings with `Z`; `Uri` uses a validating converter. Generic `PageResult<T>` and `Outcome<T>` use Freezed/JSON generic argument factories. Enum decoding accepts an explicit unknown case where future provider values are retained; it never silently changes an unknown video type into Trailer.

ViewModel state remains feature-owned. Each section carries requested key, displayed key/data, generation, loading/refresh/continuation state, last failure, and next-page availability. Page-entry identity belongs to presentation state, not `MovieSummary`. The app-scoped Undo state holds the removed entry snapshot, removal intent revision/token, and a five-second monotonic deadline; it is not stored in SQLite or restored from JSON after restart.

## 6. Provider DTO mapping and response validation

`movies_data` owns endpoint-specific Freezed/JSON DTOs: movie list item/page, dated movie page, movie details, credits, person details, person movie credits, movie/person images, review page, video list, collection/parts, genres, configuration, and TMDB error payload. They have explicit snake_case mappings and do not reuse a detail DTO as a list item. Generated `fromJson` is followed by semantic validation and domain mapping. The list-item genre_ids property becomes MovieSummary.genreIds; movie details derives those IDs from its genres objects. An absent optional genre list becomes an empty list without inventing names.

| Input condition | Mapping |
| --- | --- |
| Unknown extra JSON key | Ignore it; forward-compatible DTO decoding. |
| Missing/null/blank optional artwork or text | Map to null. Unknown names/dates are not fabricated. |
| Missing required object identity, wrong structural type, absent required result array, invalid page metadata, or returned entity ID differing from requested ID | Typed invalid-data failure for that resource. A genuinely empty required array is `[]`, not a missing field. |
| Display title missing | Try nonblank original title. If both are absent, invalid-data; do not save an unidentified Library row. |
| Optional number out of range, nonfinite, or runtime nonpositive | Unavailable optional value plus safe diagnostic, not a zero-valued fact. |
| Invalid/blank optional calendar date | Null with safe diagnostic. Valid date-only values remain calendar dates. |
| Optional lists in detail object, such as genres/aliases, absent or null | Empty optional list. Mandatory endpoint result arrays still follow structural validation above. |
| Collection part title shape differs | Endpoint-specific part DTO accepts `title` then `name`, and `original_title` then `original_name`. Exclude explicit non-movie media types. Missing media_type is accepted only as the legacy movie-collection shape, with otherwise valid movie identity/title. |
| Adult movie flag true | Filter from returned lists or content-unavailable failure for direct details; never silently replace it with another movie. |
| Successful HTTP status with a documented failure-shaped payload | Map its provider error; do not treat it as a successful empty result. Unknown malformed failure/success payloads become invalid-data. |

The current [TMDB OpenAPI](https://developer.themoviedb.org/openapi/tmdb-api.json) contains incomplete nullable/schema annotations, including collection-part and review-author differences. Runtime validators therefore follow these deliberate rules rather than assuming every field in an example is always non-null.

## 7. Illustrative JSON payloads

These are **synthetic TMDB-shaped 200-response fixtures**, not observed live responses. Stage 2's IDs must not be sent to live TMDB as if they were verified records. The sample artwork filenames below resolve only through the fixture artwork adapter. Production uses provider paths. Additional optional provider fields are omitted intentionally; required fields for the consuming DTO are shown.

### 7.1 Movie page: Now Playing

```json
{
  "dates": {"minimum": "2026-01-01", "maximum": "2026-01-31"},
  "page": 1,
  "results": [
    {
      "id": 900001,
      "title": "Northbound",
      "original_title": "Northbound",
      "overview": "A traveler returns home and follows an unexpected connection.",
      "adult": false,
      "poster_path": "/fixture-northbound-poster.jpg",
      "backdrop_path": "/fixture-northbound-backdrop.jpg",
      "release_date": "2026-01-09",
      "genre_ids": [18],
      "original_language": "en",
      "vote_average": 7.8,
      "vote_count": 1250,
      "popularity": 42.0
    }
  ],
  "total_pages": 2,
  "total_results": 2
}
```

The fixture page deliberately contains one item to exercise continuation; the app does not assume a fixed provider page size. Search, Popular, Top Rated, Similar, and expected Recommendations use the same page envelope without `dates`. A successful empty page uses `results: []`; preserve the returned pagination metadata. Upcoming uses the dated-page shape with its own supplied window. Trending is decoded as its own selection contract without issuing another page request.

### 7.2 Movie details and cast

Movie `/movie/900002`:

```json
{
  "id": 900002,
  "title": "Afterlight",
  "original_title": "Afterlight",
  "overview": "An unexpected meeting changes a journey.",
  "adult": false,
  "poster_path": "/fixture-afterlight-poster.jpg",
  "backdrop_path": null,
  "release_date": "2025-10-10",
  "original_language": "en",
  "vote_average": 8.0,
  "vote_count": 800,
  "genres": [{"id": 18, "name": "Drama"}],
  "runtime": 112,
  "status": "Released",
  "tagline": null,
  "belongs_to_collection": {"id": 920001, "name": "Afterlight Collection", "poster_path": null, "backdrop_path": null}
}
```

Credits `/movie/900001/credits`:

```json
{
  "id": 900001,
  "cast": [
    {"id": 910001, "name": "Maya Reed", "profile_path": "/fixture-maya.jpg", "known_for_department": "Acting", "character": "Alex", "credit_id": "fixture-cast-001", "order": 0}
  ],
  "crew": []
}
```

### 7.3 Person, filmography, and collection

Person `/person/910001`:

```json
{
  "id": 910001,
  "name": "Maya Reed",
  "profile_path": "/fixture-maya.jpg",
  "biography": "A fictional performer used in controlled acceptance journeys.",
  "known_for_department": "Acting",
  "also_known_as": [],
  "birthday": null,
  "deathday": null,
  "place_of_birth": null
}
```

Filmography `/person/910001/movie_credits`:

```json
{
  "id": 910001,
  "cast": [
    {"id": 900002, "title": "Afterlight", "original_title": "Afterlight", "adult": false, "genre_ids": [18], "release_date": "2025-10-10", "poster_path": "/fixture-afterlight-poster.jpg", "vote_average": 8.0, "vote_count": 800, "character": "Jordan", "credit_id": "fixture-cast-002"}
  ],
  "crew": []
}
```

Collection `/collection/920001`:

```json
{
  "id": 920001,
  "name": "Afterlight Collection",
  "overview": "A fictional connected movie collection.",
  "poster_path": null,
  "backdrop_path": null,
  "parts": [
    {"id": 900002, "name": "Afterlight", "original_name": "Afterlight", "media_type": "movie", "adult": false, "genre_ids": [18], "release_date": "2025-10-10", "poster_path": "/fixture-afterlight-poster.jpg", "vote_average": 8.0, "vote_count": 800},
    {"id": 900003, "name": "Afterlight Again", "original_name": "Afterlight Again", "media_type": "movie", "adult": false, "genre_ids": [18], "release_date": "2026-06-12", "poster_path": null, "vote_average": 0, "vote_count": 0}
  ]
}
```

Northbound (`900001`) is the journey entry and credits Maya; Maya's filmography supplies Afterlight (`900002`), which supplies collection `920001`. The fixture set also defines Quiet Harbor (`900004`) with absent art/rating/collection and empty optional resources, Ember (`900005`) for query isolation, and the collection's Afterlight Again (`900003`). Their full fixture files are created during implementation, not silently sourced from live IDs.

### 7.4 Optional resources

Movie images response:

```json
{
  "id": 900001,
  "backdrops": [{"file_path": "/fixture-northbound-backdrop.jpg", "width": 1280, "height": 720, "aspect_ratio": 1.777778, "iso_639_1": null}],
  "posters": [{"file_path": "/fixture-northbound-poster.jpg", "width": 500, "height": 750, "aspect_ratio": 0.666667, "iso_639_1": "en"}]
}
```

Person images use `id` and a `profiles` array with equivalent image entries. Video candidates response:

```json
{
  "id": 900001,
  "results": [
    {"id": "fixture-video-001", "name": "Northbound trailer fixture", "key": "AbCdEfGh123", "site": "YouTube", "type": "Trailer", "official": true, "published_at": "2026-01-01T12:00:00Z", "iso_639_1": "en", "iso_3166_1": "US"}
  ]
}
```

The synthetic video key is intercepted by the simulated gateway in both the fixture app and automated tests; it is not represented as a real published trailer. Review page:

```json
{
  "id": 900001,
  "page": 1,
  "results": [
    {"id": "fixture-review-001", "author": "Fixture reviewer", "author_details": {"rating": 8.0, "avatar_path": null}, "content": "A fictional review for a controlled UI check.", "created_at": "2026-01-10T12:00:00Z", "updated_at": "2026-01-10T12:00:00Z"}
  ],
  "total_pages": 1,
  "total_results": 1
}
```

Configuration DTO expects an `images` object containing `secure_base_url`, `poster_sizes`, `backdrop_sizes`, and `profile_sizes`; genre DTO expects `genres` entries with integer `id` and string `name`. Neither failure blocks already available text or local favorites.

## 8. Artwork, reviews, and external-link contracts

Construct image URLs from the validated configuration base, a supported size, and a valid provider file path. Prefer a configured width sufficient for logical size × device pixel ratio, with reasonable caps: posters up to w500, backdrops up to w1280, profiles up to w342 when those sizes are advertised; otherwise choose an advertised suitable alternative. Avoid `original` for ordinary thumbnails. A file path is a provider-relative image path, not an arbitrary URL, traversal, or executable scheme. Image failures use placeholders; no token is sent. Follow [TMDB image construction](https://developer.themoviedb.org/docs/image-basics).

Fetch configuration independently and cache it in memory; a failed initial configuration produces artwork placeholders and a recoverable artwork/configuration Retry in the affected surface, not a failure of all movie text. Successfully loaded configuration can continue serving already visible images during a refresh failure. Genre lookup likewise cannot erase successfully loaded titles; show only genre names actually available.

Movie imagery requests explicitly include English and language-neutral images. Person imagery has no language query. Review content renders as selectable/readable plain text; do not execute provider HTML, automatically launch embedded links, or require reviewer avatars. TMDB avatar fields are not uniformly ordinary image paths, so avatars are omitted in this release.

The first release supports **YouTube trailer links**. Accept `site=YouTube`, `type=Trailer`, and an eleven-character ASCII key containing only letters, digits, hyphen, or underscore. Prefer official candidates, then latest known publication timestamp, then stable video ID. Do not silently use a teaser as a trailer. Construct `https://www.youtube.com/watch?v=<key>` with URI query encoding. The host gateway revalidates scheme, exact host, `/watch` path, and the allowed `v` parameter before launching; reject credentials in authority, unexpected ports/parameters, or arbitrary provider URLs. Unsupported/absent trailers and launch failure are distinct states. External browser launch leaves the movie route intact.

About/Credits links use fixed HTTPS TMDB destinations defined in the app, outside the trailer-candidate parser. No movie-homepage or review-supplied arbitrary URL is launched in this release.

## 9. Pagination, cache, and bounded networking

### 9.1 Page acceptance

Accept only the requested page for the same request key/generation. The provider page must be positive, totals nonnegative, and `results` a valid array. Permit `page=1, total_pages=0, results=[]` for a genuine empty collection. Other impossible metadata produces invalid-data rather than an infinite loop.

Append only after success, deduplicate movies by ID while preserving first occurrence, and advance the **provider** cursor even when adult filtering or duplicate removal leaves no new visible item. Do not mistake a filtered-empty page for exhaustion. Stop when the provider's final page is reached or page 500 is reached; the [TMDB errors reference](https://developer.themoviedb.org/docs/errors) documents the page ceiling. A later malformed/failed page retains earlier cards and the unadvanced cursor. Provider totals remain diagnostic; do not present raw totals as an exact eligible-card count.

For an all-filtered first page with more provider pages, show an honest “No eligible titles on this page” state with an accessible Load more action instead of claiming the whole source is empty. Avoid automatic unbounded page draining to fill a shelf. Complete cast, filmography, image, and collection resources may virtualize rendering locally but never issue invented page requests.

### 9.2 Cache and request ownership

Use a bounded memory LRU cache of at most 128 successful mapped resource entries: list/search/related/recommendation reads for five minutes; movie/person/details/credits/galleries/collections for fifteen minutes; image configuration and genres for twenty-four hours. Inject a monotonic clock. These are proposed app defaults, not TMDB freshness guarantees.

Cache keys include data mode, endpoint operation, ID/query/category/seed, language, applicable region, filters/adult-policy version, and provider page. Each page ViewModel still has its own generation and displayed/requested identity. Cache eviction does not erase rendered data or a branch's back stack. No disk catalog cache or offline-catalog promise is introduced.

Normal reads may use fresh cache. Explicit Refresh/Retry bypasses successful cache for the failed target. Do not cache errors as successful emptiness. Start with independent cancellable reads rather than coalescing an in-flight request whose cancellation could disrupt another page owner; coalescing is unnecessary for the first release. API/network concurrency is limited to four requests, with cancelled queued work removed before it starts.

### 9.3 Timeout, retry, and rate-limit policy

- Dio connect timeout: five seconds; send timeout: five seconds; receive timeout: ten seconds. A logical read has a twenty-five-second absolute deadline, including queue time, attempts, and backoff; deadline expiry cancels the active token. This bounds a slow response even if chunks keep arriving.
- At most **one automatic retry**, for transient connection/timeout failure or HTTP 500/502/503/504, while owner, generation, and deadline remain valid. Delay uses bounded 300–800 ms jitter. Never automatically retry authentication, invalid parameters, 404, invalid-data mapping, local writes, or user cancellation.
- HTTP 429 becomes rateLimited immediately. Respect a valid `Retry-After` delta or HTTP date; if absent/unusable, use a thirty-second cooldown. A shared API cooldown prevents other queued requests from immediately repeating the burst. Retry is unavailable until that time, and becomes a deliberate user action; no infinite wait/retry loop.
- Cancellation and superseded responses are silent. Check both cancellation and generation before applying success, failure, continuation, or side effects.

TMDB says rate ceilings can change; do not hardcode an advertised requests-per-second allowance as a guarantee. See [rate-limit guidance](https://developer.themoviedb.org/docs/rate-limiting).

## 10. Standardized application failures

TMDB errors and Dio/SQLite exceptions map to **the app's** `AppFailure`; TMDB is not expected to return our schema. Provider payloads can contain `status_code`, `status_message`, and `success`. Keep codes/status for safe diagnostics, never display raw headers, credential-bearing requests, or stack traces.

| Failure kind | Trigger | Recovery policy |
| --- | --- | --- |
| configuration | Missing/invalid live config | Catalog-unavailable message; local Library and tabs work. Developer fixes local config; no secret-entry product flow. |
| authentication | HTTP 401/403 or recognized authentication provider code | No automatic retry; preserve prior content and local access. |
| network / timeout | Connection/DNS failure / bounded deadline | One permitted automatic retry, then visible Retry. Do not infer a permanent offline state from one failure. |
| rateLimited | HTTP 429 | Explain temporary limit; cooldown as above. |
| notFound | HTTP 404 / recognized missing resource | Navigable unavailable entity; never silently delete a local favorite. No automatic retry. |
| invalidRequest | HTTP 400/405/406/422 or locally invalid ID/query/page | No automatic retry; safe error with Back/tabs. |
| server | Other provider service failures | Bounded retry for listed transient statuses; otherwise a visible deliberate Retry where meaningful. |
| invalidData | Structural/identity/schema failure | No automatic retry; explicit Retry permitted for provider changes, retained content stays correctly attributed. |
| contentUnavailable | Explicitly excluded adult movie | No automatic retry; Back/tabs work. |
| storageRead / storageWrite / storageMigration | Drift opening/read/write/migration failure | Non-destructive Retry; mutation rollback follows revision rules. No database reset masquerading as recovery. |
| externalLink | Invalid/unsupported destination or launcher failure | Explain and retain the current page; do not retry a launch automatically. |

Illustrative provider error, redacted and paraphrased:

```json
{"success": false, "status_code": 7, "status_message": "API credential was rejected."}
```

Corresponding application failure JSON; the timestamp is supplied by the client clock, not asserted as a TMDB field:

```json
{
  "kind": "authentication",
  "operation": "movie.details",
  "requestKey": {"mode": "live", "operation": "movie.details", "entityId": 693134, "language": "en-US", "filters": {"adultPolicy": "excludeFlagged-v1"}},
  "occurredAtUtc": "2026-11-01T12:00:00Z",
  "retryAllowed": false,
  "httpStatus": 401,
  "providerCode": 7
}
```

Every completion checks resource identity and generation, including failed requests and continuations. A failed new Search query retains old results only with their old-query label; it attaches the error and Retry to the attempted query. Apply the same separation to categories, entities, and recommendation seeds.

## 11. Drift favorites schema and mutation contract

Database version is 1. `movies.sqlite` is live Library storage; `movies_fixture.sqlite` isolates explicit fixture development. Tests inject an in-memory database or fake repository. The database is application-private; no network is needed to read, remove, or restore a saved entry.

| Table / column | SQLite representation and constraint |
| --- | --- |
| `favorites.movie_id` | INTEGER primary key, positive. |
| `title` | TEXT not null, nonblank. |
| `original_title`, `poster_path`, `backdrop_path` | Nullable TEXT; validated metadata snapshots. |
| `release_date` | Nullable TEXT, validated `YYYY-MM-DD`. |
| `vote_average`, `vote_count` | Nullable REAL / INTEGER; both null when no valid rating; otherwise 0–10 and positive count. |
| `added_order` | INTEGER not null, positive and unique; Library sorts descending. |
| `added_at_utc` | INTEGER UTC epoch milliseconds, not null; display/diagnostics, not ordering. |
| `favorites_meta.singleton_id` | INTEGER primary key constrained to 1. |
| `favorites_meta.last_added_order` | INTEGER not null, nonnegative persistent high-water mark. |

Initialize metadata at zero only for a genuinely new database. Read entries and metadata consistently. If metadata is missing/corrupt in an existing database, expose storage failure rather than invent an empty baseline. New versions need explicit non-destructive migrations and exported schema history; never drop/recreate the Library to clear an error.

**Ordering:** the shared favorites owner reserves increasing orders above the loaded high-water mark. An ordinary add of an absent movie gets a new order/time; adding an already favorite movie is idempotent and preserves its order. A later explicit re-add after removal moves it to the front. Undo reuses the removed snapshot's original order/time, preserving its prior relative position while newer additions stay ahead. Do not allocate using only `max(current rows)+1`: removing the highest row must not allow its order to collide with a new add before Undo.

**Writes:** one repository FIFO serializes desired-state commands. An add/restore transaction upserts the requested entry and advances metadata to at least that order; removal deletes only that ID and leaves the high-water mark intact. Acknowledgement includes intent revision and movie identity after commit. All transaction work is awaited; no network requests or Undo timers run inside it. [Drift transaction semantics](https://drift.simonbinder.eu/dart_api/transactions/) support the atomic row/metadata update.

The shared ViewModel projects confirmed state plus ordered pending intents. A success advances only that intent's confirmed result. A failure removes the failed intent and recomputes that movie from confirmed state plus valid later intents; it does not replace the entire Library from an old snapshot. No automatic database-write retry is added. A user Retry, if still meaningful, is a fresh intent with current revision checks and cannot reverse a newer same-movie action.

Do not accept mutations until an initial successful baseline read includes both rows and order metadata. An authoritative reload waits for a quiescent write queue; its generation/revision must still match before applying. Concurrent tab views observe the same projection, never separate SQL-backed favorite sets.

Removal persists immediately through the queue, without waiting for Undo expiry. A valid Undo enqueues a new restore command using the removed snapshot. Expiry, backgrounding, termination, a newer removal offer, or superseding same-movie intent invalidates its token. Tab changes do not invalidate or renew it. Failed removal invalidates its now-irrelevant offer; failed Undo restores the last confirmed state with an actionable error. Pending intents/Undo are in memory only. Restart loads the committed database state; acknowledged writes, not uncompleted UI actions, are durable.

## 12. Repository interfaces and ownership

Public contracts live under `movies_core/lib/domain/` and return `Future<Outcome<T>>`. Cancel handles/clock/read-policy types are framework-neutral; no Dio token, SQL row, Riverpod object, or widget appears in them. Catalog read options carry `cacheFirst` or explicit `refresh`, request context, and owner cancellation.

| Contract | Operations and result types |
| --- | --- |
| `DiscoveryRepository` | `getNowPlaying(page)`, `getUpcoming(page)`, `getPopular(page)`, `getTopRated(page)` → `PageResult<MovieSummary>`; `getTrending()` → `TrendingSelection`; `getRecommendations(movieId, page)` → `PageResult<MovieSummary>`; `getGenres()` → `List<Genre>`. |
| `MovieRepository` | `searchMovies(query, page)` → `PageResult<MovieSummary>`; `getMovie(movieId)` → `MovieDetails`; `getCredits(movieId)` → `MovieCredits`; `getImages(movieId)` → `ImageGallery`; `getReviews(movieId, page)` → `PageResult<MovieReview>`; `getTrailers(movieId)` → `List<TrailerLink>`; `getRelatedMovies(movieId, page)` → `PageResult<MovieSummary>`; `getCollection(collectionId)` → `MovieCollection`. |
| `PersonRepository` | `getPerson(personId)` → `PersonDetails`; `getFilmography(personId)` → `PersonFilmography`; `getImages(personId)` → `ImageGallery`. |
| `ArtworkConfigurationRepository` | `getConfiguration()` → `ImageConfiguration`; image URL resolution uses validated config and path/size, not an arbitrary supplied URL. |
| `FavoritesRepository` | `readBaseline()` → `FavoritesBaseline`; `apply(FavoriteWriteCommand)` → `PersistenceAck`. Own FIFO writes; baseline reads follow the queue barrier. No automatic external enrichment or second public favorites projection. |
| `ExternalLinkGateway` | `openTrailer(TrailerLink)` and `openAttributionLink(approved destination)` → success/failure/cancelled outcome. Host implementation validates then calls the launcher; tests replace it. |

`movies_data` implements catalog and storage contracts and contains DTO mapping/cache/fakes. `catalog_feature` publishes abstract repository providers and owns the shared favorites controller; `apps/app` supplies live or fixture overrides and owns the external-link adapter. Home owns seed/fallback presentation logic using DiscoveryRepository and the shared favorites projection. This preserves Stage 3's dependency graph.

## 13. Serialization, generation, and handoff checks

Use approved Freezed/JSON annotations and generated `.freezed.dart` / `.g.dart` files. Nested domain values serialize explicitly, optional fields remain nullable, and converters cover calendar dates, UTC instants, and validated URIs. Domain JSON does not become an alternative source of live truth or a serialized API credential container. Configuration/token holders are not catalog entities and must not expose generated secret-bearing debug/JSON output.

During implementation, from each package that owns generated models/database code, run `dart run build_runner build --delete-conflicting-outputs`. Do not assume running from the workspace root generates every member. `movies_core` owns shared entity generation; `movies_data` owns DTO/Drift generation; features generate their own Freezed state when used. Generate localizations separately as approved in Stage 3. Commit generated files with declarations and never hand-edit them. See [the pinned Freezed documentation](https://pub.dev/packages/freezed/versions/3.2.5).

Before real integration is called complete, verify an authenticated response for every consumed endpoint shape, including Recommendations and collection title/name mapping; verify missing optional fields, empty results, adult filtering, and the documented Trending limitation. Live smoke checks use actual provider IDs, not narrative-fixture IDs. Deterministic tests use the controlled graph, a controllable clock/cancellation, and injected network/storage/launcher failures; Stage 6 specifies their allocation and thresholds.

This document defines contracts without creating source files, fixture assets, database tables, config files, dependencies, or a Flutter app. Specification validation proves document structure and example JSON syntax only; it does not prove API credentials, resolver compatibility, code generation, persistence, networking, or simulator execution.

**Approval record:** the developer reviewed this document and replied “approved” on November 1, 2026. Stage 6 discovery is unlocked. Stages 6–7 and Flutter scaffolding remain pending.

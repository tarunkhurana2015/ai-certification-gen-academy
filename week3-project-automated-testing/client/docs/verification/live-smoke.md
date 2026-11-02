# Authenticated TMDB verification

Status: **notRun — no local TMDB token has been configured.** No simulated response or Demo link is counted as provider evidence.

Configure the ignored local JSON file as described in README and run live mode. A bounded smoke should verify image configuration, genres, Now Playing, Upcoming, Popular, Top Rated, weekly movie Trending, search, movie details/credits/images/reviews/videos/recommendations/similar, person details/movie credits/images, and a supplied collection. Use IDs from current real responses, not fixture IDs or fixed rankings. Empty optional resources must remain honest; use another supplied movie when a connected rich path is needed.

Confirm live artwork, adult exclusion, TMDB score/scale/vote provenance, correct provider pagination, and recovery without Demo substitution. Do not deliberately trigger rate limits. Record safe status categories and Retry outcomes, never headers/token/config contents.

N3: open a real supplied allowed YouTube trailer through the native launcher, return to the same movie context, and record failed/unsupported-launch recovery separately. **notRun** until actual provider and native browser evidence exists.

Fast CI and deterministic external-link tests do not establish these checks. The full client delivery definition remains open until authenticated verification is performed.

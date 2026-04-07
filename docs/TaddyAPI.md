# ClipCast — Taddy API Seeding Strategy

> Defines how the Taddy GraphQL API seeds the `podcasts`, `episodes`,
> `trending_podcasts`, and related tables so new users see a populated app on first
> launch.  
> Last updated: 2025-06-29

---

## Table of Contents

1. [Why Taddy](#1-why-taddy)
2. [API Overview](#2-api-overview)
3. [Authentication](#3-authentication)
4. [Pricing & Budget](#4-pricing--budget)
5. [Data Mapping — Taddy → Supabase](#5-data-mapping--taddy--supabase)
6. [Seeding Phases](#6-seeding-phases)
7. [Cron Jobs (Scheduled Edge Functions)](#7-cron-jobs-scheduled-edge-functions)
8. [Client-Side Integration](#8-client-side-integration)
9. [GraphQL Queries](#9-graphql-queries)
10. [Error Handling & Rate Limiting](#10-error-handling--rate-limiting)
11. [Caching Strategy](#11-caching-strategy)
12. [Fallback Strategy](#12-fallback-strategy)
13. [Migration from PodcastIndex References](#13-migration-from-podcastindex-references)

---

## 1. Why Taddy

| Criterion | Taddy | PodcastIndex | Listen Notes |
|-----------|-------|-------------|-------------|
| Index size | 4M+ podcasts, 200M+ episodes | 4M+ podcasts | 3M+ podcasts |
| API style | **GraphQL** (request exactly what you need) | REST | REST |
| Search | Full-text, sort by EXACTNESS or POPULARITY | Full-text | Full-text |
| Top charts | Apple Podcasts charts by country & genre | Community trending | Curated |
| Episode transcripts | ✅ (Pro: 100/mo, Business: 2000/mo) | ❌ | ❌ |
| Webhooks | ✅ (Business plan) | ❌ | ❌ |
| Chapters | ✅ | ✅ | ❌ |
| Popularity ranking | ✅ `popularityRank` field | ❌ | Partial |
| Cached responses | **Free** (don't count against quota) | N/A | N/A |
| Free tier | 500 req/mo | Unlimited (donation) | 300 req/mo |
| Paid tier (scale) | Pro $75/mo → 100K req | Free | $29-$99+/mo |

**Decision:** Taddy is the **sole primary podcast data source** for ClipCast. Its GraphQL
API lets us fetch exactly the fields we need, reducing bandwidth. Built-in episode
transcripts can supplement our OpenAI Whisper pipeline. The `popularityRank` field
eliminates the need for separate trending calculations.

---

## 2. API Overview

| Property | Value |
|----------|-------|
| Endpoint | `https://api.taddy.org` (single GraphQL endpoint) |
| Protocol | POST with JSON body |
| Auth headers | `X-USER-ID` (numeric) + `X-API-KEY` (string) |
| Pagination | `page` (1-based, max 20) + `limitPerPage` (max 25) |
| Rate limit | Monthly quota (varies by plan) |
| Caching | Cached responses are free — don't count against quota |
| Content-Type | `application/json` |

### Key Queries

| Query | Purpose |
|-------|---------|
| `getPodcastSeries(name:)` | Get podcast by name (exact match) |
| `getPodcastSeries(uuid:)` | Get podcast by UUID |
| `search(term:, filterForTypes:)` | Full-text search for podcasts / episodes |
| `getTopChartsByCountry(taddyType:, country:)` | Daily Apple Podcasts top charts |
| `getTopChartsByGenres(taddyType:, genres:)` | Top charts filtered by genre |
| `getPopularContent(filterByLanguage:)` | Most popular podcasts overall |
| `getMultiplePodcastSeries(uuids:)` | Batch fetch multiple podcasts |
| `getLatestEpisodesFromMultiplePodcasts(uuids:)` | Latest episodes for a list of podcasts |
| `getApiRequestsRemaining` | Check remaining monthly quota |

---

## 3. Authentication

All Taddy API calls happen **server-side** via Supabase Edge Functions. API keys
never reach the client.

```
Headers:
  X-USER-ID: <Taddy numeric user id>
  X-API-KEY: <Taddy API key string>
  Content-Type: application/json
```

### Supabase Secrets

| Secret Name | Value | Where Used |
|-------------|-------|------------|
| `TADDY_USER_ID` | Numeric user ID from Taddy dashboard | Edge Functions |
| `TADDY_API_KEY` | API key from Taddy dashboard | Edge Functions |

Set via:
```bash
supabase secrets set TADDY_USER_ID=<value> TADDY_API_KEY=<value>
```

---

## 4. Pricing & Budget

### Plan Recommendation by Phase

| Phase | MAU | Taddy Plan | Monthly Cost | Requests Needed |
|-------|-----|-----------|-------------|-----------------|
| Phase 0-1 (Dev + MVP) | 0-100 | **Free** | $0 | <500 (mostly seeding crons) |
| Phase 2 (Beta) | 100-1K | **Pro** | $75 | ~10K-50K (search + browse) |
| Phase 3 (Launch) | 1K-10K | **Pro** | $75 | ~50K-100K |
| Phase 4 (Growth) | 10K-100K | **Business** | $150 | ~100K-350K |
| Scale | 100K+ | Custom | $250+ | 1M+ (contact Taddy) |

### Cost Optimisation Levers

1. **Aggressive caching:** Taddy's own caching doesn't count against quota. Cache
   results in Supabase for 6-24 hours to further reduce API calls.
2. **Server-side only:** All Taddy calls go through Edge Functions; clients never
   call Taddy directly. This lets us batch, de-duplicate, and cache.
3. **Cron-driven seeding:** Trending/popular data fetched on schedule (not per-user).
4. **Paginate wisely:** Fetch 25 items per page (max allowed) to minimise requests.

---

## 5. Data Mapping — Taddy → Supabase

### `podcasts` Table

| Supabase Column | Taddy Field | Notes |
|-----------------|-------------|-------|
| `id` | — | Auto-generated UUID |
| `external_id` | `uuid` | Taddy's UUID, used as dedup key |
| `title` | `name` | |
| `publisher` | `authorName` or `itunesInfo.publisherName` | |
| `artwork_url` | `imageUrl` or `itunesInfo.baseArtworkUrlOf(size:640)` | Prefer iTunes artwork for quality |
| `feed_url` | `rssUrl` | |
| `description` | `description` | Truncate to 2000 chars |
| `categories` | `genres[]` | Map Taddy Genre ENUMs → ClipCast categories |
| `episode_count` | `totalEpisodesCount` | |
| `source` | `'taddy'` | Hardcoded |
| `language` | `language` | Map Taddy Language ENUM |
| `last_synced_at` | — | Set to `now()` on insert/update |

### `episodes` Table

| Supabase Column | Taddy Field | Notes |
|-----------------|-------------|-------|
| `id` | — | Auto-generated UUID |
| `podcast_id` | — | FK to `podcasts.id` (looked up via `external_id`) |
| `external_id` | `uuid` | Taddy's episode UUID |
| `title` | `name` | |
| `description` | `description` | |
| `audio_url` | `audioUrl` | Direct file link for streaming |
| `duration` | `duration` | In seconds |
| `published_at` | `datePublished` | Epoch → `timestamptz` |
| `episode_number` | `episodeNumber` | Nullable |
| `season_number` | `seasonNumber` | Nullable |

### `trending_podcasts` Table

| Supabase Column | Taddy Source | Notes |
|-----------------|-------------|-------|
| `id` | — | Auto-generated |
| `podcast_id` | FK via `external_id` match | From `getTopChartsByCountry` |
| `rank` | Position in response array | 1-based |
| `region` | Country parameter used in query | e.g. `EGYPT`, `UNITED_STATES_OF_AMERICA` |
| `fetched_at` | — | Set to `now()` |

### Genre Mapping (Taddy → ClipCast)

The app has two distinct category surfaces drawn from the same genre pool:

#### Podcast Categories (7) — shown on the Podcasts page (588:46043)

These are the genre-based filters users see when browsing podcasts:

| # | ClipCast Category | Taddy Genre ENUMs |
|---|-------------------|-------------------|
| 1 | Business | `PODCASTSERIES_BUSINESS`, `PODCASTSERIES_BUSINESS_CAREERS`, `PODCASTSERIES_BUSINESS_INVESTING`, `PODCASTSERIES_BUSINESS_MARKETING`, `PODCASTSERIES_BUSINESS_MANAGEMENT`, `PODCASTSERIES_BUSINESS_NON_PROFIT`, `PODCASTSERIES_BUSINESS_ENTREPRENEURSHIP` |
| 2 | News & Current Affairs | `PODCASTSERIES_NEWS`, `PODCASTSERIES_NEWS_BUSINESS`, `PODCASTSERIES_NEWS_DAILY`, `PODCASTSERIES_NEWS_POLITICS`, `PODCASTSERIES_NEWS_TECH`, `PODCASTSERIES_NEWS_SPORTS` |
| 3 | Technology | `PODCASTSERIES_TECHNOLOGY` |
| 4 | Education | `PODCASTSERIES_EDUCATION` |
| 5 | Health & Wellbeing | `PODCASTSERIES_HEALTH_FITNESS` |
| 6 | Culture & Society | `PODCASTSERIES_SOCIETY_CULTURE` |
| 7 | Other | All genres not mapped above (catch-all) |

#### Browse All Tiles (9) — shown on the Search page (588:45886)

The Search screen's "Browse All" grid contains 9 tiles. The first 4 are **content-type
or curated sections** (not genre filters). The last 5 are **genre shortcuts** that
link to the same genre data as the Podcast Categories above.

| # | Tile | Type | Behaviour |
|---|------|------|-----------|
| 1 | Podcasts | Content type | Navigates to Podcasts sub-page (all podcasts) |
| 2 | Clips | Content type | Navigates to Clips sub-page (all public clips) |
| 3 | New Releases | Curated | Shows recently published episodes across all genres |
| 4 | Made For You | Curated | Personalised recommendations based on favourites + listening history |
| 5 | Technology | Genre shortcut | Filters by Technology genre |
| 6 | Education | Genre shortcut | Filters by Education genre |
| 7 | Health & Wellbeing | Genre shortcut | Filters by Health & Wellbeing genre |
| 8 | Culture & Society | Genre shortcut | Filters by Culture & Society genre |
| 9 | Other | Genre shortcut | Shows everything not in the 6 named genres |

---

## 6. Seeding Phases

### Phase 0 — Initial Seed (One-time, during development)

**Goal:** Populate the database so the app has content for testing and demo.

| Task | Query | Records | API Requests |
|------|-------|---------|-------------|
| Seed top 200 podcasts (global, English) | `getPopularContent` × 8 pages | ~200 podcasts | 8 |
| Seed top charts Egypt | `getTopChartsByCountry(EGYPT)` × 8 pages | ~200 podcasts | 8 |
| Seed top charts by genre (7 categories) | `getTopChartsByGenres` × 7 × 4 pages | ~700 podcasts | 28 |
| Fetch latest 10 episodes per podcast (~800 unique) | `getLatestEpisodesFromMultiplePodcasts` batched | ~8000 episodes | ~160 |
| **Total** | | ~900 podcasts, ~9000 episodes | **~204 requests** |

This fits within the **Free tier** (500 req/mo).

**Seed Script:** Supabase Edge Function `seed-initial` (manual trigger or via CLI).

### Phase 1 — Cron-driven Refresh (Ongoing)

See [Section 7](#7-cron-jobs-scheduled-edge-functions).

### Phase 2 — On-demand Client Fetches (User-driven)

See [Section 8](#8-client-side-integration).

---

## 7. Cron Jobs (Scheduled Edge Functions)

### 7.1 `cron-refresh-trending` — Every 6 hours

```
Schedule: 0 */6 * * *
Purpose:  Refresh trending_podcasts table with latest Apple top charts
Budget:   ~16 requests/day = ~480/mo
```

**Logic:**
1. Query `getTopChartsByCountry(PODCASTSERIES, EGYPT)` — 4 pages × 25 = 100 podcasts
2. Query `getTopChartsByCountry(PODCASTSERIES, UNITED_STATES_OF_AMERICA)` — 4 pages
3. UPSERT podcasts into `podcasts` table (match on `external_id`)
4. DELETE + INSERT into `trending_podcasts` for each region
5. Log request count to monitoring

### 7.2 `cron-refresh-episodes` — Every 12 hours

```
Schedule: 0 */12 * * *
Purpose:  Fetch latest episodes for all tracked podcasts
Budget:   Varies by podcast count (batch 25 UUIDs per request)
```

**Logic:**
1. SELECT `external_id` FROM `podcasts` WHERE `last_synced_at < now() - interval '12 hours'`
2. Batch into groups of 25
3. Query `getLatestEpisodesFromMultiplePodcasts(uuids:[...])` per batch
4. UPSERT episodes into `episodes` table (match on `external_id`)
5. UPDATE `podcasts.last_synced_at` and `podcasts.episode_count`

### 7.3 `cron-refresh-popular` — Daily

```
Schedule: 0 3 * * *
Purpose:  Refresh popular/recommended podcasts for Browse categories
Budget:   ~30 requests/day = ~900/mo (needs Pro plan once live)
```

**Logic:**
1. For each of the 7 ClipCast categories (Business, News & Current Affairs, Technology, Education, Health & Wellbeing, Culture & Society, Other), query `getPopularContent(filterByGenres:[...])` — 2 pages each (14 requests)
2. Query `getPopularContent(filterByLanguage:ARABIC)` — 2 pages
3. Fetch "New Releases" via `search(filterForPublishedAfter:<48h_ago>)` — 2 pages
4. UPSERT into `podcasts`
5. Update category associations
6. "Made For You" is computed per-user from favourites + listening history (no Taddy call)

### 7.4 Budget Summary (Cron only)

| Cron | Frequency | Requests/Run | Monthly Total |
|------|-----------|-------------|--------------|
| Trending | 4×/day | ~8 | ~240 |
| Episodes | 2×/day | ~40 (for 1000 podcasts) | ~2,400 |
| Popular | 1×/day | ~30 | ~900 |
| **Total** | | | **~3,540/mo** |

This requires the **Pro plan** ($75/mo, 100K requests).

---

## 8. Client-Side Integration

The Flutter app **never calls Taddy directly**. All podcast data flows:

```
Flutter → Supabase (cached tables) → Edge Function → Taddy API
```

### 8.1 Search (On-demand, via Edge Function)

When a user types in the Search screen, the client calls an Edge Function:

```
POST /functions/v1/podcast-search
Body: { "term": "Modern Wisdom", "types": ["PODCASTSERIES"], "page": 1 }
```

**Edge Function logic:**
1. Check Supabase cache: SELECT from `podcasts` WHERE `title` ILIKE '%Modern Wisdom%'
2. If ≥10 results and `last_synced_at > now() - interval '1 hour'` → return cached
3. Else: call Taddy `search(term:..., filterForTypes:..., limitPerPage:25)`
4. UPSERT results into `podcasts` (and `episodes` if episodes were searched)
5. Return results to client

### 8.2 Podcast Detail (On-demand)

When user opens a podcast page:

```
POST /functions/v1/podcast-detail
Body: { "podcast_id": "<supabase uuid>" }
```

**Edge Function logic:**
1. SELECT from `podcasts` + `episodes` WHERE `podcast_id`
2. If `episodes` last synced > 1 hour ago: call Taddy `getPodcastSeries(uuid:)` with episodes
3. UPSERT new episodes
4. Return full podcast + episode list

### 8.3 Browse All (Search Page — 9 tiles)

The Search screen shows 9 "Browse All" tiles. The genre-based tiles (5-9) are
populated by the `cron-refresh-popular` job. The first 4 resolve differently:

| Tile | Data Source |
|------|-------------|
| Podcasts | `SELECT * FROM podcasts ORDER BY episode_count DESC LIMIT 25` |
| Clips | `SELECT * FROM clips WHERE is_public = true ORDER BY created_at DESC LIMIT 25` |
| New Releases | `SELECT e.* FROM episodes e JOIN podcasts p ON ... WHERE e.published_at > now() - interval '48 hours' ORDER BY e.published_at DESC LIMIT 25` |
| Made For You | `SELECT p.* FROM podcasts p JOIN podcast_favourites pf ON ... WHERE pf.user_id = auth.uid()` + algorithmic mix |
| Technology | `SELECT * FROM podcasts WHERE categories @> '{Technology}' ORDER BY episode_count DESC LIMIT 25` |
| Education | Same pattern, filtered by Education |
| Health & Wellbeing | Same pattern, filtered by Health & Wellbeing |
| Culture & Society | Same pattern, filtered by Culture & Society |
| Other | Same pattern, filtered by Other |

### 8.4 Podcast Categories (Podcasts Page — 7 tiles)

The Podcasts page shows all 7 genre categories (Business, News & Current Affairs,
Technology, Education, Health & Wellbeing, Culture & Society, Other). Each tile
links to a filtered podcast list:

```sql
SELECT * FROM podcasts
WHERE categories @> '{Technology}'
ORDER BY episode_count DESC
LIMIT 25;
```

### 8.4 Trending (Cached)

```sql
SELECT p.* FROM trending_podcasts tp
JOIN podcasts p ON p.id = tp.podcast_id
WHERE tp.region = 'EGYPT'
ORDER BY tp.rank ASC
LIMIT 25;
```

---

## 9. GraphQL Queries

### 9.1 Seed Top Podcasts

```graphql
{
  getPopularContent(filterByLanguage: ENGLISH, page: 1, limitPerPage: 25) {
    popularityRankId
    podcastSeries {
      uuid
      name
      description
      imageUrl
      rssUrl
      authorName
      totalEpisodesCount
      language
      genres
      itunesInfo {
        uuid
        baseArtworkUrlOf(size: 640)
        publisherName
      }
      popularityRank
    }
  }
}
```

### 9.2 Top Charts by Country

```graphql
{
  getTopChartsByCountry(
    taddyType: PODCASTSERIES
    country: EGYPT
    page: 1
    limitPerPage: 25
  ) {
    topChartsId
    podcastSeries {
      uuid
      name
      imageUrl
      description
      totalEpisodesCount
      genres
      itunesInfo {
        baseArtworkUrlOf(size: 640)
      }
    }
  }
}
```

### 9.3 Top Charts by Genre

```graphql
{
  getTopChartsByGenres(
    taddyType: PODCASTSERIES
    genres: [PODCASTSERIES_TECHNOLOGY]
    page: 1
    limitPerPage: 25
  ) {
    topChartsId
    podcastSeries {
      uuid
      name
      imageUrl
      genres
    }
  }
}
```

### 9.4 Search Podcasts

```graphql
{
  search(
    term: "Modern Wisdom"
    filterForTypes: PODCASTSERIES
    sortBy: POPULARITY
    limitPerPage: 25
  ) {
    searchId
    podcastSeries {
      uuid
      name
      description
      imageUrl
      totalEpisodesCount
      genres
    }
    responseDetails {
      totalResults
      totalPages
    }
  }
}
```

### 9.5 Search Episodes + Podcasts (Mixed)

```graphql
{
  search(
    term: "Elon Musk"
    filterForTypes: [PODCASTSERIES, PODCASTEPISODE]
    sortBy: POPULARITY
    limitPerPage: 25
  ) {
    searchId
    podcastSeries {
      uuid
      name
      imageUrl
    }
    podcastEpisodes {
      uuid
      name
      description
      audioUrl
      duration
      datePublished
      podcastSeries {
        uuid
        name
      }
    }
  }
}
```

### 9.6 Fetch Episodes for Multiple Podcasts

```graphql
{
  getLatestEpisodesFromMultiplePodcasts(
    uuids: ["uuid1", "uuid2", "uuid3"]
  ) {
    uuid
    name
    description
    audioUrl
    duration
    datePublished
    episodeNumber
    seasonNumber
    podcastSeries {
      uuid
    }
  }
}
```

### 9.7 Check Remaining API Requests

```graphql
{
  getApiRequestsRemaining
}
```

---

## 10. Error Handling & Rate Limiting

### Taddy Error Codes

| Code | Meaning | Action |
|------|---------|--------|
| `API_KEY_INVALID` | Bad credentials | Alert team, check Supabase secrets |
| `API_RATE_LIMIT_EXCEEDED` | Monthly quota exhausted | Switch to cached-only mode, alert team |
| `INVALID_QUERY_OR_SYNTAX` | Malformed query | Log, fix query template |
| `BAD_USER_INPUT` | Invalid argument | Log, validate inputs before calling |
| `QUERY_TOO_COMPLEX` | Too many nested fields | Simplify query |
| `TADDY_SERVER_ERROR` | Taddy is down | Retry with exponential backoff (3 retries) |

### Rate Limit Monitoring

```sql
-- Track API usage in a monitoring table
CREATE TABLE IF NOT EXISTS taddy_api_log (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  edge_fn     text NOT NULL,           -- Which Edge Function made the call
  query_type  text NOT NULL,           -- 'search', 'topCharts', 'popular', etc.
  created_at  timestamptz DEFAULT now()
);

-- Query monthly usage
SELECT count(*) FROM taddy_api_log
WHERE created_at > date_trunc('month', now());
```

### Automatic Degradation

When `getApiRequestsRemaining` returns < 10% of quota:
1. Increase cache TTLs from 1h to 24h
2. Disable on-demand search (return cached results only)
3. Send alert to team via Slack/email

---

## 11. Caching Strategy

### Two-Layer Cache

| Layer | Storage | TTL | Purpose |
|-------|---------|-----|---------|
| **L1 — Taddy built-in** | Taddy CDN | Automatic | Cached responses are free (don't count against quota) |
| **L2 — Supabase tables** | Postgres | Configurable | Long-term storage, powers client queries |

### Cache TTLs by Data Type

| Data Type | Table | TTL | Rationale |
|-----------|-------|-----|-----------|
| Trending podcasts | `trending_podcasts` | 6 hours | Refreshed by cron |
| Popular podcasts | `podcasts` (flagged) | 24 hours | Refreshed by daily cron |
| Podcast metadata | `podcasts` | 24 hours | Stable data, infrequent changes |
| Episode list | `episodes` | 12 hours | Refreshed by cron |
| Search results | `podcasts` + `episodes` | 1 hour | On-demand, more dynamic |

### Cache Invalidation

- **Cron-driven:** Cron jobs overwrite stale data with fresh Taddy responses.
- **On-demand:** Edge Functions check `last_synced_at` before calling Taddy.
- **Manual:** Admin can trigger a full refresh via `seed-initial` Edge Function.

---

## 12. Fallback Strategy

If Taddy becomes unavailable or rate-limited:

| Scenario | Fallback |
|----------|----------|
| Taddy API down | Serve from Supabase cache (stale but functional) |
| Rate limit exceeded | Cache-only mode until next billing cycle |
| Podcast not in Taddy index | Parse RSS feed directly (`feed_url` stored in `podcasts`) |
| Episode audio URL broken | Surface error to user; background job retries via RSS |

### RSS Fallback

The `podcasts.feed_url` column stores the RSS URL from Taddy's `rssUrl` field.
If Taddy is unavailable, an Edge Function can parse RSS XML directly to:
1. Fetch new episodes
2. Get audio URLs
3. Update episode metadata

This is a last-resort and not the primary data path.

---

## 13. Migration from PodcastIndex References

The original ARCHITECTURE.md referenced PodcastIndex as the primary API. The
following sections need updating:

| Section | Change |
|---------|--------|
| 9.3 Recommendation | Replace PodcastIndex → Taddy as primary |
| 9.4 Cost Analysis | Update with Taddy pricing tiers |
| 9.5 Spike Required | Replace with Taddy-specific verification steps |
| 10.1 Initial Data Seeding | Replace PodcastIndex endpoints → Taddy queries |
| 10.2 Webhook Architecture | Note: Taddy webhooks available on Business plan |
| ERD `podcasts.source` | Default value: `'taddy'` (already updated in ERD.md) |

### Updated Spike Checklist

- [ ] Register Taddy developer account and get API key
- [ ] Test `search`, `getPopularContent`, `getTopChartsByCountry` from Supabase Edge Function
- [ ] Verify `audioUrl` fields return direct streaming URLs (not redirects requiring auth)
- [ ] Test pagination with `limitPerPage: 25` across all query types
- [ ] Benchmark response times from Supabase Frankfurt → Taddy API
- [ ] Confirm cached responses don't count against quota (test with repeated queries)
- [ ] Run initial seed script and verify podcast/episode data integrity
- [ ] Test `getApiRequestsRemaining` for quota monitoring

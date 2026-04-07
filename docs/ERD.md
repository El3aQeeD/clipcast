# ClipCast — Entity-Relationship Document (ERD)

> Generated from `ARCHITECTURE.md` Section 11 + Figma HiFi + Lo-Fi wireframe analysis (all 90 designs reviewed).
> Last updated: 2025-07-17

---

## Table of Contents

1. [ENUM Types](#1-enum-types)
2. [Tables](#2-tables)
   - [profiles](#21-profiles)
   - [podcasts](#22-podcasts)
   - [episodes](#23-episodes)
   - [podcast_favourites](#24-podcast_favourites)
   - [clips](#25-clips)
   - [collections](#26-collections)
   - [collection_clips](#27-collection_clips)
   - [clip_engagement](#28-clip_engagement)
   - [comments](#29-comments)
   - [follows](#210-follows)
   - [notifications](#211-notifications)
   - [user_subscriptions](#212-user_subscriptions)
   - [playback_progress](#213-playback_progress)
   - [offline_queue](#214-offline_queue)
   - [trending_podcasts](#215-trending_podcasts)
   - [collection_favourites](#216-collection_favourites)
   - [user_downloads](#217-user_downloads)
   - [learning_preferences](#218-learning_preferences)
   - [clip_review_status](#219-clip_review_status)
   - [episode_favourites](#220-episode_favourites)
   - [clip_favourites](#221-clip_favourites)
   - [clip_shares](#222-clip_shares)
   - [notification_preferences](#223-notification_preferences)
   - [user_preferences](#224-user_preferences)
   - [feature_suggestions](#225-feature_suggestions)
   - [bug_reports](#226-bug_reports)
   - [downloaded_podcasts](#227-downloaded_podcasts)
   - [downloaded_episodes](#228-downloaded_episodes)
   - [downloaded_clips](#229-downloaded_clips)
   - [downloaded_collections](#230-downloaded_collections)
   - [podcast_subscriptions](#231-podcast_subscriptions)
   - [episode_transcripts](#232-episode_transcripts)
   - [app_config](#233-app_config)
3. [Functions & Triggers](#3-functions--triggers)
4. [Views](#4-views)
5. [Relationships](#5-relationships)
6. [Missing Tables Note (from Figma Gap Analysis)](#6-missing-tables-note)

---

## 1. ENUM Types

| ENUM | Values | Purpose |
|------|--------|---------|
| `podcast_source` | `podcastindex`, `listennotes`, `taddy`, `rss` | Tracks where podcast metadata originated |
| `subscription_status` | `trialing`, `active`, `expired`, `cancelled`, `grace_period` | RevenueCat-synced premium subscription lifecycle |
| `engagement_type` | `like`, `bookmark`, `share` | Type of user interaction on a clip |
| `notification_type` | `new_follower`, `new_clip`, `like`, `comment`, `share` | Categorises push/in-app notification events |
| `sync_status` | `local`, `uploading`, `processing`, `ready`, `failed` | Tracks clip upload + AI processing pipeline state |
| `queue_action` | `create_clip`, `update_clip`, `delete_clip` | Operation stored in the offline sync queue |
| `queue_status` | `pending`, `syncing`, `synced`, `failed` | Current sync state of an offline queue item |
| `trending_period` | `daily`, `weekly`, `monthly` | Time window for trending podcast rankings |
| `insights_frequency` | `daily`, `weekly`, `monthly`, `custom` | User's chosen Learn review cadence |
| `reminder_period` | `morning`, `afternoon`, `evening`, `night` | Preferred time-of-day for Learn reminder push |
| `default_clip_length` | `30`, `45`, `60` | User's preferred clip duration in seconds |
| `download_type` | `podcast`, `episode`, `clip`, `collection` | Content type for download tracking (discriminator for `user_downloads`) |
| `share_type` | `my_feed`, `copy_link`, `whatsapp`, `other` | Channel through which a clip was shared; used in the `clip_shares` audit log |
| `system_collection_type` | `my_favorites`, `downloads`, `unprocessed_clips` | Identifies which system-managed collection a row represents |

---

## 2. Tables

### 2.1 `profiles`

Extends Supabase `auth.users` 1:1. Stores public user info.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, FK → auth.users(id) ON DELETE CASCADE | Matches Supabase auth user ID |
| `username` | TEXT | UNIQUE, NOT NULL | Public handle shown on profile and feed cards |
| `display_name` | TEXT | | Human-readable name (e.g. "Alex Morgan") |
| `avatar_url` | TEXT | | URL to profile picture (Supabase Storage or external) |
| `bio` | TEXT | | Short user biography shown on My Profile |
| `is_premium` | BOOLEAN | NOT NULL DEFAULT FALSE | Whether user has an active premium subscription |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Account creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last profile modification (auto-updated via trigger) |

**Indexes:** `idx_profiles_username (username)`

---

### 2.2 `podcasts`

Cached podcast metadata. Seeded from Taddy API; read-only for clients.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Internal podcast identifier |
| `external_id` | TEXT | UNIQUE, NOT NULL | ID from source API (Taddy UUID / RSS GUID) |
| `title` | TEXT | NOT NULL | Podcast title (e.g. "Modern Wisdom") |
| `author` | TEXT | | Podcast host or publisher name |
| `description` | TEXT | | Podcast description / about text |
| `artwork_url` | TEXT | | URL to podcast cover artwork |
| `rss_url` | TEXT | | RSS feed URL for direct episode fetching |
| `categories` | TEXT[] | DEFAULT '{}' | Array of category tags. Valid values: Business, News & Current Affairs, Technology, Education, Health & Wellbeing, Culture & Society, Other |
| `total_episodes` | INT | DEFAULT 0 | Total episode count as reported by API |
| `source` | podcast_source | NOT NULL DEFAULT 'taddy' | Which API supplied this podcast record |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When this podcast was first cached |

**Indexes:** `idx_podcasts_external_id (external_id)`, `idx_podcasts_title_trgm USING gin (title gin_trgm_ops)` — trigram index for fuzzy search

---

### 2.3 `episodes`

Cached episode metadata. Populated from Taddy API or RSS; read-only for clients.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Internal episode identifier |
| `external_id` | TEXT | UNIQUE, NOT NULL | ID from source API or RSS GUID |
| `podcast_id` | UUID | NOT NULL, FK → podcasts(id) ON DELETE CASCADE | Parent podcast this episode belongs to |
| `title` | TEXT | NOT NULL | Episode title (e.g. "The Art of Negotiation & Persuasion") |
| `description` | TEXT | | Episode show notes or summary |
| `audio_url` | TEXT | NOT NULL | Direct URL to the episode audio file (MP3/M4A) |
| `artwork_url` | TEXT | | Episode-specific cover art (falls back to podcast artwork) |
| `duration_seconds` | INT | | Total episode length in seconds |
| `published_at` | TIMESTAMPTZ | | Original publish date from RSS feed |
| `chapters` | JSONB | DEFAULT '[]' | Podcast chapter markers (start, title, url) if available |
| `transcript_source` | TEXT | CHECK (transcript_source IN ('rss', 'whisper')) | How the episode transcript was obtained: 'rss' = extracted from RSS `<podcast:transcript>` tag, 'whisper' = auto-generated via speech-to-text. NULL if no transcript available yet |
| `chapters_source` | TEXT | CHECK (chapters_source IN ('rss', 'auto_generated')) | How chapter markers were obtained: 'rss' = from RSS feed chapter metadata, 'auto_generated' = generated from transcript/audio analysis. NULL if no chapters available |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When this episode was first cached |

**Indexes:** `idx_episodes_podcast_id (podcast_id)`, `idx_episodes_published_at (published_at DESC)`

---

### 2.4 `podcast_favourites`

Junction table for user ↔ podcast (M:N). Powers "Your Favorite Podcasts" carousels.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who favourited the podcast |
| `podcast_id` | UUID | NOT NULL, FK → podcasts(id) ON DELETE CASCADE | The favourited podcast |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the favourite was added |

**Primary Key:** `(user_id, podcast_id)` — composite, prevents duplicates

---

### 2.5 `clips`

Core entity. Represents a user-created audio snippet from an episode.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique clip identifier |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | Creator of this clip |
| `episode_id` | UUID | NOT NULL, FK → episodes(id) ON DELETE CASCADE | Source episode the clip was extracted from |
| `title` | TEXT | | User-assigned clip title (e.g. "The Power of Strategic Silence") |
| `description` | TEXT | | Optional user-provided description |
| `audio_url` | TEXT | | S3 URL to the encoded clip audio (AAC/M4A) |
| `start_time` | REAL | NOT NULL | Start offset in seconds within the episode |
| `end_time` | REAL | NOT NULL | End offset in seconds within the episode |
| `duration_seconds` | REAL | NOT NULL | Clip length in seconds (end_time − start_time) |
| `transcript` | TEXT | | AI-generated transcript via OpenAI Whisper |
| `ai_summary` | TEXT | | AI-generated "Insights" summary (premium only) |
| `ai_takeaways` | TEXT | | AI-generated "Actionable Takeaways" (premium only) |
| `tags` | TEXT[] | DEFAULT '{}' | Category tags for discovery (Technology, Health, etc.) |
| `is_public` | BOOLEAN | NOT NULL DEFAULT TRUE | Whether clip appears in Social Feed |
| `is_processed` | BOOLEAN | NOT NULL DEFAULT FALSE | Whether AI processing (transcription/summary) is complete |
| `sync_status` | sync_status | NOT NULL DEFAULT 'local' | Current state in upload → processing pipeline |
| `share_token` | TEXT | UNIQUE | URL-safe token for external sharing (auto-generated) |
| `play_count` | INT | NOT NULL DEFAULT 0 | Number of times this clip has been played |
| `share_count` | INT | NOT NULL DEFAULT 0 | Number of times this clip has been shared externally |
| `my_notes` | TEXT | | User-written notes on the clip (Learn review flow) |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the clip was created |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last modification timestamp (auto-updated via trigger) |

**Indexes:**
- `idx_clips_user_id (user_id)` — user's clip library
- `idx_clips_episode_id (episode_id)` — clips per episode
- `idx_clips_is_public (is_public) WHERE is_public = TRUE` — feed queries
- `idx_clips_created_at (created_at DESC)` — chronological feed
- `idx_clips_share_token (share_token) WHERE share_token IS NOT NULL` — share URL lookup
- `idx_clips_tags USING gin (tags)` — tag-based search

> **Note:** `ai_takeaways` is a new column added based on Figma HiFi analysis. The User Clip Details screen (554:1512) shows two distinct AI sections: "Insights" (`ai_summary`) and "Actionable Takeaways" (`ai_takeaways`).

---

### 2.6 `collections`

User-created or system-curated clip collections. Visible in Collections tab and Search sub-pages.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique collection identifier |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who created this collection |
| `name` | TEXT | NOT NULL | Collection title (e.g. "AI & Tech Insights") |
| `description` | TEXT | | Optional description of the collection theme |
| `cover_url` | TEXT | | Cover image URL for collection card display |
| `is_private` | BOOLEAN | NOT NULL DEFAULT FALSE | Whether collection is hidden from public view. **Counterintuitive toggle:** the UI shows "Make My Collection Private" OFF = Public, ON = Private. |
| `is_curated` | BOOLEAN | NOT NULL DEFAULT FALSE | Platform-curated collections (e.g. "Best Clips of Elon Musk This Week") created exclusively by Edge Functions using service_role key |
| `is_system` | BOOLEAN | NOT NULL DEFAULT FALSE | System-managed collections auto-created per user on signup (My Favorites, Downloads, Unprocessed Clips) |
| `system_type` | system_collection_type | NULL unless `is_system = TRUE` | Which system collection this row represents; enforces intent at DB level |
| `clip_count` | INT | NOT NULL DEFAULT 0 | Denormalised count of clips in collection |
| `total_duration` | REAL | NOT NULL DEFAULT 0 | Denormalised total duration in seconds |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the collection was created |
| `share_token` | TEXT | UNIQUE | URL-safe token for external collection sharing (auto-generated) |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last modification timestamp |

**Indexes:**
- `idx_collections_user_id (user_id)` — user's collections
- `idx_collections_is_curated (is_curated) WHERE is_curated = TRUE` — curated collection queries
- `idx_collections_share_token (share_token) WHERE share_token IS NOT NULL` — share URL lookup

> **Note:** This table was **not present** in the original ARCHITECTURE.md ERD but is required by the Figma design.

> **Business rule — 15-collection limit for Free users:** Frame 587:25458 shows "You have 6/15 free collections" counter for Free users. Frame 553:11537 (Premium) shows no counter. Enforcement is server-side via a Supabase Edge Function that counts `SELECT COUNT(*) FROM collections WHERE user_id = $1 AND is_system = FALSE AND is_curated = FALSE` before INSERT. System and curated collections do not count toward the limit. After creation, a toast "✓ Collection Created Successfully" is shown.

> **Business rule — Auto-publish public collections to Social Feed:** Dev note `908:9591` states "If collection is not set to private, it will be automatically shared on feed." When `is_private = FALSE`, the collection appears in the Social Feed (handled by feed_view or equivalent).

> **Business rule — Collections Onboarding:** A 3-step carousel (Create Your Own Spaces / Add Clips That Matter / Build Your Insight Library) is shown on first visit to the Collections tab. Completion state tracked in `collections_onboarding_completed` column in `profiles` or via `learning_preferences`-style table. **Decision: add `collections_onboarding_completed BOOLEAN DEFAULT FALSE` to `profiles`.**

> **Lo-Fi evidence:** Collections tab (1067:13887) shows 4 system groups: My Favorites (20 items), Downloads (20 items, Premium), Unprocessed Clips (201 count), and a "My Collections" section. Collection create toast: 624:19425. Collection Detail 3-month warning banner: 587:22821. Edit Collection Details sheet: 556:7255.

---

### 2.7 `collection_clips`

Junction table for collection ↔ clip (M:N). A clip can belong to multiple collections.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `collection_id` | UUID | NOT NULL, FK → collections(id) ON DELETE CASCADE | Parent collection |
| `clip_id` | UUID | NOT NULL, FK → clips(id) ON DELETE CASCADE | Clip in this collection |
| `position` | INT | NOT NULL DEFAULT 0 | Sort order within the collection (for drag-reorder in Edit Collection sheet) |
| `added_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the clip was added to this collection |
| `last_reviewed_at` | TIMESTAMPTZ | | When the user last reviewed this clip in the 3-month Aged Clips Review flow. NULL = never reviewed. |

**Primary Key:** `(collection_id, clip_id)` — prevents duplicate entries

**Indexes:** `idx_collection_clips_clip_id (clip_id)` — reverse lookup: which collections contain a clip

> **Collections contain only clips.** Confirmed by product: no episodes, no nested collections. A clip may appear in multiple user collections simultaneously.

> **3-month aging logic:** A clip-in-collection entry is "aged" (shown in the tidy-up warning) when `added_at < now() - interval '3 months'` AND (`last_reviewed_at IS NULL` OR `last_reviewed_at < now() - interval '3 months'`). The Collection Detail screen shows: "Time to tidy up — X of your clips reached the 3-month limit. Revisit, keep or remove clips..." + [Revisit Clips] [Delete] buttons. When the user taps "Keep" in the Review Aged Clips flow, the server sets `last_reviewed_at = now()` for that `(collection_id, clip_id)` pair. When the user taps "Delete", the clip row is removed from `clips` (CASCADE removes the `collection_clips` row).

---

### 2.8 `clip_engagement`

Records user interactions (likes, bookmarks, shares) on clips.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique engagement record ID |
| `clip_id` | UUID | NOT NULL, FK → clips(id) ON DELETE CASCADE | The clip being engaged with |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | The user performing the action |
| `type` | engagement_type | NOT NULL | Type of engagement: like, bookmark, or share |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the engagement occurred |

**Unique Constraint:** `(clip_id, user_id, type)` — one like/bookmark per user per clip

**Indexes:** `idx_engagement_clip_id (clip_id)`, `idx_engagement_user_id (user_id)`

---

### 2.9 `comments`

User comments on public clips. Shown in clip detail / feed threads.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique comment identifier |
| `clip_id` | UUID | NOT NULL, FK → clips(id) ON DELETE CASCADE | The clip being commented on |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | The user who wrote the comment |
| `body` | TEXT | NOT NULL, CHECK (char_length ≤ 2000) | Comment text content (max 2000 chars) |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the comment was posted |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last edit timestamp (auto-updated via trigger) |

**Indexes:** `idx_comments_clip_id (clip_id, created_at)` — chronological comments per clip

---

### 2.10 `follows`

Self-referencing M:N relationship for social graph. Powers Friends feed tab.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `follower_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | The user who is following |
| `following_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | The user being followed |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the follow relationship was created |

**Primary Key:** `(follower_id, following_id)` — composite, prevents duplicate follows

**Check Constraint:** `follower_id != following_id` — users cannot follow themselves

**Indexes:** `idx_follows_following (following_id)` — efficient "who follows this user?" queries

---

### 2.11 `notifications`

In-app + push notification records. Inserted by Edge Functions only.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique notification identifier |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | Recipient user |
| `type` | notification_type | NOT NULL | Category (new_follower, new_clip, like, comment, share) |
| `title` | TEXT | NOT NULL | Notification headline text |
| `body` | TEXT | | Notification detail text |
| `data` | JSONB | DEFAULT '{}' | Structured payload (actor_id, clip_id, etc.) for deep linking |
| `is_read` | BOOLEAN | NOT NULL DEFAULT FALSE | Whether the user has read/acknowledged this notification |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the notification was generated |

**Indexes:**
- `idx_notifications_user_id (user_id, created_at DESC)` — paginated notification list
- `idx_notifications_unread (user_id) WHERE is_read = FALSE` — unread badge count

---

### 2.12 `user_subscriptions`

Premium subscription records. Managed exclusively by RevenueCat webhooks.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique subscription record ID |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | The subscriber |
| `rc_customer_id` | TEXT | NOT NULL | RevenueCat customer identifier for webhook correlation |
| `product_id` | TEXT | NOT NULL | App Store/Play Store product ID (e.g. "clipcast_premium_yearly") |
| `status` | subscription_status | NOT NULL DEFAULT 'trialing' | Current lifecycle state |
| `expires_at` | TIMESTAMPTZ | | Subscription expiration date |
| `trial_end_at` | TIMESTAMPTZ | | End of 1-month free trial period |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When subscription was first created |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last webhook update (auto-updated via trigger) |

**Indexes:** `idx_subscriptions_user_id (user_id)`, `idx_subscriptions_rc_customer (rc_customer_id)`

---

### 2.13 `playback_progress`

Resume-from-where-you-left-off tracking for episodes.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | The listener |
| `episode_id` | UUID | NOT NULL, FK → episodes(id) ON DELETE CASCADE | Episode being tracked |
| `position_seconds` | REAL | NOT NULL DEFAULT 0 | Current playback position in seconds |
| `completed` | BOOLEAN | NOT NULL DEFAULT FALSE | Whether the user finished the episode |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last position save (auto-updated via trigger) |

**Primary Key:** `(user_id, episode_id)` — one progress record per user per episode

---

### 2.14 `offline_queue`

Server-side mirror of the client's offline action queue. Used for audit/debugging.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique queue entry ID |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who queued the action offline |
| `action` | queue_action | NOT NULL | Type of deferred operation (create/update/delete clip) |
| `payload` | JSONB | NOT NULL | Full action data needed to replay on sync |
| `status` | queue_status | NOT NULL DEFAULT 'pending' | Current sync state |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the action was queued on device |
| `synced_at` | TIMESTAMPTZ | | When the action was successfully synced to server |

---

### 2.15 `trending_podcasts`

Pre-computed trending rankings. Populated by cron Edge Function every 6 hours.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique trending record ID |
| `podcast_id` | UUID | NOT NULL, FK → podcasts(id) ON DELETE CASCADE | The ranked podcast |
| `rank` | INT | NOT NULL | Numerical position in trending list (1 = top) |
| `score` | REAL | NOT NULL DEFAULT 0 | Computed trending score (from API + internal signals) |
| `period` | trending_period | NOT NULL DEFAULT 'daily' | Time window this ranking applies to |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last time this ranking was refreshed |

**Unique Constraint:** `(podcast_id, period)` — one ranking per podcast per period

**Indexes:** `idx_trending_period_rank (period, rank)` — efficient "top N for period" queries

---

### 2.16 `collection_favourites`

Junction table for user ↔ collection favourites (M:N). Powers "Add to My Favorites" on collection options sheet.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who favourited the collection |
| `collection_id` | UUID | NOT NULL, FK → collections(id) ON DELETE CASCADE | The favourited collection |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the favourite was added |

**Primary Key:** `(user_id, collection_id)` — composite, prevents duplicates

> **Lo-Fi evidence:** Frames 755:21725 and 755:21654 show "Add to My Favorites" as a collection option. Frame 755:21602 shows "Add to My Favorites" for individual clips within a collection context.

---

### 2.17 `user_downloads` ⚠️ **DEPRECATED — replaced by §2.27–2.30**

> **Migration:** This polymorphic table is superseded by four type-specific tables: `downloaded_podcasts` (§2.27), `downloaded_episodes` (§2.28), `downloaded_clips` (§2.29), `downloaded_collections` (§2.30). The Profile HiFi designs (761:22330–22612) show a Downloads screen with 4 separate tabs (Podcasts / Episodes / Clips / Collections), each requiring distinct FK relationships. Separate tables provide cleaner queries, type-safe FKs, and simpler RLS policies. Existing data should be migrated before this table is dropped.

Tracks clips and collections downloaded for offline premium playback.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique download record ID |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who downloaded the content |
| `podcast_id` | UUID | FK → podcasts(id) ON DELETE CASCADE | Downloaded podcast; NULL unless `download_type = 'podcast'` |
| `episode_id` | UUID | FK → episodes(id) ON DELETE CASCADE | Downloaded episode; NULL unless `download_type = 'episode'` |
| `clip_id` | UUID | FK → clips(id) ON DELETE CASCADE | Downloaded clip; NULL unless `download_type = 'clip'` |
| `collection_id` | UUID | FK → collections(id) ON DELETE CASCADE | Downloaded collection; NULL unless `download_type = 'collection'` |
| `download_type` | download_type | NOT NULL | Discriminator: `podcast`, `episode`, `clip`, or `collection` |
| `downloaded_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the download was initiated |

**Check Constraint:** `(podcast_id IS NOT NULL OR episode_id IS NOT NULL OR clip_id IS NOT NULL OR collection_id IS NOT NULL)` — exactly one target FK must be set

**Indexes:** `idx_downloads_user_id (user_id)`, `idx_downloads_type (user_id, download_type)` — efficient per-type tab queries

> **Lo-Fi evidence:** Collections tab Downloads sub-tab (4 content types): Downloaded Podcasts, Downloaded Episodes (typo "Episoded" in design), Downloaded Clips, Downloaded Collections (666:27736). Profile offline hub Downloads (761:22330–22612) shows same 4 tabs. Collection Detail DOWNLOADED variant (666:27808): 2 downloaded clips shown bright, 4 non-downloaded items greyed out. Full-screen player OFFLINE mode (741:17244): "⊘ You're offline •" banner, clip still plays. All download features are Premium-only.
>
> When a user downloads a collection, one `user_downloads` row is inserted with `download_type = 'collection'` AND individual `download_type = 'clip'` rows are inserted for each clip in the collection. This allows the Collections tab Downloads > Clips sub-tab to show collection-downloaded clips.

---

### 2.18 `learning_preferences`

Stores each user's Learn feature configuration: insights review frequency, push-reminder settings, and onboarding completion state.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique record ID |
| `user_id` | UUID | NOT NULL UNIQUE, FK → profiles(id) ON DELETE CASCADE | One row per user |
| `frequency` | insights_frequency | NOT NULL DEFAULT 'weekly' | Review cadence: daily, weekly, monthly, custom |
| `custom_config` | JSONB | | Custom schedule details (only when frequency = 'custom'); e.g., `{"days": ["mon", "thu"], "time": "09:00"}` |
| `reminder_enabled` | BOOLEAN | NOT NULL DEFAULT TRUE | Whether push reminders are active |
| `reminder_period` | reminder_period | NOT NULL DEFAULT 'morning' | Preferred time-of-day slot |
| `reminder_time` | TIME | NOT NULL DEFAULT '08:00' | Exact reminder time (within the period) |
| `onboarding_completed` | BOOLEAN | NOT NULL DEFAULT FALSE | Whether user has finished the Learn onboarding carousel |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Row creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last modification timestamp (auto-updated via trigger) |

**Indexes:** `idx_learning_prefs_user_id (user_id)` — fast lookup by user

> **Lo-Fi evidence:** Onboarding frequency selection (586:11809), Onboarding reminder setup (586:12028), Learning Settings (587:21230, 556:4299), Frequency sub-screen (587:21273, 556:4569), Reminder sub-screen (587:21321, 556:4698).

---

### 2.19 `clip_review_status`

Tracks which clips have been reviewed in the Learn review flow. One row per clip per user per review session.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique review record ID |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who reviewed the clip |
| `clip_id` | UUID | NOT NULL, FK → clips(id) ON DELETE CASCADE | Clip being reviewed |
| `review_session_id` | UUID | NOT NULL | Groups reviews into a single "Review Weekly Insights" session |
| `reviewed_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Timestamp when the clip was marked as reviewed |

**Unique Constraint:** `(user_id, clip_id)` — prevents duplicate reviews of the same clip

**Indexes:**
- `idx_review_status_user_id (user_id)` — user's review history
- `idx_review_status_clip_id (clip_id)` — reverse lookup
- `idx_review_status_session (review_session_id)` — session grouping

> **Lo-Fi evidence:** Review Weekly Insights flow (587:21387) shows segmented progress bar "1/15 unprocessed clips". Completion screen (720:12147) shows "You're All Caught Up!" with stats (This Week: 12, Total Clips Saved: 47). Requires tracking which clips are reviewed per session.

---

### 2.20 `episode_favourites`

Junction table for user ↔ episode favourites (M:N). Powers "Favorite Episodes" sub-tab in Collections → Favorites and offline "My Favorites → Episodes" tab.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who favourited the episode |
| `episode_id` | UUID | NOT NULL, FK → episodes(id) ON DELETE CASCADE | The favourited episode |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the favourite was added |

**Primary Key:** `(user_id, episode_id)` — composite, prevents duplicates

> **Lo-Fi evidence:** Favorites sub-tab: Episodes (typo "Epsidoes" in design) shows a list of episodes with heart icons. Profile offline hub My Favorites → Episodes tab (761:22811). Matches the existing `podcast_favourites` pattern.

---

### 2.21 `clip_favourites`

Junction table for user ↔ clip favourites (M:N). Powers "Favorite Clips" sub-tab in Collections → Favorites.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who favourited the clip |
| `clip_id` | UUID | NOT NULL, FK → clips(id) ON DELETE CASCADE | The favourited clip |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the favourite was added |

**Primary Key:** `(user_id, clip_id)` — composite, prevents duplicates

> **Lo-Fi evidence:** Clip options sheet (within collection context) shows "Add to My Favorites" as option 2 (561:14831). Favorites → Clips sub-tab shows individual clips with heart icons. Matches `podcast_favourites` and `collection_favourites` pattern.

---

### 2.22 `clip_shares`

Immutable audit log of clip share events. Used to enforce the free 5-share limit securely. Cannot be stored in the `profiles` table (users have UPDATE access to their own profile row).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique share event ID |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who performed the share |
| `clip_id` | UUID | NOT NULL, FK → clips(id) ON DELETE CASCADE | Clip that was shared |
| `share_type` | share_type | NOT NULL | Channel: `my_feed`, `copy_link`, `whatsapp`, or `other` |
| `shared_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the share occurred |

**Indexes:** `idx_clip_shares_user_id (user_id, shared_at DESC)` — efficient share count per user

> **Security note:** Free users are limited to 5 clip share events total. This limit is enforced server-side by a Supabase Edge Function: before recording a new share, the function runs `SELECT COUNT(*) FROM clip_shares WHERE user_id = $1` and returns a premium upsell if count >= 5. Client-side checks are for UX only and must never be relied upon for enforcement. Dev note: `925:14322`.

> **RLS:** Users can SELECT their own rows (to check remaining share count) and INSERT new share records for themselves. No UPDATE or DELETE — this table is append-only to maintain audit integrity.

> **Lo-Fi evidence:** Free upsell sheet (925:14322): "Want to share unlimited clips with your friends?" / "Upgrade to premium to share/export an unlimited number of clips." → Explore Premium / Cancel. Share Clip bottom sheet: waveform preview, share to My Feed / Copy Link / WhatsApp / More (913:12524).

---

### 2.23 `notification_preferences`

Stores per-user notification toggle states (1:1 with `profiles`). All toggles default to enabled.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PK, FK → profiles(id) ON DELETE CASCADE | Owning user (1:1 with profiles) |
| `review_insights_enabled` | BOOLEAN | NOT NULL DEFAULT TRUE | Receive "Review Weekly Insights" reminders |
| `new_episodes_enabled` | BOOLEAN | NOT NULL DEFAULT TRUE | Notify when followed podcasts release new episodes |
| `social_enabled` | BOOLEAN | NOT NULL DEFAULT TRUE | Notify on follows, likes, comments, shares |
| `clip_generation_enabled` | BOOLEAN | NOT NULL DEFAULT TRUE | Notify when AI clip processing completes |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Row creation time |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last toggle change |

**Trigger:** `update_updated_at` on UPDATE

> **HiFi evidence:** Online Notification Settings (1048:15977) shows 4 toggles: Review Insights, New Episodes Release, Social Notifications, Clip Generation Notification. Offline version (761:22916) shows only 3 toggles (older design) — user confirmed online version is authoritative.

---

### 2.24 `user_preferences`

Stores per-user app preferences (1:1 with `profiles`): gesture control and clip duration defaults.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | PK, FK → profiles(id) ON DELETE CASCADE | Owning user (1:1 with profiles) |
| `default_clip_length` | INT | NOT NULL DEFAULT 45, CHECK (default_clip_length IN (30, 45, 60)) | Preferred clip duration in seconds |
| `gesture_double_tap_enabled` | BOOLEAN | NOT NULL DEFAULT TRUE | AirPods double-tap creates a clip |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Row creation time |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last preference change |

**Trigger:** `update_updated_at` on UPDATE

> **HiFi evidence:** Gesture Control (1048:16016) — "AirPods Double Tap" toggle ON, "Create a 30 second clip" description. Preferences (1048:16088) — 30s / 45s / 60s radio group. Dev note (929:21019): "Hijacking skipping backward gesture with generating a clip. Clip duration according to preference."

---

### 2.25 `feature_suggestions`

Stores user-submitted feature suggestions. Append-only — users cannot edit or delete submissions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique suggestion ID |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who submitted the suggestion |
| `title` | TEXT | NOT NULL | Feature title (from "Feature Title" field) |
| `description` | TEXT | | Detailed description (from "Describe the feature" field) |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When submitted |

**Indexes:** `idx_feature_suggestions_user_id (user_id)`

> **HiFi evidence:** Suggest New Feature form (1048:16046): "Feature Title" + "Describe the feature you'd like to see" fields + Submit button. Success toast (1048:16128): "Submitted successfully notification".

---

### 2.26 `bug_reports`

Stores user-submitted bug reports. Append-only — users cannot edit or delete submissions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique report ID |
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who submitted the report |
| `title` | TEXT | NOT NULL | Bug title (from "What would you like to report" field) |
| `description` | TEXT | | Detailed description (from "Describe any issues or bugs" field) |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When submitted |

**Indexes:** `idx_bug_reports_user_id (user_id)`

> **HiFi evidence:** Report a Bug form (1048:16067): header mislabelled as "Suggest New Feature" in design (confirmed by user as the bug report screen). Placeholders: "What would you like to report" / "Describe any issues or bugs encountered" + Submit button.

---

### 2.27 `downloaded_podcasts`

Tracks podcasts downloaded for offline premium playback. Replaces `user_downloads` for podcast-type downloads.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who downloaded |
| `podcast_id` | UUID | NOT NULL, FK → podcasts(id) ON DELETE CASCADE | Downloaded podcast |
| `downloaded_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the download was initiated |

**Primary Key:** `(user_id, podcast_id)` — composite, prevents duplicates

**Indexes:** `idx_downloaded_podcasts_user (user_id)` — list user's downloaded podcasts

> **Premium only.** Downloads tab → Podcasts sub-tab (761:22330). Download functionality gated behind premium subscription.

---

### 2.28 `downloaded_episodes`

Tracks episodes downloaded for offline premium playback. Replaces `user_downloads` for episode-type downloads.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who downloaded |
| `episode_id` | UUID | NOT NULL, FK → episodes(id) ON DELETE CASCADE | Downloaded episode |
| `downloaded_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the download was initiated |

**Primary Key:** `(user_id, episode_id)` — composite, prevents duplicates

**Indexes:** `idx_downloaded_episodes_user (user_id)` — list user's downloaded episodes

> **Premium only.** Downloads tab → Episodes sub-tab (761:22424). Download functionality gated behind premium subscription.

---

### 2.29 `downloaded_clips`

Tracks clips downloaded for offline premium playback. Replaces `user_downloads` for clip-type downloads.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who downloaded |
| `clip_id` | UUID | NOT NULL, FK → clips(id) ON DELETE CASCADE | Downloaded clip |
| `downloaded_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the download was initiated |

**Primary Key:** `(user_id, clip_id)` — composite, prevents duplicates

**Indexes:** `idx_downloaded_clips_user (user_id)` — list user's downloaded clips

> **Premium only.** Downloads tab → Clips sub-tab (761:22518). Shows clip duration (e.g. "30 sec"). Download functionality gated behind premium subscription.

---

### 2.30 `downloaded_collections`

Tracks collections downloaded for offline premium playback. Replaces `user_downloads` for collection-type downloads. When a collection is downloaded, individual clip rows are also inserted into `downloaded_clips` for each clip in the collection.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who downloaded |
| `collection_id` | UUID | NOT NULL, FK → collections(id) ON DELETE CASCADE | Downloaded collection |
| `downloaded_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the download was initiated |

**Primary Key:** `(user_id, collection_id)` — composite, prevents duplicates

**Indexes:** `idx_downloaded_collections_user (user_id)` — list user's downloaded collections

> **Premium only.** Downloads tab → Collections sub-tab (761:22612). Shows clip count + total duration (e.g. "24 clips • 34m"). Download functionality gated behind premium subscription.

---

### 2.31 `podcast_subscriptions`

Tracks users who subscribed to new-episode notifications for a podcast via the notification bell icon on the Podcast Page header. Toggling the bell ON inserts a row; toggling OFF deletes it. Used to trigger push notifications (via OneSignal tag) when new episodes are published.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `user_id` | UUID | NOT NULL, FK → profiles(id) ON DELETE CASCADE | User who subscribed |
| `podcast_id` | UUID | NOT NULL, FK → podcasts(id) ON DELETE CASCADE | The podcast being subscribed to |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When the subscription was created |

**Primary Key:** `(user_id, podcast_id)` — composite, prevents duplicates

**Indexes:** `idx_podcast_subscriptions_podcast (podcast_id)` — look up all subscribers for a podcast (used when broadcasting new-episode notifications)

> **Free and Premium.** Notification subscription is available to all users (FR-48). The bell icon appears on the Podcast Page header (588:49600). See Flows.md §4.1.

---

### 2.32 `episode_transcripts`

Stores episode-level transcript segments. Each row represents one speaker segment with timestamps. Separate table chosen over JSONB on `episodes` for scalability — episode transcripts can contain thousands of segments for multi-hour episodes; a dedicated table enables pagination, streaming, full-text search indexing, and avoids bloating the `episodes` rows.

> **Free for all users.** Episode-level transcripts are distinct from clip-level AI transcripts (`clips.transcript`) which are Premium-gated. See Flows.md §19.2.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK DEFAULT gen_random_uuid() | Unique segment identifier |
| `episode_id` | UUID | NOT NULL, FK → episodes(id) ON DELETE CASCADE | The episode this transcript segment belongs to |
| `speaker_name` | TEXT | | Speaker label (e.g. "Chris Williamson", "Dr. Sarah Chen"). NULL if speaker detection unavailable |
| `content` | TEXT | NOT NULL | Transcript text content for this segment |
| `start_time` | REAL | NOT NULL | Start offset in seconds within the episode audio |
| `end_time` | REAL | | End offset in seconds (NULL if not determinable) |
| `segment_order` | INT | NOT NULL | Sequential ordering of segments (0-based). Used for display order |
| `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | When this segment was inserted |

**Primary Key:** `(id)`

**Indexes:**
- `idx_episode_transcripts_episode_id (episode_id)` — load all segments for an episode
- `idx_episode_transcripts_episode_order (episode_id, segment_order)` — ordered segment retrieval (pagination)
- `idx_episode_transcripts_content_trgm USING gin (content gin_trgm_ops)` — full-text search across transcript content

> **Data sourcing (dev note 925:14290):** Transcripts should be extracted from the RSS feed if available (via `<podcast:transcript>` tags). If not available, transcripts can be generated automatically from the episode audio using speech-to-text (e.g. OpenAI Whisper). The `episodes.transcript_source` column tracks the origin.

---

### 2.33 `app_config`

Server-side configuration store for dynamic business rules. Avoids hardcoding values that may change (e.g. clip quotas, collection limits). Queried at app startup and cached client-side.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `key` | TEXT | PK | Configuration key (e.g. `clip_quota_per_podcast`, `free_collection_limit`) |
| `value` | JSONB | NOT NULL | Configuration value (type varies: number, string, object) |
| `description` | TEXT | | Human-readable explanation of this config key |
| `updated_at` | TIMESTAMPTZ | NOT NULL DEFAULT now() | Last modification timestamp |

**Seed data:**
```sql
INSERT INTO app_config (key, value, description) VALUES
  ('free_clip_limit_per_episode', '5', 'Maximum clips per episode for free-tier users (confirmed: 3–5 range)'),
  ('premium_clip_limit_per_episode', 'null', 'Maximum clips per episode for premium users. NULL = unlimited. Reserved for future configurable limit.'),
  ('free_collection_limit', '15', 'Maximum collections for free-tier users'),
  ('ad_trigger_clips_listened', '5', 'Number of clips a free user must listen to before audio ad triggers (confirmed: 4–5)'),
  ('ad_duration_seconds', '10', 'Audio ad duration in seconds (confirmed: 6–10s range)');
```

> **Clip quota (Flows.md §5.4/§19.8):** Free users: 3–5 clips per episode (configurable). Subscribed users: unlimited (configurable future limit via `premium_clip_limit_per_episode`). Figma "10/12" text is placeholder. Audio ads trigger after 4–5 clips listened to (not generated). All values must be dynamic and configurable server-side so business changes do not require a code update.

---

## 3. Functions & Triggers

### 3.1 Auto-update `updated_at`

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Applied to: `profiles`, `clips`, `comments`, `user_subscriptions`, `playback_progress`, `collections`, `learning_preferences`, `notification_preferences`, `user_preferences`

### 3.2 Auto-generate `share_token` on clip insert

```sql
CREATE OR REPLACE FUNCTION generate_share_token()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.share_token IS NULL THEN
        NEW.share_token = encode(gen_random_bytes(9), 'base64');
        NEW.share_token = replace(replace(NEW.share_token, '+', '-'), '/', '_');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

Generates a 12-character URL-safe token for external clip sharing links.

Applied to both `clips` (on INSERT) and `collections` (on INSERT) — both support external sharing.

### 3.3 Auto-update collection denormalised counts

```sql
-- Proposed trigger: update clip_count and total_duration on collection_clips insert/delete
CREATE OR REPLACE FUNCTION update_collection_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE collections SET
            clip_count = clip_count + 1,
            total_duration = total_duration + COALESCE((SELECT duration_seconds FROM clips WHERE id = NEW.clip_id), 0),
            updated_at = now()
        WHERE id = NEW.collection_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE collections SET
            clip_count = GREATEST(clip_count - 1, 0),
            total_duration = GREATEST(total_duration - COALESCE((SELECT duration_seconds FROM clips WHERE id = OLD.clip_id), 0), 0),
            updated_at = now()
        WHERE id = OLD.collection_id;
    END IF;
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;
```

---

## 4. Views

### 4.1 `feed_view`

Pre-joined view for Social Feed queries. Returns public, processed clips with engagement counts.

```sql
CREATE OR REPLACE VIEW feed_view AS
SELECT
    c.id, c.user_id,
    p.username, p.display_name, p.avatar_url,
    c.title, c.description, c.audio_url, c.duration_seconds,
    c.transcript, c.ai_summary, c.ai_takeaways,
    c.tags, c.share_token, c.play_count, c.share_count, c.created_at,
    e.title AS episode_title,
    pod.title AS podcast_title,
    pod.artwork_url AS podcast_artwork,
    COALESCE(likes.cnt, 0) AS like_count,
    COALESCE(comments.cnt, 0) AS comment_count,
    COALESCE(bookmarks.cnt, 0) AS bookmark_count
FROM clips c
JOIN profiles p ON p.id = c.user_id
JOIN episodes e ON e.id = c.episode_id
JOIN podcasts pod ON pod.id = e.podcast_id
LEFT JOIN (SELECT clip_id, COUNT(*) AS cnt FROM clip_engagement WHERE type = 'like' GROUP BY clip_id) likes ON likes.clip_id = c.id
LEFT JOIN (SELECT clip_id, COUNT(*) AS cnt FROM comments GROUP BY clip_id) comments ON comments.clip_id = c.id
LEFT JOIN (SELECT clip_id, COUNT(*) AS cnt FROM clip_engagement WHERE type = 'bookmark' GROUP BY clip_id) bookmarks ON bookmarks.clip_id = c.id
WHERE c.is_public = TRUE AND c.is_processed = TRUE;
```

---

## 5. Relationships

| Relationship | Type | Notes |
|-------------|------|-------|
| `profiles` ↔ `auth.users` | 1:1 | Profile extends Supabase auth via same PK |
| `profiles` → `clips` | 1:N | A user creates many clips |
| `episodes` → `clips` | 1:N | Each clip comes from one episode |
| `podcasts` → `episodes` | 1:N | A podcast has many episodes |
| `profiles` ↔ `podcasts` (via `podcast_favourites`) | M:N | Users bookmark podcasts |
| `profiles` ↔ `episodes` (via `episode_favourites`) | M:N | Users favourite individual episodes |
| `profiles` ↔ `clips` (via `clip_favourites`) | M:N | Users favourite individual clips |
| `profiles` ↔ `profiles` (via `follows`) | M:N | Self-referencing social graph |
| `clips` ↔ `profiles` (via `clip_engagement`) | M:N | Like / bookmark / share |
| `clips` → `comments` | 1:N | A clip has many comments |
| `profiles` → `notifications` | 1:N | User receives notifications |
| `profiles` → `user_subscriptions` | 1:N | Subscription history |
| `profiles` ↔ `episodes` (via `playback_progress`) | M:N | Resume position |
| `profiles` → `collections` | 1:N | A user creates many collections (Free: max 15 user collections; system and curated excluded from limit) |
| `collections` ↔ `clips` (via `collection_clips`) | M:N | Clips can appear in multiple collections; **clips only** (no episodes, no nested collections) |
| `profiles` ↔ `collections` (via `collection_favourites`) | M:N | Users favourite collections |
| `profiles` → `user_downloads` | 1:N | ⚠️ DEPRECATED — Premium users download podcasts/episodes/clips/collections for offline |
| `profiles` → `learning_preferences` | 1:1 | Each user has one Learn settings row |
| `profiles` → `clip_review_status` | 1:N | User's clip review history (Learn flow) |
| `clips` → `clip_review_status` | 1:N | A clip can be reviewed by many users |
| `profiles` → `clip_shares` | 1:N | User's clip share audit log (enforces free 5-share limit) |
| `clips` → `clip_shares` | 1:N | A clip can be shared multiple times |
| `podcasts` → `trending_podcasts` | 1:N | Ranked per period |
| `profiles` → `notification_preferences` | 1:1 | Per-user notification toggle states |
| `profiles` → `user_preferences` | 1:1 | Per-user app preferences (gesture control, clip length) |
| `profiles` → `feature_suggestions` | 1:N | User submits feature suggestions |
| `profiles` → `bug_reports` | 1:N | User submits bug reports |
| `profiles` ↔ `podcasts` (via `downloaded_podcasts`) | M:N | Premium users download podcasts for offline |
| `profiles` ↔ `episodes` (via `downloaded_episodes`) | M:N | Premium users download episodes for offline |
| `profiles` ↔ `clips` (via `downloaded_clips`) | M:N | Premium users download clips for offline |
| `profiles` ↔ `collections` (via `downloaded_collections`) | M:N | Premium users download collections for offline |
| `profiles` ↔ `podcasts` (via `podcast_subscriptions`) | M:N | Users subscribe to new-episode notifications for podcasts |

### Relationship Diagram (Text)

```
auth.users
    │ 1:1
    ▼
profiles ──1:N──▶ clips ◀──N:1── episodes ◀──N:1── podcasts
    │               │ │                     │             ▲
    │               │ └──1:N──▶ comments    │             │
    │               │                       │             │
    │               ├──M:N──▶ clip_engagement            │
    │               │                                    │
    │               ├──M:N──▶ collection_clips            │
    │               │              │                     │
    │               │              ▼                     │
    │               ├──1:N──▶ clip_shares               │
    │               │                                    │
    │               └──M:N──▶ clip_favourites            │
    │                                                    │
    ├──1:N──▶ collections                                │
    │                                                    │
    ├──M:N──▶ follows (self-ref)                         │
    │                                                    │
    ├──1:N──▶ notifications                              │
    │                                                    │
    ├──1:N──▶ user_subscriptions                         │
    │                                                    │
    ├──M:N──▶ playback_progress ──▶ episodes             │
    │                                                    │
    ├──M:N──▶ podcast_favourites ────────────────────────┘
    │
    ├──M:N──▶ episode_favourites ──▶ episodes
    │
    ├──1:N──▶ offline_queue
    │
    ├──1:1──▶ learning_preferences
    │
    ├──1:N──▶ clip_review_status ──▶ clips
    │
    ├──1:N──▶ user_downloads (⚠️ DEPRECATED)
    │
    ├──1:1──▶ notification_preferences
    │
    ├──1:1──▶ user_preferences
    │
    ├──1:N──▶ feature_suggestions
    │
    ├──1:N──▶ bug_reports
    │
    ├──M:N──▶ downloaded_podcasts ──▶ podcasts
    │
    ├──M:N──▶ downloaded_episodes ──▶ episodes
    │
    ├──M:N──▶ downloaded_clips ──▶ clips
    │
    ├──M:N──▶ downloaded_collections ──▶ collections
    │
    └──M:N──▶ podcast_subscriptions ──▶ podcasts

podcasts ──1:N──▶ trending_podcasts

episodes ──1:N──▶ episode_transcripts

(standalone) app_config
```

---

## 6. Schema Change Summary (Cumulative from All Figma Analysis)

All 90 Lo-Fi and HiFi designs have been reviewed. This section summarises every addition or modification made to the original `ARCHITECTURE.md` Section 11 ERD.

### New Tables Added

| Table | When Added | Primary Evidence |
|-------|-----------|-----------------|
| `collections` | HiFi analysis | Collections screen (545:4442), Collection Detail (549:6537, 553:12548) |
| `collection_clips` | HiFi analysis | Collection Detail ordered clip list, Edit Collection drag-reorder |
| `collection_favourites` | Lo-Fi analysis | Collection Options "Add to My Favorites" (755:21725) |
| `user_downloads` | Lo-Fi analysis | "Download Collection" (755:21725), "Download Clip" (755:21602) |
| `learning_preferences` | Learn Lo-Fi analysis | Learn Onboarding frequency/reminder (586:11809, 586:12028) |
| `clip_review_status` | Learn Lo-Fi analysis | Review Weekly Insights progress "1/15" (587:21387) |
| `episode_favourites` | Collections Lo-Fi (full 90 review) | Favorites → Episodes sub-tab (Collections tab) |
| `clip_favourites` | Collections Lo-Fi (full 90 review) | Favorites → Clips sub-tab; Clip Options "Add to My Favorites" |
| `clip_shares` | Collections Lo-Fi (full 90 review) | Free share limit (925:14322); Share Clip sheet (913:12524) |
| `notification_preferences` | Profile HiFi analysis | Notification Settings 4 toggles (1048:15977) |
| `user_preferences` | Profile HiFi analysis | Gesture Control (1048:16016), Preferences clip length (1048:16088) |
| `feature_suggestions` | Profile HiFi analysis | Suggest New Feature form (1048:16046) |
| `bug_reports` | Profile HiFi analysis | Report a Bug form (1048:16067) |
| `downloaded_podcasts` | Profile HiFi analysis | Downloads → Podcasts tab (761:22330); replaces `user_downloads` |
| `downloaded_episodes` | Profile HiFi analysis | Downloads → Episodes tab (761:22424); replaces `user_downloads` |
| `downloaded_clips` | Profile HiFi analysis | Downloads → Clips tab (761:22518); replaces `user_downloads` |
| `downloaded_collections` | Profile HiFi analysis | Downloads → Collections tab (761:22612); replaces `user_downloads` |
| `podcast_subscriptions` | Podcast Page Lo-Fi analysis | Notification bell on Podcast Page header (588:49600); FR-48 |
| `episode_transcripts` | Episode Details Lo-Fi analysis (32 designs) | Transcript view with speaker segments + timestamps (202:4570, 565:5052, 565:5270); separate table for scalability (FR-57) |
| `app_config` | Episode Details Lo-Fi analysis (32 designs) | Clip quota "10/12" on offline player (739:15744); dynamic configurable limit (FR-60) |

### Column Additions to Existing Tables

| Table | Column | Type | Evidence |
|-------|--------|------|---------|
| `clips` | `ai_takeaways` | TEXT | Clip Detail "Actionable Takeaways" section (554:1512, 749:18204) — separate from `ai_summary` (Insights) |
| `clips` | `my_notes` | TEXT | Editable "My Notes" field in Review card (587:21387) and Clip Detail (749:18204) |
| `collections` | `share_token` | TEXT UNIQUE | Share Collection sheet (913:12621) requires external URL |
| `collections` | `is_system` | BOOLEAN NOT NULL DEFAULT FALSE | System collections: My Favorites, Downloads, Unprocessed Clips |
| `collections` | `system_type` | system_collection_type | Discriminator for which system collection type this represents |
| `collection_clips` | `last_reviewed_at` | TIMESTAMPTZ | 3-month Aged Clips Review flow — tracks when "Keep" was last pressed |
| `user_downloads` | `podcast_id` | UUID FK → podcasts | Downloads tab: Podcasts sub-tab (761:22330) |
| `user_downloads` | `episode_id` | UUID FK → episodes | Downloads tab: Episodes sub-tab (761:22424) |
| `user_downloads` | `download_type` | download_type ENUM NOT NULL | Discriminator column for polymorphic download table |
| `episodes` | `transcript_source` | TEXT CHECK IN ('rss', 'whisper') | Tracks how transcript was obtained — RSS feed vs speech-to-text (dev note 925:14290) |
| `episodes` | `chapters_source` | TEXT CHECK IN ('rss', 'auto_generated') | Tracks how chapters were obtained — RSS feed vs auto-generated (dev note 925:14291) |

### New ENUM Types Added

| ENUM | Values | Purpose |
|------|--------|---------|
| `share_type` | `my_feed`, `copy_link`, `whatsapp`, `other` | Clip share channel; used in `clip_shares` |
| `system_collection_type` | `my_favorites`, `downloads`, `unprocessed_clips` | Identifies system-managed collections |
| `default_clip_length` | `30`, `45`, `60` | User's preferred clip duration in seconds |
| `download_type` | `podcast`, `episode`, `clip`, `collection` | Content type discriminator (used by deprecated `user_downloads`) |

### Business Rules Confirmed (Full 90-Design Review)

| Rule | Evidence |
|------|---------|
| Collections contain **only clips** (no episodes, no nested collections) | Product owner confirmed; collection_clips join table is sufficient |
| Free: max 15 user-created collections | Frame 587:25458 "6/15 free collections" counter |
| Free: max 5 clip share events total | Dev note 925:14322; enforced via `clip_shares` count in Edge Function |
| Premium: unlimited collections + shares | Upsell screens confirm |
| Public collections auto-appear on Social Feed | Dev note 908:9591 |
| Only user-generated clips can appear on Social Feed | Dev note 913:12677 |
| Clips have 3-month lifespan in collections before tidy-up warning | Dev note 587:22821; Collection Detail warning banner |
| Max clip duration: 60 seconds | Waveform note "Drag handles to trim clip (max 60s)" |
| Clip title is editable during Review Aged Clips flow | Review screen (567:24938) has editable title field |
| AI Collection button = Premium only | Player free vs premium comparison |
| "Make My Collection Private" toggle OFF = Public (counterintuitive) | Create/Edit sheet (556:7255) |
| Share limit tracking MUST be server-side | Users have UPDATE on their own profiles row — cannot trust client |
| Profile editing (avatar, name, password) is online-only | User confirmed — requires internet connection |
| "My Library" section appears on profile page **offline only** | User confirmed — online access to favorites/downloads via Collections tab |
| Episode-level transcripts are **free for all users** | Confirmed — distinct from clip AI transcripts (Premium). See Flows.md §19.2 |
| Clip quota per podcast defaults to **12** but must be dynamic | ~~Offline player "10/12" (739:15744)~~; **Updated:** Free users = 3–5 clips/episode (`app_config.free_clip_limit_per_episode`); Subscribed = unlimited (`app_config.premium_clip_limit_per_episode` = NULL for now); Figma "10/12" is placeholder. Stored in `app_config` table, not hardcoded |
| Clip aggregation uses **5–10 second window** for viral moment detection | Dev note 564:19218; overlapping clips within window are grouped |
| Episode tags extracted from RSS feed category/keyword fields | Dev note 925:14289; reuses `podcasts.categories` or `episodes` metadata |
| Transcript priority: RSS feed first, Whisper fallback | Dev note 925:14290; `episodes.transcript_source` tracks origin |
| Chapters priority: RSS feed first, auto-generation fallback | Dev note 925:14291; `episodes.chapters_source` tracks origin |
| Delete Account available **online only** | User confirmed — requires server call |
| Terms & Conditions must appear in **both** online and offline modes | User confirmed — cached locally for offline access |
| Notification toggles: online version (4 toggles) is authoritative | User confirmed — offline design (3 toggles) is outdated |
| AirPods gesture is **Double Tap** (not Triple Tap) | User confirmed — offline design notation was incorrect |
| Feature suggestions & bug reports stored in Supabase tables | User confirmed — `feature_suggestions` + `bug_reports` tables |
| Downloads use separate tables per content type | User confirmed — replaces polymorphic `user_downloads` table |

# ClipCast — Row-Level Security (RLS) Policies

> Derived from `ARCHITECTURE.md` Section 12 + new tables from Figma gap analysis.
> All tables have RLS **enabled**. Policies use `auth.uid()` to identify the current user.
> Last updated: 2025-07-17

---

## Table of Contents

1. [profiles](#1-profiles)
2. [clips](#2-clips)
3. [collections](#3-collections)
4. [collection_clips](#4-collection_clips)
5. [clip_engagement](#5-clip_engagement)
6. [comments](#6-comments)
7. [follows](#7-follows)
8. [notifications](#8-notifications)
9. [user_subscriptions](#9-user_subscriptions)
10. [playback_progress](#10-playback_progress)
11. [podcast_favourites](#11-podcast_favourites)
12. [podcasts & episodes](#12-podcasts--episodes)
13. [trending_podcasts](#13-trending_podcasts)
14. [offline_queue](#14-offline_queue)
15. [learning_preferences](#15-learning_preferences)
16. [clip_review_status](#16-clip_review_status)
17. [Backend-Only Operations](#17-backend-only-operations)
18. [Client-Side Allowed Operations](#18-client-side-allowed-operations)
19. [Secrets Management](#19-secrets-management)
20. [episode_favourites](#20-episode_favourites)
21. [clip_favourites](#21-clip_favourites)
22. [clip_shares](#22-clip_shares)
23. [notification_preferences](#23-notification_preferences)
24. [user_preferences](#24-user_preferences)
25. [feature_suggestions](#25-feature_suggestions)
26. [bug_reports](#26-bug_reports)
27. [downloaded_podcasts](#27-downloaded_podcasts)
28. [downloaded_episodes](#28-downloaded_episodes)
29. [downloaded_clips](#29-downloaded_clips)
30. [downloaded_collections](#30-downloaded_collections)
31. [podcast_subscriptions](#31-podcast_subscriptions)

---

## 1. `profiles`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `profiles_select` | SELECT | `USING (true)` | Anyone (including anonymous) can read public profile info |
| `profiles_insert` | INSERT | `WITH CHECK (auth.uid() = id)` | Profile row created on signup; user can only insert their own row |
| `profiles_update` | UPDATE | `USING (auth.uid() = id)` | Users can only edit their own display name, avatar, and bio |

> **Note:** `profiles_insert` is typically triggered by a Postgres function on `auth.users` insert, but the policy ensures direct client inserts are also restricted.

---

## 2. `clips`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `clips_select` | SELECT | `USING (is_public = TRUE OR user_id = auth.uid())` | Public clips visible to all; private clips visible only to owner |
| `clips_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only create clips attributed to themselves |
| `clips_update` | UPDATE | `USING (user_id = auth.uid())` | Users can only edit their own clips (title, tags, visibility) |
| `clips_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only delete their own clips |

> **Feed implication:** The `clips_select` policy automatically filters the Social Feed — users never see other users' private clips.

---

## 3. `collections`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `collections_select` | SELECT | `USING (is_private = FALSE OR user_id = auth.uid())` | Public collections visible to all; private ones only to owner |
| `collections_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only create collections under their own account |
| `collections_update` | UPDATE | `USING (user_id = auth.uid())` | Users can only rename/edit their own collections |
| `collections_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only delete their own collections |

> **Note:** New table from Figma gap analysis. Curated collections (`is_curated = TRUE`) are created by Edge Functions using service_role key. The `is_private` toggle is visible in Create/Edit Collection overlays.

---

## 4. `collection_clips`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `collection_clips_select` | SELECT | `USING (EXISTS (SELECT 1 FROM collections c WHERE c.id = collection_id AND (c.is_private = FALSE OR c.user_id = auth.uid())))` | Can only see clips in collections the user has access to |
| `collection_clips_insert` | INSERT | `WITH CHECK (EXISTS (SELECT 1 FROM collections c WHERE c.id = collection_id AND c.user_id = auth.uid()))` | Can only add clips to own collections |
| `collection_clips_delete` | DELETE | `USING (EXISTS (SELECT 1 FROM collections c WHERE c.id = collection_id AND c.user_id = auth.uid()))` | Can only remove clips from own collections |

> **Note:** New table from Figma gap analysis. Policies cascade from parent collection ownership.

---

## 5. `clip_engagement`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `engagement_select` | SELECT | `USING (true)` | Anyone can view engagement counts (likes, bookmarks) on clips |
| `engagement_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only create engagement records for themselves |
| `engagement_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own likes/bookmarks (unlike/unbookmark) |

> **No UPDATE policy:** Engagement records are immutable — they are inserted or deleted, never modified.

---

## 6. `comments`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `comments_select` | SELECT | `USING (true)` | Anyone can read comments on public clips |
| `comments_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only post comments under their own identity |
| `comments_update` | UPDATE | `USING (user_id = auth.uid())` | Users can only edit their own comments |
| `comments_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only delete their own comments |

---

## 7. `follows`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `follows_select` | SELECT | `USING (true)` | Anyone can see follow relationships (public social graph) |
| `follows_insert` | INSERT | `WITH CHECK (follower_id = auth.uid())` | Users can only follow others as themselves |
| `follows_delete` | DELETE | `USING (follower_id = auth.uid())` | Users can only unfollow (remove follows they initiated) |

> **No UPDATE policy:** Follow relationships are binary — created or deleted, never updated.

---

## 8. `notifications`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `notifications_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own notifications |
| `notifications_update` | UPDATE | `USING (user_id = auth.uid())` | Users can mark their own notifications as read |

> **No client INSERT policy:** Notifications are created exclusively by Edge Functions using the service_role key. This prevents spoofed notifications.

---

## 9. `user_subscriptions`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `subscriptions_select` | SELECT | `USING (user_id = auth.uid())` | Users can only view their own subscription status |

> **No client INSERT/UPDATE policies:** Subscription records are managed exclusively by the RevenueCat webhook Edge Function using the service_role key. This prevents subscription status manipulation.

---

## 10. `playback_progress`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `progress_select` | SELECT | `USING (user_id = auth.uid())` | Users can only read their own playback positions |
| `progress_upsert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only create progress records for themselves |
| `progress_update` | UPDATE | `USING (user_id = auth.uid())` | Users can only update their own playback position |

---

## 11. `podcast_favourites`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `favourites_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own favourited podcasts |
| `favourites_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only add favourites for themselves |
| `favourites_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own favourites |

---

## 12. `podcasts` & `episodes`

| Policy Name | Table | Operation | Rule | Description |
|-------------|-------|-----------|------|-------------|
| `podcasts_select` | podcasts | SELECT | `USING (true)` | All cached podcast metadata is publicly readable |
| `episodes_select` | episodes | SELECT | `USING (true)` | All cached episode metadata is publicly readable |

> **No client INSERT/UPDATE/DELETE policies:** Podcast and episode data is inserted and updated exclusively by Edge Functions (Taddy API sync, RSS fetch) using the service_role key.

---

## 13. `trending_podcasts`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `trending_select` | SELECT | `USING (true)` | Trending rankings are publicly readable (powers Homepage) |

> **No client INSERT/UPDATE/DELETE policies:** Trending data is refreshed by a cron Edge Function every 6 hours using the service_role key.

---

## 14. `offline_queue`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `queue_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own queued offline actions |
| `queue_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only queue actions for themselves |

> **Note:** This table is primarily a server-side audit copy. The main offline queue lives in the client's local SQLite (Drift) database.

---

## 15. `learning_preferences`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `learning_prefs_select` | SELECT | `USING (user_id = auth.uid())` | Users can only read their own learning preferences |
| `learning_prefs_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only create their own learning preferences row |
| `learning_prefs_update` | UPDATE | `USING (user_id = auth.uid())` | Users can only modify their own frequency, reminder, and onboarding settings |

> **Note:** One row per user (UNIQUE on `user_id`). Row is created during Learn onboarding or on first visit to Learn tab. No DELETE policy — preferences persist for the lifetime of the account (cleaned up via account deletion Edge Function).

---

## 16. `clip_review_status`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `review_status_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own review history |
| `review_status_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only mark their own clips as reviewed |

> **Note:** No UPDATE or DELETE policy — review records are append-only audit entries. If a clip is deleted, the CASCADE on `clip_id` FK removes related review records automatically.

---

## 17. Backend-Only Operations

These operations **MUST NEVER** run client-side. They require the Supabase `service_role` key, which is stored exclusively in Edge Function environment secrets.

| Operation | Reason | Edge Function |
|-----------|--------|---------------|
| AI transcription (Whisper) | OpenAI API key must not be exposed | `/functions/process-clip` |
| AI summary generation (GPT) | OpenAI API key must not be exposed | `/functions/process-clip` |
| Subscription management | RevenueCat webhook secret | `/webhooks/revenuecat` |
| Update `profiles.is_premium` flag | Business-critical entitlement flag | `/webhooks/revenuecat` |
| Send push notification | OneSignal REST API key | `/functions/notify` |
| Insert notification records | Prevents spoofed notifications | `/functions/notify` |
| Send transactional email | Resend API key | `/functions/send-email` |
| Podcast data sync from Taddy | Taddy API key + rate limiting | `/functions/sync-trending` |
| Generate S3 presigned upload URL | AWS secret access key | `/functions/get-upload-url` |
| Account deletion (GDPR hard delete) | Multi-table cascade, PII cleanup | `/functions/delete-account` |
| Clip share limit enforcement (server-side) | Free users limited to 5 total clip share events; must not be client-enforced | `/functions/enforce-clip-share-limit` |
| Create curated collections | System-level content curation | `/functions/curate-collections` |
| Premium download gating | Verify premium subscription before allowing download INSERT | `/functions/download-content` |
| Process feature suggestions / bug reports | Admin triage and status updates | Dashboard / service_role |

---

## 18. Client-Side Allowed Operations

| Operation | Table | Method | RLS Enforced |
|-----------|-------|--------|--------------|
| Read public clips, profiles, podcasts, episodes | Various | SELECT | ✅ |
| Create/update/delete own clips | `clips` | INSERT/UPDATE/DELETE | ✅ |
| Create/edit/delete own collections | `collections` | INSERT/UPDATE/DELETE | ✅ |
| Add/remove clips in own collections | `collection_clips` | INSERT/DELETE | ✅ |
| Like/bookmark clips | `clip_engagement` | INSERT/DELETE | ✅ |
| Comment on clips | `comments` | INSERT/UPDATE/DELETE | ✅ |
| Follow/unfollow users | `follows` | INSERT/DELETE | ✅ |
| Favourite/unfavourite podcasts | `podcast_favourites` | INSERT/DELETE | ✅ |
| Favourite/unfavourite episodes | `episode_favourites` | INSERT/DELETE | ✅ |
| Favourite/unfavourite clips | `clip_favourites` | INSERT/DELETE | ✅ |
| Log clip share event | `clip_shares` | INSERT | ✅ (Edge Function enforces free limit) |
| Update own profile | `profiles` | UPDATE | ✅ |
| Save/read playback progress | `playback_progress` | INSERT/UPDATE | ✅ |
| Mark notifications as read | `notifications` | UPDATE | ✅ |
| Queue offline actions | `offline_queue` | INSERT | ✅ |
| Create/update learning preferences | `learning_preferences` | INSERT/UPDATE | ✅ |
| Mark clips as reviewed | `clip_review_status` | INSERT | ✅ |
| View/toggle notification preferences | `notification_preferences` | SELECT/INSERT/UPDATE | ✅ |
| View/update app preferences | `user_preferences` | SELECT/INSERT/UPDATE | ✅ |
| Submit feature suggestion | `feature_suggestions` | INSERT | ✅ |
| View own feature suggestions | `feature_suggestions` | SELECT | ✅ |
| Submit bug report | `bug_reports` | INSERT | ✅ |
| View own bug reports | `bug_reports` | SELECT | ✅ |
| View/manage downloaded podcasts | `downloaded_podcasts` | SELECT/INSERT/DELETE | ✅ (Edge Function checks premium) |
| View/manage downloaded episodes | `downloaded_episodes` | SELECT/INSERT/DELETE | ✅ (Edge Function checks premium) |
| View/manage downloaded clips | `downloaded_clips` | SELECT/INSERT/DELETE | ✅ (Edge Function checks premium) |
| View/manage downloaded collections | `downloaded_collections` | SELECT/INSERT/DELETE | ✅ (Edge Function checks premium) |

---

## 20. `episode_favourites`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `ep_favourites_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own favourited episodes |
| `ep_favourites_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only add episode favourites for themselves |
| `ep_favourites_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own episode favourites |

> **New table (added 2025-07-16 from Collections Figma review).** Mirrors the pattern of `podcast_favourites` (§11). Surfaces in Collections → Favorites → Episodes sub-tab. No UPDATE policy — records are inserted or deleted only.

---

## 21. `clip_favourites`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `clip_favourites_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own favourited clips |
| `clip_favourites_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only add clip favourites for themselves |
| `clip_favourites_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own clip favourites |

> **New table (added 2025-07-16 from Collections Figma review).** Mirrors the pattern of `podcast_favourites` (§11). Surfaces in Collections → Favorites → Clips sub-tab and in clip options "Add to My Favorites". No UPDATE policy — records are inserted or deleted only.

---

## 22. `clip_shares`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `clip_shares_select` | SELECT | `USING (user_id = auth.uid())` | Users can only view their own share history |
| `clip_shares_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only log shares initiated by themselves |

> **New table (added 2025-07-16 from Collections Figma review).** This is an **append-only audit log** — no UPDATE or DELETE policies. This is by design: share events are immutable records used to enforce the free-tier 5-share limit.
>
> **Critical security note:** The 5-share limit for free users **MUST be enforced server-side** by the `/functions/enforce-clip-share-limit` Edge Function, which counts `clip_shares` rows for the user before permitting the INSERT. Client-side enforcement is UX-only and must not be relied upon for access control. The `profiles` table is not used for this counter — users have UPDATE on their own profile row, creating a manipulation risk.
>
> Share types: `my_feed`, `copy_link`, `whatsapp`, `other` (from `share_type` ENUM).

---

## 23. `notification_preferences`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `notif_prefs_select` | SELECT | `USING (user_id = auth.uid())` | Users can only view their own notification settings |
| `notif_prefs_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only create their own notification settings row |
| `notif_prefs_update` | UPDATE | `USING (user_id = auth.uid())` | Users can only toggle their own notification settings |

> **1:1 with profiles.** Row created on first visit to Notification Settings. No DELETE policy — toggles are flipped, not removed. Four toggles: `review_insights_enabled`, `new_episodes_enabled`, `social_enabled`, `clip_generation_enabled`.

---

## 24. `user_preferences`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `user_prefs_select` | SELECT | `USING (user_id = auth.uid())` | Users can only view their own app preferences |
| `user_prefs_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only create their own preferences row |
| `user_prefs_update` | UPDATE | `USING (user_id = auth.uid())` | Users can only change their own preferences |

> **1:1 with profiles.** Row created on first visit to Preferences or Gesture Control screens. Stores `default_clip_length` (30/45/60) and `gesture_double_tap_enabled` toggle. No DELETE policy.

---

## 25. `feature_suggestions`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `feature_suggestions_select` | SELECT | `USING (user_id = auth.uid())` | Users can only view their own submitted suggestions |
| `feature_suggestions_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only submit suggestions as themselves |

> **Append-only.** No UPDATE or DELETE policies — once submitted, feature suggestions are immutable from the client. Admin review happens via service_role in the dashboard.

---

## 26. `bug_reports`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `bug_reports_select` | SELECT | `USING (user_id = auth.uid())` | Users can only view their own submitted reports |
| `bug_reports_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only submit reports as themselves |

> **Append-only.** No UPDATE or DELETE policies — once submitted, bug reports are immutable from the client. Mirrors `feature_suggestions` pattern.

---

## 27. `downloaded_podcasts`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `dl_podcasts_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own downloaded podcasts |
| `dl_podcasts_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only download podcasts for themselves |
| `dl_podcasts_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own downloaded podcasts |

> **Premium only.** Download operations are gated by premium subscription check in the Edge Function before INSERT. No UPDATE policy — downloads are tracked, not modified.

---

## 28. `downloaded_episodes`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `dl_episodes_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own downloaded episodes |
| `dl_episodes_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only download episodes for themselves |
| `dl_episodes_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own downloaded episodes |

> **Premium only.** Same pattern as `downloaded_podcasts`.

---

## 29. `downloaded_clips`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `dl_clips_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own downloaded clips |
| `dl_clips_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only download clips for themselves |
| `dl_clips_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own downloaded clips |

> **Premium only.** Same pattern as `downloaded_podcasts`. Includes clips downloaded individually AND clips auto-downloaded as part of a collection download.

---

## 30. `downloaded_collections`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `dl_collections_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own downloaded collections |
| `dl_collections_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only download collections for themselves |
| `dl_collections_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only remove their own downloaded collections |

> **Premium only.** When a collection is downloaded, individual `downloaded_clips` rows are also inserted for each clip in the collection (handled by Edge Function). Same pattern as `downloaded_podcasts`.

---

## 31. `podcast_subscriptions`

| Policy Name | Operation | Rule | Description |
|-------------|-----------|------|-------------|
| `podcast_subs_select` | SELECT | `USING (user_id = auth.uid())` | Users can only see their own podcast subscriptions |
| `podcast_subs_insert` | INSERT | `WITH CHECK (user_id = auth.uid())` | Users can only subscribe themselves to podcasts |
| `podcast_subs_delete` | DELETE | `USING (user_id = auth.uid())` | Users can only unsubscribe themselves |

> **Free and Premium.** Notification subscription via the bell icon is available to all users (FR-48). Used to trigger OneSignal push notifications when new episodes are published. See Flows.md §4.1.

---

## 19. Secrets Management

| Secret | Storage | Accessed By | Client Exposure |
|--------|---------|-------------|----------------|
| OpenAI API Key | Supabase project secrets | Edge Functions only | ❌ Never |
| RevenueCat webhook secret | Supabase project secrets | `/webhooks/revenuecat` | ❌ Never |
| OneSignal REST API Key | Supabase project secrets | Edge Functions only | ❌ Never |
| Resend API Key | Supabase project secrets | Edge Functions only | ❌ Never |
| Taddy API Key | Supabase project secrets | Edge Functions only | ❌ Never |
| AWS Access Key + Secret | Supabase project secrets | Edge Functions only | ❌ Never |
| Supabase `service_role` key | Supabase project secrets | Edge Functions only | ❌ Never |
| Supabase `anon` key | Flutter app bundle | Client SDK | ✅ Public (RLS protects data) |
| RevenueCat public SDK key | Flutter app bundle | `purchases_flutter` SDK | ✅ Public |
| OneSignal App ID | Flutter app bundle | `onesignal_flutter` SDK | ✅ Public |

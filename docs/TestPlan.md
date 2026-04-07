# ClipCast — Test Plan

> Covers unit, widget, integration, and E2E testing strategy mapped to user flows,
> free vs premium gating, and critical paths.  
> Last updated: 2025-07-17

---

## Table of Contents

1. [Testing Philosophy](#1-testing-philosophy)
2. [Test Pyramid](#2-test-pyramid)
3. [Unit Tests](#3-unit-tests)
4. [Widget Tests](#4-widget-tests)
5. [Integration Tests](#5-integration-tests)
6. [E2E Tests](#6-e2e-tests)
7. [Free vs Premium Test Matrix](#7-free-vs-premium-test-matrix)
8. [Offline Test Scenarios](#8-offline-test-scenarios)
9. [Edge Function Tests](#9-edge-function-tests)
10. [Security Tests](#10-security-tests)
11. [Performance Benchmarks](#11-performance-benchmarks)
12. [CI/CD Pipeline](#12-cicd-pipeline)
13. [Test Data & Fixtures](#13-test-data--fixtures)

---

## 1. Testing Philosophy

| Principle | Rule |
|-----------|------|
| Coverage target | ≥80% for `data/` and `domain/` layers; ≥60% for `presentation/` |
| Critical paths | 100% test coverage for: auth, clip capture, payments, AI pipeline |
| Mocking | Mock Supabase, Taddy, OpenAI, S3 at the `RemoteSource` boundary |
| State management | Test Cubits/Blocs with `bloc_test` — every state transition |
| No flaky tests | Tests must not depend on network, real APIs, or timing |
| Test naming | `should <expected> when <condition>` |

---

## 2. Test Pyramid

```
         ╱╲
        ╱ E2E ╲          ~10 flows (Patrol / integration_test)
       ╱────────╲
      ╱Integration╲      ~40 scenarios (multi-widget, navigation)
     ╱──────────────╲
    ╱  Widget Tests   ╲   ~130 tests (isolated widget rendering)
   ╱────────────────────╲
  ╱     Unit Tests        ╲ ~400+ tests (repos, cubits, models, utils)
 ╱──────────────────────────╲
```

### Packages

| Package | Purpose |
|---------|---------|
| `flutter_test` | Widget + unit tests |
| `bloc_test` | Cubit/Bloc state testing |
| `mocktail` | Mocking dependencies |
| `integration_test` | On-device integration tests |
| `patrol` | E2E testing with native interactions |

---

## 3. Unit Tests

### 3.1 Domain Models

| Test File | Class Under Test | Key Assertions |
|-----------|-----------------|----------------|
| `podcast_test.dart` | `Podcast` | fromJson, toJson, equality, copyWith |
| `episode_test.dart` | `Episode` | fromJson, toJson, duration formatting |
| `clip_test.dart` | `Clip` | fromJson, toJson, sync_status transitions |
| `collection_test.dart` | `Collection` | fromJson, toJson, clip_count |
| `profile_test.dart` | `Profile` | fromJson, is_premium flag |
| `subscription_test.dart` | `UserSubscription` | status enum, expiry logic |
| `notification_test.dart` | `AppNotification` | fromJson, type mapping |
| `notification_preferences_test.dart` | `NotificationPreferences` | fromJson, toJson, all 4 toggle defaults = true |
| `user_preferences_test.dart` | `UserPreferences` | fromJson, toJson, default_clip_length = 45, gesture default = true |
| `feature_suggestion_test.dart` | `FeatureSuggestion` | fromJson, toJson, required title, optional description |
| `bug_report_test.dart` | `BugReport` | fromJson, toJson, required title, optional description |
| `podcast_subscription_test.dart` | `PodcastSubscription` | fromJson, toJson, equality (user_id + podcast_id) |
| `episode_transcript_segment_test.dart` | `EpisodeTranscriptSegment` | fromJson, toJson, equality, segment_order sorting |
| `app_config_test.dart` | `AppConfig` | fromJson, toJson, value parsing (int, string, object) |

### 3.2 Repositories

| Test File | Class Under Test | Scenarios |
|-----------|-----------------|-----------|
| `podcast_repository_test.dart` | `PodcastRepository` | search returns results, cache hit, cache miss → Taddy call, error handling |
| `episode_repository_test.dart` | `EpisodeRepository` | fetch by podcast, pagination, empty list |
| `clip_repository_test.dart` | `ClipRepository` | save clip (online), queue offline, sync on reconnect, upload to S3 |
| `collection_repository_test.dart` | `CollectionRepository` | CRUD, add/remove clips, reorder, copy |
| `feed_repository_test.dart` | `FeedRepository` | trending feed, friends feed, my feed, pagination |
| `social_repository_test.dart` | `SocialRepository` | follow, unfollow, follower list |
| `auth_repository_test.dart` | `AuthRepository` | Google sign-in, Apple sign-in, sign-out, session restore |
| `subscription_repository_test.dart` | `SubscriptionRepository` | check entitlement, purchase, restore |
| `notification_repository_test.dart` | `NotificationRepository` | fetch list, mark read, pagination |
| `playback_repository_test.dart` | `PlaybackRepository` | save progress, resume, update speed |
| `profile_repository_test.dart` | `ProfileRepository` | fetch profile, update avatar, update name, change password, delete account |
| `notification_prefs_repository_test.dart` | `NotificationPrefsRepository` | fetch prefs (create on miss), toggle each of 4 switches |
| `user_prefs_repository_test.dart` | `UserPrefsRepository` | fetch prefs (create on miss), update clip length, toggle gesture |
| `feedback_repository_test.dart` | `FeedbackRepository` | submit feature suggestion, submit bug report, fetch own suggestions |
| `download_repository_test.dart` | `DownloadRepository` | fetch downloaded podcasts/episodes/clips/collections, add download, remove download, premium gate check |
| `podcast_subscription_repository_test.dart` | `PodcastSubscriptionRepository` | subscribe (insert), unsubscribe (delete), check if subscribed, fetch all subscriptions for user |
| `episode_transcript_repository_test.dart` | `EpisodeTranscriptRepository` | fetch segments by episode_id (ordered), paginated fetch, empty transcript (no segments), cache hit |
| `app_config_repository_test.dart` | `AppConfigRepository` | fetch config by key, fetch all, cache on startup, fallback to default when key missing |
| `clip_quota_repository_test.dart` | `ClipQuotaRepository` | get quota for podcast (from app_config), get remaining clips (quota − user clip count), enforce limit |

### 3.3 Cubits / Blocs

| Test File | Class Under Test | State Transitions Tested |
|-----------|-----------------|--------------------------|
| `auth_cubit_test.dart` | `AuthCubit` | Initial → Authenticated, Initial → Unauthenticated, Error |
| `home_cubit_test.dart` | `HomeCubit` | Loading → Loaded (trending + recent), Loading → Error |
| `search_cubit_test.dart` | `SearchCubit` | Initial → Searching → Results, Empty, Error, debounce |
| `podcast_detail_cubit_test.dart` | `PodcastDetailCubit` | Loading → Loaded (podcast + episodes), Favourited/Unfavourited |
| `player_bloc_test.dart` | `PlayerBloc` | Initial → Loading → Playing → Paused → Seeking → Playing, Buffering, Error, ClipCaptured |
| `clip_cubit_test.dart` | `ClipCubit` | Capturing → Processing → Saved, Offline queued, Upload failed → retry |
| `collection_cubit_test.dart` | `CollectionCubit` | Loading → Loaded, Create, Edit, Delete, Add clip, Remove clip |
| `feed_cubit_test.dart` | `FeedCubit` | Loading → Loaded, Tab switch (Trending/Friends/MyFeed), Pagination |
| `follow_cubit_test.dart` | `FollowCubit` | Followed → Unfollowed, follower count update |
| `subscription_cubit_test.dart` | `SubscriptionCubit` | Free → Purchasing → Premium, Restore, Error |
| `connectivity_cubit_test.dart` | `ConnectivityCubit` | Online → Offline → Online, trigger sync |
| `profile_cubit_test.dart` | `ProfileCubit` | Loading → Loaded (profile + stats), Update avatar, Update name, Error |
| `notification_prefs_cubit_test.dart` | `NotificationPrefsCubit` | Loading → Loaded (4 toggles), Toggle each → Updated, Error |
| `user_prefs_cubit_test.dart` | `UserPrefsCubit` | Loading → Loaded, Change clip length (30/45/60), Toggle gesture, Error |
| `feedback_cubit_test.dart` | `FeedbackCubit` | Initial → Submitting → Submitted (success toast), Validation error (empty title) |
| `downloads_cubit_test.dart` | `DownloadsCubit` | Loading → Loaded (4 tabs), Tab switch, Remove download, Empty state |
| `podcast_page_cubit_test.dart` | `PodcastPageCubit` | Loading → Loaded (metadata + episodes + clips), Tab switch (Episodes/Clips/About/More Like This), Favourite toggle, Subscription toggle, Error |
| `episode_filter_cubit_test.dart` | `EpisodeFilterCubit` | Initial (All + Newest), Change filter (All/Downloaded/Not Finished), Change sort (Newest/Oldest), Reset |
| `clip_filter_cubit_test.dart` | `ClipFilterCubit` | Initial (Trending + Newest), Change filter (Trending/My Clips), Change sort (Newest/Oldest), Reset |
| `episode_player_cubit_test.dart` | `EpisodePlayerCubit` | Loading → Playing → Paused → Seeking, Speed change, Share, Previous/Next, Save progress, Background playback |
| `episode_details_cubit_test.dart` | `EpisodeDetailsCubit` | Loading → Loaded (metadata + transcript status + chapter count + clip count), Toggle favourite, Download (premium gate), Error |
| `episode_transcript_cubit_test.dart` | `EpisodeTranscriptCubit` | Loading → Loaded (segments list), Paginate next batch, Tap timestamp → seek event, Empty transcript state |
| `episode_chapters_cubit_test.dart` | `EpisodeChaptersCubit` | Loading → Loaded (chapters list from JSONB), Tap chapter → seek event |
| `episode_clips_cubit_test.dart` | `EpisodeClipsCubit` | Loading → Loaded (trending clips), Filter switch (Trending ↔ My Clips), Sort change (Newest/Oldest), Pagination |

### 3.4 Utilities

| Test File | Functions | Scenarios |
|-----------|-----------|-----------|
| `duration_formatter_test.dart` | `formatDuration()` | seconds → "1:23", hours → "1:23:45", zero |
| `date_formatter_test.dart` | `formatRelativeDate()` | today, yesterday, last week, months ago |
| `share_url_builder_test.dart` | `buildShareUrl()` | valid share_token → URL, null token → fallback |
| `genre_mapper_test.dart` | `mapTaddyGenre()` | Each Taddy genre → one of 7 ClipCast categories (Business, News & Current Affairs, Technology, Education, Health & Wellbeing, Culture & Society, Other); unmapped genres → Other |

---

## 4. Widget Tests

### 4.1 Shared Widgets

| Test File | Widget | Key Assertions |
|-----------|--------|----------------|
| `podcast_card_test.dart` | `PodcastCard` | Renders artwork, title, publisher, tap callback |
| `episode_card_test.dart` | `EpisodeCard` | Renders title, duration, date, play button |
| `clip_card_test.dart` | `ClipCard` | Renders clip title, episode info, waveform thumbnail |
| `feed_card_test.dart` | `FeedCard` | Premium: shows takeaways. Free: shows blur + lock overlay |
| `feed_card_my_feed_test.dart` | `MyFeedCard` | Premium: taller card with takeaways. Free: shorter card without takeaways. No avatar/follow button (own content) |
| `feed_card_collection_test.dart` | `FeedCollectionCard` | Collection title, 2x2 image grid with "+N" overflow, total duration, clip count, like/comment/share actions |
| `feed_empty_state_test.dart` | `FeedEmptyState` | Friends: "No friends sharing yet" + "Explore Podcasts" CTA + "Browse trending content" link. My Feed: "Share your first clip" + same CTAs |
| `comments_bottom_sheet_test.dart` | `CommentsBottomSheet` | Drag handle, "Comments" header, comment list (avatar + username + timestamp + body), "Add a comment..." input, submit |
| `share_clip_sheet_test.dart` | `ShareClipSheet` | Podcast + episode info, clip title, waveform preview with playback controls, 4 share options (MyFeed, Copy Link, WhatsApp, More) for ALL user types |
| `share_collection_sheet_test.dart` | `ShareCollectionSheet` | Collection name + stats, 4 share options (MyFeed, Copy Link, WhatsApp, More), label reads "Share your collection with" (not "clip") |
| `mini_player_test.dart` | `MiniPlayer` | Shows title, play/pause, progress bar |
| `collection_tile_test.dart` | `CollectionTile` | Name, clip count, duration, artwork grid |
| `premium_gate_test.dart` | `PremiumGate` | Free user: shows upgrade CTA. Premium: shows child content |
| `offline_banner_test.dart` | `OfflineBanner` | Visible when offline, hidden when online |
| `sync_progress_test.dart` | `SyncProgress` | Shows "Syncing 8/12 clips" with progress bar |
| `empty_state_test.dart` | `EmptyState` | Correct icon + message for each context |

### 4.2 Screen Tests

| Test File | Screen | Key Assertions |
|-----------|--------|----------------|
| `home_screen_test.dart` | `HomeScreen` | Trending section, recent clips, tab navigation |
| `search_screen_test.dart` | `SearchScreen` | Categories grid, search input, results rendering |
| `podcast_detail_screen_test.dart` | `PodcastDetailScreen` | Podcast info, episode list, favourite toggle, 4 tab bar (Episodes/Clips/About/More Like This), notification bell toggle, ⋯ menu |
| `episode_filter_sort_sheet_test.dart` | `EpisodeFilterSortSheet` | 3 filter options (All/Downloaded/Not Finished), 2 sort options (Newest/Oldest), Cancel button, selected state highlight |
| `clip_filter_sort_sheet_test.dart` | `ClipFilterSortSheet` | 2 filter options (Trending/My Clips), 2 sort options (Newest/Oldest), Cancel button, selected state highlight |
| `episode_more_details_sheet_test.dart` | `EpisodeMoreDetailsSheet` | Episode thumbnail + title, "Add to My Favorites" action, "Download Episode" action (premium gate) |
| `podcast_more_details_sheet_test.dart` | `PodcastMoreDetailsSheet` | Podcast thumbnail + title, "Add to My Favorites" action, "Download Podcast" action (TBD) |
| `clip_more_details_sheet_test.dart` | `ClipMoreDetailsSheet` | 5 actions rendered: Add to Favorites, Download Clip (premium gate), Go to Episode, Go to Podcast, Share Clip |
| `episode_player_screen_test.dart` | `EpisodePlayerScreen` | "Now Playing from" header, artwork, progress bar, play/pause/prev/next/share controls, speed toggle, "Add to My Collection" CTA, "Show Transcript" overlay |
| `download_upsell_sheet_test.dart` | `DownloadUpsellSheet` | Lock badge icon, upsell text, "Explore Premium" button, Cancel link |
| `podcast_about_tab_test.dart` | `PodcastAboutTab` | Description text, Hosts & Guests section with avatars + names + roles |
| `more_like_this_tab_test.dart` | `MoreLikeThisTab` | Recommended podcasts carousel, podcast cards with artwork + title + episode count, tap navigation |
| `collections_screen_test.dart` | `CollectionsScreen` | List of collections, create button, empty state |
| `collection_detail_screen_test.dart` | `CollectionDetailScreen` | Clips list, play all, edit, delete |
| `feed_screen_test.dart` | `FeedScreen` | 3-tab bar (Trending/Friends/My Feed), tab switching, card rendering per tab, scroll/pagination, empty states for first-time users on Friends and My Feed tabs |
| `paywall_screen_test.dart` | `PaywallScreen` | Price displayed, features list, CTA buttons |
| `learn_screen_test.dart` | `LearnScreen` | Weekly insights banner, clip list with filters, empty state, settings gear, mini player |
| `learn_onboarding_test.dart` | `LearnOnboardingScreen` | 4-step carousel (progress dots, Continue/Skip), frequency selection, reminder setup, "Start Learning" button |
| `learn_review_test.dart` | `ReviewWeeklyInsightsScreen` | Segmented progress bar, clip title (editable), audio player with drag handles, Insights/Takeaways sections, My Notes field, Add to Collection + Delete Clip buttons, completion screen |
| `learning_settings_test.dart` | `LearningSettingsScreen` | Frequency card, reminder card, sub-screen radio/toggle/chips |
| `profile_hub_screen_test.dart` | `ProfileHubScreen` | Online: Account Settings, Share Feedback, T&C, Logout, Delete Account sections. Offline: My Library section at top, Delete Account hidden |
| `profile_settings_screen_test.dart` | `ProfileSettingsScreen` | Avatar + camera icon, name field, change password, followers/following counts, save button |
| `followers_sheet_test.dart` | `FollowersSheet` | List of followers with avatar + name + Follow/Following button, Cancel |
| `following_sheet_test.dart` | `FollowingSheet` | List of following with avatar + name + Following button, Cancel |
| `notification_settings_screen_test.dart` | `NotificationSettingsScreen` | 4 toggles rendered (Review Insights, New Episodes, Social, Clip Generation), toggle state persistence |
| `gesture_control_screen_test.dart` | `GestureControlScreen` | "AirPods Double Tap" label, toggle ON/OFF, clip duration description |
| `preferences_screen_test.dart` | `PreferencesScreen` | 3 radio buttons (30s/45s/60s), selected state, save updates |
| `suggest_feature_screen_test.dart` | `SuggestFeatureScreen` | Title + Description fields, Submit button, validation (empty title), success toast |
| `report_bug_screen_test.dart` | `ReportBugScreen` | Title + Description fields, Submit button, validation (empty title), success toast |
| `my_favorites_screen_test.dart` | `MyFavoritesScreen` | Podcasts + Episodes tabs, list rendering, heart icon, empty state |
| `downloads_screen_test.dart` | `DownloadsScreen` | 4 tabs (Podcasts/Episodes/Clips/Collections), list rendering, download icon, empty state |
| `terms_conditions_screen_test.dart` | `TermsConditionsScreen` | Renders T&C content, works in both online and offline modes |
| `episode_details_screen_test.dart` | `EpisodeDetailsScreen` | Episode artwork, title, author, date, duration, tag, description, download/share/⋯ icons, play button, Transcript/Clips/Chapters rows, playing state (pause icon + 30m left + progress bar) |
| `episode_transcript_screen_test.dart` | `EpisodeTranscriptScreen` | Speaker segments with names + timestamps + content, tap timestamp → seek, mini player bar when playing |
| `episode_chapters_screen_test.dart` | `EpisodeChaptersScreen` | Numbered chapter list with thumbnails + titles + descriptions + timestamps, tap chapter → seek, mini player bar |
| `episode_clips_screen_test.dart` | `EpisodeClipsScreen` | Trending clips list (social-card style), filter icon → filter sheet, My Clips page |
| `episode_more_details_sheet_v2_test.dart` | `EpisodeMoreDetailsSheet` (§19.6) | Drag handle, episode thumbnail + title + author, 3 actions: Add to Favorites, Download Episode (premium gate), Podcast Details |
| `offline_episode_player_test.dart` | `OfflineEpisodePlayerScreen` | "You're offline" banner, Downloaded badge, artwork with Show Chapters/Transcript overlays, waveform progress, playback controls, Generate Clip CTA, clip quota card (10/12), fair usage text |
| `offline_clip_success_sheet_test.dart` | `OfflineClipSuccessSheet` | Check icon, sync message, Learn collection message, clip title preview, Review Now CTA |

---

## 5. Integration Tests

Run on device/emulator with mocked backends.

| # | Test | Flow | Tables Involved | Pass Criteria |
|---|------|------|-----------------|---------------|
| I-01 | Auth → Google Sign-In | Launch → tap Google → authenticated → home | `profiles` | User profile created, home screen visible |
| I-02 | Auth → Apple Sign-In | Launch → tap Apple → authenticated → home | `profiles` | Same as above |
| I-03 | Search → Podcast Detail | Search "Modern Wisdom" → tap result → detail | `podcasts`, `episodes` | Episode list loads, artwork visible |
| I-04 | Podcast → Episode → Play | Podcast detail → tap episode → player | `episodes`, `playback_progress` | Audio plays, progress saves |
| I-05 | Player → Capture Clip | Playing → tap capture → clip created | `clips` | Clip appears in library, status = local |
| I-06 | Clip → Upload → AI Processing | Clip saved → upload → processing → done | `clips` (S3, Edge Fn) | transcript populated, ai_summary (premium) |
| I-07 | Collections CRUD | Create → add clip → view → edit → delete | `collections`, `collection_clips` | All operations succeed, UI updates |
| I-08 | Feed → Like + Comment | Open feed → like card → comment | `clip_engagement`, `comments` | Like count increments, comment appears |
| I-09 | Follow User | View profile → follow → check friends feed | `follows`, feed_view | Followed user's clips appear in Friends tab |
| I-09a | Feed → My Feed Tab | Open feed → switch to My Feed tab | `clips` | User's shared clips/collections shown, no avatar/follow buttons |
| I-09b | Feed → Friends Empty State | First-time user → feed → Friends tab | `follows` | Empty state with "No friends sharing yet" + CTAs |
| I-09c | Feed → My Feed Empty State | First-time user → feed → My Feed tab | `clips` | Empty state with "Share your first clip" + CTAs |
| I-09d | Feed → Comments | Open feed → tap comment icon → add comment | `comments`, `notifications` | Comments bottom sheet opens, comment submits, notification generated |
| I-09e | Feed → Share Clip (Free) | Free user → feed → share → all 4 options visible | `clip_shares` | MyFeed + Copy Link + WhatsApp + More shown, share counts toward 5 limit |
| I-09f | Feed → Share Clip Quota | Free user with 5 shares → tap share | `clip_shares` | Upsell: "Want to share unlimited clips?" → Explore Premium / Cancel |
| I-09g | Feed → Share Collection | Feed → share collection → My Feed | `collections` | Collection becomes public, appears in Social Feed |
| I-10 | Premium Purchase | Free user → paywall → purchase → verify | `user_subscriptions`, `profiles` | `is_premium = true`, gated features unlock |
| I-11 | Learn Onboarding | First open Learn tab → carousel → frequency → reminder → main screen | `learning_preferences` | Preferences row created, onboarding_completed = TRUE |
| I-12 | Learn Review Flow | Learn tab → "Start Now" → review clips 1-by-1 → completion | `clips`, `clip_review_status` | All clips marked reviewed, completion screen with stats |
| I-13 | Learn → Add to Collection | Review clip → "Add to Collection" → select → Done | `collection_clips` | Toast "Clip added to collection", clip in collection |
| I-14 | Learn → Create Collection | Review clip → "Add to Collection" → "Create New" → title → create | `collections`, `collection_clips` | Toast "Collection Created Successfully", clip added |
| I-15 | Learn → Delete Clip | Review clip → "Delete Clip" → confirm | `clips`, `clip_review_status` | Clip deleted, toast "Clip is deleted", progress updates |
| I-16 | Learn Settings Update | Settings → change frequency to Monthly → disable reminder | `learning_preferences` | Preferences row updated, UI reflects changes |
| I-17 | Profile Edit Flow | Profile → Settings → change name → save | `profiles` | Name updated in DB and UI |
| I-18 | Notification Prefs Toggle | Profile → Notification Settings → toggle Social OFF → back → re-enter | `notification_preferences` | Social toggle persisted as OFF |
| I-19 | Gesture Control Toggle | Profile → Gestures → toggle OFF → back → re-enter | `user_preferences` | Gesture toggle persisted as OFF |
| I-20 | Clip Length Change | Profile → Preferences → select 60s → back → re-enter | `user_preferences` | 60s radio selected, persisted |
| I-21 | Submit Feature Suggestion | Profile → Suggest New Feature → fill form → Submit → toast | `feature_suggestions` | Row inserted, success toast shown |
| I-22 | Submit Bug Report | Profile → Report a Bug → fill form → Submit → toast | `bug_reports` | Row inserted, success toast shown |
| I-23 | Episode Favourite Toggle | Podcast → Episode → favourite → check My Favorites | `episode_favourites` | Episode appears in My Favorites → Episodes tab |
| I-24 | Downloads View (Premium) | Premium → download podcast → Profile → Downloads → Podcasts tab | `downloaded_podcasts` | Downloaded podcast listed |
| I-25 | Delete Account | Profile → Delete Account → confirm → signed out | `profiles` (Edge Fn cascade) | Account deleted, redirect to sign-in |
| I-26 | Podcast Page Episodes Tab | Search → Podcast → Episodes tab → scroll | `podcasts`, `episodes` | Episode list loads with count, cards show metadata |
| I-27 | Podcast Page Clips Tab | Podcast → Clips tab → scroll | `clips`, `profiles` | Trending clips load, author avatars + Follow buttons visible |
| I-28 | Podcast Page About Tab | Podcast → About tab | `podcasts` | Description + Hosts & Guests displayed |
| I-29 | Podcast Page More Like This | Podcast → More Like This tab → tap recommended | `podcasts` | Carousel loads, tap navigates to new podcast page |
| I-30 | Podcast Favourite Toggle | Podcast → Add to Favorites → check My Favorites | `podcast_favourites` | Podcast appears/disappears in My Favorites |
| I-31 | Podcast Subscription Toggle | Podcast → tap bell → re-enter → verify bell state | `podcast_subscriptions` | Bell icon reflects subscribed state, row created/deleted |
| I-32 | Episode Filter & Sort | Podcast → Episodes → filter icon → Not Finished → Oldest | `episodes`, `playback_progress` | Filtered list updates, sort order correct |
| I-33 | Clip Filter & Sort | Podcast → Clips → filter icon → My Clips → Newest | `clips` | Filtered list shows only user's clips |
| I-34 | Episode More Details Sheet | Podcast → Episodes → ⋯ on episode → Add to Favorites | `episode_favourites` | Episode favourited, sheet dismisses |
| I-35 | Episode Download Upsell (Free) | Free user → Podcast → Episodes → download icon | `user_downloads` | Upsell sheet shown with "Explore Premium" |
| I-36 | Episode Download (Premium) | Premium → Podcast → Episodes → download icon | `downloaded_episodes` | Episode downloaded, download icon updates |
| I-37 | Episode Player Full Flow | Podcast → episode → full player → play → seek → share | `episodes`, `playback_progress` | Audio plays, progress saves, share sheet opens |
| I-38 | Clip More Details Sheet | Podcast → Clips → ⋯ → Go to Podcast | `clips` | Navigates back to podcast page |
| I-39 | Add to Collection from Player | Episode player → "Add to My Collection" → select → Done | `collection_clips` | Toast shown, clip added to selected collection |
| I-40 | Podcast → Episode Details | Podcast → tap episode card → Episode Details page | `episodes` | Episode Details loads with metadata, transcript row, clips row, chapters |
| I-41 | Episode Details → Play | Episode Details → tap Play → Episode Player | `episodes`, `playback_progress` | Player opens, audio plays |
| I-42 | Episode Details Playing State | Episode Details with active playback | `playback_progress` | Pause icon, "30m left", progress bar visible |
| I-43 | Episode Details → Transcript | Episode Details → tap "Episode Transcript >" → Transcript screen | `episode_transcripts` | Speaker segments load with timestamps |
| I-44 | Episode Details → Chapters | Episode Details → tap chapter list → Chapters screen | `episodes.chapters` | Numbered chapters with thumbnails + timestamps |
| I-45 | Episode Details → Clips | Episode Details → tap "Clips >" → Clips screen | `clips` | Trending clips load, filter icon visible |
| I-46 | Episode Clips → My Clips | Clips → filter → My Clips | `clips` | Only user's clips shown |
| I-47 | Episode More Details Sheet (§19) | Episode Details → ⋯ → Add to Favorites | `episode_favourites` | Episode favourited, sheet dismisses |
| I-48 | Episode Download from Details (Free) | Free user → Episode Details → download icon | — | Upsell sheet shown |
| I-49 | Episode Download from Details (Premium) | Premium → Episode Details → download icon | `downloaded_episodes` | Episode downloaded |
| I-50 | Offline Episode Player | Premium + downloaded + offline → open episode | local cache | Offline banner, waveform, playback works |
| I-51 | Offline Clip Generation | Offline Episode Player → Generate Clip | `clips` (local) | Success sheet, clip queued for sync |
| I-52 | Clip Quota Enforcement | Generate clips until quota reached | `app_config`, `clips` | Quota bar updates, limit sheet shown, CTA disabled after "Continue without clipping" |
| I-53 | Episode Player — Chapters Overlay | Player → tap "Show Chapters" on artwork | `episodes.chapters` | Chapter list overlaid on artwork, current chapter cyan-highlighted, tap chapter seeks |
| I-54 | Episode Player — Transcript Overlay | Player → tap "Show Transcript" on artwork | `episode_transcripts` | Collapsed transcript on artwork, expand to full-screen, tap timestamp seeks |
| I-55 | Episode Player — Generate Clip (Premium) | Premium → Player → tap "Generate Clip" | `clips` | Success sheet with "Review Now", subtle audio cue, quota decrements |
| I-56 | Episode Player — Generate Clip (Free) | Free → Player → tap "Generate Clip" | `clips` | Success sheet auto-dismisses (no "Review Now"), subtle audio cue |
| I-57 | Episode Player — Clip Review (Premium) | Premium → Generate Clip → Review Now | `clips` | Key Takeaways, Transcript, Add to Collection, Edit actions |
| I-58 | Episode Player — Clip Limit (Free) | Free → generate 3–5 clips → limit reached | `app_config`, `clips` | "Upgrade to Premium" + "Continue without clipping" shown, CTA disabled |
| I-59 | Episode Player — ⋯ More Menu | Player → tap ⋯ → verify 7 items | — | View Clips, Clipping Preference, Gesture Controls, Add to Favorites, Download Episode, Play Next, Episode Details |
| I-60 | Episode Player — Download Episode (Free) | Free → Player → ⋯ → Download Episode | — | Download upsell sheet shown |
| I-61 | Episode Player — Episode Complete | Play episode to end | `episodes` | Episode Complete screen: Replay, Play Next (#218), Review Your Clips with count |
| I-62 | Episode Player — Audio Ads (Free) | Free → listen to 4–5 clips → ad triggers | — | 6–10s audio ad, ad overlay with "Ad" badge + countdown, controls dimmed, "Explore Premium" |
| I-63 | Episode Player — First-Time Tooltips | First episode play ever → tooltips shown | `profiles` or local | 2-step clip onboarding carousel shown on first play, not shown on subsequent plays |
| I-64 | Episode Player — Press & Hold Clip Duration | Player → press & hold "Generate Clip" | — | Duration picker appears, clip generated with selected duration |
| I-65 | Episode Player — Add to Favorites via ⋯ | Player → ⋯ → "Add to My Favorites" | `episode_favourites` | Toast confirmation shown, episode favourited |

---

## 6. E2E Tests

Full end-to-end with real (staging) backend. Run manually before each release.

| # | Scenario | Steps | Expected |
|---|----------|-------|----------|
| E-01 | New user onboarding | Install → onboarding → Google sign-in → home | Homepage with trending content |
| E-02 | Discovery → Clip → Share | Home → search → podcast → play → clip → share | Share sheet opens with valid URL |
| E-03 | Offline clip capture | Airplane mode → clip → reconnect → sync | Clip syncs, becomes processed |
| E-04 | Premium upgrade | Free → hit gate → paywall → sandbox purchase | AI takeaways visible, feed unlocked |
| E-05 | Collection playback | Create collection → add 3 clips → play all | Sequential playback with next/prev |
| E-06 | Social engagement | Follow user → their clip in feed → like + comment → notification | Notification delivered |
| E-07 | Account deletion | Settings → delete account → confirm | All data removed, redirected to sign-in |
| E-08 | App resume | Background app → resume after 10 minutes | Session restored, mini player intact |
| E-09 | Deep link | Open shared clip URL → app opens to clip detail | Correct clip displayed |
| E-10 | Push notification | Receive push → tap → navigate to source | Correct screen opens |

---

## 7. Free vs Premium Test Matrix

Tests asserting correct gating behaviour.

| Feature | Test | Free User Expected | Premium User Expected |
|---------|------|--------------------|-----------------------|
| Social Feed Takeaways | `feed_card_premium_gate_test.dart` | Blur + lock icon + "Premium Feature" | Full takeaways text visible |
| Friends Feed Takeaways | `feed_card_friends_gate_test.dart` | Blur + "Upgrade to view AI-generated insights" | Full text |
| My Feed Card Height | `my_feed_card_test.dart` | Compact card (no takeaways section) | Taller card with takeaways |
| Share Clip Options | `share_clip_options_gate_test.dart` | 4 options (MyFeed, Copy Link, WhatsApp, More) + 5-share limit | 4 options, unlimited shares |
| Share Collection Options | `share_collection_options_gate_test.dart` | 4 options + shares count toward 5 limit | 4 options, unlimited |
| Feed Empty States | `feed_empty_state_gate_test.dart` | Friends + My Feed empty states with CTAs (first-time) | Same empty states if no content |
| Comments Access | `comments_gate_test.dart` | Full access (no gating) | Full access (no gating) |
| AI Insights (Clip Detail) | `clip_detail_ai_test.dart` | Insights section hidden or upgrade prompt | Insights + Takeaways visible |
| Learn Review Insights | `learn_review_insights_gate_test.dart` | Insights locked overlay with crown icon + "Upgrade to view AI-generated Insights" | Insights text visible |
| Learn Review Takeaways | `learn_review_takeaways_gate_test.dart` | Key Takeaways locked overlay with crown icon | Key Takeaways bullet list visible |
| Learn Clip Detail Transcript | `learn_clip_detail_transcript_test.dart` | AI Transcript hidden or upgrade prompt | AI Transcript quoted text visible |
| Learn Clip Detail Takeaways | `learn_clip_detail_takeaways_test.dart` | Key Takeaways hidden or upgrade prompt | Key Takeaways bullet list visible |
| Clip Capture Limit | `clip_capture_limit_test.dart` | Max 3–5 clips per episode → "Upgrade to Premium" + "Continue without clipping" | Unlimited clips per episode |
| Offline Download | `offline_download_test.dart` | Download button disabled + upgrade prompt | Download available |
| Downloads Tab View | `downloads_tab_gate_test.dart` | Downloads tab shows upgrade prompt or empty | Downloads tab shows downloaded content |
| Profile Edit (online-only) | `profile_edit_gate_test.dart` | Edit button visible (both tiers) | Edit button visible (both tiers) |
| Ad-free Playback | `player_ads_test.dart` | Audio ads (6–10s) after 4–5 clips listened, ad overlay with countdown | No ads |
| AI Processing | `clip_processing_test.dart` | `ai_summary = null`, `ai_takeaways = null` | Both populated |
| Clip Review Access | `clip_review_gate_test.dart` | Clip success auto-dismisses, no "Review Now" | "Review Now" button, full review with takeaways/transcript |
| Episode Player ⋯ Download | `player_download_gate_test.dart` | ⋯ → "Download Episode" → upsell sheet | ⋯ → "Download Episode" → downloads + toast |
| Episode Download Gate | `episode_download_gate_test.dart` | Tap download → upsell sheet (588:36291) "Want to Download Episodes?" | Episode downloads to local storage |
| Clip Download Gate | `clip_download_gate_test.dart` | Tap "Download Clip" in Clip More Details → upsell sheet | Clip downloads to local storage |
| Podcast Page Browsing | `podcast_page_free_test.dart` | All 4 tabs accessible, all content visible | All 4 tabs accessible, all content visible |
| Podcast Notification Subscription | `podcast_subscription_test.dart` | Bell toggle works, row created | Bell toggle works, row created |
| Episode Details Page | `episode_details_gate_test.dart` | Full access (all sub-sections visible) | Full access (all sub-sections visible) |
| Episode Transcript Access | `episode_transcript_gate_test.dart` | ✅ Free for all users (full transcript) | ✅ Free for all users (full transcript) |
| Episode Download (Details) | `episode_details_download_gate_test.dart` | Tap download → upsell sheet (§19.7) | Episode downloads directly |
| Offline Episode Player | `offline_player_gate_test.dart` | N/A (no offline episodes) | Full offline playback + clip generation |
| Clip Quota per Episode | `clip_quota_gate_test.dart` | 3–5 per episode (configurable via app_config) | Unlimited (configurable future limit) |

---

## 8. Offline Test Scenarios

| # | Scenario | Setup | Action | Expected |
|---|----------|-------|--------|----------|
| O-01 | Homepage offline | Disable network | Open app | Cached content displayed, offline banner visible |
| O-02 | Clip capture offline | Disable during playback | Tap capture | Clip saved locally (sync_status = 'local') |
| O-03 | Queue multiple clips | Disable, capture 3 clips | Check library | All 3 visible with "pending sync" indicator |
| O-04 | Reconnect sync | Re-enable network | Wait | "Syncing 3/3 clips" progress → all synced |
| O-05 | Collections offline | Disable network | Open collections | Cached collections visible, offline banner |
| O-06 | Search offline | Disable network | Tap search | Offline message, recent searches shown |
| O-07 | Social feed offline | Disable network | Open feed tab | Offline screen (746:17336 design) |
| O-08 | Learn offline | Disable network | Open learn tab | Offline screen (749:17733 design) |
| O-09 | Learn offline clip playback | Premium + downloaded clip | Disable, open Learn, play clip | Audio plays from local storage, "You're offline" banner, playback controls work |
| O-10 | Premium download offline | Premium + downloaded clip | Disable, play clip | Audio plays from local storage |
| O-11 | Free download denied | Free user, offline | Tap download | "Upgrade to Premium for Offline Access" |
| O-12 | Profile hub offline | Disable network | Open profile tab | My Library section visible at top, Delete Account hidden, settings from cache |
| O-13 | My Favorites offline | Premium, cached favourites | Disable, profile → My Favorites | Cached podcasts + episodes shown, heart icons |
| O-14 | Downloads offline browse | Premium, downloaded content | Disable, profile → Downloads | 4 tabs show downloaded items, playable |
| O-15 | T&C offline | Disable network | Profile → Terms & Conditions | Cached T&C content displayed |
| O-16 | Settings read-only offline | Disable network | Profile → Notification Settings | Toggles visible (cached state), changes disabled or queued |
| O-17 | Profile edit blocked offline | Disable network | Profile → Settings | Edit fields disabled or "Requires internet" message |
| O-18 | Offline Episode Player opens | Premium + downloaded episode, disable network | Open episode from Downloads | "You're offline" banner, waveform player, playback controls, Generate Clip CTA |
| O-19 | Offline clip generation | Premium + offline + playing episode | Tap "Generate Clip" | Clip extracted from ring buffer, success sheet: "Clip Generated and will be synced" |
| O-20 | Offline clip quota tracking | Premium + offline | Generate clips repeatedly | Quota bar updates (e.g. 10/12 → 9/12), CTA disabled at 0/12 |
| O-21 | Offline clip sync on reconnect | Generated clips offline | Re-enable network | Clips upload + AI processing triggers, added to Learn collection |
| O-22 | Offline transcript/chapters access | Premium + downloaded episode, disable network | Tap Show Transcript / Show Chapters on offline player | Transcript segments + chapters load from local cache |

---

## 9. Edge Function Tests

Tested via HTTP requests against staging Supabase instance.

| Edge Function | Test | Input | Expected |
|---------------|------|-------|----------|
| `podcast-search` | Valid search | `{ "term": "Joe Rogan" }` | 200 + podcast array |
| `podcast-search` | Empty term | `{ "term": "" }` | 400 + error message |
| `podcast-detail` | Valid podcast | `{ "podcast_id": "uuid" }` | 200 + podcast + episodes |
| `podcast-detail` | Not found | `{ "podcast_id": "nonexistent" }` | 404 |
| `upload-presign` | Authenticated | Valid auth header | 200 + presigned S3 URL |
| `upload-presign` | Unauthenticated | No auth header | 401 |
| `process-clip` | Valid clip | `{ "clip_id": "uuid" }` | 200 + transcript populated |
| `process-clip` | Free user | Free user's clip | 200 + transcript only (no ai_summary) |
| `process-clip` | Premium user | Premium user's clip | 200 + transcript + ai_summary + ai_takeaways |
| `webhooks-revenuecat` | Valid webhook | Signed RC payload | 200 + subscription updated |
| `webhooks-revenuecat` | Invalid signature | Bad signature | 401 |
| `notify` | Follow event | `{ "type": "new_follower" }` | 200 + OneSignal called |
| `seed-initial` | One-time seed | Admin trigger | 200 + podcasts + episodes inserted |
| `cron-refresh-trending` | Cron trigger | — | 200 + trending_podcasts updated |

---

## 10. Security Tests

| # | Test | Category | Expected |
|---|------|----------|----------|
| S-01 | RLS: User can only read own clips | Authorization | SELECT returns only `user_id = auth.uid()` clips |
| S-02 | RLS: User cannot update another's profile | Authorization | UPDATE blocked, returns 0 rows |
| S-03 | RLS: User cannot delete another's collection | Authorization | DELETE blocked |
| S-04 | RLS: Public clips visible to all | Authorization | SELECT returns `is_public = true` clips from others |
| S-05 | RLS: Private collection hidden | Authorization | SELECT returns 0 for other user's private collection |
| S-06 | Edge Function: No Taddy key exposure | Secrets | Response body never contains API key |
| S-07 | Edge Function: Rate limiting | DoS prevention | Excessive requests return 429 |
| S-08 | Presigned URL: Cannot overwrite other user's files | S3 | URL path scoped to `user_id/` prefix |
| S-09 | Webhook: Invalid RC signature rejected | Authentication | Returns 401, no DB mutation |
| S-10 | SQL injection via search | Injection | Parameterized queries prevent injection |
| S-11 | XSS in clip/collection names | Injection | HTML entities escaped on render |
| S-12 | JWT expiry handling | Session | Expired token → refresh → retry, or sign-out |
| S-13 | RLS: User cannot read another's notification prefs | Authorization | SELECT on `notification_preferences` returns only own row |
| S-14 | RLS: User cannot update another's preferences | Authorization | UPDATE on `user_preferences` blocked for other user's row |
| S-15 | RLS: Feature suggestions append-only | Authorization | UPDATE/DELETE on `feature_suggestions` blocked |
| S-16 | RLS: Bug reports append-only | Authorization | UPDATE/DELETE on `bug_reports` blocked |
| S-17 | RLS: User cannot see another's downloads | Authorization | SELECT on `downloaded_*` returns only own rows |
| S-18 | RLS: Free user cannot INSERT download | Authorization | INSERT on `downloaded_*` blocked by Edge Function premium check |
| S-19 | RLS: User cannot delete another's downloads | Authorization | DELETE on `downloaded_*` blocked for other user's rows |
| S-20 | RLS: User cannot see another's episode favourites | Authorization | SELECT on `episode_favourites` returns only own rows |
| S-21 | RLS: User can only manage own podcast subscriptions | Authorization | SELECT/INSERT/DELETE on `podcast_subscriptions` scoped to own `user_id` |
| S-22 | RLS: User cannot subscribe on behalf of another user | Authorization | INSERT on `podcast_subscriptions` with wrong `user_id` → blocked |
| S-23 | RLS: Episode transcripts readable by all authenticated users | Authorization | SELECT on `episode_transcripts` returns segments for any episode (free for all) |
| S-24 | RLS: Episode transcripts are read-only for clients | Authorization | INSERT/UPDATE/DELETE on `episode_transcripts` blocked (server-only writes) |
| S-25 | RLS: app_config is read-only for clients | Authorization | INSERT/UPDATE/DELETE on `app_config` blocked (admin-only writes) |
| S-26 | Clip quota: Cannot bypass via direct INSERT | Authorization | Edge Function enforces `app_config.clip_quota_per_podcast` before allowing clip creation |

---

## 11. Performance Benchmarks

| Metric | Target | How to Measure |
|--------|--------|----------------|
| App cold start | < 2s | `flutter run --profile`, `Timeline` |
| Home screen data load | < 1s (cached), < 3s (fresh) | Stopwatch in Cubit |
| Search response time | < 500ms (cached), < 2s (Taddy fetch) | Edge Function logs |
| Clip capture latency | < 200ms (tap to confirmation) | AudioService benchmark |
| Audio stream start | < 1s (CDN), < 3s (direct) | just_audio events |
| AI processing (60s clip) | < 30s total | Edge Function duration log |
| Feed scroll FPS | ≥ 60fps | `flutter run --profile`, DevTools |
| Offline sync (10 clips) | < 30s | ConnectivityCubit timing |
| Memory usage (idle) | < 150MB | DevTools Memory tab |
| APK size | < 30MB | `flutter build apk --release`, file size |

---

## 12. CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/test.yml
name: Test
on: [push, pull_request]

jobs:
  unit-and-widget:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info

  integration:
    runs-on: macos-latest  # iOS simulator
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test integration_test/ --flavor staging
```

### Test Gates

| Gate | Trigger | Block on Failure |
|------|---------|-----------------|
| Unit + Widget tests | Every push | ✅ Yes |
| Lint (`flutter analyze`) | Every push | ✅ Yes |
| Integration tests | PR to `main` | ✅ Yes |
| E2E tests | Pre-release tag | ⚠️ Warning (manual review) |
| Security tests (RLS) | Weekly cron | ✅ Yes |

---

## 13. Test Data & Fixtures

### Supabase Seed File

```sql
-- test/fixtures/seed.sql
-- Idempotent seed data for testing

-- Test users
INSERT INTO auth.users (id, email)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'free@test.com'),
  ('22222222-2222-2222-2222-222222222222', 'premium@test.com')
ON CONFLICT DO NOTHING;

-- Profiles (trigger-created, but ensure state)
UPDATE profiles SET is_premium = false WHERE id = '11111111-1111-1111-1111-111111111111';
UPDATE profiles SET is_premium = true  WHERE id = '22222222-2222-2222-2222-222222222222';

-- Test podcast
INSERT INTO podcasts (id, external_id, title, publisher, source)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'taddy-uuid-1', 'Test Podcast', 'Test Publisher', 'taddy')
ON CONFLICT DO NOTHING;

-- Test episode
INSERT INTO episodes (id, podcast_id, external_id, title, audio_url, duration)
VALUES ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'taddy-ep-1', 'Test Episode', 'https://example.com/audio.mp3', 3600)
ON CONFLICT DO NOTHING;
```

### Mock Factories (Dart)

```dart
// test/fixtures/factories.dart

Podcast mockPodcast({String? title, bool? isFavourited}) => Podcast(
  id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  title: title ?? 'Mock Podcast',
  publisher: 'Mock Publisher',
  artworkUrl: 'https://example.com/art.jpg',
  episodeCount: 100,
  source: 'taddy',
);

Clip mockClip({SyncStatus? status, bool? isProcessed}) => Clip(
  id: 'cccccccc-cccc-cccc-cccc-cccccccccccc',
  userId: '11111111-1111-1111-1111-111111111111',
  episodeId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  syncStatus: status ?? SyncStatus.synced,
  isProcessed: isProcessed ?? true,
  transcript: 'Mock transcript text',
);
```

---

## Test Coverage Targets by Feature

| Feature | Unit | Widget | Integration | Phase |
|---------|------|--------|-------------|-------|
| Auth (Google + Apple) | 90% | 70% | ✅ I-01, I-02 | 1 |
| Home / Trending | 80% | 70% | — | 1 |
| Search | 80% | 70% | ✅ I-03 | 1 |
| Podcast Detail | 80% | 70% | ✅ I-03 | 1 |
| Episode Player | 90% | 60% | ✅ I-04 | 1 |
| Clip Capture | 95% | 60% | ✅ I-05, I-06 | 1 |
| Collections | 85% | 70% | ✅ I-07 | 2 |
| Social Feed | 80% | 80% | ✅ I-08 | 2 |
| Follow System | 80% | 60% | ✅ I-09 | 2 |
| Premium / Paywall | 90% | 80% | ✅ I-10 | 2 |
| Notifications | 70% | 60% | — | 3 |
| Offline Mode | 85% | 70% | ✅ O-01 – O-10 | 2 |
| Settings | 60% | 50% | — | 3 |

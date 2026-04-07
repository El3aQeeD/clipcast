# ClipCast — System Architecture & Pre-Development Brief

> **Version:** 1.0  
> **Date:** 2025-07-17  
> **Author:** Lead Developer (AI-assisted)  
> **Status:** Draft — Pending Technical Lead Approval  
> **Figma Source:** [ClipCast HiFi v01](https://www.figma.com/design/TH2Vb1mEH3Ho6nUNXm3jCo/ClipCast---Client-Review?node-id=539:802)  
> **Prep Document:** Clipcast New Project Preparation Form (internal)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Feature Inventory from Figma](#2-feature-inventory-from-figma)
3. [Important Requirements from Prep Document](#3-important-requirements-from-prep-document)
4. [Product Gaps, Assumptions & Unknowns](#4-product-gaps-assumptions--unknowns)
5. [Scalable Design Token System](#5-scalable-design-token-system)
6. [Product Requirements Document (PRD) Draft](#6-product-requirements-document-prd-draft)
7. [Architecture Decision Record (ADR)](#7-architecture-decision-record-adr)
8. [Flutter Architecture & State Management](#8-flutter-architecture--state-management)
9. [Podcast API Investigation](#9-podcast-api-investigation)
10. [Data Seeding & Webhook Strategy](#10-data-seeding--webhook-strategy)
11. [Supabase ERD & Schema](#11-supabase-erd--schema)
12. [Security, RLS & Backend Responsibility](#12-security-rls--backend-responsibility)
13. [Clip Storage Recommendation](#13-clip-storage-recommendation)
14. [Risks & Tradeoffs](#14-risks--tradeoffs)
15. [Phased Implementation Plan](#15-phased-implementation-plan)
16. [Final System Design](#16-final-system-design)

---

## 1. Executive Summary

**ClipCast** is a mobile-first application (iOS & Android) for podcast discovery, listening, clipping key moments, generating AI transcripts and summaries, saving clips to a personal library, and sharing them on a social feed.

### Core Value Loop

```
Listen → Clip → AI Process → Save/Share → Discover
```

A user discovers a podcast, plays an episode, taps to capture the last 15–60 seconds, and the system generates an AI transcript and summary. The clip is saved to their personal library and optionally shared to a social feed where other users can discover, play, like, comment on, and bookmark clips.

### Business Model

**Freemium** with IAP subscription via RevenueCat.

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | Core playback, AI transcription, basic clipping (3–5 per episode), social feed, external sharing, subtle non-intrusive ads (audio ads after 4–5 clips listened) |
| Premium | $49/year (after 1-month free trial) | Advanced AI summaries, unlimited clips per episode, offline access, ad-free, enhanced lock screen controls, metadata tagging & categorisation |

### Technology Stack

| Layer | Technology |
|-------|-----------|
| Client | Flutter (Dart ^3.10.4) |
| Backend / Database | Supabase (Auth, Postgres, Storage, Edge Functions, Realtime) |
| Media Storage | AWS S3 + CloudFront CDN |
| Payments | RevenueCat (IAP) |
| Push Notifications | OneSignal |
| AI Processing | OpenAI Whisper (transcription) + GPT (summaries) |
| Podcast Data | TBD — See Section 9 (Podcast API Investigation) |
| Email | Resend |
| Crash Monitoring | Crashlytics |
| Analytics | UXCam |

### Target Users

- **Primary:** Early-adopter knowledge workers (founders, leaders) and podcast "power listeners" (5+ hours/week)
- **Focus:** Users who consume podcasts for learning and insight and need to quickly capture and reuse information

### North Star Metric

Weekly Active Users creating at least one clip.

---

## 2. Feature Inventory from Figma

### 2.1 High-Fidelity Screens Confirmed (HiFi ready for development)

| # | Screen | Figma Node(s) | Variants / Notes |
|---|--------|---------------|-----------------|
| 1 | **Onboarding** | Multiple frames within canvas | Welcome illustrations, feature highlights, get started CTA |
| 2 | **Homepage** | 544:1559 + variants | Normal state, Offline mode, Network-back state, New-user empty state |
| 3 | **Homepage — Offline** | Within homepage variants | Shows downloaded content, pending clips (created offline, will sync when connected), sync progress bar |
| 4 | **Collections / Library** | 545:4442, 549:6040, 549:6537, 553:11537, 556:7255, 557:7282, 561:14831, 567:24938, 586:9879, 587:24210, 587:25458, 624:19408, 624:19434, 649:21274, 666:27736, 666:27808, 700:8464, 908:9591, 913:12677, 925:14322, 1067:13887, + 32 more frames | 4-tab layout (All / Favorites / Downloads / My Collections). System collections: My Favorites, Downloads (Premium), Unprocessed Clips. 3-Month Aged Clips review flow (paginated, Keep/Delete). Collection create/edit/delete with privacy toggle (OFF = public = auto-published to Social Feed). Collection Clips: clips only, no sub-collections or episodes. Share Collection + Share Clip sheets. Collections Onboarding (3-step carousel, first visit). Free: 15 collection max, 5 clip share events max. Premium: unlimited + Offline Downloads + AI (Insights/Key Takeaways) in review flow. See FR-35–FR-42 and Flows.md §9. |
| 5 | **Social Feed** | 680:31417, 912:12148, 912:11638 | Three tabs: **Trending** (most engagement), **Friends** (following-only), and **My Feed** (user's own shared clips/collections); feed cards with user avatar/name/timestamp, follow button, clip title, image with play overlay, source podcast, KEY TAKEAWAYS section, duration + share count, like/comment/share/bookmark actions. My Feed cards omit avatar/follow (own content). |
| 6 | **Social Feed — Free User** | Within feed variants (925:14386, 925:14573, 925:14748, 925:15473) | KEY TAKEAWAYS blurred with "Premium Feature — Upgrade to view AI-generated insights" overlay on Trending and Friends tabs. My Feed tab shows own clips in shorter cards without takeaways. |
| 6a | **Social Feed — First-Time User** | 925:15674, 925:15863 | Empty states: Friends tab — "No friends sharing yet" + "Follow your friends…" + Explore Podcasts CTA. My Feed tab — "Share your first clip" + "Start building your podcast collection…" + Explore Podcasts CTA + "Browse trending content" link. |
| 7 | **Learn / Clip Review** | 545:3635, 587:21054, 635:21061, 587:21387, 720:12147, 587:21230, 749:18204, 741:17244 | Learn onboarding (4-step carousel + frequency/reminder setup), main screen (weekly insights banner + clip list), empty state, Review Weekly Insights flow (per-clip review with progress tracking), clip actions (options sheet, add to collection, delete), Learning Settings (frequency + reminder), Clip Detail (takeaways, transcript, notes), offline playback. AI Insights + Key Takeaways premium-gated. |
| 8 | **Explore Premium (Paywall)** | 662:22577 | Feature list: Advanced AI Summaries, numerous clips per episode, Offline Access, Ad-free; price: $49/year after 1-month free trial; CTA buttons |
| 9 | **Splash Screen** | Existing in codebase | Logo animation on dark background |
| 10 | **Profile (Online)** | 1048:15663, 1048:15791, 1048:15849, 1048:15913, 1048:15977, 1048:16016, 1048:16046, 1048:16067, 1048:16088, 1048:16128 | Profile hub (Account Settings, Share Feedback, T&C, Logout, Delete Account), Profile Settings (avatar, name, password, followers/following), Notification Settings (4 toggles), Gesture Control (AirPods Double Tap), Preferences (Default Clip Length 30s/45s/60s), Suggest New Feature form, Report a Bug form, Followers/Following bottom sheets, Success toast |
| 11 | **Profile (Offline)** | 761:22189, 761:22706, 761:22811, 761:22330, 761:22424, 761:22518, 761:22612, 761:22916, 761:22950, 761:22980, 761:23001, 929:21019 | Offline profile hub (My Library section added: My Favorites + Downloads), My Favorites (Podcasts/Episodes tabs), Downloads (4 tabs: Podcasts/Episodes/Clips/Collections), Notification Settings (offline variant), Gesture Control, Suggest New Feature, Preferences, Dev note (gesture hijacking for clip creation) |
| 12 | **Podcast Page** | 588:49600, 588:49489, 588:49439, 588:50206, 548:5047, 564:22839, 564:20078, 562:17982, 666:27547, 588:49634, 564:19715, 564:19750, 755:22124, 717:11456, 717:11491 | 4-tab layout (Episodes / Clips / About / More Like This). Header: podcast artwork, title, author, ranking badge ("#6 in Podcasts"), category tag, "Add to Favorites" button, notification bell (subscribe to new episodes), ⋯ more menu. **Episodes Tab:** filter icon + episode count ("217 Episodes"), episode cards with thumbnail, title, description, metadata (plays, clips, date, duration), download/share/⋯/play buttons. Filter & Sort sheet (All Episodes/Downloaded/Not Finished + Newest/Oldest). **Clips Tab:** "Trending Clips" section with social-feed-style cards (user avatar, username, "Follow" button, clip thumbnail with play overlay, title, description, source info, timestamp). Filter & Sort sheet (Trending Clips/My Clips + Newest/Oldest). **About Tab:** podcast description, Hosts & Guests section with circular avatars + name/role. **More Like This Tab:** "Recommended Podcasts" horizontal carousel with artwork + title + episode count. **Bottom sheets:** Episode More Details (Add to My Favorites + Download Episode), Podcast More Details (Add to My Favorites + Download Podcast — behaviour TBD), Clip More Details (Add to My Favorites + Download Clip + Go to Episode + Go to Podcast + Share Clip). Free vs Premium: no visible gating on podcast browsing; downloads premium-only. See FR-43–FR-52 and Flows.md §4. |
| 13 | **Episode Player** | 588:49766, 587:35786, 562:17895 + 52 Lo-Fi wireframes across 4 user flows (first-time: 13, free: 12, subscribed: 25, offline: 2) | Full-screen player with comprehensive playback, clipping, and overlay features. **Header:** "Now Playing from [Podcast Name]" with down arrow (minimize) and ⋯ more menu (7 items: View Clips, Clipping Preference, Gesture Controls, Add to My Favorites, Download Episode, Play Next, Episode Details). **Artwork:** large episode artwork with "Show Chapters" (bottom-left) and "Show Transcript" (bottom-right) overlay buttons. **Chapters overlay** on artwork with numbered list, current chapter cyan-highlighted. **Transcript overlay** on artwork: collapsed (1 highlighted line) and expanded (full-screen with mini player). **Episode title** centered below artwork. **Waveform progress bar** with purple dots (user clips + viral moments), current/total timestamps. **Controls:** 1x speed, skip ±30s, play/pause, share. **Generate Clip:** full-width cyan CTA, scissors icon, clips previous 60s (default per FR-27); press-and-hold to change duration. **Clip quota** display with progress bar + fair usage text. **Clip success sheet** with "Review Now" (premium) or auto-dismiss (free). **Clip review** (premium only): takeaways, transcript, add to collection, edit. **Episode Complete screen:** artwork+check badge, replay, Play Next, Review Your Clips. **Audio feedback:** subtle cues on clip gen + viral section upcoming. **Free:** audio ads after 4–5 clips listened; 3–5 clip limit/episode; no review/AI. **Subscribed:** no ads; unlimited clips; full review. **Offline:** green dots, clips sync on reconnect. See FR-53 and Flows.md §5. |
| 14 | **Clip Detail** | 588:49720, 562:17850, 565:20995, 587:34654, 587:36211 | **Premium view:** clip title, podcast info (avatar, name, episode #), mini player with progress bar, 3 AI sections (Insights bullet list, Actionable Takeaways bullet list, AI Transcript quoted block), "Add to My Collection" CTA. **Free view:** identical layout but ALL 3 AI sections blurred with lock icon + "Premium Feature" + "Upgrade to view AI-generated insights" overlay. Tapping locked section triggers "Want to get access to AI generated insights?" upsell sheet (Explore Premium / Cancel). Dev note confirms: "AI Transcript and summary are blocked for free users." See FR-54 and Flows.md §8. |
| 15 | **Episode Details Page** | 588:50662, 587:33754, 565:5135, 566:22375, 588:50828, 587:33889, 565:5270, 588:50874, 587:33969, 565:5480, 588:50941, 587:34103, 565:5587, 588:51029, 587:34070, 564:20184, 702:11387, 588:36332, 739:15744, 739:15866, 588:51061, 588:51062, 925:14290, 925:14289, 564:19218, 925:14291, 925:14281, 908:9506, 908:9498, 587:32901, 587:32900, 587:33523 | **New intermediate screen** between Podcast Page and Episode Player. 32 Lo-Fi wireframes across 4 user flows (first-time: 7, free: 12, paid: 11, offline: 2). **Main screen:** episode header (artwork, title "#217 - The Art of Negotiation", author "Chris Williamson", tag "Time Management", date, "1h 34m"), action bar (download, share, ⋯ more, play button), description with "See more", 3 navigable sections: "Episode Transcript >" (chevron → full transcript page), "Clips >" (chevron → episode clips page), "Episode Chapters" (Show All + inline chapter preview). **Playing state variant:** play button → pause icon, progress bar + "30m left" text. **Sub-screens:** Episode Transcript view (full-page, speaker names + timestamps, mini player), Episode Chapters view (full-page, numbered chapters 01–05 with thumbnails, titles, timestamps, mini player), Episode Clips view ("Trendy Clips" social cards with filter icon), Filter & Sort sheet (Trendy Clips ✓ / My Clips + Newest / Oldest), Episode More Details sheet (Add to My Favorites, Download Episode, Podcast Details). **My Clips page:** separate view showing user's own clips for the episode (distinct from Trendy Clips which shows all podcast clips). **Free gating:** Download triggers "Want to Download Episodes?" upsell. Episode transcript and chapters are **free for all users** (distinct from clip-level AI transcript which is premium-gated). **Offline variant:** "You're offline" banner, "Downloaded" green dot indicator, artwork overlaid with "Show Chapters" / "Show Transcript" buttons, waveform progress bar (32:15 / 74:44), playback controls (1x, ⏪30s, ▶/⏸, ⏩30s, share), "Generate Clip" button (clips previous 30s), clip quota display ("You have 10 Clips available 10/12" + fair-usage policy message), offline clip success sheet ("Clip Generated and will be synced when your connection is back!" → clip added to "Learn" collection). **Dev notes:** (1) Chapters sourced from RSS metadata, fallback = generated from transcript/audio. (2) Tags sourced from RSS category/keyword fields. (3) Transcripts sourced from RSS transcript tags, fallback = speech-to-text. (4) Clip aggregation algorithm: 5–10s overlapping window to detect viral moments. (5) Downloading restricted for free users. (6) Clip quota per podcast: configurable (default 12), enforced via fair-usage policy. See FR-55–FR-66 and Flows.md §19. |

### 2.2 Title Cards Only (Design NOT yet HiFi — blocking development)

These screens are represented in Figma only as 1440×1024 labelled section cards, not as actual mobile HiFi designs. **They cannot be built until HiFi designs are delivered.**

| # | Screen | Figma Label | Impact |
|---|--------|------------|--------|
| 1 | **Search** | "Search" title card | Blocks podcast discovery flow |
| ~~2~~ | ~~**Podcast Page**~~ | ~~"Podcast Page" title card~~ | ✅ **RESOLVED** — Lo-Fi wireframes delivered (50 designs reviewed). Full 4-tab podcast page documented: Episodes, Clips, About, More Like This. See §2.1 item 12, FR-43–FR-52, and Flows.md §4. |
| ~~3~~ | ~~**Episode Details**~~ | ~~"Episode Details" title card~~ | ✅ **RESOLVED** — Lo-Fi wireframes delivered (32 designs across 4 user flows reviewed). Dedicated Episode Details page confirmed as a **new intermediate screen** between Podcast Page and Episode Player. See §2.1 item 15, FR-55–FR-66, and Flows.md §19. |
| ~~4~~ | ~~**Episode Player**~~ | ~~"Episode Player" title card~~ | ✅ **RESOLVED** — 52 Lo-Fi wireframes delivered across 4 user flows (first-time: 13, free: 12, subscribed: 25, offline: 2). Full-screen player with chapters/transcript overlays, waveform progress, ±30s controls, Generate Clip CTA with quota, clip success/review flow, ⋯ more menu (7 items), Episode Complete screen, audio ads (free), audio feedback. See §2.1 item 13, FR-53, and Flows.md §5. |
| 5 | **Web URL Clip Player** | "Web URL Clip Player" title card | Blocks external clip sharing preview |
| ~~6~~ | ~~**My Profile**~~ | ~~"My Profile" title card~~ | ✅ **RESOLVED** — HiFi delivered (see §2.1 items 10–11). 22 screens across online + offline modes. |
| 7 | **Authentication** | "Authentication" title card | Blocks sign-in/sign-up flow |
| 8 | **Lock Screen** | "Lock Screen" title card | Blocks premium lock screen controls |

### 2.3 Navigation Structure (from Figma)

**Bottom Navigation Bar** — 4 tabs:

| Tab | Icon | Destination |
|-----|------|-------------|
| Home | House | Homepage (podcast discovery, recent, trending) |
| Collections | Folder/List | Personal clip library |
| Feed | People/Social | Social feed (Trending / Friends / My Feed) |
| Learn | Lightbulb/Book | Clip review with AI insights, weekly review flow, learning settings |

### 2.4 UI Patterns Observed

- **Feed Card Anatomy:** Avatar + username + timestamp → Follow button → Clip title → Image with play overlay → Source podcast label → KEY TAKEAWAYS (premium-gated for free users) → Duration + share count → Action bar (like, comment, share, bookmark)
- **Offline Mode Pattern:** Downloaded content visible, pending clips shown with "will sync" indicator, sync progress bar at top
- **Empty States:** New user homepage shows onboarding-style prompts to discover podcasts
- **Premium Upsell:** Contextual upsell overlays on premium-gated content (not just paywall screen)

### 2.5 Typography System (from Figma inspection)

| Token | Size | Weight | Line Height | Letter Spacing |
|-------|------|--------|-------------|----------------|
| H1-Large | 18px | Bold (700) | 28px | 0 |
| H1 | 16px | Bold (700) | 28px | 0 |
| H2 | 14px | Medium (500) | 20px | 0 |
| Body1 | 12px | Regular (400) | 100% | -0.5px |
| Caption | 10px | Regular (400) | 14px | 0 |

---

## 3. Important Requirements from Prep Document

### 3.1 Functional Requirements (from proposal, embedded in prep doc)

The prep document embeds the full proposal functional requirements. Key specifications:

| ID | Requirement | Tier | Notes |
|----|------------|------|-------|
| FR-01 | Podcast Search & Discovery | Free | Taddy API or RSS fallback; search by title/host/keyword; trending, recent, recommended |
| FR-02 | Podcast Favourites | Free | Favourite/unfavourite podcasts and episodes; dedicated tab; sync with Supabase |
| FR-03 | Podcast Player | Free | Stream via Taddy audioUrl or RSS fallback; play/pause/seek/skip ±30s/speed; buffer last 60s; background playback; resume position |
| FR-04 | Clip Capture | Freemium | "Save Last 60s" (adjustable 15–60s via preference FR-27; Figma "30s" text is placeholder); triggers: UI button (Generate Clip CTA), double-tap AirPods (FR-26), triple-tap phone case; press-and-hold CTA to change clip duration; queue offline; visual confirmation + subtle audio feedback |
| FR-05 | Clip Editing | Free | Waveform editor; drag-to-trim; add tags/title/description; preview before save |
| FR-06 | Personal Library | TBC | Saved clips with thumbnail/episode/duration/date; playback/edit/delete/share; filter/search; cloud-sync |
| FR-07 | Social Feed | Free | Three tabs: Trending (public clips by engagement), Friends (following-only), My Feed (user's own shared clips/collections); playback from feed; like/comment/share/bookmark; follow from feed; empty states for first-time users on Friends and My Feed tabs |
| FR-08 | Follow System | Free | Follow/unfollow; profiles with avatar/bio/followers/following/clips; "Following Feed"; default public, can toggle private |
| FR-09 | Notifications | Free | Real-time in-app (Supabase Realtime); push (OneSignal); types: new follower, new clip from following, like/comment, shared clip; toggleable; history with mark-read/clear-all |
| FR-10 | Clip Sharing (External) | Free | Unique public URL per clip (clipcast.app/clip/abc123); web preview with embedded player; deep link to app; share sheet integrations |
| FR-11 | User Accounts | Free | Email/password, Google, Apple auth; logout; delete account; GDPR-compliant data export |
| FR-12 | AI Transcription (Whisper) | Free | Auto-transcript for each clip |
| FR-13 | AI Summary (GPT) | Premium | Brief summary + suggested title per clip |
| FR-14 | Metadata Tagging | Premium | Auto-tag clips by topic, emotion, keyword |
| FR-15 | Skip Ads / Speed Up Ad Segment | Premium | Control for efficient listening |
| FR-16 | Lock Screen Controls | Premium | 15s rewind/forward; UX enhancements (limited by OS) |
| FR-17 | Daily/Weekly Digest Email | Free | AI-generated recap of saved clips and learnings |
| FR-18 | Fair Usage Clip Limit | TBC | Calculation based on % of episode time — see Design Handover Notes |
| FR-19 | Learn Onboarding | Free | 4-step carousel explaining clip review benefit; frequency + reminder setup (586:11263–586:12028) |
| FR-20 | Learn Weekly Insights Review | Freemium | Full-screen guided clip review with progress tracking; edit title/timing/notes; AI Insights + Key Takeaways premium-gated (587:21387, 720:12147) |
| FR-21 | Learning Settings | Free | Configure insights frequency (daily/weekly/monthly/custom) and push reminder time/period (587:21230) |
| FR-22 | Clip Notes | Free | User-editable notes field on clips, accessible from review flow and clip detail (587:21387, 749:18204) |
| FR-23 | Profile Hub | Free | Central profile page with Account Settings, Share Feedback, Terms & Conditions, Logout. Offline variant adds My Library section (My Favorites + Downloads) for quick access to local content. Online variant adds Delete Account. (1048:15663, 761:22189) |
| FR-24 | Profile Settings (Edit) | Free | Edit avatar (camera icon → image picker), display name; view followers/following counts with tappable bottom sheets; Change Password navigation. Online-only — requires internet. (1048:15791, 1048:15849, 1048:15913) |
| FR-25 | Notification Preferences | Free | 4 toggles: Review Insights Notification, New Episodes Release, Social Notifications, Clip Generation Notification. Persisted in Supabase. (1048:15977) |
| FR-26 | Gesture Control | Free | AirPods Double Tap toggle — when enabled, double-tap creates a clip with duration set by FR-27 default clip length. Clip is generated by hijacking the skip-backward gesture. (1048:16016, 929:21019) |
| FR-27 | Clip Length Preferences | Free | Default Clip Length radio selection: 30 seconds ("Quick highlights"), 45 seconds ("Balanced length" — default), 60 seconds ("Extended context"). Applied to gesture captures and default clip creation. (1048:16088) |
| FR-28 | Suggest New Feature | Free | Form: Feature Title + Description (multiline). Submitted to `feature_suggestions` Supabase table. Success toast shown on submit. (1048:16046, 1048:16128) |
| FR-29 | Report a Bug | Free | Form: Title + Description (multiline). Submitted to `bug_reports` Supabase table. Success toast shown on submit. (1048:16067, 1048:16128) |
| FR-30 | Episode Favourites | Free | Favourite/unfavourite individual episodes (separate from podcast favourites FR-02). Listed in My Favorites → Episodes tab (offline profile). (761:22811) |
| FR-31 | My Favorites (Offline Profile) | Free | Two-tab view: Podcasts (from `podcast_favourites`) and Episodes (from `episode_favourites`). Shown in offline profile under My Library. (761:22706, 761:22811) |
| FR-32 | Downloads (Offline Profile) | Premium | Four-tab view: Podcasts, Episodes, Clips, Collections. Each tab shows downloaded content with artwork, title, and metadata. Stored in separate download tables per content type. (761:22330, 761:22424, 761:22518, 761:22612) |
| FR-33 | Terms & Conditions | Free | Accessible from Profile hub in both online and offline modes. Displays legal T&C content. |
| FR-34 | Delete Account | Free | Accessible from Profile hub in online mode only (requires server call). Triggers GDPR-compliant account deletion via Edge Function. |
| FR-35 | Collections Onboarding | Free | 3-step carousel shown on first visit to Collections tab only. Steps: "Create Your Own Spaces" / "Add Clips That Matter" / "Build Your Insight Library". Completion stored in `profiles.collections_onboarding_completed`. (See Flows.md §9.0) |
| FR-36 | Aged Clip Review Flow | Freemium | Clips not reviewed for 3 months trigger a warning banner on Collection Detail. [Revisit Clips] opens paginated review (1/N progress). Each clip: editable title, waveform trimmer (max 60s), My Notes (free). AI Insights + Key Takeaways = Premium only. [Keep Clip] → sets `collection_clips.last_reviewed_at = now()`. [Delete] → deletes clip. Completion screen shows stats. (See Flows.md §9.8) |
| FR-37 | Collection Sharing | Free | Share Collection sheet: My Feed / Copy Link / WhatsApp / More. `collections.share_token` used for URL. Making collection public auto-publishes to Social Feed. (See Flows.md §9.14) |
| FR-38 | Clip Share Limit | Freemium | Clip shares logged to `clip_shares` table (append-only). Free: max 5 total clip share events (any type). Premium: unlimited. Limit enforced server-side via Edge Function — NOT on profiles table. Upsell: "Want to share unlimited clips?" (See Flows.md §9.16) |
| FR-39 | Offline Clip Playback | Premium | Downloaded clips play from local device storage. Full-screen player shows "⊘ You're offline" banner when offline but clip is still playable. Non-downloaded clips are greyed out in Collection Detail offline view. (See Flows.md §9.7 + §16) |
| FR-40 | Collection CRUD | Freemium | Create collection (title + privacy toggle; OFF = public). Edit collection sheet (reorder + remove clips via drag handle and − button; clips only). Name & Details sheet (rename + toggle privacy). Delete collection with CASCADE. Context-dependent create button: "Create Collection" standalone, "Create & Add Clip" from clip. (See Flows.md §9.6, §9.12, §9.13) |
| FR-41 | Clip & Episode Favourites | Free | Clips favorited via `clip_favourites`, episodes via `episode_favourites` (separate from podcast favorites FR-02). Visible in Collections → Favorites tab (4 sub-tabs: Podcasts / Episodes / Clips / Collections). (See Flows.md §9.3) |
| FR-42 | Downloads (Collections Tab) | Premium | Downloads tab in Collections shows 4 sub-tabs: Podcasts / Episodes / Clips / Collections. Uses `user_downloads` table with `download_type` discriminator. Entire Downloads tab is Premium-gated. Same data also accessible via Offline Profile hub. (See Flows.md §9.4) |
| FR-43 | Podcast Page — Episodes Tab | Free | 4-tab podcast page (Episodes / Clips / About / More Like This). Header shows artwork, title, author, ranking badge ("#6 in Podcasts"), category tag ("Time Management"). Episodes tab: filter icon + episode count header ("217 Episodes"), scrollable episode cards with thumbnail, title, description, metadata (500k+ plays, 200 clips, date, 1h 23m duration), action icons (download, share, ⋯, play). (See Flows.md §4) |
| FR-44 | Podcast Page — Clips Tab | Free | "Trending Clips" section with social-feed-style clip cards: user avatar, username, "Follow" button (follows user), clip thumbnail with play icon overlay, clip title, description, source podcast + episode number, timestamp. Filter & Sort sheet: Trending Clips / My Clips + Newest / Oldest. (See Flows.md §4) |
| FR-45 | Podcast Page — About Tab | Free | Podcast description paragraph + "Hosts & Guests" section with circular avatar images, names, and roles (e.g. "Host"). Data sourced from Taddy API or RSS feed metadata. (See Flows.md §4) |
| FR-46 | Podcast Page — More Like This Tab | Free | "Recommended Podcasts" horizontal carousel. Podcast cards with artwork, title, and episode count. Tapping navigates to that podcast's page. (See Flows.md §4) |
| FR-47 | Podcast Page — Add to Favorites | Free | "Add to Favorites" button in podcast header. Toggles favourite state. Uses `podcast_favourites` table. (See Flows.md §4) |
| FR-48 | Podcast Page — Notification Subscription | Free | Bell icon in podcast header. Subscribes/unsubscribes user to new episode notifications for this podcast. Uses `podcast_subscriptions` table + OneSignal tag. (See Flows.md §4) |
| FR-49 | Episode Filter & Sort | Free | Bottom sheet: Filter (All Episodes / Downloaded / Not Finished) + Sort (Newest / Oldest). "Downloaded" = locally saved. "Not Finished" = started but incomplete (requires `playback_progress` tracking). (See Flows.md §4) |
| FR-50 | Episode More Details | Freemium | ⋯ menu on episode card → bottom sheet: "Add to My Favorites" (heart icon) + "Download Episode" (download icon). Download is Premium-only; tapping triggers download upsell sheet for free users. (See Flows.md §4) |
| FR-51 | Podcast More Details | Freemium | ⋯ menu on podcast header → bottom sheet: "Add to My Favorites" (heart icon) + "Download Podcast" (download icon). Download Podcast behaviour TBD. (See Flows.md §4) |
| FR-52 | Clip More Details | Freemium | ⋯ menu on clip card → bottom sheet: "Add to My Favorites" + "Download Clip" (Premium) + "Go to Episode" + "Go to Podcast" + "Share Clip". (See Flows.md §4) |
| FR-53 | Episode Player | Freemium | **Full-screen player** with comprehensive playback, clipping, and overlay features. **Header:** "Now Playing from [Podcast Name]" with down arrow (minimize) and ⋯ more menu. **Artwork:** large episode artwork with two overlay buttons — "Show Chapters" (bottom-left) and "Show Transcript" (bottom-right). **Chapters Overlay:** numbered chapter list overlaid on artwork, current chapter highlighted in cyan with timestamp, "Hide Chapters" toggle. **Transcript Overlay (collapsed):** 1 highlighted line + faded context lines on artwork, "Show Thumbnail" toggle, down arrow to expand. **Transcript Overlay (expanded):** full-screen transcript view with mini player at bottom. **Episode title** centered below artwork. **Waveform progress bar:** multi-coloured waveform with purple dots indicating user clips + viral clip moments, current/total timestamps. **Controls:** 1x speed toggle, skip back 30s, play/pause, skip forward 30s, share. **Generate Clip CTA:** full-width cyan button with scissors icon; clips the previous 60 seconds (default duration per user preference FR-27; Figma text "30s" is placeholder); press-and-hold to change clip duration. **Clip quota display:** "You have [X] Clips available [X]/[Y]" with progress bar + fair usage policy text. **Clip Generation Success sheet:** "Clip Generated Successfully!" with clip title, "Review Now" button (premium only — free users get auto-dismiss after 5s). **Clip Review (premium only):** clip title, Key Takeaways (3 bullets), Transcript, "Add to Collection" + "Edit" actions. **Add to Collection sheet:** collection list with radio selection, "Create New Collection", "Done". **⋯ More Menu (7 items):** (1) View Clips — default My Clips with filter to Trendy Clips, (2) Clipping Preference, (3) Gesture Controls, (4) Add to My Favorites → toast, (5) Download Episode → toast (Premium) / upsell (Free), (6) Play Next, (7) Episode Details → navigates to Episode Details page (§19). **Episode Complete screen:** artwork with cyan check, "Episode Complete" badge, episode info, Replay Episode button, Play Next Episode (next in sequence) button, "Review Your Clips" (count) + View All. **Audio feedback:** subtle audio cue on clip generation + subtle audio cue when viral clip section upcoming. **Clip destination logic (dev note):** unprocessed clips → My Collections; clips also appear on Learn page waiting for review; after user reviews + adds → specified collection. **First-time user variant:** 2-step clip onboarding tooltip carousel; My Clips empty state "No clips generated yet". **Free user variant:** audio ads (6–10s, pre-roll/mid-roll, triggered after 4–5 clips listened to) with ad overlay (creative, "Ad" badge, countdown, "Explore Premium", controls dimmed); clip limit 3–5 per episode → "Upgrade to Premium" + "Continue without clipping"; no clip review/AI — can only generate clips; clip success auto-dismisses (no "Review Now"). **Subscribed user variant:** no ads; unlimited clips (configurable limit in `app_config` for future); full clip review with AI takeaways/transcript; clip success has "Review Now". **Offline variant (§19.8/FR-65):** "You're offline" banner, "Downloaded" green dot, green waveform dots, clips sync when back online. (See Flows.md §5) |
| FR-54 | Clip Detail with AI Content | Freemium | Clip title, podcast info, mini audio player, 3 AI section cards: Insights (bullet list), Actionable Takeaways (bullet list), AI Transcript (quoted block). FREE: all 3 sections blurred + lock + "Premium Feature" overlay. Tapping locked section shows upsell sheet. PREMIUM: all 3 sections visible. "Add to My Collection" CTA available to all. (See Flows.md §8) |
| FR-55 | Episode Details Page | Free | Dedicated intermediate screen between Podcast Page and Episode Player. Header: episode artwork (thumbnail), title ("#217 - The Art of Negotiation"), author ("Chris Williamson"), category tag ("Time Management"), date ("Dec 11, 2025"), duration ("1h 34m"). Action bar: download icon, share icon, ⋯ more icon, large cyan play button. Description paragraph with "See more" truncation. Three navigable sections: "Episode Transcript >" (chevron), "Clips >" (chevron), "Episode Chapters" with "Show All" link + inline chapter preview (first 2 chapters visible). Navigation: Podcast Page episode card → Episode Details → tap Play → Episode Player. (See Flows.md §19) |
| FR-56 | Episode Details — Playing State | Free | When an episode is actively playing, the Episode Details page shows: play button replaced by pause icon, linear progress bar, "30m left" remaining time text. All other elements remain the same. (See Flows.md §19.1) |
| FR-57 | Episode Transcript View | Free | Full-page transcript accessed via "Episode Transcript >" on Episode Details. Header: back arrow + episode title + podcast name. Transcript body: speaker-segmented text with speaker name (bold) + timestamp (right-aligned) per segment. Speakers: e.g. "Chris Williamson" (00:00, 00:15, 01:12), "Dr. Sarah Chen" (00:35). Guest speakers highlighted in accent colour. Mini player bar at bottom (persistent). **Free for all users** — distinct from clip-level AI transcript (premium-gated). Data source: extracted from RSS feed transcript tags if available; fallback = generated via speech-to-text (Whisper). (See Flows.md §19.2) |
| FR-58 | Episode Chapters View | Free | Full-page chapter list accessed via "Episode Chapters" → "Show All" on Episode Details. Header: back arrow + episode title + podcast name. Chapter list: numbered items (01–05) with thumbnail image, chapter title, description (2 lines), timestamp (right-aligned). Mini player bar at bottom (persistent). Data source: extracted from RSS feed chapter metadata if available; fallback = generated automatically from transcript or audio. (See Flows.md §19.3) |
| FR-59 | Episode Clips View — Trendy Clips | Free | Full-page clips list accessed via "Clips >" on Episode Details. Header: back arrow + episode title + podcast name + filter icon. "Trendy Clips" section with social-card-style items: user avatar, username, "Follow" button, clip thumbnail with play icon overlay, clip title, description (2 lines), source podcast + episode number, timestamp ("2 days ago"). Displays clips from ALL users for this episode's podcast. (See Flows.md §19.4) |
| FR-60 | Episode Clips View — My Clips | Free | Separate view showing only the current user's clips for this specific episode. Accessed via "My Clips" filter on the Filter & Sort sheet from Episode Clips. Distinct from Trendy Clips (which shows all users' clips across the podcast). (See Flows.md §19.4) |
| FR-61 | Episode Clips — Filter & Sort Sheet | Free | Bottom sheet: "Filter and Sort" title with Cancel. Filter section: "Trendy Clips" (default, checkmark shown) and "My Clips". Sort section: "Newest" and "Oldest". Single selection per section. (See Flows.md §19.5) |
| FR-62 | Episode More Details Sheet | Free | Bottom sheet accessed via ⋯ on Episode Details action bar. Shows: episode thumbnail + title + author. Options: "Add to My Favorites" (heart icon) → `episode_favourites` INSERT/DELETE, "Download Episode" (download icon) → Premium: downloads locally / Free: triggers download upsell, "Podcast Details" (headphones icon) → navigates to Podcast Page (§4). (See Flows.md §19.6) |
| FR-63 | Clip Aggregation Algorithm | Free | Algorithm aggregates overlapping clips within a 5–10 second window to detect viral moments. Used to power the "Trendy Clips" ranking on Episode Clips view. Dev note: "algorithm will aggregate overlapping clips within a 5–10 second window to detect viral moments." (See Flows.md §19.4) |
| FR-64 | Clip Quota Per Podcast | Freemium | Fair-usage clip limit per episode. **Free:** 3–5 clips per episode (configurable via `app_config.free_clip_limit_per_episode`). **Subscribed:** unlimited (configurable limit in `app_config.premium_clip_limit_per_episode` for future use). Displayed on Episode Player as "You have X Clips available X/N" with progress bar. Warning: "To comply with fair usage policy for the podcaster, we have to limit the number of clips per podcast." Enforced server-side via Edge Function. Figma "10/12" text is placeholder. (See Flows.md §5, §19.8) |
| FR-65 | Offline Episode Player | Premium | Offline variant of Episode Player for downloaded episodes. Shows: "You're offline" banner at top, "Downloaded" green dot indicator, podcast name. Episode artwork overlaid with "Show Chapters" and "Show Transcript" quick-access buttons. Waveform-style progress bar with current/total timestamps (32:15 / 74:44). Controls: 1x speed, skip back 30s, play/pause, skip forward 30s, share. "Generate Clip" button (scissors icon) — clips previous 30s. Clip quota display with fair-usage message. (See Flows.md §19.8) |
| FR-66 | Offline Clip Generation Success | Premium | Bottom sheet shown after generating a clip while offline. Check icon + "Clip Generated and will be synced when your connection is back!" + "Clip will be added to your 'Learn' collection when your connection is back" + clip title display + "Review Now" button. Clip queued in `offline_queue` for sync on reconnection. (See Flows.md §19.9) |

### 3.2 Technical Decisions from Prep Document

| Decision | Value | Rationale (from prep doc) |
|----------|-------|--------------------------|
| Backend | Supabase | Fits relational data, auth, storage, RLS, and server-side logic needs |
| State Management | Cubit | Cleaner business logic separation and easier maintainability |
| Offline Support | Yes, partial | Draft data cached locally, synced later, server authoritative on final state |
| Media Storage | AWS S3 + CloudFront | Cheaper long-term cost and better delivery for media-heavy app |
| AI Tools | Cursor, MCP (Supabase & Figma), GPT | Schema design, RLS review, SQL generation, Figma review, documentation |
| Account Deletion | Hybrid (soft + hard) | Soft delete protects auditability, hard delete removes PII where required |
| Email | Resend | Production email delivery with SPF, DKIM, domain verification |
| Payments | IAP Subscription via RevenueCat | Digital premium access requires IAP for platform compliance |
| Region | Frankfurt | Selected based on Egypt/GCC user base and latency |
| Notifications | Push notifications configured | Doc references Firebase setup; project uses OneSignal — needs alignment |

### 3.3 API / Service Map (from prep doc Section 5.2)

| Service | Purpose | Access Status |
|---------|---------|--------------|
| OneSignal | Push notifications | Requested |
| Crashlytics | Crash monitoring | Requested |
| UXCam | Analytics | Requested |
| RevenueCat | Subscription management | Requested |
| Firebase | Push notification infra (per doc) | Requested |
| Supabase | Backend (auth, DB, storage, functions) | Requested |
| OpenAI / Gemini | AI transcripts, summaries, takeaways | Requested |
| AWS S3 + CloudFront | Media storage and caching | Requested |
| Resend | Transactional email | Requested |
| Podcast API (TBD) | Podcasts, chapters, hosts, episodes | **NOT CHOSEN** |

### 3.4 Design Handover Notes (critical items from meeting)

1. **Bug/feature request email flow needed** — not in design
2. **Fair usage calculation** — clip limit based on % of episode time; formula TBD
3. **Ad source clarification** — must determine where ads come from to avoid App Store rejection (no in-audio ads; non-intrusive display ads only)
4. **Legal pages required** — Terms & Conditions, Privacy Policy, Comment Reporting mechanism — none currently in design

---

## 4. Product Gaps, Assumptions & Unknowns

### 4.1 Critical Gaps (Blocking)

| # | Gap | Impact | Resolution |
|---|-----|--------|-----------|
| G1 | **~~7~~ 3 screens have no HiFi design** (Search, ~~Podcast Page, Episode Details, Episode Player,~~ Web Clip Player, Authentication, Lock Screen) | Remaining 3 screens need HiFi before build | Designer must deliver HiFi for at minimum: Authentication, Search before Phase 1 sprint starts. **My Profile resolved** — 22 HiFi screens delivered (§2.1 items 10–11). **Collections resolved** — all 90 Lo-Fi wireframes reviewed; full Collections feature documented in Flows.md §9 and ERD.md; see FR-35–FR-42. **Podcast Page resolved** — 50 Lo-Fi wireframes reviewed; 4-tab podcast page, episode player, clip detail, all overlays documented in §2.1 items 12–14, FR-43–FR-54, and Flows.md §4–§5, §8. **Episode Details resolved** — 32 Lo-Fi wireframes reviewed across 4 user flows (first-time, free, paid, offline). Dedicated Episode Details page confirmed as new intermediate screen with transcript, chapters, clips sub-views, offline variant, and clip quota. Documented in §2.1 item 15, FR-55–FR-66, and Flows.md §19. |
| G2 | **Podcast API not selected** | Cannot build discovery, search, or playback | Must be resolved in Phase 0 — see Section 9 |
| G3 | **Fair usage clip limit formula ~~undefined~~** | Cannot implement clip gating for free tier | **PARTIALLY RESOLVED** — Free users: 3–5 clips per episode (configurable via `app_config.free_clip_limit_per_episode`). Subscribed users: unlimited (configurable limit in `app_config.premium_clip_limit_per_episode` for future use). Audio ads (6–10s) trigger for free users after 4–5 clips listened to. Remaining TBD: exact ad provider/placement. |
| G4 | **Ad source / provider not decided** | Cannot implement ad injection; risks App Store rejection if done wrong | Product/business decision; recommend Google AdMob with native ad placements (never in-audio) |
| G5 | **Notification provider conflict** — Prep doc references Firebase Cloud Messaging setup but project services list OneSignal | Dual integration is wasteful | **Decision required:** Use OneSignal only (recommended — simpler Flutter SDK, no Firebase dependency) |
| G6 | **Privacy Policy, Comment Reporting not in Figma** (T&C screen now exists in Profile HiFi) | Required for App Store submission and GDPR compliance | Legal copy required; Privacy Policy screen/modal needed; comment reporting mechanism needed |

### 4.2 Assumptions (proceeding with these unless corrected)

| # | Assumption | Basis |
|---|-----------|-------|
| A1 | One subscription tier (Premium) — no multi-tier | Figma shows single tier at $49/year |
| A2 | Premium price is $49/year with 1-month free trial (Figma), not £4.99/month (proposal) | Figma is post-sign-off source of truth |
| A3 | Single currency (USD) for IAP | Standard IAP handles local currency conversion |
| A4 | No admin panel in MVP | Not mentioned in Figma or functional requirements |
| A5 | AI processing (Whisper + GPT) runs server-side via Supabase Edge Functions | Secrets must not be client-side |
| A6 | Clips are audio-only (no video) | All references are to audio clips |
| A7 | Social feed is public by default; users can toggle individual clips to private | FR-08 specifies this |
| A8 | Web clip preview page (clipcast.app/clip/abc123) is a separate web deployment, not part of the Flutter app | External sharing requirement |
| A9 | Background audio buffer is 60 seconds, clip capture window is adjustable 15–60s within that buffer | FR-03 + FR-04 |
| A10 | OneSignal is the sole push notification provider (Firebase only used if required as a transport layer by OneSignal) | Simplicity; avoids dual integration |

### 4.3 Unknowns (require stakeholder answers)

| # | Unknown | Who Decides | Impact if Unresolved |
|---|---------|-------------|---------------------|
| U1 | Exact fair usage clip formula for free tier | Product Owner | Cannot implement free-tier gating |
| U2 | Ad provider and placement strategy | Product Owner / Client | Revenue model incomplete; App Store risk |
| U3 | Deep link domain setup (clipcast.app) — is domain owned? | Client | Cannot implement external sharing |
| U4 | GDPR data export format and scope | Legal / Product | Account management incomplete |
| U5 | Comment moderation strategy (auto-mod? manual? report-only?) | Product Owner | Social feed safety |
| U6 | Digest email frequency (daily vs weekly) and content scope | Product Owner | FR-17 implementation |
| U7 | AirPods double-tap / phone triple-tap feasibility on both platforms | Developer (spike) | May be platform-limited; needs technical spike |
| U8 | Whether Gemini is needed alongside OpenAI or as fallback | CTO / Client | Affects API integrations and cost |
| U9 | AWS account ownership — client or Red Software? | TPM / Client | Infrastructure ownership and billing |
| U10 | Waveform editor: build custom or use package (e.g., `audio_waveforms`)? | Developer | Build time estimate |

---

## 5. Scalable Design Token System

### 5.1 Current State

`lib/theme/app_colors.dart` contains hardcoded `Color` constants. This is a flat, non-semantic system that will not scale.

### 5.2 Proposed Token Architecture

Three-tier token system: **Primitive → Semantic → Component**.

#### Tier 1: Primitive Tokens (raw values, never referenced directly in widgets)

```dart
// lib/theme/tokens/primitives.dart
abstract final class PrimitiveColors {
  // Neutrals
  static const Color neutral950 = Color(0xFF0B1215);
  static const Color neutral900 = Color(0xFF0C1215);
  static const Color neutral850 = Color(0xFF111C1F);
  static const Color neutral800 = Color(0xFF12191D);
  static const Color neutral700 = Color(0xFF1F2A2E);
  static const Color neutral600 = Color(0xFF2D3A40);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral50  = Color(0xFFF8FAFC);

  // Cyan / Brand
  static const Color cyan500 = Color(0xFF11C5E1);
  static const Color cyan400 = Color(0xFF0BC9E9);

  // White alpha
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
}
```

#### Tier 2: Semantic Tokens (purpose-driven, theme-switchable)

```dart
// lib/theme/tokens/semantic.dart
abstract final class SemanticColors {
  // Backgrounds
  static const Color backgroundPrimary   = PrimitiveColors.neutral950; // #0B1215
  static const Color backgroundSecondary = PrimitiveColors.neutral850; // #111C1F
  static const Color backgroundSurface   = PrimitiveColors.neutral800; // #12191D
  static const Color backgroundCard      = PrimitiveColors.neutral900; // #0C1215

  // Text
  static const Color textPrimary   = PrimitiveColors.neutral50;  // #F8FAFC
  static const Color textSecondary = PrimitiveColors.neutral400; // #9CA3AF
  static const Color textOnPrimary = PrimitiveColors.neutral950; // #0B1215 (dark text on cyan buttons)
  static const Color textTertiary  = PrimitiveColors.neutral200; // #E5E7EB

  // Interactive
  static const Color interactivePrimary = PrimitiveColors.cyan500;  // #11C5E1
  static const Color interactiveHover   = PrimitiveColors.cyan400;  // #0BC9E9

  // Borders
  static const Color borderDefault  = PrimitiveColors.neutral700; // #1F2A2E
  static const Color borderSubtle   = PrimitiveColors.neutral600; // #2D3A40

  // Feedback (to be extracted from Figma when available)
  static const Color feedbackSuccess = Color(0xFF22C55E);
  static const Color feedbackError   = Color(0xFFEF4444);
  static const Color feedbackWarning = Color(0xFFF59E0B);
}
```

#### Tier 3: Component Tokens (scoped to specific widgets)

```dart
// lib/theme/tokens/components.dart
abstract final class ComponentColors {
  // Buttons
  static const Color buttonPrimaryBg     = SemanticColors.interactiveHover;    // #0BC9E9
  static const Color buttonPrimaryText   = SemanticColors.textOnPrimary;       // #0B1215
  static const Color buttonSecondaryBg   = PrimitiveColors.white20;
  static const Color buttonSecondaryBorder = PrimitiveColors.white40;
  static const Color buttonSecondaryText = SemanticColors.textTertiary;

  // Nav bar
  static const Color navBarBg           = SemanticColors.backgroundPrimary;
  static const Color navBarActive       = SemanticColors.interactivePrimary;
  static const Color navBarInactive     = SemanticColors.textSecondary;

  // Feed card
  static const Color feedCardBg         = SemanticColors.backgroundCard;
  static const Color feedCardBorder     = SemanticColors.borderDefault;

  // Player
  static const Color playerProgressActive   = SemanticColors.interactivePrimary;
  static const Color playerProgressInactive = SemanticColors.borderSubtle;

  // Premium overlay
  static const Color premiumOverlayBg   = Color(0xCC0B1215); // 80% dark bg
}
```

### 5.3 Typography Tokens

```dart
// lib/theme/tokens/typography.dart
import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String _fontFamily = 'Inter';

  static const TextStyle h1Large = TextStyle(
    fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, height: 28 / 18,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w700, height: 28 / 16,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14,
  );
  static const TextStyle body1 = TextStyle(
    fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w400, height: 1.0, letterSpacing: -0.5,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily, fontSize: 10, fontWeight: FontWeight.w400, height: 14 / 10,
  );
}
```

### 5.4 Spacing & Radius Tokens

```dart
// lib/theme/tokens/spacing.dart
abstract final class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double base = 16;
  static const double lg  = 20;
  static const double xl  = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract final class AppRadius {
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double full = 999;
}
```

### 5.5 Migration Path

1. Replace `AppColors` references with semantic/component tokens
2. Keep `AppColors` as deprecated alias during transition
3. Wire semantic tokens into `ThemeData` and `ColorScheme` via `AppTheme` class
4. When light theme is needed, swap semantic values (primitives stay the same)

---

## 6. Product Requirements Document (PRD) Draft

### 6.1 Product Overview

| Field | Value |
|-------|-------|
| Product Name | ClipCast |
| Version | MVP (1.0) |
| Platforms | iOS, Android |
| Launch Target | 10–12 weeks from dev start |
| Business Model | Freemium + IAP Subscription |

### 6.2 User Personas

**Persona 1 — "The Knowledge Worker"**
- Role: Founder, team lead, consultant
- Listens to 5–10+ hours of podcasts per week
- Problem: Hears valuable insights but forgets them; manual note-taking interrupts flow
- Goal: Capture insights instantly, build a searchable knowledge library
- Key Feature: Tap-to-clip + AI summary + personal library

**Persona 2 — "The Social Listener"**
- Role: Curious professional, content creator
- Listens to a wide range of podcasts
- Problem: Wants to share interesting moments but sharing a full episode link loses context
- Goal: Share specific moments with context (transcript, summary) and discover what others are sharing
- Key Feature: Social feed + external clip sharing + follow system

### 6.3 User Stories (Epic-level)

| Epic | User Story | Priority | Tier |
|------|-----------|----------|------|
| Onboarding & Auth | As a new user, I can sign up with email, Google, or Apple and be guided through onboarding so I can start using the app quickly | P0 | Free |
| Podcast Discovery | As a user, I can search for podcasts by title/host/keyword and browse trending/recommended so I can find content I care about | P0 | Free |
| Podcast Playback | As a user, I can play episodes with standard controls (play/pause/seek/skip/speed) and continue listening in the background so my experience is uninterrupted | P0 | Free |
| Clip Capture | As a listener, I can tap a button to save the last 15–60s of audio as a clip without interrupting playback so I never lose an insight | P0 | Free (limited) |
| AI Processing | As a user, my clip is automatically transcribed (free) and summarised with a suggested title (premium) so I can review it later without re-listening | P0 | Freemium |
| Clip Editing | As a user, I can trim my clip using a visual waveform editor and add a title/tags before saving so my library stays organised | P1 | Free |
| Personal Library | As a user, I can browse, search, filter, play, edit, and delete my saved clips so I have a personal knowledge base | P0 | TBC |
| Social Feed | As a user, I can browse a feed of public clips in three tabs (Trending, Friends, My Feed), play clips inline, like/comment/share/bookmark, and view my own shared content in My Feed so I can discover and manage social content | P0 | Free |
| Follow System | As a user, I can follow other users and see their clips in my Friends feed, and view their profile with bio/clips/stats | P1 | Free |
| External Sharing | As a user, I can generate a unique link for any clip that opens a web preview with audio player, transcript, and summary so I can share outside the app | P1 | Free |
| Notifications | As a user, I receive in-app and push notifications for followers, liked/commented clips, and new clips from people I follow so I stay engaged | P1 | Free |
| Premium Subscription | As a user, I can upgrade to Premium for advanced AI summaries, unlimited clips, offline access, ad-free experience, and lock screen controls | P0 | Premium |
| Offline Mode | As a premium user, I can download episodes and access my library offline, with clips syncing when reconnected | P1 | Premium |
| Digest Email | As a user, I receive a periodic email recap of my saved clips and learnings | P2 | Free |
| Settings & Account | As a user, I can manage my profile, notification preferences, subscription, and delete my account with GDPR compliance | P1 | Free |
| Profile Hub | As a user, I can access account settings, share feedback, view T&C, and log out from a central Profile screen; offline shows My Library (Favorites + Downloads) | P1 | Free |
| Profile Edit | As a user, I can edit my avatar and display name, view my followers/following, and change my password | P1 | Free |
| Notification Preferences | As a user, I can toggle 4 notification types (review insights, new episodes, social, clip generation) on/off | P1 | Free |
| Gesture Control | As a user, I can enable/disable AirPods Double Tap to auto-create clips at my preferred duration | P1 | Free |
| Clip Length Preference | As a user, I can set my default clip duration (30s/45s/60s) for gesture-created clips | P1 | Free |
| Suggest Feature / Report Bug | As a user, I can submit feature suggestions and bug reports through in-app forms | P2 | Free |
| Episode Favourites | As a user, I can favourite individual episodes and view them in My Favorites → Episodes tab | P1 | Free |
| Downloads View | As a premium user, I can view all my downloaded content (podcasts, episodes, clips, collections) in the offline profile | P1 | Premium |

### 6.4 Feature Prioritisation (MoSCoW for MVP)

**Must Have (P0)**
- User authentication (email, Google, Apple)
- Podcast search & discovery
- Podcast playback with background audio
- Clip capture (tap-to-clip with 60s buffer)
- AI transcription (Whisper)
- Personal clip library
- Social feed (trending + friends + my feed)
- Premium subscription paywall (RevenueCat)

**Should Have (P1)**
- Clip editing (waveform trim)
- Follow system
- External clip sharing (web URL)
- Push notifications
- AI summary + suggested title (premium)
- Offline mode (premium)
- User profile page (hub, settings, edit)
- Settings & account management
- Notification preferences (4 toggles)
- Gesture control (AirPods Double Tap)
- Clip length preferences (30s/45s/60s)
- Episode favourites
- Downloads view (premium offline)

**Could Have (P2)**
- Digest email
- Metadata auto-tagging (premium)
- Ad skip / speed up ad segment (premium)
- Lock screen controls (premium)
- Advanced search filters
- Comment reporting / moderation
- Suggest New Feature form
- Report a Bug form

**Won't Have (MVP)**
- Admin panel
- Web application (full)
- Video clips
- Podcast creation/publishing tools
- Multi-language AI

### 6.5 Acceptance Criteria (for core flow)

**Clip Capture — Happy Path:**
1. User is playing an episode for at least 30 seconds
2. User taps "Clip" button in player UI
3. System captures last 30 seconds of buffered audio (default; adjustable 15–60s)
4. Playback is NOT interrupted
5. Visual confirmation appears (toast/animation)
6. Clip metadata saved: episode_id, start_time, end_time, duration, created_at
7. AI transcription triggered asynchronously
8. Clip appears in Personal Library within 5 seconds
9. If offline: clip queued locally with sync-pending status

---

## 7. Architecture Decision Record (ADR)

### ADR-001: Backend — Supabase over Firebase

| Field | Value |
|-------|-------|
| Status | Accepted |
| Context | App needs relational data (users, podcasts, episodes, clips, follows, likes, comments), row-level security, server-side functions, real-time subscriptions |
| Decision | Supabase (Postgres + Auth + Storage + Edge Functions + Realtime) |
| Alternatives | Firebase (rejected: weaker relational querying, Firestore not suited for complex joins/aggregations needed for feed ranking, follower counts, analytics); Custom backend (rejected: too much overhead for MVP timeline) |
| Consequences | (+) Strong SQL, RLS, Edge Functions, real-time listeners. (−) Smaller ecosystem than Firebase; fewer community packages; need to manage Postgres performance at scale |

### ADR-002: State Management — flutter_bloc (Cubit)

| Field | Value |
|-------|-------|
| Status | Accepted (from prep doc) |
| Context | Need predictable state management for complex flows: audio playback (multiple states), clip capture, offline sync, social feed pagination, subscription gating |
| Decision | flutter_bloc with Cubit for most features; full Bloc (events) only where complex event streams are needed (e.g., audio player) |
| Alternatives | Riverpod (considered: excellent DI and testability, but team has Cubit experience per prep doc); Provider (rejected: too primitive for this complexity) |
| Consequences | (+) Clean separation, testable, team familiarity. (−) More boilerplate than Riverpod; must be disciplined about Cubit granularity |

### ADR-003: Media Storage — AWS S3 + CloudFront over Supabase Storage

| Field | Value |
|-------|-------|
| Status | Accepted (from prep doc) |
| Context | Clips are audio files (15–60s each). At scale, thousands of clips generated daily. Need low-cost storage with CDN delivery for playback from feed |
| Decision | AWS S3 for storage + CloudFront for CDN delivery |
| Alternatives | Supabase Storage (rejected: higher cost at volume, less CDN control, bandwidth limits); Cloudinary (rejected: optimised for images/video, not audio) |
| Consequences | (+) Cost-effective at scale, global CDN, fine-grained access control. (−) Additional infrastructure to manage; need signed URLs for private clips; separate from Supabase ecosystem |

### ADR-004: Payments — RevenueCat (IAP)

| Field | Value |
|-------|-------|
| Status | Accepted |
| Context | Premium subscription for digital features; App Store / Google Play require IAP for in-app digital goods |
| Decision | RevenueCat for subscription management, entitlement tracking, and webhook integration |
| Alternatives | Direct StoreKit/BillingClient (rejected: complex, no cross-platform dashboard); Stripe (rejected: not allowed for in-app digital goods on mobile) |
| Consequences | (+) Cross-platform, handles receipt validation, webhooks to Supabase, analytics. (−) Revenue share with platform (15–30%); RevenueCat pricing at scale |

### ADR-005: Push Notifications — OneSignal

| Field | Value |
|-------|-------|
| Status | Proposed (needs alignment — prep doc mentions Firebase but service list has OneSignal) |
| Context | Need push notifications for social interactions (follow, like, comment) and new clips from followed users |
| Decision | OneSignal as sole push provider; uses FCM/APNs as transport layer internally |
| Rationale | Simpler Flutter SDK (onesignal_flutter), built-in segmentation, no need for separate Firebase project, aligns with service access list |
| Consequences | (+) Single integration point, rich targeting. (−) Vendor dependency; free tier has limits |

### ADR-006: AI Pipeline — Server-side via Supabase Edge Functions

| Field | Value |
|-------|-------|
| Status | Accepted |
| Context | AI calls to OpenAI (Whisper for transcription, GPT for summaries) require API keys that must never be client-side |
| Decision | All AI processing via Supabase Edge Functions. Client uploads clip audio to S3 → triggers Edge Function → transcription → summary → results stored in DB |
| Alternatives | Direct client-side API calls (rejected: exposes API keys); AWS Lambda (rejected: adds infrastructure complexity) |
| Consequences | (+) Keys secure, logic centralised, can rate-limit per user. (−) Edge Function cold starts; need to handle timeouts for long audio processing |

### ADR-007: Offline Strategy — Cache-first with Server-authoritative Sync

| Field | Value |
|-------|-------|
| Status | Accepted (from prep doc) |
| Context | Users may clip while offline (subway, airplane); clips must not be lost |
| Decision | Local SQLite/Drift cache for draft clips + queue. On reconnection, sync to server. Server is authoritative on final state |
| Alternatives | Full offline-first (rejected: complexity too high for MVP); online-only (rejected: core use case is mobile listening which is often offline) |
| Consequences | (+) Clips never lost, good UX. (−) Conflict resolution needed; sync progress UI required; Drift adds dependency |

---

## 8. Flutter Architecture & State Management

### 8.1 Project Structure (Feature-first)

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp, routing, theme
│   ├── router.dart                 # GoRouter configuration
│   └── di.dart                     # Dependency injection (get_it)
│
├── core/
│   ├── constants/                  # App-wide constants
│   ├── errors/                     # Failure classes, exceptions
│   ├── extensions/                 # Dart/Flutter extensions
│   ├── network/                    # Supabase client, connectivity
│   ├── storage/                    # Local cache (Drift/SharedPrefs)
│   └── utils/                      # Formatters, helpers
│
├── theme/
│   ├── tokens/
│   │   ├── primitives.dart
│   │   ├── semantic.dart
│   │   ├── components.dart
│   │   ├── typography.dart
│   │   └── spacing.dart
│   └── app_theme.dart              # ThemeData builder
│
├── shared/
│   ├── widgets/                    # Reusable widgets (buttons, cards, loaders)
│   ├── models/                     # Shared data models
│   └── cubits/                     # Cross-feature cubits (auth, connectivity)
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_remote_source.dart
│   │   ├── domain/
│   │   │   └── auth_models.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           ├── sign_in_screen.dart
│   │           ├── sign_up_screen.dart
│   │           └── onboarding_screen.dart
│   │
│   ├── discovery/
│   │   ├── data/
│   │   │   ├── podcast_repository.dart
│   │   │   ├── podcast_remote_source.dart  # Podcast API integration
│   │   │   └── podcast_local_source.dart   # Cache
│   │   ├── domain/
│   │   │   ├── podcast.dart
│   │   │   └── episode.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       ├── screens/
│   │       │   ├── home_screen.dart
│   │       │   ├── search_screen.dart
│   │       │   └── podcast_detail_screen.dart
│   │       └── widgets/
│   │
│   ├── player/
│   │   ├── data/
│   │   │   ├── audio_service.dart          # just_audio + audio_service
│   │   │   └── playback_repository.dart
│   │   ├── domain/
│   │   │   └── playback_state.dart
│   │   └── presentation/
│   │       ├── bloc/                       # Full Bloc (complex event streams)
│   │       │   ├── player_bloc.dart
│   │       │   ├── player_event.dart
│   │       │   └── player_state.dart
│   │       ├── screens/
│   │       │   └── episode_player_screen.dart
│   │       └── widgets/
│   │           ├── mini_player.dart
│   │           └── player_controls.dart
│   │
│   ├── episode_details/
│   │   ├── data/
│   │   │   ├── episode_details_repository.dart
│   │   │   ├── transcript_remote_source.dart   # RSS + Whisper fallback
│   │   │   └── chapter_remote_source.dart      # RSS + auto-generation fallback
│   │   ├── domain/
│   │   │   ├── transcript_segment.dart
│   │   │   └── chapter.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── episode_details_cubit.dart
│   │       │   └── episode_details_state.dart
│   │       ├── screens/
│   │       │   ├── episode_details_screen.dart
│   │       │   ├── episode_transcript_screen.dart
│   │       │   ├── episode_chapters_screen.dart
│   │       │   └── episode_clips_screen.dart
│   │       └── widgets/
│   │           ├── chapter_list_item.dart
│   │           └── transcript_segment_widget.dart
│   │
│   ├── clipping/
│   │   ├── data/
│   │   │   ├── clip_repository.dart
│   │   │   ├── clip_remote_source.dart
│   │   │   └── clip_local_source.dart      # Offline queue
│   │   ├── domain/
│   │   │   └── clip.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── screens/
│   │           └── clip_editor_screen.dart  # Waveform editor
│   │
│   ├── library/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── screens/
│   │           └── library_screen.dart
│   │
│   ├── feed/
│   │   ├── data/
│   │   │   ├── feed_repository.dart
│   │   │   └── feed_remote_source.dart
│   │   ├── domain/
│   │   │   └── feed_item.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       ├── screens/
│   │       │   └── feed_screen.dart        # Trending + Friends + My Feed tabs
│   │       └── widgets/
│   │           └── feed_card.dart
│   │
│   ├── social/
│   │   ├── data/
│   │   │   ├── social_repository.dart
│   │   │   └── follow_remote_source.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── screens/
│   │           ├── profile_screen.dart
│   │           └── followers_screen.dart
│   │
│   ├── notifications/
│   │   ├── data/
│   │   │   ├── notification_repository.dart
│   │   │   └── onesignal_service.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── screens/
│   │           └── notifications_screen.dart
│   │
│   ├── premium/
│   │   ├── data/
│   │   │   ├── subscription_repository.dart
│   │   │   └── revenuecat_service.dart
│   │   ├── domain/
│   │   │   └── entitlement.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       └── screens/
│   │           └── paywall_screen.dart
│   │
│   └── settings/
│       ├── data/
│       └── presentation/
│           ├── cubit/
│           └── screens/
│               └── settings_screen.dart
│
└── main.dart                               # Entry point, DI init, runApp
```

### 8.2 Layer Responsibilities

| Layer | Purpose | Rules |
|-------|---------|-------|
| **Presentation** | Cubits/Blocs, Screens, Widgets | Never imports `data/` directly; only talks to repository interfaces |
| **Domain** | Models, repository interfaces (abstract) | Pure Dart; no Flutter or package imports |
| **Data** | Repository implementations, remote/local sources | Handles Supabase calls, API calls, caching; maps raw data to domain models |

### 8.3 State Management Guidelines

| Scenario | Approach |
|----------|----------|
| Simple CRUD screens (library, settings, profile) | **Cubit** — emit state directly from methods |
| Complex event-driven flows (audio player) | **Bloc** — event-driven with event transformers for debounce/throttle |
| Global cross-cutting state (auth, connectivity, subscription) | **Cubit** provided at app root via `MultiBlocProvider` |
| Feed pagination | **Cubit** with `loadMore()` method, maintaining list + hasMore + loading state |
| Offline clip queue | **Cubit** watching connectivity, triggering sync batch on reconnect |

### 8.4 Key Packages (Recommended)

| Category | Package | Purpose |
|----------|---------|---------|
| State | `flutter_bloc` | Cubit/Bloc |
| DI | `get_it` + `injectable` | Service locator + code gen |
| Routing | `go_router` | Declarative routing, deep links |
| Audio | `just_audio` + `audio_service` | Playback + background/lock screen controls |
| Audio Buffer | Custom ring buffer on `just_audio` stream | 60s clip capture buffer |
| Waveform | `audio_waveforms` | Clip editor visualisation |
| Supabase | `supabase_flutter` | Auth, DB, Storage, Realtime, Edge Functions |
| Local DB | `drift` | SQLite for offline cache + clip queue |
| Network | `connectivity_plus` | Connectivity monitoring |
| Payments | `purchases_flutter` | RevenueCat SDK |
| Notifications | `onesignal_flutter` | Push notifications |
| Image | `cached_network_image` | Podcast artwork caching |
| Analytics | `uxcam_flutter` | UXCam integration |
| Crash | `firebase_crashlytics` | Crash reporting |
| Email | Server-side only (Resend) | No client package needed |
| Sharing | `share_plus` | Native share sheet |
| Deep Links | `go_router` + platform config | Universal links / App Links |

### 8.5 Audio Architecture (Critical Path)

```
┌─────────────────────────────────────────────────┐
│                   PlayerBloc                      │
│  Events: Play, Pause, Seek, Skip, SetSpeed,     │
│          CaptureClip, ToggleBuffer               │
│  States: Initial, Loading, Playing, Paused,      │
│          Buffering, Error, ClipCaptured           │
└────────────────────┬────────────────────────────┘
                     │
          ┌──────────▼──────────┐
          │   AudioService       │
          │   (background)       │
          │   ┌────────────┐    │
          │   │ just_audio  │    │
          │   │  Player     │    │
          │   └─────┬──────┘    │
          │         │            │
          │   ┌─────▼──────┐    │
          │   │ RingBuffer  │    │  ← Captures last 60s of decoded audio
          │   │ (60s PCM)   │    │
          │   └─────┬──────┘    │
          │         │            │
          └─────────┼────────────┘
                    │
          ┌─────────▼──────────┐
          │  ClipCaptureService │  ← On tap: extract last N seconds from buffer
          │  - extractClip()   │     encode to AAC/M4A, save to temp file
          │  - encodeAudio()   │     queue for upload
          └─────────┬──────────┘
                    │
          ┌─────────▼──────────┐
          │  ClipRepository     │  ← Upload to S3, save metadata to Supabase
          │  - saveClip()      │     trigger AI Edge Function
          │  - queueOffline()  │
          └────────────────────┘
```

---

## 9. Podcast API — Taddy

### 9.1 Requirements for the Podcast API

Based on functional requirements (FR-01, FR-02, FR-03), the podcast API must provide:

| Requirement | Priority | Taddy Support |
|-------------|----------|---------------|
| Search by title, host, keyword | Must | ✅ `search(term:, filterForTypes:)` — full-text, sort by EXACTNESS or POPULARITY |
| Podcast metadata (name, artwork, publisher, description) | Must | ✅ `getPodcastSeries` — name, imageUrl, authorName, description |
| Episode list per podcast | Must | ✅ `getPodcastSeries(uuid:) { episodes }` — paginated |
| Episode streaming URL (audio file URL) | Must | ✅ `audioUrl` field — direct file link |
| Episode duration, publish date | Must | ✅ `duration` (seconds), `datePublished` (epoch) |
| Trending / popular podcasts | Should | ✅ `getTopChartsByCountry`, `getPopularContent` |
| Genre / category browsing (7 categories) | Should | ✅ `getTopChartsByGenres`, genre filtering on search — Business, News & Current Affairs, Technology, Education, Health & Wellbeing, Culture & Society, Other |
| Podcast RSS feed URL | Should | ✅ `rssUrl` field (for fallback parsing) |
| Episode chapters | Could | ✅ Chapter support via `chapters` field |
| Episode transcripts | Could | ✅ Built-in transcripts (Pro: 100/mo, Business: 2000/mo) |

### 9.2 Why Taddy

**Decision: Taddy GraphQL API is the sole primary podcast data source.**

| Criterion | Taddy | PodcastIndex | Listen Notes |
|-----------|-------|-------------|-------------|
| Index size | 4M+ podcasts, 200M+ episodes | 4M+ | 3M+ |
| API style | **GraphQL** (request exactly what you need) | REST | REST |
| Trending | Apple Podcasts top charts by country & genre | Community trending | Curated |
| Transcripts | ✅ Built-in | ❌ | ❌ |
| Chapters | ✅ | ✅ | ❌ |
| Popularity rank | ✅ `popularityRank` field | ❌ | Partial |
| Cached responses | Free (don't count against quota) | N/A | N/A |
| Webhooks | ✅ (Business plan) | ❌ | ❌ |
| Free tier | 500 req/mo | Unlimited | 300 req/mo |

### 9.3 Architecture

- **Single endpoint:** `https://api.taddy.org` (POST, GraphQL)
- **Auth headers:** `X-USER-ID` + `X-API-KEY` — **server-side only** (Supabase Edge Functions)
- **Client never calls Taddy directly**
- Wrap behind `PodcastRemoteSource` interface → `TaddySource` implementation
- RSS fallback via `rssUrl` field if Taddy is unavailable

```
Flutter app → Supabase (cached tables) → Edge Function → Taddy API
```

### 9.4 Cost Analysis

| Phase | MAU | Taddy Plan | Monthly Cost | Requests |
|-------|-----|-----------|-------------|----------|
| Dev / MVP | 0-100 | Free | $0 | <500 |
| Beta | 100-1K | Pro | $75 | ~10K-50K |
| Launch | 1K-10K | Pro | $75 | ~50K-100K |
| Growth | 10K-100K | Business | $150 | ~100K-350K |
| Scale | 100K+ | Custom | $250+ | 1M+ |

### 9.5 Key Queries

| Query | Purpose |
|-------|---------|
| `search(term:, filterForTypes:)` | Full-text search for podcasts/episodes |
| `getPopularContent(filterByLanguage:)` | Most popular podcasts |
| `getTopChartsByCountry(country:)` | Apple Podcasts daily charts |
| `getTopChartsByGenres(genres:)` | Charts filtered by genre |
| `getPodcastSeries(uuid:)` | Podcast detail + episodes |
| `getLatestEpisodesFromMultiplePodcasts(uuids:)` | Batch episode fetch |
| `getApiRequestsRemaining` | Quota monitoring |

> Full Taddy integration details, GraphQL query examples, seeding phases, and cron
> schedules are documented in `docs/TaddyAPI.md`.

### 9.6 Spike Required

- [ ] Register Taddy developer account and get API key
- [ ] Test `search`, `getPopularContent`, `getTopChartsByCountry` from Supabase Edge Function
- [ ] Verify `audioUrl` fields return direct streaming URLs (not redirects requiring auth)
- [ ] Benchmark response times from Supabase Frankfurt → Taddy API
- [ ] Confirm cached responses don't count against quota (verify with repeated queries)
- [ ] Run initial seed script and verify podcast/episode data integrity

---

## 10. Data Seeding & Webhook Strategy

### 10.1 Initial Data Seeding

The app needs a non-empty experience for new users. Seeding strategy:

| Data | Source | Method | Frequency |
|------|--------|--------|-----------|
| Trending podcasts | Taddy `getTopChartsByCountry` | Supabase Edge Function (cron, every 6h) | Ongoing |
| Popular by genre | Taddy `getPopularContent(filterByGenres:)` | Supabase Edge Function (cron, daily) | Ongoing |
| Genre/category list (7 categories) | Mapped from Taddy Genre ENUMs → Business, News & Current Affairs, Technology, Education, Health & Wellbeing, Culture & Society, Other | One-time seed | Seed |
| Featured/recommended podcasts | Manual curation by product team | Supabase `featured_podcasts` table, manual insert | As needed |
| Sample clips (for new users) | Internal team creates demo clips | Pre-populate via seed script | One-time |
| Podcast artwork | CDN URLs from Taddy responses | Stored as URLs, not downloaded | N/A |

### 10.2 Webhook Architecture

```
┌──────────────┐     webhook      ┌─────────────────────┐
│  RevenueCat   │ ───────────────▶ │ Supabase Edge Func  │
│  (payments)   │                  │ /webhooks/revenuecat│
└──────────────┘                  └────────┬────────────┘
                                           │ Update user_subscriptions table
                                           │ Set/revoke entitlements
                                           ▼
┌──────────────┐     webhook      ┌─────────────────────┐
│  OneSignal    │ ◀─────────────── │ Supabase Edge Func  │
│  (push)       │                  │ /functions/notify   │
└──────────────┘                  └────────┬────────────┘
                                           │ Triggered by DB events
                                           │ (new follow, like, comment, clip)
                                           ▼
┌──────────────┐    Supabase DB    ┌─────────────────────┐
│  OpenAI       │ ◀─────Edge Func── │ clips table INSERT  │
│  (Whisper+GPT)│                   │ trigger → process   │
└──────────────┘                   └─────────────────────┘
```

### 10.3 Webhook Endpoints (Supabase Edge Functions)

| Endpoint | Trigger | Action |
|----------|---------|--------|
| `/webhooks/revenuecat` | RevenueCat subscription events (purchase, renewal, cancellation, expiry) | Update `user_subscriptions` table; set `is_premium` flag; revoke entitlements on expiry |
| `/functions/process-clip` | New row in `clips` table (via DB trigger or direct call) | Download audio from S3 → Whisper transcription → GPT summary (if premium) → Update clip record |
| `/functions/notify` | New row in `notifications` table (via DB trigger) | Send push via OneSignal API |
| `/functions/sync-trending` | Cron (every 6 hours) | Fetch trending from Taddy `getTopChartsByCountry` → upsert into `trending_podcasts` table |
| `/functions/digest-email` | Cron (weekly, Monday 8am user-local) | Generate AI recap per user → send via Resend |

### 10.4 Real-time Subscriptions (Supabase Realtime)

| Channel | Table/Event | Client Use |
|---------|-------------|-----------|
| `notifications:{user_id}` | `notifications` INSERT | Badge count update, in-app notification toast |
| `feed:trending` | `feed_items` INSERT (where trending) | Live feed updates |
| `clip:{clip_id}:engagement` | `likes`, `comments` INSERT | Live like/comment count on clip detail |

---

## 11. Supabase ERD & Schema

### 11.1 Entity Relationship Diagram (Text)

```
┌──────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   profiles    │       │    podcasts       │       │    episodes      │
├──────────────┤       ├──────────────────┤       ├──────────────────┤
│ id (PK, FK→  │       │ id (PK, uuid)    │       │ id (PK, uuid)    │
│   auth.users)│       │ external_id      │       │ external_id      │
│ username     │       │ title            │       │ podcast_id (FK)  │
│ display_name │       │ author           │       │ title            │
│ avatar_url   │       │ description      │       │ description      │
│ bio          │       │ artwork_url      │       │ audio_url        │
│ is_premium   │       │ rss_url          │       │ artwork_url      │
│ created_at   │       │ categories       │       │ duration_seconds │
│ updated_at   │       │ total_episodes   │       │ published_at     │
└──────┬───────┘       │ source (enum)    │       │ chapters (jsonb) │
       │               │ created_at       │       │ created_at       │
       │               └────────┬─────────┘       └────────┬─────────┘
       │                        │                           │
       │  ┌─────────────────────┼───────────────────────────┘
       │  │                     │
       │  │  ┌──────────────────▼──────────┐
       │  │  │     podcast_favourites       │
       │  │  ├─────────────────────────────┤
       │  │  │ user_id (PK, FK→profiles)   │
       │  │  │ podcast_id (PK, FK→podcasts)│
       │  │  │ created_at                  │
       │  │  └─────────────────────────────┘
       │  │
       ▼  │
┌──────────────────┐       ┌──────────────────┐
│     clips        │       │  clip_engagement  │
├──────────────────┤       ├──────────────────┤
│ id (PK, uuid)    │       │ id (PK, uuid)    │
│ user_id (FK)     │       │ clip_id (FK)     │
│ episode_id (FK)  │       │ user_id (FK)     │
│ title            │       │ type (enum:      │
│ description      │       │  like/bookmark)  │
│ audio_url (S3)   │       │ created_at       │
│ start_time       │       └──────────────────┘
│ end_time         │
│ duration_seconds │       ┌──────────────────┐
│ transcript       │       │    comments      │
│ ai_summary       │       ├──────────────────┤
│ tags (text[])    │       │ id (PK, uuid)    │
│ is_public        │       │ clip_id (FK)     │
│ is_processed     │       │ user_id (FK)     │
│ sync_status      │       │ body             │
│ share_token      │       │ created_at       │
│ play_count       │       │ updated_at       │
│ share_count      │       └──────────────────┘
│ created_at       │
│ updated_at       │       ┌──────────────────┐
└──────────────────┘       │    follows       │
                           ├──────────────────┤
┌──────────────────┐       │ follower_id (FK) │
│ user_subscriptions│      │ following_id (FK)│
├──────────────────┤       │ created_at       │
│ id (PK, uuid)    │       └──────────────────┘
│ user_id (FK)     │
│ rc_customer_id   │       ┌──────────────────┐
│ product_id       │       │  notifications   │
│ status (enum)    │       ├──────────────────┤
│ expires_at       │       │ id (PK, uuid)    │
│ trial_end_at     │       │ user_id (FK)     │
│ created_at       │       │ type (enum)      │
│ updated_at       │       │ title            │
└──────────────────┘       │ body             │
                           │ data (jsonb)     │
┌──────────────────┐       │ is_read          │
│ playback_progress│       │ created_at       │
├──────────────────┤       └──────────────────┘
│ user_id (FK, PK) │
│ episode_id(FK,PK)│       ┌──────────────────┐
│ position_seconds │       │ offline_queue    │
│ completed        │       ├──────────────────┤
│ updated_at       │       │ id (PK, uuid)    │
└──────────────────┘       │ user_id (FK)     │
                           │ action (enum)    │
┌──────────────────┐       │ payload (jsonb)  │
│ trending_podcasts│       │ status (enum)    │
├──────────────────┤       │ created_at       │
│ id (PK, uuid)    │       │ synced_at        │
│ podcast_id (FK)  │       └──────────────────┘
│ rank             │
│ score            │
│ period (enum)    │
│ updated_at       │
└──────────────────┘
```

### 11.2 Schema DDL

```sql
-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE podcast_source AS ENUM ('taddy', 'rss');
CREATE TYPE subscription_status AS ENUM ('trialing', 'active', 'expired', 'cancelled', 'paused');
CREATE TYPE engagement_type AS ENUM ('like', 'bookmark');
CREATE TYPE notification_type AS ENUM ('new_follower', 'new_clip', 'like', 'comment', 'share');
CREATE TYPE sync_status AS ENUM ('local', 'uploading', 'processing', 'ready', 'failed');
CREATE TYPE queue_action AS ENUM ('create_clip', 'update_clip', 'delete_clip');
CREATE TYPE queue_status AS ENUM ('pending', 'syncing', 'synced', 'failed');
CREATE TYPE trending_period AS ENUM ('daily', 'weekly', 'monthly');

-- ============================================================
-- PROFILES (extends auth.users)
-- ============================================================
CREATE TABLE profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username    TEXT UNIQUE NOT NULL,
    display_name TEXT,
    avatar_url  TEXT,
    bio         TEXT,
    is_premium  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_profiles_username ON profiles (username);

-- ============================================================
-- PODCASTS (cached from API)
-- ============================================================
CREATE TABLE podcasts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_id     TEXT UNIQUE NOT NULL,    -- Taddy UUID
    title           TEXT NOT NULL,
    author          TEXT,
    description     TEXT,
    artwork_url     TEXT,
    rss_url         TEXT,
    categories      TEXT[] DEFAULT '{}',
    total_episodes  INT DEFAULT 0,
    source          podcast_source NOT NULL DEFAULT 'taddy',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_podcasts_external_id ON podcasts (external_id);
CREATE INDEX idx_podcasts_title_trgm ON podcasts USING gin (title gin_trgm_ops);

-- ============================================================
-- EPISODES (cached from API)
-- ============================================================
CREATE TABLE episodes (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_id     TEXT UNIQUE NOT NULL,
    podcast_id      UUID NOT NULL REFERENCES podcasts(id) ON DELETE CASCADE,
    title           TEXT NOT NULL,
    description     TEXT,
    audio_url       TEXT NOT NULL,
    artwork_url     TEXT,
    duration_seconds INT,
    published_at    TIMESTAMPTZ,
    chapters        JSONB DEFAULT '[]',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_episodes_podcast_id ON episodes (podcast_id);
CREATE INDEX idx_episodes_published_at ON episodes (published_at DESC);

-- ============================================================
-- PODCAST FAVOURITES
-- ============================================================
CREATE TABLE podcast_favourites (
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    podcast_id  UUID NOT NULL REFERENCES podcasts(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, podcast_id)
);

-- ============================================================
-- CLIPS
-- ============================================================
CREATE TABLE clips (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    episode_id      UUID NOT NULL REFERENCES episodes(id) ON DELETE CASCADE,
    title           TEXT,
    description     TEXT,
    audio_url       TEXT,                   -- S3 URL after upload
    start_time      REAL NOT NULL,          -- seconds into episode
    end_time        REAL NOT NULL,
    duration_seconds REAL NOT NULL,
    transcript      TEXT,                   -- populated by AI
    ai_summary      TEXT,                   -- populated by AI (premium)
    tags            TEXT[] DEFAULT '{}',
    is_public       BOOLEAN NOT NULL DEFAULT TRUE,
    is_processed    BOOLEAN NOT NULL DEFAULT FALSE,
    sync_status     sync_status NOT NULL DEFAULT 'local',
    share_token     TEXT UNIQUE,            -- for external sharing URL
    play_count      INT NOT NULL DEFAULT 0,
    share_count     INT NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_clips_user_id ON clips (user_id);
CREATE INDEX idx_clips_episode_id ON clips (episode_id);
CREATE INDEX idx_clips_is_public ON clips (is_public) WHERE is_public = TRUE;
CREATE INDEX idx_clips_created_at ON clips (created_at DESC);
CREATE INDEX idx_clips_share_token ON clips (share_token) WHERE share_token IS NOT NULL;
CREATE INDEX idx_clips_tags ON clips USING gin (tags);

-- ============================================================
-- CLIP ENGAGEMENT (likes, bookmarks)
-- ============================================================
CREATE TABLE clip_engagement (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clip_id     UUID NOT NULL REFERENCES clips(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type        engagement_type NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (clip_id, user_id, type)
);

CREATE INDEX idx_engagement_clip_id ON clip_engagement (clip_id);
CREATE INDEX idx_engagement_user_id ON clip_engagement (user_id);

-- ============================================================
-- COMMENTS
-- ============================================================
CREATE TABLE comments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clip_id     UUID NOT NULL REFERENCES clips(id) ON DELETE CASCADE,
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    body        TEXT NOT NULL CHECK (char_length(body) <= 2000),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_comments_clip_id ON comments (clip_id, created_at);

-- ============================================================
-- FOLLOWS
-- ============================================================
CREATE TABLE follows (
    follower_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    following_id    UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id != following_id)
);

CREATE INDEX idx_follows_following ON follows (following_id);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    type        notification_type NOT NULL,
    title       TEXT NOT NULL,
    body        TEXT,
    data        JSONB DEFAULT '{}',         -- actor_id, clip_id, etc.
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_notifications_user_id ON notifications (user_id, created_at DESC);
CREATE INDEX idx_notifications_unread ON notifications (user_id) WHERE is_read = FALSE;

-- ============================================================
-- USER SUBSCRIPTIONS (managed by RevenueCat webhooks)
-- ============================================================
CREATE TABLE user_subscriptions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    rc_customer_id  TEXT NOT NULL,           -- RevenueCat customer ID
    product_id      TEXT NOT NULL,           -- e.g., 'clipcast_premium_yearly'
    status          subscription_status NOT NULL DEFAULT 'trialing',
    expires_at      TIMESTAMPTZ,
    trial_end_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_subscriptions_user_id ON user_subscriptions (user_id);
CREATE INDEX idx_subscriptions_rc_customer ON user_subscriptions (rc_customer_id);

-- ============================================================
-- PLAYBACK PROGRESS
-- ============================================================
CREATE TABLE playback_progress (
    user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    episode_id      UUID NOT NULL REFERENCES episodes(id) ON DELETE CASCADE,
    position_seconds REAL NOT NULL DEFAULT 0,
    completed       BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, episode_id)
);

-- ============================================================
-- OFFLINE QUEUE (client-side mirror, synced to server)
-- ============================================================
-- Note: This table primarily exists on the client (Drift/SQLite).
-- The server-side version is for audit/debugging only.
CREATE TABLE offline_queue (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    action      queue_action NOT NULL,
    payload     JSONB NOT NULL,
    status      queue_status NOT NULL DEFAULT 'pending',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    synced_at   TIMESTAMPTZ
);

-- ============================================================
-- TRENDING PODCASTS (populated by cron edge function)
-- ============================================================
CREATE TABLE trending_podcasts (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    podcast_id  UUID NOT NULL REFERENCES podcasts(id) ON DELETE CASCADE,
    rank        INT NOT NULL,
    score       REAL NOT NULL DEFAULT 0,
    period      trending_period NOT NULL DEFAULT 'daily',
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (podcast_id, period)
);

CREATE INDEX idx_trending_period_rank ON trending_podcasts (period, rank);

-- ============================================================
-- FUNCTIONS: Auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_clips_updated BEFORE UPDATE ON clips
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_comments_updated BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_subscriptions_updated BEFORE UPDATE ON user_subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_playback_updated BEFORE UPDATE ON playback_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- FUNCTIONS: Generate share token on clip insert
-- ============================================================
CREATE OR REPLACE FUNCTION generate_share_token()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.share_token IS NULL THEN
        NEW.share_token = encode(gen_random_bytes(9), 'base64');
        -- Replace URL-unsafe chars
        NEW.share_token = replace(replace(NEW.share_token, '+', '-'), '/', '_');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_clips_share_token BEFORE INSERT ON clips
    FOR EACH ROW EXECUTE FUNCTION generate_share_token();

-- ============================================================
-- VIEWS: Feed query (public clips with engagement counts)
-- ============================================================
CREATE OR REPLACE VIEW feed_view AS
SELECT
    c.id,
    c.user_id,
    p.username,
    p.display_name,
    p.avatar_url,
    c.title,
    c.description,
    c.audio_url,
    c.duration_seconds,
    c.transcript,
    c.ai_summary,
    c.tags,
    c.share_token,
    c.play_count,
    c.share_count,
    c.created_at,
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

### 11.3 Key Relationships

| Relationship | Type | Notes |
|-------------|------|-------|
| profiles ↔ auth.users | 1:1 | Profile extends Supabase auth |
| profiles → clips | 1:N | A user has many clips |
| episodes → clips | 1:N | A clip belongs to one episode |
| podcasts → episodes | 1:N | A podcast has many episodes |
| profiles ↔ podcasts (via podcast_favourites) | M:N | Junction table |
| profiles ↔ profiles (via follows) | M:N | Self-referencing |
| clips ↔ profiles (via clip_engagement) | M:N | Like/bookmark |
| clips → comments | 1:N | A clip has many comments |
| profiles → notifications | 1:N | User receives notifications |
| profiles → user_subscriptions | 1:N | Subscription history |
| profiles ↔ episodes (via playback_progress) | M:N | Resume position tracking |

---

## 12. Security, RLS & Backend Responsibility

### 12.1 Row-Level Security (RLS) Policies

All tables have RLS enabled. Policies use `auth.uid()` to identify the current user.

```sql
-- ============================================================
-- PROFILES
-- ============================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Anyone can read public profile info
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (true);
-- Users can only update their own profile
CREATE POLICY "profiles_update" ON profiles FOR UPDATE USING (auth.uid() = id);
-- Profile created via trigger on auth.users insert (not directly)
CREATE POLICY "profiles_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- ============================================================
-- CLIPS
-- ============================================================
ALTER TABLE clips ENABLE ROW LEVEL SECURITY;

-- Public clips visible to all; own clips always visible
CREATE POLICY "clips_select" ON clips FOR SELECT
    USING (is_public = TRUE OR user_id = auth.uid());
-- Users can only insert their own clips
CREATE POLICY "clips_insert" ON clips FOR INSERT
    WITH CHECK (user_id = auth.uid());
-- Users can only update their own clips
CREATE POLICY "clips_update" ON clips FOR UPDATE
    USING (user_id = auth.uid());
-- Users can only delete their own clips
CREATE POLICY "clips_delete" ON clips FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================
-- CLIP ENGAGEMENT
-- ============================================================
ALTER TABLE clip_engagement ENABLE ROW LEVEL SECURITY;

-- Anyone can see engagement on public clips
CREATE POLICY "engagement_select" ON clip_engagement FOR SELECT USING (true);
-- Users can only insert their own engagement
CREATE POLICY "engagement_insert" ON clip_engagement FOR INSERT
    WITH CHECK (user_id = auth.uid());
-- Users can only delete their own engagement
CREATE POLICY "engagement_delete" ON clip_engagement FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================
-- COMMENTS
-- ============================================================
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "comments_select" ON comments FOR SELECT USING (true);
CREATE POLICY "comments_insert" ON comments FOR INSERT
    WITH CHECK (user_id = auth.uid());
-- Users can update only their own comments
CREATE POLICY "comments_update" ON comments FOR UPDATE
    USING (user_id = auth.uid());
-- Users can delete only their own comments
CREATE POLICY "comments_delete" ON comments FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================
-- FOLLOWS
-- ============================================================
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "follows_select" ON follows FOR SELECT USING (true);
CREATE POLICY "follows_insert" ON follows FOR INSERT
    WITH CHECK (follower_id = auth.uid());
CREATE POLICY "follows_delete" ON follows FOR DELETE
    USING (follower_id = auth.uid());

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only see their own notifications
CREATE POLICY "notifications_select" ON notifications FOR SELECT
    USING (user_id = auth.uid());
-- Only Edge Functions (service role) insert notifications
-- No client insert policy
CREATE POLICY "notifications_update" ON notifications FOR UPDATE
    USING (user_id = auth.uid());  -- mark as read

-- ============================================================
-- USER SUBSCRIPTIONS
-- ============================================================
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only read their own subscription
CREATE POLICY "subscriptions_select" ON user_subscriptions FOR SELECT
    USING (user_id = auth.uid());
-- Only Edge Functions (service role via webhook) can insert/update
-- No client insert/update policy

-- ============================================================
-- PLAYBACK PROGRESS
-- ============================================================
ALTER TABLE playback_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "progress_select" ON playback_progress FOR SELECT
    USING (user_id = auth.uid());
CREATE POLICY "progress_upsert" ON playback_progress FOR INSERT
    WITH CHECK (user_id = auth.uid());
CREATE POLICY "progress_update" ON playback_progress FOR UPDATE
    USING (user_id = auth.uid());

-- ============================================================
-- PODCAST FAVOURITES
-- ============================================================
ALTER TABLE podcast_favourites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "favourites_select" ON podcast_favourites FOR SELECT
    USING (user_id = auth.uid());
CREATE POLICY "favourites_insert" ON podcast_favourites FOR INSERT
    WITH CHECK (user_id = auth.uid());
CREATE POLICY "favourites_delete" ON podcast_favourites FOR DELETE
    USING (user_id = auth.uid());

-- ============================================================
-- PODCASTS & EPISODES (cached, read-only for clients)
-- ============================================================
ALTER TABLE podcasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE episodes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "podcasts_select" ON podcasts FOR SELECT USING (true);
CREATE POLICY "episodes_select" ON episodes FOR SELECT USING (true);
-- Insert/update only via service role (Edge Functions)

-- ============================================================
-- TRENDING PODCASTS (read-only for clients)
-- ============================================================
ALTER TABLE trending_podcasts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "trending_select" ON trending_podcasts FOR SELECT USING (true);
-- Insert/update only via service role (cron Edge Function)

-- ============================================================
-- OFFLINE QUEUE (server-side audit copy)
-- ============================================================
ALTER TABLE offline_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "queue_select" ON offline_queue FOR SELECT
    USING (user_id = auth.uid());
CREATE POLICY "queue_insert" ON offline_queue FOR INSERT
    WITH CHECK (user_id = auth.uid());
```

### 12.2 Backend-Only Operations (Edge Functions with service_role key)

These operations MUST NEVER run client-side:

| Operation | Why Server-Side | Edge Function |
|-----------|----------------|---------------|
| AI transcription (Whisper) | OpenAI API key | `/functions/process-clip` |
| AI summary (GPT) | OpenAI API key | `/functions/process-clip` |
| Subscription management | RevenueCat webhook secret | `/webhooks/revenuecat` |
| Send push notification | OneSignal REST API key | `/functions/notify` |
| Send email | Resend API key | `/functions/send-email` |
| Insert notification record | Prevents spoofing | `/functions/notify` |
| Update `is_premium` flag | Business-critical entitlement | `/webhooks/revenuecat` |
| Podcast data sync (trending) | API key + rate control | `/functions/sync-trending` |
| Generate S3 presigned upload URL | AWS secret key | `/functions/get-upload-url` |
| Account deletion (hard delete PII) | Cascading multi-table cleanup | `/functions/delete-account` |

### 12.3 Client-Side Allowed Operations

| Operation | Table | Method |
|-----------|-------|--------|
| Read public clips, profiles, podcasts, episodes | Various | SELECT via Supabase client |
| Create/update/delete own clips | clips | INSERT/UPDATE/DELETE (RLS enforced) |
| Like/bookmark clips | clip_engagement | INSERT/DELETE (RLS enforced) |
| Comment on clips | comments | INSERT/UPDATE/DELETE (RLS enforced) |
| Follow/unfollow | follows | INSERT/DELETE (RLS enforced) |
| Favourite podcasts | podcast_favourites | INSERT/DELETE (RLS enforced) |
| Update own profile | profiles | UPDATE (RLS enforced) |
| Save/read playback progress | playback_progress | UPSERT (RLS enforced) |
| Mark notifications as read | notifications | UPDATE (RLS enforced) |

### 12.4 Secrets Management

| Secret | Storage Location | Accessed By |
|--------|-----------------|-------------|
| OpenAI API Key | Supabase project secrets | Edge Functions only |
| RevenueCat webhook secret | Supabase project secrets | `/webhooks/revenuecat` only |
| OneSignal REST API Key | Supabase project secrets | Edge Functions only |
| Resend API Key | Supabase project secrets | Edge Functions only |
| AWS Access Key + Secret | Supabase project secrets | Edge Functions only |
| Supabase service_role key | Never in client | Edge Functions only |
| Supabase anon key | Flutter app (public) | Client SDK (RLS protects) |
| RevenueCat public SDK key | Flutter app (public) | purchases_flutter SDK |
| OneSignal App ID | Flutter app (public) | onesignal_flutter SDK |

---

## 13. Clip Storage Recommendation

### 13.1 Requirements

| Requirement | Value |
|-------------|-------|
| Clip duration | 15–60 seconds |
| Audio format | AAC/M4A (compressed) |
| Estimated file size | 60–250 KB per clip (128kbps AAC) |
| Access pattern | Frequent reads (feed playback), write-once |
| Privacy | Public clips accessible by URL; private clips restricted |
| Scale projection | 10K clips/day at 100K MAU |

### 13.2 Architecture

```
┌─────────────┐    presigned URL     ┌──────────────────┐
│ Flutter App  │ ──────────────────▶  │  AWS S3 Bucket   │
│              │    direct upload     │  (clipcast-clips) │
└──────┬──────┘                      └────────┬─────────┘
       │                                       │
       │ request URL                           │ origin
       ▼                                       ▼
┌──────────────┐                     ┌──────────────────┐
│ Edge Function│                     │  CloudFront CDN  │
│ get-upload-  │                     │  (d1234.cf.net)  │
│ url          │                     └────────┬─────────┘
└──────────────┘                              │
                                              │ cached delivery
                                              ▼
                                     ┌──────────────────┐
                                     │  End Users       │
                                     │  (feed playback) │
                                     └──────────────────┘
```

### 13.3 Upload Flow

1. Client creates clip locally (extract from ring buffer → encode AAC)
2. Client calls Edge Function `get-upload-url` with clip metadata
3. Edge Function generates S3 presigned PUT URL (expires in 5 minutes)
4. Client uploads directly to S3 using presigned URL
5. Client saves clip record to `clips` table with S3 key as `audio_url`
6. DB trigger or client calls `process-clip` Edge Function
7. Edge Function downloads from S3 → Whisper → GPT → updates clip record

### 13.4 S3 Configuration

```
Bucket: clipcast-clips
Region: eu-central-1 (Frankfurt — matches Supabase region)

Structure:
  clips/{user_id}/{clip_id}.m4a       ← clip audio
  clips/{user_id}/{clip_id}_waveform.json  ← pre-computed waveform (optional)

Lifecycle Rules:
  - Failed/orphaned uploads: delete after 24 hours (via incomplete multipart cleanup)
  - Deleted clips: move to Glacier after 30 days (soft-delete recovery window)

Access:
  - Presigned URLs for upload (PUT, 5-minute expiry)
  - CloudFront for read (signed URLs for private clips, public URL for public clips)
  - No direct public S3 access (bucket is private)
```

### 13.5 Cost Estimate

| Scale | Storage/mo | Requests/mo | Transfer/mo | Total/mo |
|-------|-----------|-------------|-------------|----------|
| 1K MAU (~500 clips/day) | ~1 GB ($0.02) | ~50K ($0.02) | ~10 GB ($0.85) | ~$1 |
| 10K MAU (~5K clips/day) | ~10 GB ($0.23) | ~500K ($0.20) | ~100 GB ($8.50) | ~$9 |
| 100K MAU (~50K clips/day) | ~100 GB ($2.30) | ~5M ($2.00) | ~1 TB ($85) | ~$90 |

CloudFront costs additional but reduces S3 transfer. Very cost-effective.

### 13.6 Private Clips

Private clips (is_public = FALSE) use CloudFront signed URLs:
- Edge Function generates signed URL with 1-hour expiry
- Only the clip owner can request the signed URL (verified via auth)
- Signed URL policy restricts to specific S3 key

---

## 14. Risks & Tradeoffs

### 14.1 Risk Register

| ID | Risk | Probability | Impact | Mitigation | Owner |
|----|------|------------|--------|-----------|-------|
| R1 | **Episode Player has no HiFi design** — core screen for Listen→Clip flow | High | Critical | Escalate to designer immediately; block Phase 1 sprint until delivered | TPM / Designer |
| R2 | **8 screens missing HiFi designs** — Search, Podcast Page, Episode Details, Player, Web Clip Player, Profile, Auth, Lock Screen | High | High | Prioritise: Auth + Player + Search for Phase 1; others can follow | TPM / Designer |
| R3 | **Podcast API not selected** | Medium | High | Complete spike in Phase 0 (Section 9); Taddy API confirmed as primary | Developer |
| R4 | **Large media volumes impact cost** | Medium | High | S3 + CloudFront is cost-effective; implement clip size limits; monitor usage | Developer / Client |
| R5 | **60-second audio ring buffer feasibility** on both platforms | Medium | High | Technical spike needed; `just_audio` supports buffered streams but custom ring buffer for PCM extraction is non-trivial | Developer |
| R6 | **AI processing latency** (Whisper + GPT) for each clip | Medium | Medium | Process async; show "processing" state in library; Edge Function timeout management | Developer |
| R7 | **AirPods double-tap / phone triple-tap triggers** may not be feasible on all devices | Medium | Low | Implement as best-effort; always have in-app button as primary; document platform limitations | Developer |
| R8 | **App Store rejection risk** — unclear ad source, potential IAP compliance issues | Medium | High | Use only Apple/Google-approved ad networks (AdMob); ensure all digital purchases go through IAP; no external payment links | TPM / Developer |
| R9 | **Notification provider mismatch** — prep doc says Firebase, service list says OneSignal | Low | Medium | Decision: use OneSignal only; update prep doc | Developer / TPM |
| R10 | **Supabase Edge Function cold starts** affect AI processing | Medium | Medium | Use Deno Deploy (Supabase default); implement retry logic; consider dedicated function for heavy processing | Developer |
| R11 | **Fair usage clip limit formula undefined** | High | Medium | Cannot implement free-tier gating until formula decided; propose: 3 clips per episode for free users | Product Owner |
| R12 | **Deep link domain (clipcast.app) ownership unconfirmed** | Medium | Medium | Need client to confirm domain ownership and DNS access for universal links / App Links | TPM / Client |
| R13 | **GDPR data export** — format and scope undefined | Low | Medium | Implement JSON export of all user data; confirm scope with client | Developer / Legal |
| R14 | **Waveform editor complexity** | Medium | Medium | Evaluate `audio_waveforms` package first; fall back to custom if insufficient | Developer |

### 14.2 Key Tradeoffs

| Decision | Tradeoff | Rationale |
|----------|---------|-----------|
| **Cubit over Riverpod** | Less reactive, more boilerplate | Team familiarity wins for MVP speed; can migrate later if needed |
| **S3 + CloudFront over Supabase Storage** | Additional infra complexity | Cost savings at scale justify the overhead; clips are the highest-volume asset |
| **Taddy over PodcastIndex/Listen Notes** | Vendor dependency on Taddy | GraphQL efficiency; built-in transcripts & popularity ranking; RSS as fallback |
| **Server-side AI only** | Higher latency for clip processing | Security (no exposed API keys) and cost control (rate limiting) are non-negotiable |
| **Offline-first for clips** | Sync complexity, conflict handling | Core use case — listeners are often on the go with poor connectivity; clips cannot be lost |
| **Hybrid delete (soft + hard)** | More complex deletion flow | Auditability + GDPR compliance; 30-day grace period for soft-deleted data |
| **Single subscription tier** | Limits segmentation | Simpler MVP; can add tiers later based on user data |

---

## 15. Phased Implementation Plan

### Phase 0: Foundation (Week 1)

| Task | Details | Deliverable |
|------|---------|------------|
| Project scaffolding | Feature-first structure, packages, linting, CI | Clean project skeleton |
| Design token system | Implement primitives, semantic, component, typography tokens | `lib/theme/tokens/` |
| Supabase setup | Create project (Frankfurt), configure auth (email, Google, Apple), enable RLS | Working Supabase instance |
| Database schema | Run full DDL (Section 11), verify ERD, RLS policies | Populated schema with RLS |
| AWS S3 + CloudFront | Create bucket, configure CDN, test presigned URLs | Working media pipeline |
| Podcast API spike | Register Taddy API key, test endpoints, verify audio URLs | API validated or fallback chosen |
| RevenueCat setup | Create project, configure products, test sandbox | Subscription infra ready |
| Audio buffer spike | Prototype 60s ring buffer with `just_audio` | Feasibility confirmed |
| Authentication HiFi | **BLOCKER** — Designer must deliver Auth screen HiFi | Design ready for dev |
| Episode Player HiFi | **BLOCKER** — Designer must deliver Player screen HiFi | Design ready for dev |

### Phase 1: Core Listen → Clip Flow (Weeks 2–4)

| Task | Details | Depends On |
|------|---------|-----------|
| Authentication | Sign in/up (email, Google, Apple), profile creation | Auth HiFi, Supabase Auth |
| Onboarding flow | Splash → onboarding → home (already started in codebase) | Auth |
| Podcast discovery (home) | Trending, recent, recommended; API integration | Taddy API spike |
| Search | Search by title/host/keyword | Search HiFi, API |
| Podcast detail page | Episode list, metadata, favourite button | Podcast Page HiFi |
| Episode player | Full playback: play/pause/seek/skip/speed, background audio | Player HiFi, `just_audio` |
| Audio ring buffer | 60s PCM buffer running during playback | Player |
| Clip capture | Tap-to-clip, extract from buffer, encode AAC, save locally | Ring buffer |
| Clip upload | S3 presigned URL upload, metadata to Supabase | S3 setup |
| AI processing | Edge Function: Whisper transcription (+ GPT summary for premium) | Clip upload, OpenAI key |

### Phase 2: Library & Social (Weeks 5–7)

| Task | Details | Depends On |
|------|---------|-----------|
| Clip editing | Waveform editor, trim, add title/tags, preview | `audio_waveforms` evaluation |
| Personal library | Browse, search, filter, play, edit, delete clips | Clip data model |
| Social feed | Trending + Friends + My Feed tabs, feed cards, inline playback, empty states | Feed view, clips |
| Feed engagement | Like, comment, share, bookmark | Engagement tables |
| Follow system | Follow/unfollow, follower/following lists | Follows table |
| User profile | Avatar, bio, stats, public clips | Profile HiFi |
| External sharing | Generate share URL, web preview page | Share token, web deploy |

### Phase 3: Premium & Engagement (Weeks 8–9)

| Task | Details | Depends On |
|------|---------|-----------|
| Premium paywall | RevenueCat integration, paywall screen, entitlement gating | RevenueCat setup |
| Premium features | AI summaries, unlimited clips, ad-free, metadata tagging | Subscription status |
| Push notifications | OneSignal integration, notification types, in-app screen | OneSignal setup |
| Offline mode | Download episodes, offline clip capture, sync queue | Drift local DB |
| Podcast favourites | Favourite/unfavourite, dedicated section in library | Favourites table |
| Playback resume | Save/restore position per episode | Playback progress table |

### Phase 4: Polish & Launch Prep (Weeks 10–12)

| Task | Details | Depends On |
|------|---------|-----------|
| Settings & account | Profile edit, notification prefs, subscription management, delete account | All features |
| Legal pages | T&C, Privacy Policy, comment reporting | Legal copy from client |
| Digest email | Weekly AI recap via Resend | Edge Function, Resend |
| Empty states | All screens: no content, no network, first-time user | All screens |
| Error handling | Global error states, retry logic, offline indicators | All features |
| Performance | Image caching, pagination, lazy loading, startup time | All features |
| QA & bug fixes | Full regression, device testing | All features |
| Store preparation | Icons, screenshots, descriptions, review guidelines | All features |
| App submission | TestFlight + Google Internal Testing → Production | Store prep |

### Milestone Summary

| Milestone | Target | Key Deliverable |
|-----------|--------|----------------|
| Phase 0 Complete | End of Week 1 | Foundation ready, blockers resolved |
| Phase 1 Complete | End of Week 4 | Core Listen → Clip → AI flow working end-to-end |
| Phase 2 Complete | End of Week 7 | Library, social feed, and sharing functional |
| Phase 3 Complete | End of Week 9 | Premium, notifications, offline working |
| Phase 4 Complete | End of Week 12 | App submitted to stores |

---

## 16. Final System Design

### 16.1 System Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER APP                                 │
│                                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Auth       │  │  Discovery   │  │   Player     │  │  Clipping    │ │
│  │   Cubit      │  │  Cubit       │  │   Bloc       │  │  Cubit       │ │
│  └──────┬──────┘  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘ │
│         │                │                  │                  │         │
│  ┌──────▼──────┐  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼──────┐ │
│  │  Library    │  │    Feed      │  │   Social     │  │  Premium    │ │
│  │  Cubit      │  │    Cubit     │  │   Cubit      │  │  Cubit      │ │
│  └─────────────┘  └──────────────┘  └──────────────┘  └─────────────┘ │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                    Repository Layer                                 │ │
│  │  AuthRepo | PodcastRepo | ClipRepo | FeedRepo | SocialRepo | ...  │ │
│  └─────────────────────────┬──────────────────────────────────────────┘ │
│                             │                                            │
│  ┌──────────────────────────▼─────────────────────────────────────────┐ │
│  │                    Data Sources                                     │ │
│  │  SupabaseClient | TaddyAPI (via EF) | S3Upload | Drift(SQLite) | ... │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                          │
│  ┌─────────────────────┐  ┌────────────────┐  ┌───────────────────┐    │
│  │ just_audio +        │  │ Drift (offline │  │ OneSignal         │    │
│  │ audio_service       │  │ cache + queue) │  │ (push receiver)   │    │
│  │ + RingBuffer (60s)  │  │                │  │                   │    │
│  └─────────────────────┘  └────────────────┘  └───────────────────┘    │
└──────────────────────────────────┬───────────────────────────────────────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │         SUPABASE              │
                    │   Region: eu-central-1        │
                    ├──────────────────────────────┤
                    │  ┌────────┐  ┌────────────┐  │
                    │  │  Auth  │  │  Postgres   │  │
                    │  │        │  │  (with RLS) │  │
                    │  └────────┘  └────────────┘  │
                    │  ┌────────┐  ┌────────────┐  │
                    │  │Realtime│  │   Edge      │  │
                    │  │        │  │  Functions  │  │
                    │  └────────┘  └─────┬──────┘  │
                    └────────────────────┼─────────┘
                                         │
              ┌──────────────────────────┬┼──────────────────────────┐
              │                          ││                          │
    ┌─────────▼──────────┐   ┌──────────▼▼─────────┐   ┌──────────▼──────────┐
    │     AWS S3 +       │   │      OpenAI          │   │     External        │
    │     CloudFront     │   │  Whisper + GPT       │   │     Services        │
    │   (clip storage)   │   │  (AI processing)     │   │                     │
    │                    │   │                       │   │  - RevenueCat       │
    │  clipcast-clips/   │   │  /functions/          │   │  - OneSignal        │
    │  eu-central-1      │   │  process-clip         │   │  - Resend           │
    └────────────────────┘   └───────────────────────┘   │  - Crashlytics      │
                                                          │  - UXCam            │
                                                          │  - Taddy API        │
                                                          └─────────────────────┘
```

### 16.2 Data Flow — Core Clip Capture

```
User taps "Clip" in Player
         │
         ▼
PlayerBloc dispatches CaptureClip event
         │
         ▼
RingBuffer.extract(duration: 30s)
  → Returns PCM audio bytes
         │
         ▼
ClipCaptureService.encode(pcm → AAC/M4A)
  → Saves to temp file
         │
         ▼
ClipRepository.saveClip()
  ├─ If ONLINE:
  │    1. Call Edge Function get-upload-url → presigned S3 PUT URL
  │    2. Upload M4A to S3
  │    3. INSERT into clips table (sync_status: 'uploading')
  │    4. Call Edge Function process-clip
  │       → Whisper transcription
  │       → GPT summary (if user is_premium)
  │       → UPDATE clips (transcript, ai_summary, is_processed: true, sync_status: 'ready')
  │    5. Clip appears in library and feed
  │
  └─ If OFFLINE:
       1. Save M4A to local storage (Drift)
       2. INSERT into local offline_queue (status: 'pending')
       3. Show clip in library with "pending sync" badge
       4. On reconnect → ConnectivityCubit triggers sync
          → Execute steps 1-5 from ONLINE path
          → Update offline_queue status
```

### 16.3 Data Flow — Social Feed

```
User opens Feed tab
         │
         ▼
FeedCubit.loadFeed(tab: trending|friends|myFeed)
         │
         ├─ trending: SELECT from feed_view ORDER BY like_count + comment_count DESC
         │
         ├─ friends:  SELECT from feed_view
         │            WHERE user_id IN (SELECT following_id FROM follows WHERE follower_id = auth.uid())
         │            ORDER BY created_at DESC
         │
         └─ myFeed:   SELECT from clips
                      WHERE user_id = auth.uid() AND is_public = TRUE
                      ORDER BY created_at DESC
                      (also includes public collections via separate query)
         │
         ▼
Returns paginated list of FeedItem models
  → Display feed cards
  → Real-time subscription on feed for new items
         │
         ▼
User taps Like/Comment/Share/Bookmark
  → Cubit handles engagement mutation
  → Optimistic UI update
  → Supabase INSERT into clip_engagement/comments
  → DB trigger → notifications table INSERT
  → Edge Function → OneSignal push to clip owner
```

### 16.4 Data Flow — Premium Subscription

```
User taps "Upgrade" on paywall
         │
         ▼
PremiumCubit.purchase()
  → purchases_flutter initiates IAP flow
  → Apple/Google handles payment
         │
         ▼
RevenueCat receives receipt
  → Validates with store
  → Sends webhook to /webhooks/revenuecat
         │
         ▼
Edge Function processes webhook
  1. Verify webhook signature
  2. Extract customer_id, product_id, event_type
  3. UPSERT user_subscriptions (status: 'active', expires_at: ...)
  4. UPDATE profiles SET is_premium = TRUE
  5. Return 200
         │
         ▼
Client: purchases_flutter listener detects entitlement change
  → PremiumCubit emits PremiumActive state
  → UI unlocks premium features (AI summaries, unlimited clips, ad-free)
```

### 16.5 Offline Sync Architecture

```
┌────────────────────────────────────────────────────────┐
│                     CLIENT (Drift/SQLite)               │
│                                                         │
│  ┌─────────────────┐    ┌────────────────────────────┐ │
│  │ offline_queue    │    │ cached_clips               │ │
│  │                  │    │ (local mirror of           │ │
│  │ - create_clip    │    │  clips table for           │ │
│  │ - update_clip    │    │  offline viewing)          │ │
│  │ - delete_clip    │    │                            │ │
│  └────────┬────────┘    └────────────────────────────┘ │
│           │                                             │
│  ┌────────▼────────────────────────────────────────┐   │
│  │         ConnectivityCubit                        │   │
│  │  Watches connectivity_plus stream                │   │
│  │  On reconnect → SyncService.syncAll()            │   │
│  └────────┬────────────────────────────────────────┘   │
└───────────┼─────────────────────────────────────────────┘
            │
            ▼
┌────────────────────────────────────────┐
│  SyncService.syncAll()                  │
│  1. Read all pending items from queue   │
│  2. For each: upload to S3 + Supabase   │
│  3. Mark as synced                      │
│  4. Server is authoritative on final    │
│     state (conflict: server wins)       │
└────────────────────────────────────────┘
```

### 16.6 Edge Function Inventory

| Function | Trigger | Runtime | Secrets Used |
|----------|---------|---------|-------------|
| `process-clip` | HTTP (called after clip upload) | Deno | OPENAI_API_KEY, SUPABASE_SERVICE_ROLE_KEY |
| `get-upload-url` | HTTP (called before clip upload) | Deno | AWS_ACCESS_KEY, AWS_SECRET_KEY |
| `revenuecat-webhook` | HTTP (RevenueCat webhook) | Deno | RC_WEBHOOK_SECRET, SUPABASE_SERVICE_ROLE_KEY |
| `notify` | HTTP (called by DB trigger function) | Deno | ONESIGNAL_API_KEY, ONESIGNAL_APP_ID |
| `send-email` | HTTP (called by cron or system events) | Deno | RESEND_API_KEY |
| `sync-trending` | Cron (every 6 hours) | Deno | TADDY_USER_ID, TADDY_API_KEY |
| `digest-email` | Cron (weekly) | Deno | OPENAI_API_KEY, RESEND_API_KEY |
| `delete-account` | HTTP (called from settings) | Deno | AWS_ACCESS_KEY, SUPABASE_SERVICE_ROLE_KEY |

### 16.7 Key Technical Decisions Summary

| Area | Decision | Confidence |
|------|---------|-----------|
| Backend | Supabase (Postgres + Auth + Edge Functions + Realtime) | High |
| State Management | flutter_bloc (Cubit default, Bloc for player) | High |
| Routing | go_router with deep link support | High |
| DI | get_it + injectable | High |
| Audio | just_audio + audio_service + custom ring buffer | Medium (needs spike) |
| Media Storage | AWS S3 + CloudFront | High |
| Payments | RevenueCat IAP | High |
| Push | OneSignal | High (pending alignment) |
| AI | OpenAI (Whisper + GPT) via Edge Functions | High |
| Podcast Data | Taddy API (primary) + RSS (fallback) | Medium (needs spike) |
| Offline | Drift (SQLite) + connectivity_plus + server-authoritative sync | High |
| Local Cache | Drift for structured data, cached_network_image for artwork | High |

---

## Appendix A: Files to Create Before Development

| File | Purpose | Status |
|------|---------|--------|
| `docs/ARCHITECTURE.md` | This document | ✅ Created |
| `docs/ERD.md` | ERD diagram + table descriptions | To create (extract from Section 11) |
| `docs/RLS.md` | Security rules + backend responsibilities | To create (extract from Section 12) |
| `docs/RISKS.md` | Risk register | To create (extract from Section 14) |
| `docs/PRD.md` | Full PRD | To create (extract from Section 6) |

## Appendix B: Open Items for Technical Lead Review

1. **Approve or modify** the proposed Podcast API strategy (Taddy API primary, RSS fallback)
2. **Confirm** OneSignal as sole push notification provider (vs Firebase Cloud Messaging)
3. **Review** S3 + CloudFront architecture for clip storage vs alternatives
4. **Approve** the Cubit/Bloc split (Cubit default, Bloc for player only)
5. **Confirm** the offline sync strategy (server-authoritative, Drift local)
6. **Review** complete RLS policies for security sign-off
7. **Confirm** the fair usage clip limit approach (propose: 3 clips/episode for free users)
8. **Review** Edge Function inventory and secret management
9. **Flag** any missing tables, relationships, or indexes in the ERD
10. **Approve** the phased implementation plan timeline

---

*This document satisfies Section 6 (Pre-Development Technical Approval Brief) of the ClipCast New Project Preparation Form. All architecture decisions include reasoning, risks, and linked artifacts as required.*

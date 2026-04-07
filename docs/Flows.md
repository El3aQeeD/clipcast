# ClipCast — User Flows, Table Mapping & Free vs Premium

> Each flow maps to the database tables it touches and documents the behavioural
> difference between **Free** and **Premium** users as observed in the Figma HiFi frames.
> Last updated: 2025-06-29

---

## Table of Contents

1. [Authentication & Onboarding](#1-authentication--onboarding)
2. [Home / Discovery](#2-home--discovery)
3. [Search & Browse](#3-search--browse)
4. [Podcast Detail](#4-podcast-detail)
5. [Episode Playback (Episode Player)](#5-episode-playback)
   - [5.1 Core Playback](#51-episode-player--core-playback)
   - [5.2 Chapters Overlay](#52-chapters-overlay)
   - [5.3 Transcript Overlay](#53-transcript-overlay)
   - [5.4 Generate Clip Flow](#54-generate-clip-flow)
   - [5.5 Clip Review (Premium Only)](#55-clip-review-premium-only)
   - [5.6 Audio Ads (Free Users Only)](#56-audio-ads-free-users-only)
   - [5.7 ⋯ More Menu (Episode Player)](#57--more-menu-episode-player)
   - [5.8 Episode Complete](#58-episode-complete)
   - [5.9 Audio Feedback](#59-audio-feedback)
   - [5.10 First-Time User Variant](#510-first-time-user-variant)
   - [5.11 Free vs Premium Summary](#511-free-vs-premium-summary-episode-player)
6. [Clip Capture](#6-clip-capture)
7. [Clip Processing (AI)](#7-clip-processing-ai)
8. [Clip Detail View](#8-clip-detail-view)
9. [Collections](#9-collections)
10. [Social Feed](#10-social-feed)
11. [Follow System](#11-follow-system)
12. [Premium Paywall](#12-premium-paywall)
13. [Notifications](#13-notifications)
14. [Learn](#14-learn)
15. [Profile](#15-profile)
16. [Offline Mode](#16-offline-mode)
17. [External Sharing](#17-external-sharing)
18. [Settings & Account Management](#18-settings--account-management)

---

## Legend

| Symbol | Meaning |
|--------|---------|
| 🟢 | Available to Free users |
| 🔒 | Premium only / gated |
| ⚡ | Limited for Free users |
| 📱 | Figma frame reference (node ID) |

---

## 1. Authentication & Onboarding

**Flow:** App launch → Splash → Onboarding → Sign Up/In → Home

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Launch splash screen | — | 🟢 Same | 🟢 Same |
| Onboarding carousel | — | 🟢 Same | 🟢 Same |
| Sign up (Google / Apple / Email) | `profiles` (INSERT via trigger) | 🟢 Same | 🟢 Same |
| Sign in | `profiles` (SELECT) | 🟢 Same | 🟢 Same |
| Profile creation (auto) | `profiles` (INSERT) | Creates with `is_premium = false` | `is_premium = true` (set by webhook) |

📱 Title card: 544:834 (Authentication — no HiFi yet). Existing code: `splash_screen.dart`, `onboarding_screen.dart`

---

## 2. Home / Discovery

**Flow:** Home tab → Browse trending, recently played, recommended content

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load trending podcasts | `trending_podcasts`, `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Load recommended episodes | `episodes`, `podcasts`, `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |
| Load recent clips feed | `clips`, `profiles` via `feed_view` (SELECT) | 🟢 Same | 🟢 Same |
| Tap podcast card → Podcast Detail | `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Tap episode card → Episode Player | `episodes` (SELECT) | 🟢 Same | 🟢 Same |

📱 Homepage Normal (544:1559), Offline (666:29075), Network Back (741:16912), New User (588:43549)

**Free vs Premium difference:** No visible difference on Homepage itself. The "Explore Premium" paywall (662:22577) is accessible from here but is a separate flow.

---

## 3. Search & Browse

**Flow:** Search tab → Browse categories / Active search → Results → Drill-down

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Browse categories (Podcasts, Clips, etc.) | — (static UI) | 🟢 Same | 🟢 Same |
| "Discover Something New" carousel | `episodes`, `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Type search query | `podcasts`, `episodes`, `clips` (SELECT with text search) | 🟢 Same | 🟢 Same |
| Autocomplete suggestions | `podcasts`, `episodes` (SELECT) | 🟢 Same | 🟢 Same |
| View search results (mixed) | `podcasts`, `episodes`, `clips` (SELECT) | 🟢 Same | 🟢 Same |
| Drill into Podcasts sub-page | `podcasts`, `podcast_favourites` (SELECT) | 🟢 Same | 🟢 Same |
| Drill into Clips sub-page | `clips`, `collections` (SELECT) | 🟢 Same | 🟢 Same |
| Category → Technology Clips | `clips`, `collections` (SELECT, filtered) | 🟢 Same | 🟢 Same |
| Category → Technology Podcasts | `podcasts` (SELECT, filtered) | 🟢 Same | 🟢 Same |

📱 Search Browse (545:2930), Active/Keyboard (557:7466), Results "Elon" (558:12125), Offline (749:18132), Podcasts sub-page (549:7221), Clips sub-page (551:8195), Clips Category (552:10798, 553:11561), Podcasts Category (549:7495)

**Figma category surfaces:**

- **Browse All tiles (Search page, 588:45886) — 9 tiles:**
  Podcasts · Clips · New Releases · Made For You · Technology · Education · Health & Wellbeing · Culture & Society · Other
  _(First 4 are content-type/curated shortcuts; last 5 are genre shortcuts.)_

- **Podcast Categories (Podcasts page, 588:46043) — 7 genre tiles:**
  Business · News & Current Affairs · Technology · Education · Health & Wellbeing · Culture & Society · Other

- **Clip Categories (Clips page, 551:8195) — 7 genre tiles (mirrors Podcast Categories):**
  Business · News & Current Affairs · Technology · Education · Health & Wellbeing · Culture & Society · Other
  _(Clips sub-page also features a "Curated Clip Collections For You" horizontal carousel with "Collection" badges.)_

- **Combined Category pages (e.g. 553:11561 "Technology"):**
  A genre page that mixes podcasts, clips, and collections in one view — e.g. "Top 10 AI Podcasts in 2025", "Best Clips of Elon Musk This Week", "Curated AI Collections For You".

**Search autocomplete & instant results (557:7466, 558:12125):**
- Recent searches shown with per-item ✕ clear and "Clear all recent searches" link.
- As the user types, autocomplete suggestions appear above instant mixed results.
- Results carry colour-coded badges: purple **Episode**, green **Clip**, to distinguish content types.

**Free vs Premium difference:** No visible gating on search or browse. Discovery is open to all users.

---

## 4. Podcast Detail

**Flow:** Podcast card → Podcast page with episodes list

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load podcast metadata | `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Load episodes list | `episodes` (SELECT WHERE podcast_id) | 🟢 Same | 🟢 Same |
| Favourite / unfavourite | `podcast_favourites` (INSERT / DELETE) | 🟢 Same | 🟢 Same |
| Tap episode → Episode Details (§19) | `episodes`, `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |

📱 Podcast Page (548:5047 — "Modern Wisdom", 217 episodes, 4 tabs), Podcast Page variant (666:27547)

**Figma details:** Shows podcast rank (#6 in Podcasts), tag (Time Management), play counts (500k+), clip counts (200 clips), episode metadata (date, duration).

**Free vs Premium difference:** No visible gating on podcast browsing (all 4 tabs accessible). Downloads are Premium-only — free users see upsell sheet. Notification subscription is available to all users.

### 4.1 Podcast Page Header & Actions

**Flow:** Navigate to podcast → View header → Interact with action bar

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load podcast metadata (title, author, artwork, ranking, category) | `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Display ranking badge ("#6 in Podcasts") | `podcasts.ranking` (SELECT) | 🟢 Same | 🟢 Same |
| Display category tag ("Time Management") | `podcasts.categories` or Taddy API | 🟢 Same | 🟢 Same |
| Tap "Add to Favorites" | `podcast_favourites` (INSERT / DELETE) | 🟢 Same | 🟢 Same |
| Tap notification bell (subscribe) | `podcast_subscriptions` (INSERT / DELETE) + OneSignal tag | 🟢 Same | 🟢 Same |
| Tap ⋯ → Podcast More Details sheet | — (UI) | 🟢 Same | 🟢 Same |
| Sheet: "Add to My Favorites" | `podcast_favourites` (INSERT / DELETE) | 🟢 Same | 🟢 Same |
| Sheet: "Download Podcast" | — | ❓ **TBD** (behaviour not decided) | ❓ **TBD** |

📱 Podcast header (588:49600, 666:27547), Podcast More Details sheet (717:11456)

### 4.2 Episodes Tab

**Flow:** Podcast page → Episodes tab → Browse / Filter / Sort → Tap episode

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load episodes list | `episodes` (SELECT WHERE podcast_id ORDER BY published_at DESC) | 🟢 Same | 🟢 Same |
| Display episode count ("217 Episodes") | `episodes` (COUNT WHERE podcast_id) | 🟢 Same | 🟢 Same |
| Display episode card metadata (plays, clips, date, duration) | `episodes` (SELECT play_count, clip_count, published_at, duration) | 🟢 Same | 🟢 Same |
| Tap filter icon → Filter & Sort sheet | — (UI) | 🟢 Same | 🟢 Same |
| Filter: All Episodes (default) | `episodes` (SELECT all) | 🟢 Same | 🟢 Same |
| Filter: Downloaded | `user_downloads` JOIN `episodes` (SELECT WHERE download_type = 'episode') | ❌ No downloads | 🔒 Shows locally saved episodes |
| Filter: Not Finished | `playback_progress` JOIN `episodes` (SELECT WHERE progress > 0 AND progress < duration) | 🟢 Same | 🟢 Same |
| Sort: Newest (default) / Oldest | `episodes` (ORDER BY published_at DESC/ASC) | 🟢 Same | 🟢 Same |
| Tap episode card → Episode Details (§19) | `episodes` (SELECT) | 🟢 Same | 🟢 Same |
| Tap download icon on episode card | `user_downloads` (INSERT) + local storage | ❌ Shows "Want to Download Episodes?" upsell | 🔒 Downloads episode |
| Tap share icon on episode card | — (share sheet) | 🟢 Same | 🟢 Same |
| Tap ⋯ on episode card → Episode More Details | — (UI) | 🟢 Same | 🟢 Same |
| Tap play button on episode card | `episodes` (SELECT audio_url) | 🟢 Same | 🟢 Same |

📱 Episodes tab (588:49600, 666:27547), Filter Episodes sheet (564:19715), Episode More Details sheet (755:22124)

**Episode card anatomy:**
```
[Thumbnail] Title
             Description text (2 lines)
             500k+ plays • 200 clips • 9 Dec • 1h 23m
⬇ download   ↗ share   ⋯ more                    ▶ play
```

**Filter & Sort — Episodes sheet:**
```
                    Filter and Sort            Cancel
─────────────────────────────────────────────────────
Filter
  All Episodes ✓
  Downloaded
  Not Finished
─────────────────────────────────────────────────────
Sort
  Newest
  Oldest
```

### 4.3 Clips Tab

**Flow:** Podcast page → Clips tab → Browse trending/my clips → Filter/Sort → Tap clip

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load trending clips for podcast | `clips` JOIN `episodes` (SELECT WHERE podcast_id ORDER BY engagement DESC) | 🟢 Same | 🟢 Same |
| Display clip cards (social feed style) | `clips`, `profiles` (SELECT) | 🟢 Same | 🟢 Same |
| Display clip author avatar + username | `profiles` (SELECT) | 🟢 Same | 🟢 Same |
| Tap "Follow" on clip card | `follows` (INSERT) — follows the clip author/user | 🟢 Same | 🟢 Same |
| Tap clip → Clip Detail | `clips` (SELECT) | 🟢 Same (AI blurred) | 🟢 Full AI content |
| Tap filter icon → Filter & Sort sheet | — (UI) | 🟢 Same | 🟢 Same |
| Filter: Trending Clips (default) | `clips` (SELECT ORDER BY engagement DESC) | 🟢 Same | 🟢 Same |
| Filter: My Clips | `clips` (SELECT WHERE user_id = auth.uid()) | 🟢 Same | 🟢 Same |
| Sort: Newest / Oldest | `clips` (ORDER BY created_at DESC/ASC) | 🟢 Same | 🟢 Same |
| Tap ⋯ on clip → Clip More Details | — (UI) | 🟢 Same | 🟢 Same |

📱 Clips tab (588:49489, 564:22839), Filter Clips sheet (588:49634, 564:19750), Clip More Details sheet (717:11491)

**Clip card anatomy:**
```
[Avatar] Username                          [Follow]
[Thumbnail with ▶ overlay]
Title
Description (2 lines)
AI Podcast • Episode 42                    2 days ago
```

**Clip More Details sheet (717:11491):**
```
[Thumbnail] #217 - The Art of Negotiation
             Chris Williamson
─────────────────────────────────────────
♥  Add to My Favorites
⬇  Download Clip              (Premium only)
🎧 Go to Episode              (behaviour TBD)
🎙 Go to Podcast
↗  Share Clip
```

### 4.4 About Tab

**Flow:** Podcast page → About tab → Read description & view hosts/guests

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load podcast description | `podcasts.description` (SELECT) | 🟢 Same | 🟢 Same |
| Load hosts & guests | `podcast_hosts` or Taddy API `people` | 🟢 Same | 🟢 Same |
| Display host avatars, names, roles | — (UI) | 🟢 Same | 🟢 Same |

📱 About tab (588:49439, 564:20078)

**About tab layout:**
```
[Podcast description paragraph]

Hosts & Guests
[Avatar] Angela    [Avatar] Mike Maughan
         Duckworth
         Host               Host
```

> **Data source note (dev note 907:13806):** "Podcast tags (e.g., Technology, Business, AI) can be extracted from the podcast RSS feed metadata, specifically from the category or keyword fields provided in the feed."

### 4.5 More Like This Tab

**Flow:** Podcast page → More Like This tab → Browse recommended → Tap podcast

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load recommended podcasts | `podcasts` (SELECT — algorithm TBD, likely genre/tag-based) | 🟢 Same | 🟢 Same |
| Display horizontal carousel | — (UI) | 🟢 Same | 🟢 Same |
| Tap recommended podcast → Navigate to its Podcast Page | — (navigation) | 🟢 Same | 🟢 Same |

📱 More Like This tab (588:50206, 562:17982)

**More Like This layout:**
```
Recommended Podcasts
[Artwork]    [Artwork]    [Artwork] →
AI For       Deep Tech    Business
Beginners    Dive         Insights
24 episodes  18 episodes  31 episodes
```

### 4.6 Episode More Details Sheet

**Flow:** Tap ⋯ on episode card → Bottom sheet with actions

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Show Episode More Details sheet | — (UI) | 🟢 Same | 🟢 Same |
| "Add to My Favorites" | `episode_favourites` (INSERT / DELETE) | 🟢 Same | 🟢 Same |
| "Download Episode" | `user_downloads` (INSERT) + local storage | ❌ Shows "Want to Download Episodes?" upsell (588:36291) | 🔒 Downloads locally |

📱 Episode More Details (755:22124), Download upsell (588:36291)

**Download upsell sheet (588:36291):**
```
      [Download icon with lock badge]
Want to Download Episodes?
Download episodes and play them
anytime when you're offline with premium.

    [ Explore Premium ]
         Cancel
```

### 4.7 Add to Collection (from Podcast Page context)

**Flow:** Episode Player / Clip Detail → "Add to My Collection" → Select/create collection

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open "Add to My Collection" sheet | `collections` (SELECT WHERE user_id) | 🟢 Same | 🟢 Same |
| Show existing collections with radio buttons | `collections`, `collection_clips` (SELECT) | 🟢 Same | 🟢 Same |
| Select collection + tap "Done" | `collection_clips` (INSERT) | 🟢 Same | 🟢 Same |
| Tap "Create New Collection" | — (navigate to Create Collection flow) | ⚡ Check 15-collection limit | 🟢 Unlimited |
| Empty state (no collections yet) | — (UI: illustration + "No collections yet" + "Create Collection" CTA) | 🟢 Same | 🟢 Same |
| Success toast | — (UI: "✓ Clip added to collection \| now") | 🟢 Same | 🟢 Same |

📱 Add to Collection (587:36125, 562:17792), Empty state (588:49829), Create New Collection from clip (587:36179: "Create & Add Clip"), standalone (562:17768: "Create Collection"), Success toasts (720:12239, 720:12238, 624:19790, 624:19799)

> **Collection limit note:** Free users see "You have 6/15 free collections" counter in the Create New Collection sheet. Blocked at 15 with premium upsell. Premium users see no counter.

---

## 5. Episode Playback

> **52 Lo-Fi wireframes reviewed** across 4 user flows: first-time (13), free (12), subscribed (25), offline (2). The Episode Player is a full-screen player with comprehensive playback, clipping, and overlay features. This section supersedes the previous §5 stub.

**Flow:** Episode Details (§19) → tap Play → Full-screen Episode Player → Play/Pause/Seek/Clip → Background listening

### 5.1 Episode Player — Core Playback

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open full-screen player | `episodes` (SELECT audio_url, title, podcast_id) | 🟢 Same | 🟢 Same |
| Display header: "Now Playing from [Podcast Name]" | `podcasts.title` (SELECT) | 🟢 Same | 🟢 Same |
| Display down arrow (minimize) button | — (UI, returns to previous screen) | 🟢 Same | 🟢 Same |
| Display ⋯ more menu (see §5.7) | — (UI) | 🟢 Same | 🟢 Same |
| Display large episode artwork | `episodes.artwork_url` (SELECT) | 🟢 Same | 🟢 Same |
| Display "Show Chapters" overlay (bottom-left on artwork) | — (UI) | 🟢 Same | 🟢 Same |
| Display "Show Transcript" overlay (bottom-right on artwork) | — (UI) | 🟢 Same | 🟢 Same |
| Display episode title centered below artwork | `episodes.title` (SELECT) | 🟢 Same | 🟢 Same |
| Display waveform progress bar with current/total timestamps | `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |
| Display purple dots on waveform (user clips + viral moments) | `clips` (SELECT WHERE episode_id) | 🟢 Same | 🟢 Same |
| Resume from saved position | `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |
| Play / Pause | — (client-side `just_audio`) | 🟢 Same | 🟢 Same |
| Seek via waveform progress bar | — (client-side) | 🟢 Same | 🟢 Same |
| Speed control (1x toggle) | — (client-side) | 🟢 Same | 🟢 Same |
| Skip back 30s | — (client-side) | 🟢 Same | 🟢 Same |
| Skip forward 30s | — (client-side) | 🟢 Same | 🟢 Same |
| Share button | — (share sheet) | 🟢 Same | 🟢 Same |
| Save playback position (periodic) | `playback_progress` (UPSERT) | 🟢 Same | 🟢 Same |
| Background audio playback | — (client-side `just_audio`) | 🟢 Same | 🟢 Same |

📱 Episode Player: First-time (multiple frames), Free (multiple frames), Subscribed (588:49766, 587:35786, 562:17895 + Lo-Fi frames), Offline (739:15744, 739:15866).

**Episode Player layout:**
```
      ⌄  Now Playing from       ⋯
            Modern Wisdom
   ┌───────────────────────────┐
   │                           │
   │    [Episode Artwork]      │
   │ Show                Show  │
   │ Chapters         Transcript│
   │                           │
   └───────────────────────────┘
   #217 - The Power of Strategic
   Silence in Negotiations

   32:15  ≋≋≋•≋≋≋≋≋≋●≋≋•≋≋≋  74:44   (waveform + dots)

     1x    ⏮30   ▶   ⏭30   ↗

   ┌───────────────────────────────────┐
   │  ✂ Generate Clip                  │  (cyan CTA)
   │  We will clip the previous 60     │
   │  seconds from this podcast        │
   └───────────────────────────────────┘

   You have 8 Clips available  8/12  ━━━━━━━━○━━
   To comply with fair usage policy for the
   podcaster, we have to limit the number
   of clips per podcast
```

> **Note:** Figma text says "30 seconds" but confirmed default is **60 seconds** (per user preference FR-27). The "30s" text in Figma is outdated/placeholder.

**Mini player bar (649:21310):** A collapsed persistent player bar (Spotify-like) showing track title, progress bar, and play button. Dev note (913:12701): "Clicking on play button would open player card overlay, clicking on player card would open episode/clip player page (eg. spotify)."

**Clip player context variants:**
- **Standalone** (555:2787): Single CTA — "Add to My Collection".
- **From collection** (565:21345, 561:15105): Two CTAs — "[Collection Name]" + "View Clip Details".

---

### 5.2 Chapters Overlay

**Flow:** Tap "Show Chapters" on artwork → Chapter list overlaid on artwork → Tap chapter to seek

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Overlay numbered chapter list on artwork | `episodes.chapters` (SELECT JSONB) | 🟢 Same | 🟢 Same |
| Highlight current chapter in cyan with timestamp | — (UI, based on playback position) | 🟢 Same | 🟢 Same |
| Tap chapter → Seek player to chapter start time | — (client-side `just_audio` seek) | 🟢 Same | 🟢 Same |
| Tap "Hide Chapters" → Return to artwork | — (UI toggle) | 🟢 Same | 🟢 Same |

**Chapters overlay layout (on artwork):**
```
   ┌───────────────────────────┐
   │  01  Introduction          │
   │  02  The Psychology…       │
   │ ●03  Real World Apps  23:12│  (cyan = current)
   │  04  Building Relations    │
   │  05  Mastering Silence     │
   │                            │
   │          Hide Chapters     │
   └───────────────────────────┘
```

> **Data source (dev note 925:14291):** Chapters sourced from RSS feed chapter metadata; fallback = generated from transcript or audio.

---

### 5.3 Transcript Overlay

**Flow:** Tap "Show Transcript" on artwork → Collapsed transcript on artwork → Tap expand → Full-screen transcript

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Show collapsed transcript on artwork (1 highlighted line + faded context) | `episode_transcripts` (SELECT WHERE episode_id) | 🟢 Same | 🟢 Same |
| Display "Show Thumbnail" toggle (return to artwork) | — (UI) | 🟢 Same | 🟢 Same |
| Tap down arrow → Expand to full-screen transcript | — (UI transition) | 🟢 Same | 🟢 Same |
| Full-screen transcript with mini player at bottom | `episode_transcripts` (SELECT ORDER BY segment_order) | 🟢 Same | 🟢 Same |
| Tap timestamp → Seek player to that position | — (client-side seek) | 🟢 Same | 🟢 Same |

> **Access:** Episode-level transcripts are **free for all users** (distinct from clip-level AI transcripts which are Premium-gated).

**Collapsed transcript overlay layout (on artwork):**
```
   ┌───────────────────────────┐
   │  ...and that's when I     │  (faded)
   │  realized the power of    │  (highlighted)
   │  strategic silence...     │  (faded)
   │                           │
   │ Show Thumbnail        ⌄   │
   └───────────────────────────┘
```

**Expanded transcript:** Same layout as §19.2 Episode Transcript View (full-page, speaker segments + timestamps, mini player at bottom).

---

### 5.4 Generate Clip Flow

**Flow:** Tap "Generate Clip" CTA → Clip extracted from buffer → Success sheet → Review (premium) / Auto-dismiss (free)

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| 60s audio ring buffer running | — (client-side PCM buffer) | 🟢 Same | 🟢 Same |
| Tap "✂ Generate Clip" button | — (check quota first) | ⚡ 3–5 clips/episode limit | 🟢 Unlimited |
| Press & hold "Generate Clip" → Change clip duration | — (UI: duration picker) | 🟢 Same | 🟢 Same |
| Extract clip from ring buffer (default 60s per FR-27) | — (client-side AAC encoding) | 🟢 Same | 🟢 Same |
| Save clip locally | `clips` (INSERT, sync_status='local') | 🟢 Same | 🟢 Same |
| Play subtle audio feedback on clip generation | — (client-side audio cue) | 🟢 Same | 🟢 Same |
| Show Clip Generated Success sheet | — (UI bottom sheet) | ⚡ Auto-dismiss after 5s (no "Review Now") | 🟢 "Review Now" button shown |
| Update clip quota display | `app_config` (SELECT), local tracking | 🟢 Counter decrements | 🟢 Counter decrements |
| Request presigned upload URL | — (Edge Function call) | 🟢 Same | 🟢 Same |
| Upload to S3 | — (direct S3 PUT) | 🟢 Same | 🟢 Same |
| Update clip record with S3 URL | `clips` (UPDATE audio_url, sync_status) | 🟢 Same | 🟢 Same |
| Trigger AI processing | `clips` (UPDATE sync_status='processing') | 🟢 Same | 🟢 Same |

📱 Clip capture triggered from Episode Player "Generate Clip" CTA. Unprocessed Clips Collection (557:7282) shows clips awaiting processing.

**Clip Generated Success sheet layout:**
```
          ━━━━━━━━━━━━━━━━              (drag handle)

              ✓                         (check icon)
   Clip Generated Successfully!

   Clip has been added to your
   Learn collection

   "The Power of Strategic Silence
    in Negotiations"                    (clip title)

         [ Review Now ]                 (Premium only)
```

> **Clip destination logic (dev note):** Unprocessed clips → My Collections (Unprocessed Clips system collection). Clip also appears on Learn page waiting for review. After user reviews and adds → specified user collection.

> **Free users:** No "Review Now" button. Cannot review, delete, or regenerate clips. Can only generate 3–5 clips per episode. Success sheet auto-dismisses after 5 seconds.

---

### 5.4.1 Clip Limit Reached

**Flow:** User reaches clip limit → Limit reached sheet → Upgrade (free) or Review (premium)

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Detect clip limit reached | `app_config` (SELECT), `clips` (COUNT WHERE episode_id AND user_id) | ⚡ 3–5 per episode | 🟢 Unlimited (configurable future limit) |
| Show limit reached sheet | — (UI bottom sheet) | ⚡ "Upgrade to Premium" + "Continue without clipping" | 🟢 "Review Clips" + "Continue without clipping" (if future limit is set) |
| Tap "Continue without clipping" | — (dismiss sheet) | ⚡ Generate Clip button becomes DISABLED/greyed | 🟢 N/A (unlimited) |
| Tap "Upgrade to Premium" | — (navigate to paywall) | ⚡ Paywall flow | — |
| Tap "Review Clips" | — (navigate to clip review) | — | 🟢 Opens clip review |

---

### 5.5 Clip Review (Premium Only)

**Flow:** Tap "Review Now" on success sheet → View clip details with AI content → Add to collection

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Display clip title | `clips.title` (SELECT) | ❌ Not accessible | 🟢 Shown |
| Display Key Takeaways (3 AI-generated bullets) | `clips.ai_takeaways` (SELECT) | ❌ Not accessible | 🟢 Shown |
| Display Transcript | `clips.transcript` (SELECT) | ❌ Not accessible | 🟢 Shown |
| Tap "Add to Collection" | — (open Add to Collection sheet §4.7) | ❌ Not accessible | 🟢 Available |
| Tap "Edit" | — (open clip editor) | ❌ Not accessible | 🟢 Available |

> **Free users cannot access clip review.** They can only generate clips. No review, no AI content, no delete, no regenerate.

**Clip Review layout:**
```
      ←  Review Clip

   "The Power of Strategic Silence
    in Negotiations"

   Key Takeaways
   • Strategic silence creates space for
     the other party to fill with information
   • Pausing before responding signals
     confidence and control
   • Silence is most effective after asking
     a question or making a strong point

   Transcript
   "...and that's when I realized that
   the most powerful tool in any
   negotiation isn't what you say..."

   [ Add to Collection ]    [ Edit ]
```

---

### 5.5.1 Add to Collection Sheet

**Flow:** Tap "Add to Collection" → Select collection → Done

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load user collections | `collections` (SELECT WHERE user_id) | ❌ Not accessible from clip review | 🟢 List shown with radio buttons |
| Select collection + tap "Done" | `collection_clips` (INSERT) | — | 🟢 Clip added |
| Tap "Create New Collection" | — (navigate to Create Collection §9.6) | — | 🟢 Available |
| Empty state: no collections | — (UI: "No collections yet" + "Create Collection" CTA) | — | 🟢 Shown |

---

### 5.6 Audio Ads (Free Users Only)

**Flow:** Free user listens to 4–5 clips → Audio ad plays → Ad overlay shown → Playback resumes

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Track clips listened count | — (client-side counter, per session) | ⚡ Triggers after 4–5 clips listened to | 🔒 No ads |
| Play audio ad (6–10 seconds) | — (ad network stream) | ⚡ Audio ad plays | — |
| Show ad overlay on player | — (UI: ad creative image, "Ad" badge, countdown timer) | ⚡ Shown | — |
| Show "Explore Premium" CTA on ad overlay | — (UI) | ⚡ Shown | — |
| Dim playback controls during ad | — (UI: controls greyed/disabled) | ⚡ Dimmed | — |
| Ad completes → Resume normal playback | — (client-side) | 🟢 Resumes | — |

> **Trigger:** Audio ads fire after the user has **listened to** 4–5 clips (not after generating them). This is a session-level counter.

**Ad overlay layout:**
```
   ┌───────────────────────────┐
   │                           │
   │    [Ad Creative Image]    │
   │                    Ad     │  (badge)
   │                    0:06   │  (countdown)
   │                           │
   └───────────────────────────┘
   
   Explore Premium

     1x    ⏮30   ▶   ⏭30   ↗    (controls dimmed)
```

---

### 5.7 ⋯ More Menu (Episode Player)

**Flow:** Tap ⋯ in header → Bottom sheet with 7 actions

> **Important:** This is the **Episode Player** ⋯ more menu. It is DIFFERENT from the Episode Details more menu (§19.6) and the Collection more menu (§9).

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open ⋯ menu sheet | — (UI) | 🟢 Same | 🟢 Same |
| "View Clips" | — (navigate to clips view, default My Clips, filter to Trendy Clips) | 🟢 Same | 🟢 Same |
| "Clipping Preference" | — (navigate to clip length preference FR-27) | 🟢 Same | 🟢 Same |
| "Gesture Controls" | — (navigate to gesture control settings FR-26) | 🟢 Same | 🟢 Same |
| "Add to My Favorites" | `episode_favourites` (INSERT / DELETE) | 🟢 Toast confirmation | 🟢 Toast confirmation |
| "Download Episode" | `user_downloads` (INSERT) + local storage | ❌ Shows download upsell (§19.7) | 🔒 Downloads + toast |
| "Play Next" | — (queue next episode in playlist) | 🟢 Same | 🟢 Same |
| "Episode Details" | — (navigate to Episode Details page §19) | 🟢 Same | 🟢 Same |

**⋯ More Menu layout:**
```
          ━━━━━━━━━━━━━━━━              (drag handle)

   🎬 View Clips
   ✂  Clipping Preference
   🎮 Gesture Controls
   ♥  Add to My Favorites
   ⬇  Download Episode
   ▶  Play Next
   📄 Episode Details
```

> **Note:** First-time/free user Lo-Fi wireframes incorrectly show "Download Collection" and "Go to Episode" labels. The **subscribed user version** has the correct labels: "Download Episode" and "Episode Details". Use the subscribed labels for implementation.

---

### 5.8 Episode Complete

**Flow:** Episode finishes playing → Episode Complete screen → Replay / Play Next / Review Clips

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Display episode artwork with cyan check badge | `episodes.artwork_url` (SELECT) | 🟢 Same | 🟢 Same |
| Display "Episode Complete" badge | — (UI) | 🟢 Same | 🟢 Same |
| Display episode info (number, title, author, duration) | `episodes` (SELECT) | 🟢 Same | 🟢 Same |
| Tap "Replay Episode" | — (seek to 0:00, resume playback) | 🟢 Same | 🟢 Same |
| Tap "Play Next Episode (#218)" | `episodes` (SELECT next by published_at) | 🟢 Same | 🟢 Same |
| Display "Review Your Clips" (count) + "View All" | `clips` (COUNT WHERE episode_id AND user_id) | ⚡ Shows count but review limited | 🟢 Full review access |

**Episode Complete layout:**
```
   ┌───────────────────────────┐
   │                           │
   │    [Episode Artwork]      │
   │         ✓                 │  (cyan check overlay)
   │    Episode Complete       │
   │                           │
   └───────────────────────────┘
   #217 - The Power of Strategic
   Silence in Negotiations
   Chris Williamson · 1h 34m

       [ Replay Episode ]
   [ Play Next Episode (#218) ]

   Review Your Clips (5)      View All
```

---

### 5.9 Audio Feedback

| Event | Audio Cue | All Users |
|-------|-----------|-----------|
| Clip generated successfully | Subtle confirmation sound | 🟢 Same |
| Viral clip section upcoming (waveform dot approaching) | Subtle anticipation sound | 🟢 Same |

> Audio cues should be unobtrusive and respect device silent mode settings.

---

### 5.10 First-Time User Variant

**Flow:** First time opening Episode Player → 2-step clip onboarding tooltip carousel → Normal player

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Detect first play session | `profiles` or local flag (SELECT) | 🟢 Same | 🟢 Same |
| Show onboarding tooltip step 1 (how to generate clips) | — (UI overlay) | 🟢 Shown | 🟢 Shown |
| Show onboarding tooltip step 2 (clip features) | — (UI overlay) | 🟢 Shown | 🟢 Shown |
| Dismiss tooltips → Normal player | — (UI) | 🟢 Same | 🟢 Same |
| My Clips empty state | — (UI: "No clips generated yet") | 🟢 Same | 🟢 Same |

---

### 5.11 Free vs Premium Summary (Episode Player)

| Feature | Free | Premium |
|---------|------|---------|
| Core playback (play/pause/seek/skip ±30s/speed) | ✅ Full | ✅ Full |
| Chapters overlay | ✅ Full | ✅ Full |
| Transcript overlay | ✅ Full | ✅ Full |
| Waveform progress with dots | ✅ Full | ✅ Full |
| Generate Clip | ⚡ 3–5 per episode | ✅ Unlimited |
| Clip success → Review Now | ❌ Auto-dismiss (no review) | ✅ Review Now button |
| Clip Review (AI takeaways/transcript) | ❌ Not accessible | ✅ Full review |
| Add to Collection (from review) | ❌ Not accessible | ✅ Available |
| Audio ads | ⚡ After 4–5 clips listened (6–10s) | ✅ Ad-free |
| ⋯ More Menu (7 items) | ✅ Same (Download triggers upsell) | ✅ Same (Download works) |
| Episode Complete | ✅ Same | ✅ Same |
| Audio feedback | ✅ Same | ✅ Same |
| First-time onboarding tooltips | ✅ Shown once | ✅ Shown once |

---

## 6. Clip Capture

> Clip capture is now fully documented within §5.4 (Generate Clip Flow). This section is retained for compatibility with existing cross-references.

**Flow:** Listening in Episode Player → Tap "✂ Generate Clip" → Extract from ring buffer → Save locally → Upload

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| 60s audio ring buffer running | — (client-side PCM buffer) | 🟢 Same | 🟢 Same |
| Tap "✂ Generate Clip" CTA | — (check quota) | ⚡ 3–5 clips/episode limit | 🟢 Unlimited (configurable future limit in `app_config`) |
| Press & hold CTA → Change clip duration | — (UI: duration picker) | 🟢 Same | 🟢 Same |
| Extract clip from buffer (default 60s per FR-27) | — (client-side AAC encoding) | 🟢 Same | 🟢 Same |
| Subtle audio feedback on clip generation | — (client-side audio cue) | 🟢 Same | 🟢 Same |
| Save clip locally | `clips` (INSERT, sync_status='local') | 🟢 Same | 🟢 Same |
| Request presigned upload URL | — (Edge Function call) | 🟢 Same | 🟢 Same |
| Upload to S3 | — (direct S3 PUT) | 🟢 Same | 🟢 Same |
| Update clip record with S3 URL | `clips` (UPDATE audio_url, sync_status) | 🟢 Same | 🟢 Same |
| Trigger AI processing | `clips` (UPDATE sync_status='processing') | 🟢 Same | 🟢 Same |

📱 Clip capture triggered from Episode Player "Generate Clip" CTA (see §5.4). Unprocessed Clips Collection (557:7282) shows clips awaiting processing.

**Free vs Premium difference:**
- **Free:** 3–5 clips per episode (configurable via `app_config.free_clip_limit_per_episode`). No clip review — success sheet auto-dismisses. Cannot review, delete, or regenerate clips.
- **Premium:** Unlimited clips (configurable future limit via `app_config.premium_clip_limit_per_episode`). Full clip review with AI takeaways/transcript.
- **Premium:** "15 hours of AI transcription/mo" limit mentioned on paywall (662:22577).

---

## 7. Clip Processing (AI)

**Flow:** Upload complete → Edge Function → Whisper → GPT → Update clip

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Whisper transcription | `clips` (UPDATE transcript) | 🟢 Basic transcript | 🟢 Basic transcript |
| GPT summary ("Insights") | `clips` (UPDATE ai_summary) | ❌ Not generated | 🔒 "Advanced AI Summaries" |
| GPT takeaways ("Actionable Takeaways") | `clips` (UPDATE ai_takeaways) | ❌ Not generated | 🔒 "Advanced AI Summaries" |
| Mark as processed | `clips` (UPDATE is_processed=true) | 🟢 Same | 🟢 Same |

📱 User Clip Details (554:1512) shows: "Insights" section, "Actionable Takeaways" section, "AI Transcript" section — all three are distinct.

**Free vs Premium difference:**
- **Free:** All three AI sections (Insights, Actionable Takeaways, **and AI Transcript**) are **blurred with a lock overlay** + "Premium Feature" + "Upgrade to view AI-generated insights" (per Lo-Fi frame 565:20995). `ai_summary` and `ai_takeaways` columns remain NULL; transcript may still be generated server-side but is gated in the UI.
- **Premium:** Gets transcript + AI-generated Insights + Actionable Takeaways — all shown unblurred (per Lo-Fi frame 554:1512).

> ⚠️ **Lo-Fi vs previous docs discrepancy:** Earlier documentation stated Free users see the transcript. The Lo-Fi wireframes (565:20995) show **all three sections blurred** for Free users, including the transcript. Confirm intended behaviour with design before implementation.

---

## 8. Clip Detail View

**Flow:** Tap clip → View full clip details with AI content

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load clip data | `clips` (SELECT) | 🟢 Same | 🟢 Same |
| Load episode/podcast info | `episodes`, `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Display transcript | `clips.transcript` | � **Blurred** (Lo-Fi 565:20995) | 🟢 Shown |
| Display "Insights" | `clips.ai_summary` | 🔒 **Blurred** + lock overlay | 🟢 Shown |
| Display "Actionable Takeaways" | `clips.ai_takeaways` | 🔒 **Blurred** + lock overlay | 🟢 Shown |
| Tap blurred section (upsell) | — (client-side UI) | Shows upsell sheet (587:35897) | N/A |
| Play clip audio | `clips.audio_url` via CloudFront | 🟢 Same | 🟢 Same |
| Add to collection | `collection_clips` (INSERT) | 🟢 Same | 🟢 Same |
| Share clip | `clips.share_token` | 🟢 Same | 🟢 Same |
| Tap ⋯ → Clip More Details sheet | — (UI) | 🟢 Same | 🟢 Same |
| Sheet: "Add to My Favorites" | `clip_favourites` (INSERT / DELETE) | 🟢 Same | 🟢 Same |
| Sheet: "Download Clip" | `user_downloads` (INSERT) + local storage | ❌ Shows download upsell | 🔒 Downloads locally |
| Sheet: "Go to Episode" | — (navigation) | ❓ **TBD** (behaviour not decided) | ❓ **TBD** |
| Sheet: "Go to Podcast" | — (navigation → Podcast Page §4) | 🟢 Same | 🟢 Same |
| Sheet: "Share Clip" | — (share sheet) | 🟢 Same | 🟢 Same |

📱 **Premium** Clip Details (554:1512): "Insights" = "Frequent dopamine spikes reduce baseline motivation", "Actionable Takeaways" = "Reduce high-frequency dopamine triggers", "AI Transcript" = full quote block. CTA: "Add to My Collection".

📱 **Free** Clip Details (565:20995): All three sections blurred with lock icon + "Premium Feature" + "Upgrade to view AI-generated insights".

📱 **Upsell sheet** (587:35897): "Want to get access to AI generated insights?" — "Get access to AI generated insights and key takeaways on all clips with premium." — "Explore Premium" button + Cancel.

📱 **Clip More Details sheet** (717:11491): 5 actions — Add to My Favorites, Download Clip (premium-only), Go to Episode (TBD), Go to Podcast, Share Clip.

---

## 9. Collections

> The Collections tab is the primary content-organisation feature. It is the second tab in the bottom navigation (Home | **Collections** | Feed | Learn). All 90 Lo-Fi designs have been reviewed. This section supersedes the previous §9 stub.

### 9.0 Collections Onboarding (First Visit Only)

**Flow:** First visit to Collections tab → 3-step carousel → Enter Collections tab

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Detect first visit | `profiles.collections_onboarding_completed` (SELECT) | 🟢 Same | 🟢 Same |
| Show Step 1: "Create Your Own Spaces" | — (UI only) | 🟢 Same | 🟢 Same |
| Tap "Continue" → Step 2: "Add Clips That Matter" | — (UI only) | 🟢 Same | 🟢 Same |
| Tap "Continue" → Step 3: "Build Your Insight Library" | — (UI only) | 🟢 Same | 🟢 Same |
| Tap "Start Now" | `profiles` (UPDATE collections_onboarding_completed = TRUE) | 🟢 Enter Collections tab | 🟢 Enter Collections tab |

> **Onboarding is skipped on all subsequent visits.** Completion state stored in `profiles.collections_onboarding_completed`.

---

### 9.1 Collections Tab Structure

The Collections tab has **4 top-level tabs** in a horizontal tab bar:

| Tab | Contents | Access |
|-----|----------|--------|
| **All** | System collections (My Favorites, Downloads, Unprocessed Clips) + My Collections section with "+" create button | 🟢 Free |
| **Favorites** | 4 sub-tabs (Podcasts / Episodes / Clips / Collections) | 🟢 Free |
| **Downloads** | 4 sub-tabs (Podcasts / Episodes / Clips / Collections) | 🔒 Premium |
| **My Collections** | User-created collections list with "6/15 free" counter + "+" button | 🟢 Free (limited) |

📱 Collections tab All (1067:13887), My Collections (1067:13887 variant), Offline (666:27736)

---

### 9.2 All Tab

**Flow:** Collections tab default → All sub-tab → See system + user collections

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load system collections | `collections` (SELECT WHERE user_id AND is_system = TRUE) | 🟢 Same | 🟢 Same |
| Show "My Favorites" system collection | `clip_favourites`, `collection_favourites` (COUNT) | 🟢 Badge count shown | 🟢 Badge count shown |
| Show "Downloads" system collection | `user_downloads` (COUNT WHERE user_id) | ❌ Locked / Premium upsell | 🔒 Badge count shown |
| Show "Unprocessed Clips" count | `clips` (COUNT WHERE user_id AND is_processed = FALSE) | 🟢 Same | 🟢 Same |
| Load My Collections section | `collections` (SELECT WHERE user_id AND is_system = FALSE AND is_curated = FALSE ORDER BY created_at DESC) | 🟢 Same | 🟢 Same |
| Tap "+" button | — (open Create New Collection flow §9.6) | ⚡ Check 15-collection limit | 🟢 Unlimited |
| Tap a collection card | — (navigate to Collection Detail §9.7) | 🟢 Same | 🟢 Same |
| Tap ▶ on a collection card | `clips` (SELECT audio_url), sequential playback | 🟢 Same | 🟢 Same |

---

### 9.3 Favorites Tab (4 Sub-tabs)

**Flow:** Collections tab → Favorites tab → View favourited content by type

#### Favorites → Podcasts

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load favourited podcasts | `podcast_favourites` JOIN `podcasts` (SELECT WHERE user_id) | 🟢 Same | 🟢 Same |
| Tap podcast → Podcast Detail | `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Unfavourite podcast | `podcast_favourites` (DELETE) | 🟢 Same | 🟢 Same |

#### Favorites → Episodes

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load favourited episodes | `episode_favourites` JOIN `episodes`, `podcasts` (SELECT WHERE user_id) | 🟢 Same | 🟢 Same |
| Tap episode → Episode Player | `episodes` (SELECT) | 🟢 Same | 🟢 Same |
| Unfavourite episode | `episode_favourites` (DELETE) | 🟢 Same | 🟢 Same |

> **Design note:** The Favorites → Episodes sub-tab has a typo in the design ("Epsidoes") — implement with correct spelling "Episodes".

#### Favorites → Clips

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load favourited clips | `clip_favourites` JOIN `clips`, `episodes`, `podcasts` (SELECT WHERE user_id) | 🟢 Same | 🟢 Same |
| Tap clip → Clip Detail | `clips` (SELECT) | 🟢 Same | 🟢 Same |
| Unfavourite clip | `clip_favourites` (DELETE) | 🟢 Same | 🟢 Same |

#### Favorites → Collections

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load favourited collections | `collection_favourites` JOIN `collections` (SELECT WHERE user_id) | 🟢 Same | 🟢 Same |
| Tap collection → Collection Detail | `collections` (SELECT) | 🟢 Same | 🟢 Same |
| Unfavourite collection | `collection_favourites` (DELETE) | 🟢 Same | 🟢 Same |

---

### 9.4 Downloads Tab (4 Sub-tabs — Premium Only)

**Flow:** Collections tab → Downloads tab → Premium gate → View downloaded content

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Tap Downloads tab | — (UI check) | ❌ Premium upsell shown | 🔒 Load content |
| Load downloaded podcasts | `user_downloads` (SELECT WHERE user_id AND download_type = 'podcast') JOIN `podcasts` | ❌ | 🔒 List shown |
| Load downloaded episodes | `user_downloads` (SELECT WHERE user_id AND download_type = 'episode') JOIN `episodes` | ❌ | 🔒 List shown |
| Load downloaded clips | `user_downloads` (SELECT WHERE user_id AND download_type = 'clip') JOIN `clips` | ❌ | 🔒 List shown |
| Load downloaded collections | `user_downloads` (SELECT WHERE user_id AND download_type = 'collection') JOIN `collections` | ❌ | 🔒 List shown |
| Tap downloaded item → play offline | Local device storage | ❌ | 🔒 Plays from local cache |

> **Design note:** The Downloads → Episodes sub-tab has a typo in the design ("Episoded") — implement with correct spelling "Episodes".

---

### 9.5 My Collections Tab

**Flow:** Collections tab → My Collections tab → Browse user's own collections

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load user's collections | `collections` (SELECT WHERE user_id AND is_system = FALSE AND is_curated = FALSE ORDER BY updated_at DESC) | 🟢 Same | 🟢 Same |
| Show collection count (free counter) | `collections` (COUNT WHERE user_id AND is_system = FALSE) | ⚡ Shows "6/15 free" | 🟢 Counter hidden |
| Tap "+" button | — (open Create New Collection §9.6) | ⚡ Check limit | 🟢 Unlimited |
| Tap collection card | — (navigate to Collection Detail §9.7) | 🟢 Same | 🟢 Same |
| Tap ▶ on collection card | `clips` (SELECT audio_url), sequential playback | 🟢 Same | 🟢 Same |
| Collection card with ⬇️ icon | `user_downloads` (SELECT WHERE collection_id) | ❌ No ⬇️ | 🔒 ⬇️ icon shown |

📱 My Collections list (1067:13887): Shows 4 collections with metadata: "AI & Technology" 24 clips•34m, "Health & Fitness" 10 clips•10m, "Business Insights" 8 clips•15m, "Marketing Inspiration" 15 clips•1h34m.

---

### 9.6 Create New Collection

**Flow:** Tap "+" button → Create sheet → Enter title → Toggle privacy → Create

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Create New Collection sheet | — (UI only) | 🟢 Same | 🟢 Same |
| Show free collection counter ("6/15 free") | `collections` (COUNT WHERE user_id AND is_system = FALSE) | ⚡ Counter shown | 🟢 Counter hidden |
| Enter collection title | — (UI state) | 🟢 Same | 🟢 Same |
| Toggle "Make My Collection Private" (default OFF = Public) | — (UI state) | 🟢 Same | 🟢 Same |
| Tap "Create Collection" | `collections` (INSERT) | ⚡ Blocked if ≥ 15 → premium upsell | 🟢 INSERT succeeds |
| Toast on success | — (client UI) | 🟢 "✓ Collection Created Successfully \| now" | 🟢 Same |
| Blocked (15 reached) | — (UI only) | ❌ Shows "Want to Add Unlimited Collections?" upsell | — |

> **Business rules:**
> - Toggle OFF = Public (counterintuitive). "Make My Collection Private" — when the toggle is in the OFF/unchecked state, the collection is PUBLIC. When ON, it is private.
> - Public collections automatically appear on the Social Feed (dev note 908:9591).
> - Server enforces the limit; client check is UX only.
> - Context-dependent button text: standalone = "Create Collection"; triggered from a clip = "Create & Add Clip".

📱 Create sheet (549:6040): Free variant shows "6/15 free" counter. Premium variant (553:11537) shows no counter. Premium upsell (context: collections limit) says "Want to Add Unlimited Collections?" → Explore Premium / Cancel.

---

### 9.7 Collection Detail Screen

**Flow:** Tap collection → Full-screen detail with clip list and action buttons

#### Loading States

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load collection metadata | `collections` (SELECT) | 🟢 Same | 🟢 Same |
| Load clips in collection | `collection_clips` JOIN `clips`, `episodes`, `podcasts` (SELECT ORDER BY position) | 🟢 Same | 🟢 Same |
| Show empty state | — (UI: "No Clips Added Yet") | 🟢 Same | 🟢 Same |
| Show public/private badge | `collections.is_private` (SELECT) | 🟢 🌐 Public or 🔒 Private | 🟢 Same |
| Show total duration | `collections.total_duration` (SELECT) | 🟢 Same | 🟢 Same |
| Show clip count | `collections.clip_count` (SELECT) | 🟢 Same | 🟢 Same |

#### 3-Month Aged Clips Warning Banner

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Check for aged clips | `collection_clips` (SELECT WHERE added_at < now() - interval '3 months' AND (last_reviewed_at IS NULL OR last_reviewed_at < now() - interval '3 months')) | 🟢 Same | 🟢 Same |
| Show warning banner | — (UI: "Time to tidy up — X clips waiting / [Revisit Clips] [Delete]") | 🟢 Same | 🟢 Same |
| Tap [Revisit Clips] | — (navigate to Review Aged Clips §9.8) | 🟢 Same | 🟢 Same |
| Tap [Delete] | `collection_clips` (DELETE aged clips WHERE added_at < interval) | 🟢 Same | 🟢 Same |

#### Playback

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Tap [▶ Play Clips] | `clips` (SELECT audio_url ORDER BY collection_clips.position) | 🟢 Same | 🟢 Same |
| Sequential playback in full-screen player | — (client-side `just_audio`) | 🟢 Same | 🟢 Same |
| Mini-player shows "Now Playing from [Collection Name]" | — (client state) | 🟢 Same | 🟢 Same |

#### Collection Detail — Downloaded State (Premium)

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Show download indicator per clip | `user_downloads` (SELECT WHERE clip_id IN collection_clips.clip_id) | ❌ | 🔒 ⬇️ icon on downloaded clips |
| Downloaded clips shown bright | — (local storage check) | ❌ | 🔒 Full opacity |
| Non-downloaded clips greyed | — (local storage check) | ❌ | 🔒 Reduced opacity |

📱 Collection Detail with clips (549:6537), Empty state (586:9879), Downloaded variant (666:27808): 2 bright clips + 4 greyed clips.

---

### 9.8 3-Month Aged Clips Review Flow

**Flow:** Warning banner → [Revisit Clips] → Paginated review → Keep or Delete → Completion

This flow is triggered from the 3-month warning banner on the Collection Detail screen. It is distinct from the Learn tab's "Review Weekly Insights" flow (§14.3), though visually similar.

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Review Aged Clips screen | `collection_clips` (SELECT aged entries), `clips` (SELECT) | 🟢 Same | 🟢 Same |
| Show progress bar (e.g. "1/15 unprocessed clips") | `collection_clips` (COUNT aged) | 🟢 Same | 🟢 Same |
| Display editable clip title | `clips.title` (SELECT) | 🟢 Editable | 🟢 Editable |
| Display waveform + timing [start] ▶ [end] | `clips.audio_url, start_time, end_time` | 🟢 Play & view | 🟢 Play & view |
| Adjust clip start/end drag handles (max 60s) | `clips` (UPDATE start_time, end_time) | 🟢 Same | 🟢 Same |
| Display Insights section | `clips.ai_summary` | 🔒 Crown icon + locked overlay | 🟢 Visible content |
| Display Key Takeaways section | `clips.ai_takeaways` | 🔒 Crown icon + locked overlay | 🟢 Visible content |
| Edit My Notes | `clips` (UPDATE my_notes) | 🟢 Editable | 🟢 Editable |
| Tap [Keep Clip] | `collection_clips` (UPDATE last_reviewed_at = now()) | 🟢 Advances to next aged clip | 🟢 Same |
| Save edited clip title | `clips` (UPDATE title) | 🟢 Same | 🟢 Same |
| Tap [Delete] | — (open Delete Clip Confirmation §9.15) | 🟢 Same | 🟢 Same |
| Confirm delete | `clips` (DELETE — cascades to collection_clips) | 🟢 Toast "✓ Clip is deleted \| now" | 🟢 Same |
| All aged clips reviewed | — (UI: Completion screen) | 🟢 Same | 🟢 Same |
| Completion: "✓ You're All Caught Up!" | — (UI only) | 🟢 Same | 🟢 Same |
| Completion stats shown | `clip_review_status` or `collection_clips` (aggregate) | 🟢 This Week: X, Total Clips Saved: X | 🟢 Same |
| Tap [Discover More Podcasts] | — (navigate to Home/Search) | 🟢 Same | 🟢 Same |
| Tap [View My Collections] | — (navigate to Collections tab) | 🟢 Same | 🟢 Same |

📱 Review Aged Clips — Free (587:24210), Premium (567:24938 — all unlocked). Completion screen (700:8464).

> **Premium upsell in review:** Tapping a locked Insights or Key Takeaways section shows "Want to generate AI key takeaways & add notes to clips?" → Explore Premium.

---

### 9.9 Collection Options ⋯ Menu

**Flow:** Tap ⋯ on Collection Detail → Bottom sheet → Choose action

The Collection Detail header shows: ← Title ⋯. Tapping ⋯ opens a 7-item options sheet:

| # | Option | Action | Tables |
|---|--------|--------|--------|
| 1 | Add to My Favorites | `collection_favourites` (INSERT) | ❤️ |
| 2 | Download Collection | `user_downloads` (INSERT, type='collection') + per-clip INSERTs | 🔒 Premium |
| 3 | Edit Collection | Open Edit Collection sheet (§9.12) | `collection_clips` (SELECT ORDER BY position) |
| 4 | Add to this Collection | Open Add Clips sheet (§9.11) | `clips` (SELECT available) |
| 5 | Name & Details | Open Name & Details sheet (§9.13) | `collections` (SELECT) |
| 6 | Delete Collection | Confirm → `collections` (DELETE, CASCADE to collection_clips) | ⚠️ Destructive |
| 7 | Share Collection | Open Share Collection sheet (§9.14) | `collections.share_token` |

---

### 9.10 Clip Options ⋯ Menu (Within Collection Context)

**Flow:** Tap ⋯ on a clip row inside a Collection Detail → Bottom sheet → Choose action

When accessed from inside a collection, **"Remove From Collection" appears first** (before "Add to My Favorites"). This is different from clip options accessed from Learn or other contexts.

| # | Option | Action | Tables |
|---|--------|--------|--------|
| 1 | **Remove From Collection** | `collection_clips` (DELETE WHERE collection_id AND clip_id) | ⚠️ Context-specific — first item |
| 2 | Add to My Favorites | `clip_favourites` (INSERT) | ❤️ |
| 3 | Download Clip | `user_downloads` (INSERT, type='clip') | 🔒 Premium |
| 4 | Go to Episode | — (navigate to Episode Detail/Player) | `episodes` (SELECT) |
| 5 | Go to Podcast | — (navigate to Podcast Detail) | `podcasts` (SELECT) |
| 6 | Share Clip | Open Share Clip sheet (§9.16) | `clip_shares` (INSERT), `clips.share_count` UPDATE |

> **"Remove From Collection" is specific to the collection context.** In other contexts (Learn, search results), the clip options start with "Add to My Favorites".

📱 Clip options in collection context (561:14831).

---

### 9.11 Add Clips to Collection Sheet

**Flow:** Collection ⋯ → "Add to this Collection" → Search and select clips → Confirm

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Add Clips sheet | `clips` (SELECT WHERE user_id AND clip NOT IN collection_clips WHERE collection_id) | 🟢 Same | 🟢 Same |
| Search within available clips | `clips` (SELECT with text filter) | 🟢 Same | 🟢 Same |
| Show "Unsorted Clips" section | `clips` (SELECT WHERE user_id AND not yet in this collection) | 🟢 Same | 🟢 Same |
| Select clip(s) via checkboxes | — (UI state) | 🟢 Same | 🟢 Same |
| Tap Confirm / Add | `collection_clips` (INSERT, position = MAX(position) + 1) | 🟢 Same | 🟢 Same |

---

### 9.12 Edit Collection Sheet

**Flow:** Collection ⋯ → "Edit Collection" → Reorder or remove clips → Save

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Edit Collection sheet | `collection_clips` JOIN `clips` (SELECT ORDER BY position) | 🟢 Same | 🟢 Same |
| Show Cancel / Save header | — (UI only) | 🟢 Same | 🟢 Same |
| Drag clip to reorder (≡ handle) | `collection_clips` (UPDATE position batch) | 🟢 Same | 🟢 Same |
| Remove clip (− button) | `collection_clips` (DELETE WHERE collection_id AND clip_id) | 🟢 Same | 🟢 Same |
| Tap Save | `collection_clips` (UPSERT positions) | 🟢 Same | 🟢 Same |
| Tap Cancel | — (discard changes) | 🟢 Same | 🟢 Same |

> **Items are CLIPS only** — no sub-collections, no episodes.

---

### 9.13 Name & Details Sheet (Edit Collection Metadata)

**Flow:** Collection ⋯ → "Name & Details" → Edit title and privacy → Save

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Name & Details sheet | `collections` (SELECT title, is_private) | 🟢 Same | 🟢 Same |
| Edit "Collection Title" field | — (UI state) | 🟢 Same | 🟢 Same |
| Toggle "Make My Collection Private" | — (UI state; OFF = Public) | 🟢 Same | 🟢 Same |
| Tap Save | `collections` (UPDATE title, is_private) | 🟢 Same | 🟢 Same |
| Tap Cancel | — (discard changes) | 🟢 Same | 🟢 Same |

> **Auto-publish rule:** Setting `is_private = FALSE` (toggle OFF) will cause the collection to appear on the Social Feed automatically (server-side, no extra action needed).

📱 Edit Collection Details sheet (556:7255).

---

### 9.14 Share Collection Flow

**Flow:** Collection ⋯ → "Share Collection" → Select share method

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Share Collection sheet | `collections` (SELECT share_token) | 🟢 Same | 🟢 Same |
| Show collection preview card (name + stats) | `collections` (SELECT clip_count, total_duration) | 🟢 Same | 🟢 Same |
| Share to "My Feed" | `collections.is_private = FALSE` (ensure public) — posts to Social Feed | 🟢 Same | 🟢 Same |
| Share via "Copy Link" | `collections.share_token` → URL (clipcast.app/collection/{token}) | 🟢 Same | 🟢 Same |
| Share via WhatsApp | OS share sheet with URL | 🟢 Same | 🟢 Same |
| Share via "More" | OS native share sheet | 🟢 Same | 🟢 Same |

> **Design inconsistency in Lo-Fi:** The Share Collection sheet label reads "Share your clip with" (should be "Share your collection with"). Implement with corrected text "Share your collection with".

> ⚠️ **Figma design note:** First-time (925:16096) and free user (925:15001) Lo-Fi wireframes show only 3 share options (Copy Link, WhatsApp, More) — omitting "My Feed". The subscribed wireframe (913:9823) shows all 4. **Per product owner confirmation, all user types have access to all 4 share options.** Free users’ shares count toward the 5-share limit.

---

### 9.15 Delete Clip Flow

**Flow:** Clip options → "Delete Clip" (or "Delete" in Review flow) → Confirmation → Delete

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Tap "Delete" (in clip options or Review Aged Clips) | — (open confirmation sheet) | 🟢 Same | 🟢 Same |
| Show Delete Clip Confirmation sheet | — (UI: trash icon + "Are you sure you want to delete?") | 🟢 Same | 🟢 Same |
| Tap [Delete Clip] (teal, destructive) | `clips` (DELETE — CASCADE removes collection_clips, clip_review_status, clip_favourites, clip_engagement, clip_shares) | 🟢 Toast "✓ Clip is deleted \| now" | 🟢 Same |
| Tap Cancel | — (dismiss sheet) | 🟢 Same | 🟢 Same |

📱 Delete Clip Confirmation sheet (624:19434). Delete Clip toast (624:19408).

---

### 9.16 Share Clip Flow (from Collection Context)

**Flow:** Clip options → "Share Clip" → Select share method → Log share event

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Share Clip sheet | `clips` (SELECT share_token) | 🟢 Same | 🟢 Same |
| Show waveform preview | `clips.audio_url, start_time, end_time` | 🟢 Same | 🟢 Same |
| Check remaining share quota | `clip_shares` (COUNT WHERE user_id) via Edge Function | ⚡ Up to 5 shares free | 🟢 Unlimited |
| Share to "My Feed" | `clip_shares` (INSERT type='my_feed'), `clips.share_count` (UPDATE) | ⚡ Counts toward 5 | 🟢 Same (no limit) |
| Share via "Copy Link" | `clip_shares` (INSERT type='copy_link'), `clips.share_token` (SELECT) | ⚡ Counts toward 5 | 🟢 Same |
| Share via WhatsApp | `clip_shares` (INSERT type='whatsapp') | ⚡ Counts toward 5 | 🟢 Same |
| Share via "More" | `clip_shares` (INSERT type='other') | ⚡ Counts toward 5 | 🟢 Same |
| Quota reached (5 shares) | — (premium upsell sheet) | ❌ "Want to share unlimited clips with your friends?" → Explore Premium / Cancel | — |

> **Business rule — only user-generated clips on feed:** Dev note 913:12677: "Only clips generated by user can be shared on feed." Platform-curated or system clips cannot be shared to the Social Feed.

> ⚠️ **Figma design note:** First-time (925:16003) and free user (925:14908) Lo-Fi wireframes show only 3 share options (Copy Link, WhatsApp, More) — omitting "My Feed". The subscribed wireframe (913:9726) shows all 4. **Per product owner confirmation, all user types have access to all 4 share options.** Free users’ shares count toward the 5-share limit.

---

### 9.17 Premium Upsell Triggers (Collections Context)

| Trigger | Upsell Message | Action |
|---------|---------------|--------|
| Free user taps "+" when at 15-collection limit | "Want to Add Unlimited Collections?" | Explore Premium / Cancel |
| Free user taps locked Insights in Review Aged Clips | "Want to generate AI key takeaways & add notes to clips?" | Explore Premium |
| Free user tries to share 6th clip | "Want to share unlimited clips with your friends?" / "Upgrade to premium to share/export an unlimited number of clips." | Explore Premium / Cancel |
| Free user taps Downloads tab | Premium gate | Explore Premium |
| Free user taps "Download Collection" or "Download Clip" in options | Premium gate | Explore Premium |

---

**Free vs Premium — Collections Summary**

| Feature | Free | Premium |
|---------|------|---------|
| User collections | ⚡ Max 15 (shows "X/15 free" counter) | ✅ Unlimited (counter hidden) |
| Collection create/edit/delete | ✅ Full access | ✅ Full access |
| Collection privacy toggle | ✅ Full access | ✅ Full access |
| Clip add/remove/reorder | ✅ Full access | ✅ Full access |
| 3-month Aged Clips Review | ✅ Keep/Delete + title edit + notes | ✅ All above + Insights + Key Takeaways |
| AI Insights in Review | 🔒 Locked (crown + upsell) | ✅ Visible |
| AI Key Takeaways in Review | 🔒 Locked (crown + upsell) | ✅ Visible |
| Clip sharing | ⚡ Max 5 share events total | ✅ Unlimited |
| Collection sharing | ✅ Full access | ✅ Full access |
| Favorites (Podcasts/Episodes/Clips/Collections) | ✅ Full access | ✅ Full access |
| Downloads tab | 🔒 Premium gate | ✅ Full access (4 content types) |
| Download Clip / Collection | 🔒 Premium only | ✅ With offline playback |
| AI Collection button (player) | 🔒 Hidden | ✅ Visible |

---

## 10. Social Feed

**Flow:** Feed tab → Trending / Friends / My Feed → Engage with clips

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load Trending feed | `clips`, `profiles` via `feed_view` (SELECT) | 🟢 Clips shown | 🟢 Clips shown |
| View KEY TAKEAWAYS on feed cards | `clips.ai_summary`, `clips.ai_takeaways` | ⚡ **Blurred + lock icon** + "Premium Feature" overlay | 🔒 **Full takeaways shown** |
| Load Friends feed | `feed_view` + `follows` (SELECT WHERE followed) | 🟢 Clips shown | 🟢 Clips shown |
| View KEY TAKEAWAYS on Friends cards | `clips.ai_summary` | ⚡ **Blurred + "Upgrade to view AI-generated insights"** | 🔒 **Full text shown** |
| Load My Feed | `clips` (SELECT WHERE user_id = auth.uid()) | 🟢 Clips shown (shorter cards) | 🟢 Clips shown (taller cards with takeaways) |
| Like a clip | `clip_engagement` (INSERT type='like') | 🟢 Same | 🟢 Same |
| Bookmark a clip | `clip_engagement` (INSERT type='bookmark') | 🟢 Same | 🟢 Same |
| Comment on a clip | `comments` (INSERT) | 🟢 Same | 🟢 Same |
| Share a clip | `clip_engagement` (INSERT type='share'), `clips` (UPDATE share_count) | 🟢 Same | 🟢 Same |

📱 **Trending Premium (680:31417):** Full KEY TAKEAWAYS section visible. **Trending Free (925:14386):** Blur overlay with lock icon + "Premium Feature" + "Upgrade to view AI-generated insights". **Trending First-Time (925:15473):** Same blur/lock as free. **Friends Premium (912:11638):** Full takeaways. **Friends Free (925:14573):** Same blur/lock pattern. **Friends First-Time (925:15674):** Empty state. **My Feed Premium (912:12148):** 1766px tall cards with takeaways, includes both clips and collections. **My Feed Free (925:14748):** 1532px tall cards, takeaways completely absent. **My Feed First-Time (925:15863):** Empty state. **Offline (746:17336).**

> ⚠️ **Business rule (913:12689):** "Clips that are not generated by user cannot be shared on feed." Only user-generated clips may appear on the Social Feed; platform-curated clips cannot be shared to feed.

**This is the most significant Free vs Premium visual difference in the app.**

### 10.1 Feed Tab Structure

The Social Feed has **3 top-level tabs** in a horizontal tab bar:

| Tab | Contents | Description |
|-----|----------|-------------|
| **Trending** | Clips sorted by engagement (like_count + comment_count) | Shows clips from all public users. Each card: avatar, username, timestamp, Follow button, clip title, image with play overlay, source podcast, KEY TAKEAWAYS (premium-gated), duration + share count, like/comment/share/bookmark actions. |
| **Friends** | Clips from followed users only | Same card anatomy as Trending but shows "Following" badge instead of "Follow" button for already-followed users. |
| **My Feed** | User's own shared clips and collections | No avatar/follow buttons (own content). Free: shorter cards without KEY TAKEAWAYS. Premium: taller cards with KEY TAKEAWAYS visible. |

### 10.2 Feed Card Anatomy

**Trending / Friends card:**
```
   ┌─────────────────────────────┐
   │ [Avatar] Username    Follow │  (or "Following" badge)
   │          2 hours ago        │
   │                             │
   │ Clip Title                  │
   │ ┌─────────────────────────┐ │
   │ │   [Clip Image / ▶]     │ │
   │ └─────────────────────────┘ │
   │ From [Podcast Name]        │
   │                             │
   │ KEY TAKEAWAYS               │  (blurred for free; visible for premium)
   │ • Bullet point 1            │
   │ • Bullet point 2            │
   │                             │
   │ ⏱ 60 sec      🔗 12k shares│
   │ ♥ 324  💬 48  ↗  🔖       │
   └─────────────────────────────┘
```

**My Feed card (premium — with takeaways):**
```
   ┌─────────────────────────────┐
   │ Clip Title                  │
   │ ┌─────────────────────────┐ │
   │ │   [Clip Image / ▶]     │ │
   │ └─────────────────────────┘ │
   │ From [Podcast Name]        │
   │                             │
   │ KEY TAKEAWAYS               │  (visible for premium only)
   │ • Bullet point 1            │
   │ • Bullet point 2            │
   │                             │
   │ ⏱ 60 sec      🔗 12k shares│
   │ ♥ 324  💬 48  ↗            │
   └─────────────────────────────┘
```

**My Feed card (free — shorter, no takeaways):**
```
   ┌─────────────────────────────┐
   │ Clip Title                  │
   │ ┌─────────────────────────┐ │
   │ │   [Clip Image / ▶]     │ │
   │ └─────────────────────────┘ │
   │ From [Podcast Name]        │
   │                             │
   │ ⏱ 60 sec      🔗 12k shares│
   │ ♥ 324  💬 48  ↗            │
   └─────────────────────────────┘
```

**My Feed — Collection card (premium):**
```
   ┌─────────────────────────────┐
   │ Collection Title            │
   │ ┌──────┐ ┌──────┐          │
   │ │[img1]│ │[img2]│          │
   │ └──────┘ └──────┘          │
   │ ┌──────┐ ┌──────┐          │
   │ │[img3]│ │ +3   │          │
   │ └──────┘ └──────┘          │
   │ ⏱ 1h 24min total 📋 5 clips│
   │ ♥ 324  💬 48  ↗            │
   └─────────────────────────────┘
```

### 10.3 Empty States (First-Time Users)

**Friends tab — empty state (925:15674):**

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Detect no followed users with public content | `follows` (COUNT WHERE follower_id = auth.uid()) | 🟢 Same | 🟢 Same |
| Show empty state illustration + message | — (UI only) | 🟢 Same | 🟢 Same |
| Tap "Explore Podcasts" CTA | — (navigate to Home/Search) | 🟢 Same | 🟢 Same |
| Tap "Browse trending content" link | — (switch to Trending tab) | 🟢 Same | 🟢 Same |

```
         [Illustration]

   No friends sharing yet

   Follow your friends to see their
   shared clips and collections
   in your feed

      [ Explore Podcasts ]

     Browse trending content
```

**My Feed tab — empty state (925:15863):**

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Detect no public clips/collections from user | `clips` (COUNT WHERE user_id = auth.uid() AND is_public = TRUE) | 🟢 Same | 🟢 Same |
| Show empty state illustration + message | — (UI only) | 🟢 Same | 🟢 Same |
| Tap "Explore Podcasts" CTA | — (navigate to Home/Search) | 🟢 Same | 🟢 Same |
| Tap "Browse trending content" link | — (switch to Trending tab) | 🟢 Same | 🟢 Same |

```
         [Illustration]

   Share your first clip

   Start building your podcast collection
   by sharing clips and insights with
   the community.

      [ Explore Podcasts ]

     Browse trending content
```

> **Suggested People context:** The empty states on Friends and My Feed tabs serve as the primary discovery surface encouraging first-time users to follow other users and start sharing content. User discovery is integrated into the social flow through Follow buttons on Trending feed cards, profile screens, and search results.

### 10.4 Comments Bottom Sheet

**Flow:** Tap comment icon on feed card → Comments bottom sheet → View/add comments

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open comments bottom sheet | `comments` (SELECT WHERE clip_id ORDER BY created_at ASC) | 🟢 Same | 🟢 Same |
| Display comment list | `comments` JOIN `profiles` (SELECT avatar, username) | 🟢 Same | 🟢 Same |
| Type and submit comment | `comments` (INSERT) | 🟢 Same | 🟢 Same |
| Generate comment notification | `notifications` (INSERT via Edge Function) | 🟢 Same | 🟢 Same |

📱 **Comments — First-Time (925:16141)**, **Free (925:15050)**, **Subscribed (685:34973)**: Identical layout across all user types. No premium gating on comments.

```
   ━━━━━━━━━━━━━━━━              (drag handle)

            Comments

   [Avatar] sarah_coach     1h ago
   This clip is gold! I'm using this
   technique in my next client meeting 🔥

   [Avatar] mike_sales      2h ago
   Perfect timing! I've been struggling
   with this exact scenario.

   ┌─────────────────────────────────┐
   │ Add a comment...               │
   └─────────────────────────────────┘
```

### 10.5 Share Clip from Feed

**Flow:** Tap share icon on feed card → Share Clip bottom sheet → Select share method

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Share Clip sheet | `clips` (SELECT share_token) | 🟢 Same | 🟢 Same |
| Show clip preview (podcast, episode, title, waveform 0:24–0:30, play controls) | `clips`, `episodes`, `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Check remaining share quota | `clip_shares` (COUNT WHERE user_id) via Edge Function | ⚡ Up to 5 shares free | 🟢 Unlimited |
| Share to "My Feed" | `clip_shares` (INSERT type='my_feed'), `clips.share_count` (UPDATE) | ⚡ Counts toward 5 | 🟢 Same (no limit) |
| Share via "Copy Link" | `clip_shares` (INSERT type='copy_link'), `clips.share_token` (SELECT) | ⚡ Counts toward 5 | 🟢 Same |
| Share via WhatsApp | `clip_shares` (INSERT type='whatsapp') | ⚡ Counts toward 5 | 🟢 Same |
| Share via "More" | `clip_shares` (INSERT type='other') | ⚡ Counts toward 5 | 🟢 Same |
| Quota reached (5 shares) | — (premium upsell sheet) | ❌ "Want to share unlimited clips with your friends?" → Explore Premium / Cancel | — |

📱 **Share Clip — First-Time (925:16003)**, **Free (925:14908)**, **Subscribed (913:9726)**: All three user types have access to all 4 share options (My Feed, Copy Link, WhatsApp, More). Free users are limited to 5 total share events across all methods.

> ⚠️ **Figma design note:** First-time and free user Lo-Fi wireframes show only 3 share options (Copy Link, WhatsApp, More) — omitting the "My Feed" option. **Per product owner confirmation, free users DO have access to the My Feed share option** (subject to the 5-share limit). The subscribed user wireframe (913:9726) showing all 4 options is the authoritative reference. Implement all 4 options for all user types.

**Share Clip layout:**
```
   ━━━━━━━━━━━━━━━━              (drag handle)

   Cancel        Share Clip

   ┌─────────────────────────────┐
   │ 🎵 Modern Wisdom            │
   │    #217 - The Art of...     │
   │                             │
   │ The Power of Strategic      │
   │ Silence in Negotiations     │
   │                             │
   │ ┌─────────────────────────┐ │
   │ │ ||||||||  waveform      │ │
   │ │ 0:24              0:30 │ │
   │ └─────────────────────────┘ │
   │       ↺    ▶    ↻          │
   └─────────────────────────────┘

   Share your clip with

   📌         🔗         📱         •••
  MyFeed   Copy Link  Whatsapp    More
```

### 10.6 Share Collection from Feed

**Flow:** Tap share on collection → Share Collection bottom sheet → Select share method

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Share Collection sheet | `collections` (SELECT share_token) | 🟢 Same | 🟢 Same |
| Show collection preview (name, clip count, duration) | `collections` (SELECT clip_count, total_duration) | 🟢 Same | 🟢 Same |
| Share to "My Feed" | `collections.is_private = FALSE` (ensure public) — posts to Social Feed | 🟢 Same | 🟢 Same |
| Share via "Copy Link" | `collections.share_token` → URL | 🟢 Same | 🟢 Same |
| Share via WhatsApp | OS share sheet with URL | 🟢 Same | 🟢 Same |
| Share via "More" | OS native share sheet | 🟢 Same | 🟢 Same |

📱 **Share Collection — First-Time (925:16096)**, **Free (925:15001)**, **Subscribed (913:9823)**: Same note as Share Clip — all user types should see all 4 share options. Free/first-time Lo-Fi wireframes omit MyFeed option but subscribed wireframe (913:9823) is authoritative.

> **Design inconsistency in Lo-Fi:** The Share Collection sheet label reads "Share your clip with" (should be "Share your collection with"). Implement with corrected text "Share your collection with".

**Share Collection layout:**
```
   ━━━━━━━━━━━━━━━━              (drag handle)

   Cancel     Share Collection

   ┌─────────────────────────────┐
   │ 🖼  AI & Technology          │
   │    24 clips • 34m           │
   └─────────────────────────────┘

   Share your collection with

   📌         🔗         📱         •••
  MyFeed   Copy Link  Whatsapp    More
```

### 10.7 Free vs Premium Summary (Social Feed)

| Feature | Free | Premium |
|---------|------|---------|
| Trending tab | ✅ Full access | ✅ Full access |
| Friends tab | ✅ Full access | ✅ Full access |
| My Feed tab | ✅ Full access (shorter cards) | ✅ Full access (taller cards with takeaways) |
| KEY TAKEAWAYS on Trending/Friends | 🔒 Blurred + "Premium Feature" overlay | ✅ Visible |
| KEY TAKEAWAYS on My Feed | ❌ Absent (cards don't include section) | ✅ Visible |
| Like/Bookmark/Comment | ✅ Unlimited, no gating | ✅ Unlimited |
| Share to My Feed / Copy Link / WhatsApp / More | ⚡ 4 options, max 5 total share events | ✅ 4 options, unlimited |
| Follow from feed cards | ✅ Full access | ✅ Full access |
| Friends empty state | ✅ "No friends sharing yet" | ✅ Same |
| My Feed empty state | ✅ "Share your first clip" | ✅ Same |

---

## 11. Follow System

**Flow:** Visit profile → Follow/Unfollow → Appears in Friends feed

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Follow a user | `follows` (INSERT) | 🟢 Same | 🟢 Same |
| Unfollow a user | `follows` (DELETE) | 🟢 Same | 🟢 Same |
| Load follower/following list | `follows`, `profiles` (SELECT) | 🟢 Same | 🟢 Same |
| Generate follow notification | `notifications` (INSERT via Edge Function) | 🟢 Same | 🟢 Same |

📱 No dedicated Follow screen in HiFi. Follows are managed from Profile screens and feed cards.

---

## 12. Premium Paywall

**Flow:** Free user hits gated feature → Paywall displayed → Purchase → Entitlement granted

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Show paywall | — (client-side UI) | 🟢 Sees paywall | N/A (already premium) |
| RevenueCat purchase | `user_subscriptions` (INSERT via webhook) | Flow starts here | — |
| Webhook updates subscription | `user_subscriptions` (UPDATE status) | → `trialing` → `active` | Status maintained |
| Update `profiles.is_premium` | `profiles` (UPDATE via Edge Function) | → `is_premium = true` | Already true |

📱 Explore Premium (662:22577): **$49/year**, 1-month free trial. Features listed:
- ✅ Advanced AI Summaries
- ✅ Generate numerous clips per episode
- ✅ Offline Access
- ✅ Ad-free Experience
- ✅ 15 hours of AI transcription/mo

---

## 13. Notifications

**Flow:** Event occurs → Edge Function creates notification → Push via OneSignal → In-app display

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| New follower notification | `notifications` (INSERT via Edge Function) | 🟢 Same | 🟢 Same |
| New clip from followed user | `notifications` (INSERT via Edge Function) | 🟢 Same | 🟢 Same |
| Like/comment/share notification | `notifications` (INSERT via Edge Function) | 🟢 Same | 🟢 Same |
| Load notification list | `notifications` (SELECT WHERE user_id, ORDER BY created_at DESC) | 🟢 Same | 🟢 Same |
| Mark as read | `notifications` (UPDATE is_read=true) | 🟢 Same | 🟢 Same |
| Push delivery (OneSignal) | — (external service) | 🟢 Same | 🟢 Same |

📱 No dedicated notifications HiFi screen. Title card only (implied from navigation).

---

## 14. Learn

The Learn tab is a clip-review and retention feature — **not** static content. Users review their unprocessed clips in a guided weekly-insights flow, optionally annotate them, and organise them into collections. AI-generated Insights and Key Takeaways are premium-gated.

### 14.1 Learn Onboarding

**Flow:** First visit to Learn tab → 4-step carousel → Frequency selection → Reminder setup → Learn main screen

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Show step 1/4 "Capture to Remember" | — (UI only) | 🟢 Same | 🟢 Same |
| Show step 2/4 "Stop Forgetting What You Hear" | — (UI only) | 🟢 Same | 🟢 Same |
| Show step 3/4 "Listen & Read. Learn Better." | — (UI only) | 🟢 Same | 🟢 Same |
| Show step 4/4 "Short Wins, Long Retention" | — (UI only) | 🟢 Same | 🟢 Same |
| Skip onboarding (any step) | `learning_preferences` (INSERT onboarding_completed = TRUE) | 🟢 Same | 🟢 Same |
| Select Insights Frequency (Daily / Weekly / Monthly / Custom) | `learning_preferences` (INSERT/UPDATE frequency) | 🟢 Same | 🟢 Same |
| Set Reminder Time (toggle on/off, preferred period, time) | `learning_preferences` (INSERT/UPDATE reminder fields) | 🟢 Same | 🟢 Same |
| Tap "Start Learning" | `learning_preferences` (UPDATE onboarding_completed = TRUE) | 🟢 Same | 🟢 Same |

📱 Carousel: (586:11263, 725:14323, 586:11503, 586:11685), Frequency: (586:11809), Reminder: (586:12028)

**UI Details:**
- Progress dots indicate current step (1/4 through 4/4)
- "Continue" advances to the next step; "Skip" jumps to frequency selection
- Frequency default: Weekly
- Reminder defaults: Enabled, Morning, 8:00 AM
- "Start Learning" button finalises onboarding and navigates to Learn main screen

### 14.2 Learn Main Screen

**Flow:** Learn tab → Show weekly insights banner + clips awaiting review (or empty state)

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load learn screen | `learning_preferences` (SELECT), `clips` (SELECT WHERE reviewed = FALSE) | 🟢 Same | 🟢 Same |
| Show empty state (no clips) | — (UI only) | 🟢 Same | 🟢 Same |
| Tap "Discover Podcasts" (empty state) | — (navigate to Home/Search) | 🟢 Same | 🟢 Same |
| Show "Learn From Weekly Insights" banner | — (UI only) | 🟢 Same | 🟢 Same |
| Tap "Start Now" on banner | — (open Review Weekly Insights flow §14.3) | 🟢 Same | 🟢 Same |
| Display "Clips Waiting For Your Review" list | `clips` (SELECT), `clip_review_status` (SELECT) | 🟢 Same | 🟢 Same |
| Filter clips: All / Last 7 Days / Last 30 Days | `clips` (SELECT with date filter) | 🟢 Same | 🟢 Same |
| Tap three-dot menu on clip | — (open Clip Options §14.4) | 🟢 Same | 🟢 Same |
| Tap clip to play in mini player | `clips` (SELECT audio_url), `playback_progress` (UPDATE) | 🟢 Same | 🟢 Same |
| Tap Settings gear icon | — (navigate to Learning Settings §14.6) | 🟢 Same | 🟢 Same |

📱 Main: (545:3635, 587:21054), Empty state: (635:21061), Mini player: (700:8210)

**UI Details:**
- Header: ClipCast logo (left) + Settings gear (right)
- Banner text: "Reviewing key moments can improve long-term retention by up to 80% compared to re-listening."
- Clip list items show: artwork thumbnail with play overlay, clip title, podcast name, timestamp range (e.g., 33:12 – 33:42), three-dot overflow menu
- Mini audio player bar: clip artwork, title, podcast name, progress bar, play/pause button

### 14.3 Review Weekly Insights (Clip Review Flow)

**Flow:** "Start Now" on Learn banner → Full-screen review of unprocessed clips one-by-one → Completion screen

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open review mode | `clips` (SELECT WHERE unreviewed), `clip_review_status` (SELECT/INSERT session) | 🟢 Same | 🟢 Same |
| Show segmented progress bar (e.g., 1/15) | `clip_review_status` (SELECT count) | 🟢 Same | 🟢 Same |
| Display clip title (editable) | `clips` (SELECT title) | 🟢 Edit title | 🟢 Edit title |
| Display clip timing with audio player | `clips` (SELECT start_time, end_time, audio_url) | 🟢 Play & trim | 🟢 Play & trim |
| Adjust clip start/end via drag handles | `clips` (UPDATE start_time, end_time) | 🟢 Max 60s | 🟢 Max 60s |
| View Insights section | `clips` (SELECT ai_summary) | 🔒 Locked overlay — "Upgrade to view AI-generated Insights" | 🟢 Visible |
| View Key Takeaways section | `clips` (SELECT ai_takeaways) | 🔒 Locked overlay — "Upgrade to view AI-generated Insights" | 🟢 Visible |
| Tap premium lock → paywall | `user_subscriptions` (SELECT) | 🔒 Show paywall | — |
| Edit My Notes | `clips` (UPDATE my_notes) | 🟢 Edit | 🟢 Edit |
| Tap "Add to Collection" | — (open Add to Collection §14.5) | 🟢 Same | 🟢 Same |
| Tap "Delete Clip" | — (open Delete Confirmation §14.4) | 🟢 Same | 🟢 Same |
| Close review (X button) | `clip_review_status` (progress saved) | 🟢 Same | 🟢 Same |
| Advance to next clip | `clip_review_status` (INSERT reviewed) | 🟢 Same | 🟢 Same |
| Complete all clips → "You're All Caught Up!" | `clip_review_status` (all marked) | 🟢 Same | 🟢 Same |
| View stats on completion (This Week / Total Saved) | `clip_review_status` (aggregate), `clips` (COUNT) | 🟢 Same | 🟢 Same |
| Tap "Discover More Podcasts" | — (navigate to Home/Search) | 🟢 Same | 🟢 Same |
| Tap "View My Collections" | — (navigate to Collections tab) | 🟢 Same | 🟢 Same |

📱 Review card: (587:21387), Completion: (720:12147)

**UI Details:**
- Header: "Review Weekly Insights" title + X close button
- Segmented progress bar shows reviewed vs total (e.g., 1/15 unprocessed clips)
- Audio player: waveform visualisation, play button, start/end timestamps, drag handles (max 60s)
- Premium gating on Insights & Key Takeaways: crown icon + lock overlay with "Upgrade to view AI-generated Insights" message
- My Notes: free-text input field
- Two action buttons at bottom: "Add to Collection" (primary) + "Delete Clip" (secondary/destructive)
- Completion screen: teal checkmark, stats card, two CTAs

### 14.4 Clip Actions (from Learn)

**Flow:** Three-dot menu on clip → Clip Options bottom sheet → Action

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Clip Options bottom sheet | — (UI only) | 🟢 Same | 🟢 Same |
| Add to My Favorites | `clip_engagement` (INSERT type = 'favourite') | 🟢 Same | 🟢 Same |
| Download Clip | `user_downloads` (INSERT) | ⚡ Upgrade prompt | 🔒 Download saved |
| Delete Clip → Confirmation dialog | — (UI only) | 🟢 Same | 🟢 Same |
| Confirm Delete Clip | `clips` (DELETE), `clip_review_status` (DELETE) | 🟢 Toast "Clip is deleted" | 🟢 Toast "Clip is deleted" |
| Go to Episode | — (navigate to episode detail) | 🟢 Same | 🟢 Same |
| Go to Podcast | — (navigate to podcast detail) | 🟢 Same | 🟢 Same |
| Share Clip | — (OS share sheet, `clips.share_count` UPDATE) | 🟢 Same | 🟢 Same |

📱 Options sheet: (755:21867, 700:8165), Delete confirm: (755:21771), Delete toast: (755:21794, 624:19408)

**UI Details:**
- Bottom sheet header: clip artwork + title + podcast name + duration
- Options list: heart icon — Add to My Favorites, download icon — Download Clip, trash icon — Delete Clip, headphones icon — Go to Episode, podcast icon — Go to Podcast, share icon — Share Clip
- Delete confirmation dialog: trash icon, warning text "Are you sure you want to delete this clip?", "Delete Clip" (destructive) + Cancel buttons

### 14.5 Add to Collection (from Learn)

**Flow:** "Add to Collection" button → Collection picker → Select or create → Done

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open "Add to My Collection" sheet | `collections` (SELECT WHERE user_id) | 🟢 Same | 🟢 Same |
| Select existing collection (radio) | — (UI state) | 🟢 Same | 🟢 Same |
| Tap "Done" | `collection_clips` (INSERT) | 🟢 Toast "Clip added to collection" | 🟢 Toast "Clip added to collection" |
| Tap "Create New Collection" | — (open Create sheet) | ⚡ Check 15-collection limit | 🟢 Unlimited |
| Enter Collection Title | — (UI state) | 🟢 Same | 🟢 Same |
| Toggle "Make My Collection Private" | — (UI state, default OFF = public) | 🟢 Same | 🟢 Same |
| Tap "Create & Add Clip" | `collections` (INSERT), `collection_clips` (INSERT) | 🟢 Toast "Collection Created Successfully" | 🟢 Toast "Collection Created Successfully" |

📱 Collection picker: (587:21160, 556:3857), Create new: (556:3915), Toasts: (720:12230, 720:12082, 624:19782, 624:19424)

**UI Details:**
- Collection picker: list of existing collections with artwork, name, clip count, total duration, radio-button selection
- Create New Collection sheet: title text input, "Make My Collection Private" toggle (default OFF), "Create & Add Clip" CTA
- Free user limit: 15 collections (see §9 Collections)

### 14.6 Learning Settings

**Flow:** Settings gear on Learn screen → Learning Settings → Edit frequency / reminders

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Learning Settings | `learning_preferences` (SELECT) | 🟢 Same | 🟢 Same |
| View current frequency | `learning_preferences` (SELECT frequency) | 🟢 Same | 🟢 Same |
| View current reminder time | `learning_preferences` (SELECT reminder fields) | 🟢 Same | 🟢 Same |
| Tap "Your Insights Frequency" | — (navigate to frequency sub-screen) | 🟢 Same | 🟢 Same |
| Change frequency (Daily / Weekly / Monthly / Custom) | `learning_preferences` (UPDATE frequency) | 🟢 Same | 🟢 Same |
| Tap "Reminder Time" | — (navigate to reminder sub-screen) | 🟢 Same | 🟢 Same |
| Toggle Enable Reminders on/off | `learning_preferences` (UPDATE reminder_enabled) | 🟢 Same | 🟢 Same |
| Select Preferred Time (Morning / Afternoon / Evening / Night) | `learning_preferences` (UPDATE reminder_period) | 🟢 Same | 🟢 Same |
| Set specific Reminder Time (e.g., 8:00 AM) | `learning_preferences` (UPDATE reminder_time) | 🟢 Same | 🟢 Same |

📱 Settings: (587:21230, 556:4299), Frequency: (587:21273, 556:4569), Reminder: (587:21321, 556:4698)

**UI Details:**
- Settings screen: two tappable cards with current values and right-chevron
  - "Your Insights Frequency": e.g., "Weekly, Every Sunday"
  - "Reminder Time": e.g., "Morning, 8:00 AM"
- Frequency sub-screen: radio selection (Daily / Weekly / Monthly / Configure Custom Plan)
- Reminder sub-screen: Enable Reminders toggle, Preferred Time chips (Morning / Afternoon / Evening / Night), specific time display (e.g., 8:00 AM)
- Layouts are identical to onboarding steps 5 & 6 (reusable widget)

### 14.7 Clip Detail (from Learn)

**Flow:** Tap clip → Full clip detail screen with takeaways, transcript, notes

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open clip detail | `clips` (SELECT) | 🟢 Same | 🟢 Same |
| View audio scrubber | `clips` (SELECT audio_url, start_time, end_time) | 🟢 Play | 🟢 Play |
| View Key Takeaways | `clips` (SELECT ai_takeaways) | 🔒 Hidden or upgrade | 🟢 Bullet-point list |
| View AI Transcript | `clips` (SELECT transcript) | 🔒 Hidden or upgrade | 🟢 Quoted text block |
| View / edit My Notes | `clips` (SELECT/UPDATE my_notes) | 🟢 Edit | 🟢 Edit |
| Tap Edit (pencil icon) | `clips` (UPDATE title, description) | 🟢 Same | 🟢 Same |
| Tap Share | — (OS share sheet) | 🟢 Same | 🟢 Same |
| Tap Delete Clip | `clips` (DELETE) | 🟢 Same | 🟢 Same |
| Tap "AI Collection" | `collection_clips` (INSERT into AI-curated collection) | 🟢 Same | 🟢 Same |

📱 Detail: (749:18204)

**UI Details:**
- Header: back arrow + clip title
- Podcast info: podcast name + episode number
- Audio scrubber: start/end timestamps, progress bar, play button
- Action buttons: edit (pencil), share, play
- Key Takeaways: bullet-point list of actionable items
- AI Transcript: quoted text block
- My Notes: user-editable text section
- Bottom buttons: "Delete Clip" (destructive) + "AI Collection"

### 14.8 Offline Learn Experience

**Flow:** Network unavailable → Offline playback of downloaded clips

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Detect offline state | — (connectivity check) | 🟢 Banner shown | 🟢 Banner shown |
| Play downloaded clip audio | Local storage (downloaded clip) | ❌ No downloads | 🔒 Plays from local storage |
| Show "Show Transcript" overlay | Local cache | — | 🟢 If cached |
| Playback controls (speed, prev/next, share) | — (UI only) | — | 🟢 Same |
| Tap "AI Collection" | — (queued offline) | — | 🟢 Queued |
| Tap "View Clip Details" | Local cache | — | 🟢 If cached |

📱 Offline playback: (741:17244)

**UI Details:**
- "You're offline" banner at top of player
- Large podcast artwork with "Show Transcript" overlay button
- Playback controls: 1x speed selector, previous, play/pause, next, share
- Bottom buttons: "AI Collection" + "View Clip Details"

### 14.9 Related Screens (Collections integration from Learn)

The Learn flow frequently navigates into the Collections feature (documented in §9). Key cross-references:

| Action in Learn | Destination | Tables |
|-----------------|-------------|--------|
| "Add to Collection" | Collection picker → §9 | `collections`, `collection_clips` |
| "View My Collections" (completion) | Collections tab → §9 | `collections` |
| "AI Collection" button | AI-curated collection detail | `collections`, `collection_clips` |

📱 My Collections: (666:27736), Collection Detail: (666:27808)

**Free vs Premium difference:**
- 🔒 **AI Insights** (in review card and clip detail): Premium only — free users see locked overlay with crown icon
- 🔒 **Key Takeaways** (in review card and clip detail): Premium only — free users see locked overlay with crown icon
- 🔒 **AI Transcript** (in clip detail): Premium only — free users see upgrade prompt
- 🔒 **Download Clip** (in clip options): Premium only for offline access
- 🟢 **Clip review, title editing, audio playback/trimming, My Notes, collection management, clip actions (favourite, delete, share, navigate), learning settings, onboarding, reminders**: Available to both Free and Premium users
- ⚡ **Create New Collection**: Free users capped at 15 collections

---

## 15. Profile

> HiFi delivered: 10 online screens (1048:\*) + 12 offline screens (761:\*, 929:\*).
> Last updated: 2025-07-12

### 15.1 Profile Hub (Online)

**Flow:** Bottom nav Profile tab → Profile hub → Navigate to sub-screens

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load own profile hub | `profiles`, `user_subscriptions` (SELECT) | 🟢 Same | Shows plan + renewal date |
| Tap Notification Settings | → Navigate to §15.4 | 🟢 Same | 🟢 Same |
| Tap Gesture Controls | → Navigate to §15.5 | 🟢 Same | 🟢 Same |
| Tap Preferences | → Navigate to §15.6 | 🟢 Same | 🟢 Same |
| Tap Premium Plan | → Navigate to paywall or subscription details | Shows upgrade CTA | Shows expiry/renewal |
| Tap Suggest New Feature | → Navigate to §15.7 | 🟢 Same | 🟢 Same |
| Tap Report a Bug | → Navigate to §15.8 | 🟢 Same | 🟢 Same |
| Tap Terms & Conditions | → Navigate to T&C screen | 🟢 Same | 🟢 Same |
| Tap Logout | — (sign out via Supabase auth) | 🟢 Same | 🟢 Same |
| Tap Delete Account | → Confirm dialog → `/functions/delete-account` | 🟢 Same | 🟢 Same |

📱 Online hub (1048:15663): Sections — **Account Settings** (Notification Settings, Gesture Controls, Preferences, Premium Plan) → **Share Feedback** (Suggest New Feature, Report a Bug) → **Terms & Conditions** → **Logout** (red text) → **Delete Account** (red text).

**UI notes:**
- Header: back arrow + "Profile" title
- Premium Plan card shows gold crown icon + "Renews [date]" subtitle
- Logout and Delete Account are separate items with red text
- Bottom nav: Home, Collections, Feed, Learn

### 15.2 Profile Hub (Offline)

**Flow:** Bottom nav Profile tab (offline) → Profile hub with My Library → Navigate to local content

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load offline profile hub | Local cache / SQLite | 🟢 Same | 🟢 Same |
| Tap My Favorites | → Navigate to §15.9 | 🟢 Same | 🟢 Same |
| Tap Downloads | → Navigate to §15.10 | ❌ Empty / upgrade prompt | 🔒 Shows downloaded content |
| Tap Suggest New Feature | → Queue locally or show offline message | 🟢 Same | 🟢 Same |
| Tap Notification Settings | → Show cached settings (read-only) | 🟢 Same | 🟢 Same |
| Tap Gesture Controls | → Show cached settings (may toggle locally) | 🟢 Same | 🟢 Same |
| Tap Preferences | → Show cached settings (may toggle locally) | 🟢 Same | 🟢 Same |
| Tap Terms & Conditions | → Show cached T&C content | 🟢 Same | 🟢 Same |

📱 Offline hub (761:22189): Sections — **My Library** (My Favorites, Downloads) → **Share Feedback** (Suggest New Feature, Report a Bug) → **Account Settings** (Notification Settings, Gesture Controls, Preferences, Premium Plan, Logout).

**Offline differences:**
- My Library section appears at top (quick access to local content)
- Delete Account hidden (requires server call)
- Terms & Conditions must still be accessible from cached content
- Section order: My Library → Share Feedback → Account Settings

### 15.3 Profile Settings (Edit Profile) — Online Only

**Flow:** Profile hub → Profile Settings → Edit avatar/name/password → Save

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load profile settings | `profiles` (SELECT), follower/following counts via `follows` (COUNT) | 🟢 Same | 🟢 Same |
| Change profile picture | `profiles.avatar_url` (UPDATE), Supabase Storage (UPLOAD) | 🟢 Same | 🟢 Same |
| Edit full name | `profiles.display_name` (UPDATE) | 🟢 Same | 🟢 Same |
| Tap Followers count | → Open Followers bottom sheet (§15.3.1) | 🟢 Same | 🟢 Same |
| Tap Following count | → Open Following bottom sheet (§15.3.2) | 🟢 Same | 🟢 Same |
| Tap Change Password | → Supabase auth password reset flow | 🟢 Same | 🟢 Same |
| Tap Save Changes | `profiles` (UPDATE) | 🟢 Same | 🟢 Same |

📱 Profile Settings (1048:15791): Circular avatar with camera badge → "Change Profile Picture" link → Followers (1,234) / Following (567) stat cards → Full Name text field → Change Password row (lock icon + chevron) → Cyan "Save Changes" button.

#### 15.3.1 Followers Bottom Sheet

📱 (1048:15849): Draggable bottom sheet — "Cancel" + "Followers" header + count. Scrollable list: avatar, display name, Follow/Following toggle button.

#### 15.3.2 Following Bottom Sheet

📱 (1048:15913): Same layout as Followers — "Cancel" + "Following" header + count. All entries show "Following" button state.

### 15.4 Notification Settings

**Flow:** Profile hub → Notification Settings → Toggle preferences → Auto-save

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load notification preferences | `notification_preferences` (SELECT) | 🟢 Same | 🟢 Same |
| Toggle Review Insights Notification | `notification_preferences` (UPDATE) | 🟢 Same | 🟢 Same |
| Toggle New Episodes Release | `notification_preferences` (UPDATE) | 🟢 Same | 🟢 Same |
| Toggle Social Notifications | `notification_preferences` (UPDATE) | 🟢 Same | 🟢 Same |
| Toggle Clip Generation Notification | `notification_preferences` (UPDATE) | 🟢 Same | 🟢 Same |

📱 (1048:15977): Header "Notification Settings". Four toggle rows with title + subtitle description:
- **Review Insights Notification** — "Get notified for weekly insights review"
- **New Episodes Release** — "Get notified when new episode of your favorite podcast is released"
- **Social Notifications** — "Get notified when someone likes/comments on your shared feed"
- **Clip Generation Notification** — "Get notified when you generate clips with gesture control features"

### 15.5 Gesture Control

**Flow:** Profile hub → Gesture Control → Toggle AirPods Double Tap

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load gesture settings | `user_preferences` (SELECT) | 🟢 Same | 🟢 Same |
| Toggle AirPods Double Tap | `user_preferences.gesture_double_tap_enabled` (UPDATE) | 🟢 Same | 🟢 Same |

📱 (1048:16016): Header "Gesture Control". Single toggle row: headphones icon, "AirPods Double Tap", subtitle "Create 30s clip", toggle ON (cyan).

**Dev note (929:21019):** "Hijacking skipping backward gesture with generating a clip. Clip duration will be according to preference" — the double-tap gesture intercepts the native skip-backward action and instead generates a clip using the user's default clip length (§15.6).

### 15.6 Preferences (Default Clip Length)

**Flow:** Profile hub → Preferences → Select default clip duration

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load preferences | `user_preferences` (SELECT) | 🟢 Same | 🟢 Same |
| Select 30 seconds | `user_preferences.default_clip_length` (UPDATE → 30) | 🟢 Same | 🟢 Same |
| Select 45 seconds | `user_preferences.default_clip_length` (UPDATE → 45) | 🟢 Same | 🟢 Same |
| Select 60 seconds | `user_preferences.default_clip_length` (UPDATE → 60) | 🟢 Same | 🟢 Same |

📱 (1048:16088): Header "Preferences". Section "Default Clip Length" with subtitle "Choose your preferred clip duration for new highlights." Radio-button group:
- **30 seconds** — "Quick highlights"
- **45 seconds** — "Balanced length" (default selected, cyan ring)
- **60 seconds** — "Extended context"

### 15.7 Suggest New Feature

**Flow:** Profile hub → Suggest New Feature → Fill form → Submit

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open form | — (UI only) | 🟢 Same | 🟢 Same |
| Submit feature suggestion | `feature_suggestions` (INSERT) | 🟢 Same | 🟢 Same |
| Show success toast | — (UI: "Submitted successfully notification") | 🟢 Same | 🟢 Same |

📱 (1048:16046): Header "Suggest New Feature". Fields: **Feature Title** ("What feature would you like to see?") + **Description** multiline ("Describe your feature idea in detail. How would it work? What problem would it solve?") + Cyan "Submit" button.

📱 Success toast (1048:16128): "Submitted successfully notification" snackbar.

### 15.8 Report a Bug

**Flow:** Profile hub → Report a Bug → Fill form → Submit

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open form | — (UI only) | 🟢 Same | 🟢 Same |
| Submit bug report | `bug_reports` (INSERT) | 🟢 Same | 🟢 Same |
| Show success toast | — (UI: "Submitted successfully notification") | 🟢 Same | 🟢 Same |

📱 (1048:16067): Header "Report a Bug" (note: Figma header mislabeled as "Suggest New Feature" — content identifies this as the bug report form). Fields: **Title** ("What would you like to report") + **Description** multiline ("Describe any issues or bugs you faced while using the app") + Cyan "Submit" button.

### 15.9 My Favorites (Offline Profile)

**Flow:** Offline profile hub → My Library → My Favorites → Browse cached favourites

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load favourite podcasts | `podcast_favourites` (local cache) | 🟢 Same | 🟢 Same |
| Load favourite episodes | `episode_favourites` (local cache) | 🟢 Same | 🟢 Same |
| Tap podcast → navigate to cached podcast page | — | 🟢 Same | 🟢 Same |
| Tap episode → navigate to cached episode | — | 🟢 Same | 🟢 Same |

📱 My Favorites — Podcasts tab (761:22706): Header "My Favorites", 2 tabs (Podcasts / Episodes). Podcasts tab: list with artwork thumbnail, podcast title, episode count ("245 episodes"), heart icon.

📱 My Favorites — Episodes tab (761:22811): Same header + tabs. Episodes tab: list with artwork thumbnail, episode title, podcast name, duration ("34m"), heart icon.

### 15.10 Downloads (Offline Profile — Premium Only)

**Flow:** Offline profile hub → My Library → Downloads → Browse downloaded content by type

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load downloaded podcasts | `downloaded_podcasts` (local) | ❌ Empty / upgrade | 🔒 List shown |
| Load downloaded episodes | `downloaded_episodes` (local) | ❌ Empty / upgrade | 🔒 List shown |
| Load downloaded clips | `downloaded_clips` (local) | ❌ Empty / upgrade | 🔒 List shown |
| Load downloaded collections | `downloaded_collections` (local) | ❌ Empty / upgrade | 🔒 List shown |
| Tap content → play from local storage | — | ❌ N/A | 🔒 Plays offline |

📱 Downloads — Podcasts tab (761:22330): Header "Downloads", 4 tabs (Podcasts / Episodes / Clips / Collections). List: artwork, title, episode count, download icon.

📱 Downloads — Episodes tab (761:22424): Same header + 4 tabs. List: artwork, episode title, podcast name, duration ("34m"), download icon.

📱 Downloads — Clips tab (761:22518): Same layout. List: artwork, clip title, duration ("30 sec"), download icon.

📱 Downloads — Collections tab (761:22612): Same layout. List: artwork, collection title, clip count + total duration ("24 clips • 34m"), download icon.

📱 **Figma note (Section 2.2 Title Cards Only):** Title card 544:830 "My Profile" is now fully resolved by these 22 HiFi screens.

---

## 16. Offline Mode

**Flow:** Network unavailable → Show offline UI → Queue actions locally → Sync when back online

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Detect offline state | — (connectivity check) | 🟢 Same | 🟢 Same |
| Show offline banner | — (UI only) | 🟢 Same | 🟢 Same |
| Download episodes/clips for offline | `playback_progress`, local SQLite | ❌ Not available | 🔒 "Offline Access" |
| View previously cached content | Local cache only | 🟢 Cached data shown | 🟢 Cached + downloaded data |
| Queue clip creation offline | `offline_queue` (local INSERT) | 🟢 Same | 🟢 Same |
| Sync when network returns | `offline_queue` → server, `clips` (INSERT) | 🟢 Same | 🟢 Same |
| Show sync progress | — (UI: "Syncing 8/12 clips") | 🟢 Same | 🟢 Same |

📱 **Offline variants:** Homepage (666:29075 — shows pending clips + downloaded clips), Collections (666:27736), Collection Detail (666:27808), Social Feed (746:17336), Learn (749:17733), Search (749:18132), **Profile (761:22189 — adds My Library section)**. **Network Back (741:16912):** "Syncing 8/12 clips" progress indicator.

**Dedicated offline screen (749:18132):** ClipCast logo, "You're currently offline", "Please reconnect to the internet to review your clips and learn from weekly insights", **"Review Your Downloads"** CTA button. Bottom nav remains active (Home, Collections, Feed, Learn).

**Profile offline behaviour (761:22189):** When offline, the Profile hub adds a **My Library** section at the top with quick access to:
- **My Favorites** — cached podcast and episode favourites (§15.9)
- **Downloads** — all downloaded content across 4 tabs (§15.10, Premium only)

The following profile actions are **hidden or disabled offline:**
- **Delete Account** — requires server call, hidden from offline hub
- **Profile Settings (edit)** — requires internet, not accessible offline

The following remain accessible offline (from cached data):
- Notification Settings, Gesture Controls, Preferences — read from local cache, changes queued for sync
- Terms & Conditions — cached content displayed
- Share Feedback forms — submissions queued locally for sync when online

**Free vs Premium difference:**
- **Free:** Can view cached data offline but **cannot proactively download** episodes/clips for offline use. The "Review Your Downloads" screen would be empty.
- **Premium:** Full "Offline Access" — can download episodes and clips for offline playback. "Review Your Downloads" shows all downloaded content.

---

## 17. External Sharing

**Flow:** Clip owner → Share → Generate URL → Recipient opens web player

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Tap share button | `clips.share_token` (SELECT) | 🟢 Same | 🟢 Same |
| Generate share URL | `clips` (share_token auto-generated on INSERT) | 🟢 Same | 🟢 Same |
| Increment share count | `clips` (UPDATE share_count), `clip_engagement` (INSERT type='share') | 🟢 Same | 🟢 Same |
| Share collection | `collections` (SELECT) | 🟢 Same | 🟢 Same |
| Web player loads clip | `clips`, `episodes`, `podcasts` (SELECT via API) | 🟢 Public access | 🟢 Public access |

📱 Title card: 544:823 (Web URL Clip Player — **no HiFi yet**).

**Share Clip bottom sheet (913:12524):** Shows a clip preview card with podcast source, clip title, **waveform visualization** with timestamps (e.g. 0:24 – 0:30), and mini playback controls. Share options: **Copy Link** · **Whatsapp** · **More**.

**Share Collection bottom sheet (913:12621):** Shows a collection preview card (name, clip count, duration). Share options: Copy Link · Whatsapp · More. _(Note: Lo-Fi text reads "Share your clip with" even for collections — likely a design text error.)_

---

## 18. Settings & Account Management

> Consolidated with Profile feature — most settings are sub-screens of the Profile hub (§15).

**Flow:** Profile hub → Manage subscription, notifications, account deletion

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| View subscription status | `user_subscriptions` (SELECT) | Shows "Free" tier | Shows plan details + expiry ("Renews Feb 15, 2025") |
| Manage subscription | — (RevenueCat native UI) | Upgrade prompt | Cancel/restore options |
| Notification preferences | `notification_preferences` (SELECT/UPDATE) — 4 toggles (§15.4) | 🟢 Same | 🟢 Same |
| Gesture controls | `user_preferences` (SELECT/UPDATE) — AirPods Double Tap (§15.5) | 🟢 Same | 🟢 Same |
| Clip length preferences | `user_preferences` (SELECT/UPDATE) — 30s/45s/60s (§15.6) | 🟢 Same | 🟢 Same |
| Edit profile (avatar, name) | `profiles` (UPDATE) — online only (§15.3) | 🟢 Same | 🟢 Same |
| Change password | Supabase auth — online only (§15.3) | 🟢 Same | 🟢 Same |
| View Terms & Conditions | — (static content, both modes) | 🟢 Same | 🟢 Same |
| Suggest feature / Report bug | `feature_suggestions` / `bug_reports` (INSERT) (§15.7, §15.8) | 🟢 Same | 🟢 Same |
| Delete account (GDPR) | All user tables (CASCADE DELETE via Edge Function) — online only | 🟢 Same | 🟢 Same |
| Export data (GDPR) | All user tables (SELECT via Edge Function → JSON) | 🟢 Same | 🟢 Same |
| Logout | — (Supabase auth sign out) | 🟢 Same | 🟢 Same |

📱 **Profile hub screens:** Online (1048:15663), Offline (761:22189). **Sub-screens:** Profile Settings (1048:15791), Notification Settings (1048:15977), Gesture Control (1048:16016), Preferences (1048:16088), Suggest Feature (1048:16046), Report Bug (1048:16067), Followers (1048:15849), Following (1048:15913).

**New tables required:** `notification_preferences`, `user_preferences`, `feature_suggestions`, `bug_reports`, `episode_favourites`, `downloaded_podcasts`, `downloaded_episodes`, `downloaded_clips`, `downloaded_collections`. See ERD.md for full schema.

---

## 19. Episode Details

> **NEW intermediate screen** between Podcast Page and Episode Player. The Episode Details page provides a deep-dive into a single episode — showing metadata, transcript, chapters, clips, and more — before the user commits to full playback.

**Navigation flow:** Podcast Page (episode card tap) → **Episode Details** → tap Play → Episode Player (full-screen)

### 19.1 Episode Details — Main Page

**Flow:** Tap episode card on Podcast Page → Episode Details with metadata, description, and sub-sections

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load episode metadata (title, author, date, duration, artwork) | `episodes` JOIN `podcasts` (SELECT) | 🟢 Same | 🟢 Same |
| Display episode tag (e.g. "Time Management") | `episodes.categories` or `podcasts.categories` (SELECT) | 🟢 Same | 🟢 Same |
| Display episode artwork (large) | `episodes.artwork_url` or `podcasts.artwork_url` (SELECT) | 🟢 Same | 🟢 Same |
| Display description text | `episodes.description` (SELECT) | 🟢 Same | 🟢 Same |
| Tap download icon | `user_downloads` (INSERT) + local storage | ❌ Shows download upsell (§19.7) | 🔒 Downloads episode locally |
| Tap share icon | — (share sheet) | 🟢 Same | 🟢 Same |
| Tap ⋯ icon → Episode More Details sheet | — (UI, opens §19.6) | 🟢 Same | 🟢 Same |
| Tap play button (cyan CTA) | — (navigate to Episode Player §5) | 🟢 Same | 🟢 Same |
| Tap "Episode Transcript >" row | — (navigate to §19.2) | 🟢 Same | 🟢 Same |
| Tap "Clips >" row | — (navigate to §19.4) | 🟢 Same | 🟢 Same |
| Tap Episode Chapters inline list | — (navigate to §19.3) | 🟢 Same | 🟢 Same |

📱 **First-time user:** Episode Details (202:4218), Playing State (202:4466). **Free user:** Episode Details (565:4920), Playing State (566:22164). **Paid user:** Episode Details (565:5135), Playing State (566:22375).

**Episode Details layout (not playing):**
```
      ←  Episode Details
   ┌───────────────────────────┐
   │    [Episode Artwork]      │
   │                           │
   └───────────────────────────┘
   Time Management                    (tag)
   #217 - The Art of Negotiation      (title)
   Chris Williamson                   (author)
   Dec 11, 2025 · 1h 34m             (date · duration)

   ⬇ download   ↗ share   ⋯ more    [▶ Play] (cyan)

   Episode description paragraph text…

   Episode Transcript                     >
   Clips                                  >
   Episode Chapters
     [Ch thumbnail] 01 - Introduction…
     [Ch thumbnail] 02 - The Psychology…
     [Ch thumbnail] 03 - Real World…
```

### 19.1.1 Episode Details — Playing State

When an episode is actively playing, the Episode Details page reflects playback state:

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Show pause icon instead of play button | — (UI, player state) | 🟢 Same | 🟢 Same |
| Display "30m left" remaining time | `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |
| Display progress bar under action row | `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |

📱 Playing state: First-time (202:4466), Free (566:22164), Paid (566:22375).

**Playing state differences from non-playing:**
```
   ⬇ download   ↗ share   ⋯ more    [⏸ Pause] (cyan)
   30m left  ━━━━━━━━━━━━━━━○━━━━   (progress bar)
```

### 19.2 Episode Transcript View

**Flow:** Episode Details → Tap "Episode Transcript >" → Full transcript with speaker segments and timestamps

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load transcript segments | `episode_transcripts` (SELECT WHERE episode_id ORDER BY segment_order) | 🟢 Same | 🟢 Same |
| Display speaker name per segment | `episode_transcripts.speaker_name` (SELECT) | 🟢 Same | 🟢 Same |
| Display segment timestamp | `episode_transcripts.start_time` (SELECT) | 🟢 Same | 🟢 Same |
| Display segment content text | `episode_transcripts.content` (SELECT) | 🟢 Same | 🟢 Same |
| Tap timestamp → Seek player to that position | — (client-side `just_audio` seek) | 🟢 Same | 🟢 Same |
| Mini player bar at bottom (when playing) | `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |

📱 **First-time user:** Transcript (202:4570). **Free user:** Transcript (565:5052). **Paid user:** Transcript (565:5270).

> **Access:** Episode-level transcripts are **free for all users** (distinct from clip-level AI transcripts which are Premium-gated).

**Transcript layout:**
```
      ←  Episode Transcript

   Chris Williamson                    00:00
   Welcome everyone to Modern Wisdom.
   Today we're diving deep into the art
   of negotiation...

   Chris Williamson                    00:15
   Before we begin, I want to share a
   quick story about…

   Dr. Sarah Chen                      00:35
   Thanks for having me, Chris. I've
   spent the last 15 years studying…

   ─────────────────────────────────────
   [Mini Player: "The Future of AI" ▶ ━━○━━]
```

> **Data source (dev note 925:14290):** "Transcripts should be extracted from the RSS feed if available (via transcript tags). If not available, transcripts can be generated automatically from the episode audio using speech-to-text."

**New table required:** `episode_transcripts` — see ERD.md for full schema. Separate table chosen over JSONB for scalability (episodes can have hours of content with thousands of segments).

### 19.3 Episode Chapters View

**Flow:** Episode Details → Tap chapter or navigate to chapters view → Numbered chapter list with thumbnails

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load chapter list | `episodes.chapters` (SELECT JSONB) | 🟢 Same | 🟢 Same |
| Display chapter number, title, description, timestamp | — (parse JSONB) | 🟢 Same | 🟢 Same |
| Display chapter thumbnail | — (chapter image from JSONB) | 🟢 Same | 🟢 Same |
| Tap chapter → Seek player to chapter start time | — (client-side `just_audio` seek) | 🟢 Same | 🟢 Same |
| Mini player bar at bottom (when playing) | `playback_progress` (SELECT) | 🟢 Same | 🟢 Same |

📱 **First-time user:** Chapters (202:4676). **Free user:** Chapters (565:5182). **Paid user:** Chapters (565:5480).

**Chapters layout:**
```
      ←  Episode Chapters

   [Thumb] 01 - Introduction to Negotiation
           Setting the stage for effective        0:00
           communication strategies…

   [Thumb] 02 - The Psychology Behind Deals
           Understanding cognitive biases          12:30
           and emotional triggers…

   [Thumb] 03 - Real World Applications
           From salary negotiations to             23:12
           international diplomacy…

   [Thumb] 04 - Building Long-term Relations
           How to create win-win outcomes          38:45
           that last beyond the deal…

   [Thumb] 05 - Mastering the Art of Silence
           Using strategic pauses and              52:18
           active listening techniques…

   ─────────────────────────────────────
   [Mini Player: "The Art of…" ⏸ ━━━━○━━]
```

> **Data source (dev note 925:14291):** "Chapters can be extracted from the RSS feed if the podcast provides chapter metadata. If chapters are not included, they can be generated automatically from the transcript or audio."

### 19.4 Episode Clips View — Trendy Clips & My Clips

**Flow:** Episode Details → Tap "Clips >" → Trendy clips list → Filter to My Clips

This view shows clips associated with the **entire podcast** (not just the current episode). "My Clips" is a separate filtered page showing only the current user's clips for this episode.

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Load trending clips for podcast | `clips` JOIN `episodes` (SELECT WHERE podcast_id ORDER BY engagement DESC) | 🟢 Same | 🟢 Same |
| Display clip cards (social-card style) | `clips`, `profiles` (SELECT) | 🟢 Same | 🟢 Same |
| Display clip author avatar + username | `profiles` (SELECT) | 🟢 Same | 🟢 Same |
| Tap "Follow" on clip author | `follows` (INSERT) | 🟢 Same | 🟢 Same |
| Tap clip → Clip Detail (§8) | `clips` (SELECT) | 🟢 Same (AI blurred) | 🟢 Full AI content |
| Tap filter icon → Filter & Sort sheet (§19.5) | — (UI) | 🟢 Same | 🟢 Same |
| Filter: Trendy Clips (default) | `clips` (SELECT ORDER BY engagement DESC) | 🟢 Same | 🟢 Same |
| Filter: My Clips → separate page | `clips` (SELECT WHERE user_id = auth.uid() AND episode_id) | 🟢 Same | 🟢 Same |
| Sort: Newest / Oldest | `clips` (ORDER BY created_at DESC/ASC) | 🟢 Same | 🟢 Same |

📱 **First-time user:** Clips (202:4787). **Free user:** Clips (565:5362), My Clips (564:22482). **Paid user:** Clips (565:5587).

> **Clip aggregation (dev note 564:19218):** "Algorithm will aggregate overlapping clips within a 5–10 second window to detect viral moments."

**Clip card anatomy:**
```
[Avatar] Sarah Mitchell @sarahtech        [Follow]
[Thumbnail with ▶ overlay]
The Power of Strategic Silence
When Chris asked about the moment
that changed everything…
Modern Wisdom • #217                    2 days ago
```

### 19.5 Filter & Sort Sheet (Clips)

**Flow:** Clips view → Tap filter icon → Bottom sheet with filter and sort options

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Filter & Sort sheet | — (UI) | 🟢 Same | 🟢 Same |
| Select filter: Trendy Clips (default ✓) | — (UI state) | 🟢 Same | 🟢 Same |
| Select filter: My Clips | — (UI state, navigates to My Clips page) | 🟢 Same | 🟢 Same |
| Select sort: Newest | — (ORDER BY created_at DESC) | 🟢 Same | 🟢 Same |
| Select sort: Oldest | — (ORDER BY created_at ASC) | 🟢 Same | 🟢 Same |
| Tap "Cancel" | — (dismiss sheet) | 🟢 Same | 🟢 Same |

📱 **First-time user:** Filter sheet (202:4900). **Free user:** Filter sheet (564:19750, 564:22621). **Paid user:** Filter sheet (564:20184).

**Filter & Sort sheet layout:**
```
                    Filter and Sort            Cancel
─────────────────────────────────────────────────────
Filter
  Trendy Clips ✓
  My Clips
─────────────────────────────────────────────────────
Sort
  Newest
  Oldest
```

### 19.6 Episode More Details Sheet

**Flow:** Episode Details → Tap ⋯ icon → Bottom sheet with episode actions

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Open Episode More Details sheet | — (UI) | 🟢 Same | 🟢 Same |
| "Add to My Favorites" | `episode_favourites` (INSERT / DELETE) | 🟢 Same | 🟢 Same |
| "Download Episode" | `user_downloads` (INSERT) + local storage | ❌ Shows download upsell (§19.7) | 🔒 Downloads episode locally |
| "Podcast Details" | — (navigate to Podcast Page §4) | 🟢 Same | 🟢 Same |

📱 **First-time user:** More Details (203:5007). **Free user:** More Details (702:11387). **Paid user:** More Details (702:11387).

**Episode More Details sheet layout:**
```
          ━━━━━━━━━━━━━━━━              (drag handle)
   [Thumb] #217 - The Art of Negotiation
           Chris Williamson

   ♥  Add to My Favorites
   ⬇  Download Episode
   🎧 Podcast Details
                                        (home indicator)
```

### 19.7 Download Upsell Sheet (Free Users)

**Flow:** Free user taps download (on Episode Details or More Details sheet) → Upsell bottom sheet

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Show download upsell sheet | — (UI) | ⚡ Shown | 🟢 N/A (downloads directly) |
| Tap "Explore Premium" | — (navigate to paywall) | ⚡ Opens paywall | — |
| Tap "Cancel" | — (dismiss sheet) | 🟢 Dismiss | — |

📱 **First-time user:** Download upsell (203:5125). **Free user:** Reuses existing upsell (588:36291). **Paid user:** N/A (downloads directly).

> This is the same upsell sheet as §4.6 but triggered from Episode Details context.

**Download upsell layout:**
```
      [Download icon with lock badge]
   Want to Download Episodes?
   Download episodes and play them
   anytime when you're offline with premium.

       [ Explore Premium ]
            Cancel
```

### 19.8 Offline Episode Player

**Flow:** Premium user offline → Opens downloaded episode → Full offline playback with clip generation

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Display "You're offline" banner with indicator dot | — (UI, connectivity state) | ❌ N/A (no offline episodes) | 🟢 Shown |
| Show "Downloaded" green badge + podcast name | `downloaded_episodes` (SELECT) | — | 🟢 Shown |
| Display large episode artwork with "Show Chapters" & "Show Transcript" overlay buttons | `episodes` (local cache) | — | 🟢 Same |
| Display episode title | `episodes.title` (local cache) | — | 🟢 Shown |
| Display waveform progress bar (e.g. 32:15 / 74:44) | `playback_progress` (local) | — | 🟢 Same |
| Playback controls (1x speed, skip-back 30s, play/pause, skip-forward 30s, share) | — (client-side `just_audio`) | — | 🟢 Same |
| Tap "✂ Generate Clip" CTA | — (client-side clip extraction from ring buffer) | — | 🟢 Generates clip locally |
| Display clip quota card ("You have 10 Clips available 10/12") | `clip_quotas` or `app_config` (SELECT) + local tracking | — | 🟢 Shown |
| Display fair usage policy text | — (UI) | — | 🟢 Shown |

📱 **Offline Episode Player:** (739:15744). Premium-only screen.

> **Clip quota:** Default limit is 12 clips per podcast. This value must be **dynamic and configurable** server-side (stored in `app_config` or `clip_quotas` table) so business changes do not require a code update.

**Offline Episode Player layout:**
```
   ● You're offline                    (banner)

   ● Downloaded  Modern Wisdom         (green dot)
   ┌───────────────────────────────────┐
   │                                   │
   │    [Episode Artwork]              │
   │         Show Chapters             │
   │         Show Transcript           │
   │                                   │
   └───────────────────────────────────┘
   #217 - The Art of Negotiation
   & Persuasion

   32:15  ≋≋≋≋≋≋≋≋≋≋●≋≋≋≋≋≋  74:44   (waveform)

     1x    ⏮30   ▶   ⏭30   ↗

   ┌───────────────────────────────────┐
   │  ✂ Generate Clip                  │  (cyan CTA)
   │  We will clip the previous 30     │
   │  seconds from this podcast        │
   └───────────────────────────────────┘

   You have 10 Clips available  10/12  ━━━━━━━━○━━
   To comply with fair usage policy for the
   podcaster, we have to limit the number
   of clips per podcast
```

### 19.9 Offline Clip Generation Success

**Flow:** Premium user offline → Generates clip → Success confirmation bottom sheet

| Step | Tables | Free | Premium |
|------|--------|------|---------|
| Display success bottom sheet with check icon | — (UI) | — | 🟢 Shown |
| Show "Clip Generated and will be synced when your connection is back!" | — (UI) | — | 🟢 Shown |
| Show "Clip will be added to your 'Learn' collection when your connection is back" | — (UI) | — | 🟢 Shown |
| Display clip title preview | `clips.title` (local INSERT) | — | 🟢 Shown |
| Tap "Review Now" | — (navigate to local clip detail) | — | 🟢 Available |

📱 **Offline Clip Success:** (739:15866). Premium-only sheet.

**Offline Clip Success layout:**
```
          ━━━━━━━━━━━━━━━━              (drag handle)

              ✓                         (check icon)
   Clip Generated and will be
   synced when your connection
   is back!

   Clip will be added to your 'Learn'
   collection when your connection
   is back

   "The Power of Strategic Silence
    in Negotiations"                    (clip title)

         [ Review Now ]                 (CTA)
```

> **Sync behaviour:** Offline-generated clips are queued locally with `sync_status='local'`. On reconnect, the standard clip sync flow (§6) uploads them to storage and triggers AI processing. The clip is automatically added to the user's "Learn" collection.

---

## Summary: Free vs Premium Feature Matrix

| Feature | Free | Premium ($49/yr) |
|---------|------|-------------------|
| Podcast discovery & search | ✅ Full access | ✅ Full access |
| Episode playback (§5) | ✅ With audio ads (after 4–5 clips listened) | ✅ Ad-free |
| Episode Player — chapters overlay (§5.2) | ✅ Full access | ✅ Full access |
| Episode Player — transcript overlay (§5.3) | ✅ Full access | ✅ Full access |
| Episode Player — waveform + dots (§5.1) | ✅ Full access | ✅ Full access |
| Episode Player — ⋯ more menu (§5.7) | ✅ Same (Download triggers upsell) | ✅ Same (Download works) |
| Episode Player — episode complete (§5.8) | ✅ Same | ✅ Same |
| Episode Player — audio feedback (§5.9) | ✅ Same | ✅ Same |
| Episode Player — first-time tooltips (§5.10) | ✅ Shown once | ✅ Shown once |
| Clip capture (§5.4/§6) | ⚡ 3–5 per episode | ✅ Unlimited |
| Clip success — Review Now (§5.4) | ❌ Auto-dismiss (no review) | ✅ Review Now button |
| Clip review with AI (§5.5) | ❌ Not accessible | ✅ Full review (takeaways/transcript) |
| Audio ads (§5.6) | ⚡ 6–10s after 4–5 clips listened | ✅ No ads |
| AI Transcription (clip-level) | 🔒 Blurred in UI (Lo-Fi) | ✅ Transcript (15h/mo) |
| AI Insights & Takeaways | 🔒 Blurred in UI (Lo-Fi) | ✅ Full AI summaries |
| Social Feed clips | ✅ Visible | ✅ Visible |
| Social Feed KEY TAKEAWAYS | 🔒 Blurred + lock overlay | ✅ Fully readable |
| My Feed cards | ✅ Compact (no takeaways) | ✅ Full (with takeaways) |
| Collections | ⚡ 15 collections max | ✅ Unlimited collections |
| Follow / engage | ✅ Full access | ✅ Full access |
| Offline download | ❌ Not available | ✅ Full offline access |
| External sharing | ✅ Full access | ✅ Full access |
| Notifications | ✅ Full access | ✅ Full access |
| Profile hub (online) | ✅ Full access | ✅ Full access |
| Profile settings (edit) | ✅ Full access | ✅ Full access |
| Notification preferences | ✅ 4 toggles | ✅ 4 toggles |
| Gesture control | ✅ AirPods Double Tap | ✅ AirPods Double Tap |
| Clip length preference | ✅ 30s/45s/60s | ✅ 30s/45s/60s |
| Episode favourites | ✅ Full access | ✅ Full access |
| My Favorites (offline) | ✅ Cached favourites | ✅ Cached favourites |
| Downloads (offline) | ❌ Empty / upgrade prompt | ✅ 4-tab downloaded content |
| Suggest feature / report bug | ✅ Full access | ✅ Full access |
| Terms & Conditions | ✅ Both modes | ✅ Both modes |
| Delete Account | ✅ Online only | ✅ Online only |
| Episode Details page (§19) | ✅ Full access | ✅ Full access |
| Episode Transcript (§19.2) | ✅ Free for all users | ✅ Free for all users |
| Episode Chapters (§19.3) | ✅ Full access | ✅ Full access |
| Episode Clips / My Clips (§19.4) | ✅ Full access (AI blurred) | ✅ Full AI content |
| Episode download (§19.6/§19.7) | ❌ Upsell to Premium | ✅ Downloads directly |
| Offline Episode Player (§19.8) | ❌ N/A | ✅ Full offline playback + clip generation |
| Clip quota per episode (§5.4.1/§19.8) | ⚡ 3–5 per episode | ✅ Unlimited (configurable future limit) |

---

## Appendix: Complete Figma Frame Inventory

### HiFi Mobile Screens (42 unique frames)

| # | Node ID | Name | Size | Variant / State |
|---|---------|------|------|-----------------|
| 1 | 544:1559 | Homepage | 375×1415 | Normal (logged in) |
| 2 | 666:29075 | Homepage | 375×1615 | Offline mode |
| 3 | 741:16912 | Homepage - Network Back | 375×1559 | Syncing (8/12 clips) |
| 4 | 588:43549 | Homepage | 375×1401 | New user |
| 5 | 662:22577 | Explore Premium | 375×1050 | Paywall ($49/yr) |
| 6 | 545:3635 | Learn | 375×884 | Normal |
| 7 | 749:17733 | Learn | 375×884 | Offline |
| 8 | 545:4442 | Collections | 375×853 | Normal |
| 9 | 666:27736 | Collections | 375×853 | Offline |
| 10 | 549:6537 | Collection Detail | 375×853 | With clips |
| 11 | 666:27808 | Collection Detail | 375×853 | Offline |
| 12 | 586:9879 | Collection Detail | 375×853 | Empty state |
| 13 | 557:7282 | Unprocessed Clips Collection | 375×853 | Special (12 clips, 1h 34m) |
| 14 | 553:12548 | Collection Detail | 375×819 | Curated ("AI for beginners") |
| 15 | 680:31417 | Social Feed - Trending | 375×1909 | Premium |
| 16 | 925:14386 | Social Feed - Trending | 375×1909 | Free (gated takeaways) |
| 17 | 912:11638 | Social Feed - Friends | 375×1909 | Premium |
| 18 | 925:14573 | Social Feed - Friends | 375×1909 | Free (gated takeaways) |
| 19 | 912:12148 | Social Feed - My Feed | 375×1766 | Premium |
| 20 | 925:14748 | Social Feed - My Feed | 375×1532 | Free (no takeaways) |
| 21 | 746:17336 | Social Feed | 375×853 | Offline |
| 22 | 548:5047 | Podcast Page | 375×1006 | Normal ("Modern Wisdom") |
| 23 | 666:27547 | Podcasts Page | 376×945 | Variant |
| 24 | 545:2930 | Search | 375×1205 | Browse mode |
| 25 | 749:18132 | Search | 375×884 | Offline |
| 26 | 557:7466 | Search | 375×885 | Active search + keyboard |
| 27 | 558:12125 | Search | 375×885 | Results for "Elon" |
| 28 | 549:7221 | Search - Podcasts | 375×1107 | Podcasts sub-page |
| 29 | 551:8195 | Search - Clips | 375×1107 | Clips sub-page |
| 30 | 552:10798 | Search - Clips - Category | 375×1273 | Technology clips |
| 31 | 553:11561 | Search - Clips - Category | 375×1273 | Technology podcasts variant |
| 32 | 549:7495 | Search - Podcasts - Category | 375×1107 | Technology Podcasts |
| 33 | 554:1512 | User Clip Details | 375×1001 | Clip detail with AI sections |
| 34 | 555:2787 | User Clip Player | 375×819 | Full-screen player |
| 35 | 561:15105 | Play Clips in Collection | 375×863 | Collection player (Next/Prev) |
| 36 | 549:6040 | Create New Collection | 373×344 | Bottom sheet overlay |
| 37 | 556:7255 | Edit Collection Details | 373×266 | Bottom sheet overlay |
| 38 | 555:2690 | Copy Collection | 373×680 | Bottom sheet with clip selection |
| 39 | 555:1721 | Add Clip to Collection | 373×581 | Bottom sheet with collection list |

### Profile HiFi Screens (22 frames — online + offline)

**Online Mode (10 screens)**

| # | Node ID | Name | Dimensions | Notes |
|---|---------|------|-----------|-------|
| 40 | 1048:15663 | Profile Hub (Online) | 375×884 | Account Settings, Share Feedback, T&C, Logout, Delete Account |
| 41 | 1048:15791 | Profile Settings | 375×884 | Avatar, name, password, followers/following |
| 42 | 1048:15849 | Followers Bottom Sheet | 375×650 | Scrollable list with Follow/Following buttons |
| 43 | 1048:15913 | Following Bottom Sheet | 375×650 | Scrollable list with Following buttons |
| 44 | 1048:15977 | Notification Settings | 375×884 | 4 toggles: Review Insights, New Episodes, Social, Clip Generation |
| 45 | 1048:16016 | Gesture Control | 375×884 | AirPods Double Tap toggle |
| 46 | 1048:16046 | Suggest New Feature | 375×884 | Feature Title + Description + Submit |
| 47 | 1048:16067 | Report a Bug | 375×884 | Title + Description + Submit (header mislabeled in Figma) |
| 48 | 1048:16088 | Preferences | 375×884 | Default Clip Length: 30s/45s/60s radio |
| 49 | 1048:16128 | Success Toast | — | "Submitted successfully notification" |

**Offline Mode (12 screens)**

| # | Node ID | Name | Dimensions | Notes |
|---|---------|------|-----------|-------|
| 50 | 761:22189 | Profile Hub (Offline) | 375×884 | My Library + Share Feedback + Account Settings |
| 51 | 761:22706 | My Favorites - Podcasts | 375×884 | 2 tabs, podcast list with hearts |
| 52 | 761:22811 | My Favorites - Episodes | 375×884 | 2 tabs, episode list with hearts |
| 53 | 761:22330 | Downloads - Podcasts | 375×884 | 4 tabs, podcast list with download icons |
| 54 | 761:22424 | Downloads - Episodes | 375×884 | 4 tabs, episode list |
| 55 | 761:22518 | Downloads - Clips | 375×884 | 4 tabs, clip list (30 sec) |
| 56 | 761:22612 | Downloads - Collections | 375×884 | 4 tabs, collection list (24 clips • 34m) |
| 57 | 761:22916 | Notification Settings (Offline) | 375×884 | 3 toggles (superseded by online version §15.4) |
| 58 | 761:22950 | Gesture Control (Offline) | 375×884 | AirPods Triple Tap (superseded — correct is Double Tap) |
| 59 | 761:22980 | Suggest New Feature (Offline) | 375×884 | Same form layout |
| 60 | 761:23001 | Preferences (Offline) | 375×884 | Same 30s/45s/60s radio |
| 61 | 929:21019 | Dev Note - Gesture | — | "Hijacking skipping backward gesture with generating a clip" |

### Title Cards Only (no HiFi — design gaps)

| # | Node ID | Name | Notes |
|---|---------|------|-------|
| T1 | 544:814 | Podcast Page | HiFi exists (548:5047) |
| T2 | 544:817 | Episode Details | ✅ **RESOLVED** — Lo-Fi wireframes delivered: 32 designs across 4 user flows (see Lo-Fi Episode Details section below) |
| T3 | 567:25285 | Episode Player | **No HiFi — BLOCKER for Phase 1** |
| T4 | 544:823 | Web URL Clip Player | **No HiFi — needed for sharing** |
| T5 | 544:826 | Social Feed | HiFi exists (multiple variants) |
| T6 | 544:830 | My Profile | ✅ **RESOLVED** — HiFi delivered: 10 online screens (1048:*) + 12 offline screens (761:*, 929:*) |
| T7 | 544:834 | Authentication | **No HiFi — BLOCKER for Phase 1** |
| T8 | 544:837 | Lock Screen | **No HiFi — needs design** |

### Lo-Fi Episode Details Screens (32 frames across 4 user flows)

> These are Lo-Fi wireframes confirming the Episode Details feature. HiFi designs are still pending.

**First-Time User (7 frames)**

| # | Node ID | Name | Notes |
|---|---------|------|-------|
| L1 | 202:4218 | Episode Details | Main page (not playing) |
| L2 | 202:4466 | Episode Details (Playing) | Pause icon + "30m left" progress bar |
| L3 | 202:4570 | Episode Transcript | Speaker segments with timestamps |
| L4 | 202:4676 | Episode Chapters | 5 chapters with thumbnails |
| L5 | 202:4787 | Episode Clips (Trendy) | Social-card clip list |
| L6 | 202:4900 | Filter & Sort (Clips) | Trendy Clips / My Clips + Newest / Oldest |
| L7 | 203:5007 | Episode More Details | Add to Favorites, Download, Podcast Details |

**Free User (12 frames)**

| # | Node ID | Name | Notes |
|---|---------|------|-------|
| L8 | 565:4920 | Episode Details | Main page (not playing) |
| L9 | 566:22164 | Episode Details (Playing) | Pause icon + progress bar |
| L10 | 565:5052 | Episode Transcript | Speaker segments with timestamps |
| L11 | 565:5182 | Episode Chapters | 5 chapters with thumbnails |
| L12 | 565:5362 | Episode Clips (Trendy) | Social-card clip list |
| L13 | 564:22482 | Episode Clips (My Clips) | Filtered to user's clips |
| L14 | 564:19750 | Filter & Sort (Clips) | Filter + Sort options |
| L15 | 564:22621 | Filter & Sort (My Clips) | My Clips selected |
| L16 | 702:11387 | Episode More Details | Add to Favorites, Download, Podcast Details |
| L17 | 203:5125 | Download Upsell | "Want to Download Episodes?" + Explore Premium |
| L18 | 564:19218 | Dev Note — Clip Aggregation | "Algorithm will aggregate overlapping clips within 5–10s window" |
| L19 | 925:14289 | Dev Note — Episode Tags | "Tags extracted from RSS feed category/keyword fields" |

**Paid User (11 frames)**

| # | Node ID | Name | Notes |
|---|---------|------|-------|
| L20 | 565:5135 | Episode Details | Main page (not playing) |
| L21 | 566:22375 | Episode Details (Playing) | Pause icon + "30m left" progress bar |
| L22 | 565:5270 | Episode Transcript | Speaker segments with timestamps + mini player |
| L23 | 565:5480 | Episode Chapters | 5 chapters with timestamps + mini player |
| L24 | 565:5587 | Episode Clips (Trendy) | Social-card clip list |
| L25 | 564:20184 | Filter & Sort (Clips) | Filter + Sort options |
| L26 | 702:11387 | Episode More Details | Add to Favorites, Download, Podcast Details |
| L27 | 925:14290 | Dev Note — Transcript Source | "Extract from RSS feed; fallback to speech-to-text" |
| L28 | 925:14291 | Dev Note — Chapters Source | "Extract from RSS feed; fallback to auto-generation" |
| L29 | 564:19218 | Dev Note — Clip Aggregation | "Aggregate overlapping clips in 5–10s window" |

**Offline Mode (2 frames — Premium only)**

| # | Node ID | Name | Notes |
|---|---------|------|-------|
| L30 | 739:15744 | Offline Episode Player | "You're offline" banner, waveform, Generate Clip CTA, clip quota 10/12 |
| L31 | 739:15866 | Offline Clip Success | Bottom sheet: "Clip Generated and will be synced", Review Now CTA |

# ClipCast — Service Access & Credentials Checklist

> Tracks every external service account, API key, and credential required before
> development can begin. Checkboxes indicate readiness status.  
> Last updated: 2025-06-29

---

## How to Use

1. Create accounts below **before** Phase 1 development begins.
2. Store all secrets in Supabase Edge Function secrets (`supabase secrets set`).
3. Client-side keys go in `.env` / build configs — never hardcode.
4. Mark each checkbox when the credential is obtained and configured.

---

## 1. Supabase

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] Create Supabase project (Frankfurt region) | | Backend | Region: `eu-central-1` for Egypt/GCC latency |
| [ ] Note Project URL | | Backend | `https://<ref>.supabase.co` |
| [ ] Note `anon` (public) key | | Client | Used in `supabase_flutter` init |
| [ ] Note `service_role` key | | Backend | **Never expose to client** — Edge Functions only |
| [ ] Enable Email auth provider | | Backend | For email/password sign-in |
| [ ] Configure Google OAuth provider | | Backend | Needs Google Cloud Console credentials |
| [ ] Configure Apple OAuth provider | | Backend | Needs Apple Developer credentials |
| [ ] Enable Row-Level Security on all tables | | Backend | See `RLS.md` |
| [ ] Run DDL migrations | | Backend | See `ERD.md` for full schema |
| [ ] Set up Edge Functions runtime | | Backend | Deno runtime, for all server-side logic |
| [ ] Configure `pg_cron` extension | | Backend | For scheduled Taddy refresh jobs |

### Supabase Secrets to Set

```bash
supabase secrets set \
  TADDY_USER_ID=<value> \
  TADDY_API_KEY=<value> \
  OPENAI_API_KEY=<value> \
  ONESIGNAL_APP_ID=<value> \
  ONESIGNAL_REST_API_KEY=<value> \
  RESEND_API_KEY=<value> \
  AWS_ACCESS_KEY_ID=<value> \
  AWS_SECRET_ACCESS_KEY=<value> \
  AWS_S3_BUCKET=<value> \
  AWS_CLOUDFRONT_DISTRIBUTION_ID=<value> \
  REVENUECAT_WEBHOOK_AUTH_TOKEN=<value>
```

---

## 2. Google Sign-In

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] Google Cloud Console project created | | Client | Or reuse existing Firebase project |
| [ ] OAuth 2.0 Client ID — iOS | | Client | Bundle ID: `com.clipcast.app` |
| [ ] OAuth 2.0 Client ID — Android | | Client | SHA-1 fingerprint from keystore |
| [ ] OAuth 2.0 Client ID — Web | | Backend | Used by Supabase as the OAuth provider |
| [ ] Add redirect URL to Supabase dashboard | | Backend | `https://<ref>.supabase.co/auth/v1/callback` |
| [ ] Test sign-in flow end-to-end | | QA | Both platforms |

### Client-Side Config

- **Package:** `google_sign_in`
- **iOS:** Add client ID to `Info.plist` (`GIDClientID` + `CFBundleURLSchemes`)
- **Android:** Place `google-services.json` (or set `serverClientId` in code)

---

## 3. Apple Sign-In

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] Apple Developer account (paid) | | Client | Required for Sign in with Apple |
| [ ] Register App ID with Sign in with Apple capability | | Client | `com.clipcast.app` |
| [ ] Create Services ID for web auth | | Backend | For Supabase callback |
| [ ] Generate private key (`.p8` file) | | Backend | For server-side token verification |
| [ ] Add redirect URL to Supabase dashboard | | Backend | Same callback URL as Google |
| [ ] Test sign-in flow end-to-end | | QA | iOS only (Android uses web flow) |

### Client-Side Config

- **Package:** `sign_in_with_apple`
- **iOS:** Enable "Sign in with Apple" entitlement in Xcode
- **Android:** Handled via Supabase web OAuth flow

---

## 4. Taddy API (Podcast Data)

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] Sign up at [taddy.org/signup/developers](https://taddy.org/signup/developers) | | Backend | Free tier: 500 req/mo |
| [ ] Copy User ID from dashboard | | Backend | Numeric ID |
| [ ] Copy API Key from dashboard | | Backend | String key |
| [ ] Set `TADDY_USER_ID` + `TADDY_API_KEY` as Supabase secrets | | Backend | See TaddyAPI.md |
| [ ] Test `getPopularContent` query from Edge Function | | Backend | Verify connectivity |
| [ ] Test `search` query with known podcast name | | Backend | Verify search works |
| [ ] Verify `audioUrl` returns direct file links | | Backend | Must be direct streams, not gated |
| [ ] Upgrade to Pro plan when launching beta | | Backend | $75/mo for 100K requests |

### Architecture Note

Taddy is **server-side only**. All calls go through Supabase Edge Functions. No
Taddy credentials or SDK on the client.

---

## 5. OpenAI (Whisper STT + GPT)

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] OpenAI platform account created | | Backend | [platform.openai.com](https://platform.openai.com) |
| [ ] API key generated | | Backend | Project-scoped key recommended |
| [ ] Set `OPENAI_API_KEY` as Supabase secret | | Backend | Used by AI processing Edge Function |
| [ ] Set usage limit / budget alert | | Backend | Prevent runaway costs |
| [ ] Test Whisper API with sample audio clip | | Backend | Model: `whisper-1` |
| [ ] Test GPT API for summary generation | | Backend | Model: `gpt-4o-mini` or `gpt-4o` |
| [ ] Verify response times acceptable (<30s for 60s clip) | | Backend | Consider timeout settings |

### Cost Estimates

| Model | Cost | Usage |
|-------|------|-------|
| Whisper | $0.006/min | ~$0.006 per 60s clip |
| GPT-4o-mini | $0.15/1M input tokens | ~$0.001 per summary |

At 10K clips/month: ~$70/month

---

## 6. AWS (S3 + CloudFront)

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] AWS account created | | Backend | |
| [ ] S3 bucket created (eu-central-1) | | Backend | `clipcast-audio-prod` |
| [ ] S3 bucket policy: private (no public access) | | Backend | All access via presigned URLs or CloudFront |
| [ ] S3 CORS configured for presigned upload from client | | Backend | Allow PUT from app domains |
| [ ] IAM user for Edge Functions with minimal S3 permissions | | Backend | `s3:PutObject`, `s3:GetObject` only |
| [ ] CloudFront distribution created | | Backend | Origin: S3 bucket |
| [ ] CloudFront OAC (Origin Access Control) configured | | Backend | Only CloudFront can read S3 |
| [ ] Set AWS secrets in Supabase | | Backend | See secrets list above |
| [ ] SSL certificate for CloudFront | | Backend | Use ACM (free) |
| [ ] Test presigned URL upload flow | | Backend | Client uploads directly to S3 |
| [ ] Test CloudFront playback URL | | Client | Verify audio streams correctly |

### Architecture Note

- **Upload:** Client gets presigned URL from Edge Function → PUTs file to S3
- **Download/Play:** Client uses CloudFront URL (signed or public, depending on clip visibility)

---

## 7. RevenueCat (In-App Purchases)

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] RevenueCat account created | | Client | [app.revenuecat.com](https://app.revenuecat.com) |
| [ ] RevenueCat project created | | Client | |
| [ ] iOS App Store Connect: create subscription product | | Client | `clipcast_premium_yearly` — $49/yr |
| [ ] iOS: add Shared Secret to RevenueCat | | Client | For receipt validation |
| [ ] Google Play Console: create subscription product | | Client | Same product ID |
| [ ] Google: add Play service credentials JSON to RevenueCat | | Client | For server verification |
| [ ] RevenueCat Entitlement created: `premium` | | Client | Maps to subscription product |
| [ ] RevenueCat Offering created: `default` | | Client | Contains `premium_yearly` package |
| [ ] Configure webhook URL in RevenueCat | | Backend | `https://<ref>.supabase.co/functions/v1/webhooks-revenuecat` |
| [ ] Set `REVENUECAT_WEBHOOK_AUTH_TOKEN` as Supabase secret | | Backend | Validate webhook signatures |
| [ ] Copy RevenueCat Public API Key (iOS) | | Client | Used in `purchases_flutter` init |
| [ ] Copy RevenueCat Public API Key (Android) | | Client | Platform-specific key |
| [ ] Test purchase flow in sandbox | | QA | Both platforms |
| [ ] Test webhook → Supabase subscription update | | QA | Verify `user_subscriptions` updated |

### Client-Side Config

- **Package:** `purchases_flutter`
- Configure with platform-specific public API keys at app startup
- Check `premium` entitlement to gate features

---

## 8. OneSignal (Push Notifications)

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] OneSignal account created | | Backend | [onesignal.com](https://onesignal.com) |
| [ ] OneSignal App created | | Backend | |
| [ ] iOS: upload APNs auth key (`.p8`) | | Backend | From Apple Developer portal |
| [ ] Android: add FCM Server Key / Service Account JSON | | Backend | From Firebase Console |
| [ ] Copy OneSignal App ID | | Client | Used in `onesignal_flutter` init |
| [ ] Set `ONESIGNAL_APP_ID` + `ONESIGNAL_REST_API_KEY` as Supabase secrets | | Backend | For server-side push sends |
| [ ] Test push notification delivery (iOS) | | QA | Requires physical device |
| [ ] Test push notification delivery (Android) | | QA | Emulator or device |

### Client-Side Config

- **Package:** `onesignal_flutter`
- Init with App ID at startup
- Register player ID and associate with Supabase `profiles.onesignal_player_id`

### Server-Side (Edge Functions)

Sends push via OneSignal REST API when:
- New follower
- New clip from followed user
- Like / comment / share on user's clip
- Clip processing complete

---

## 9. Resend (Transactional Email)

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] Resend account created | | Backend | [resend.com](https://resend.com) |
| [ ] Domain verified (e.g. `mail.clipcast.app`) | | Backend | DNS records: SPF, DKIM, DMARC |
| [ ] API key generated | | Backend | |
| [ ] Set `RESEND_API_KEY` as Supabase secret | | Backend | Used by email Edge Functions |
| [ ] Create email templates: welcome, password reset, weekly digest | | Backend | |
| [ ] Test email delivery from Edge Function | | QA | |

### Architecture Note

Resend is **server-side only**. No client SDK needed. Triggered from Edge Functions for:
- Welcome email on sign-up
- Password reset (if email auth)
- Weekly clip digest (cron-driven)
- Account deletion confirmation

---

## 10. Firebase (Crashlytics only)

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] Firebase project created (or reuse Google Cloud project) | | Client | |
| [ ] `google-services.json` (Android) downloaded | | Client | Place in `android/app/` |
| [ ] `GoogleService-Info.plist` (iOS) downloaded | | Client | Place in `ios/Runner/` |
| [ ] Crashlytics enabled in Firebase Console | | Client | |
| [ ] Test crash report in debug mode | | QA | |

### Client-Side Config

- **Package:** `firebase_crashlytics` + `firebase_core`
- Init firebase in `main.dart` before `runApp()`

---

## 11. App Stores

| Item | Status | Owner | Notes |
|------|--------|-------|-------|
| [ ] Apple Developer Program membership (paid, $99/yr) | | Client | Required for App Store + Sign in with Apple |
| [ ] App Store Connect: app record created | | Client | Bundle ID: `com.clipcast.app` |
| [ ] Google Play Console: developer account ($25 one-time) | | Client | |
| [ ] Google Play Console: app created | | Client | Package: `com.clipcast.app` |
| [ ] Signing key (Android): upload key generated | | Client | For Play App Signing |
| [ ] iOS provisioning profiles created (dev + dist) | | Client | For builds |

---

## Summary: Secrets Matrix

| Secret | Where Stored | Used By | Required Phase |
|--------|-------------|---------|----------------|
| `SUPABASE_URL` | Client `.env` | Flutter app | Phase 0 |
| `SUPABASE_ANON_KEY` | Client `.env` | Flutter app | Phase 0 |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase secrets | Edge Functions | Phase 0 |
| `TADDY_USER_ID` | Supabase secrets | Edge Functions | Phase 0 |
| `TADDY_API_KEY` | Supabase secrets | Edge Functions | Phase 0 |
| `OPENAI_API_KEY` | Supabase secrets | Edge Functions | Phase 1 |
| `AWS_ACCESS_KEY_ID` | Supabase secrets | Edge Functions | Phase 1 |
| `AWS_SECRET_ACCESS_KEY` | Supabase secrets | Edge Functions | Phase 1 |
| `AWS_S3_BUCKET` | Supabase secrets | Edge Functions | Phase 1 |
| `AWS_CLOUDFRONT_DISTRIBUTION_ID` | Supabase secrets | Edge Functions | Phase 1 |
| `ONESIGNAL_APP_ID` | Client `.env` + Supabase secrets | Flutter + Edge Functions | Phase 2 |
| `ONESIGNAL_REST_API_KEY` | Supabase secrets | Edge Functions | Phase 2 |
| `RESEND_API_KEY` | Supabase secrets | Edge Functions | Phase 2 |
| `REVENUECAT_WEBHOOK_AUTH_TOKEN` | Supabase secrets | Edge Functions | Phase 2 |
| `REVENUECAT_PUBLIC_KEY_IOS` | Client `.env` | Flutter app | Phase 2 |
| `REVENUECAT_PUBLIC_KEY_ANDROID` | Client `.env` | Flutter app | Phase 2 |
| `GOOGLE_OAUTH_CLIENT_ID` | Supabase dashboard | Supabase Auth | Phase 0 |
| `APPLE_SERVICES_ID` | Supabase dashboard | Supabase Auth | Phase 0 |

---

## Pre-Development Readiness Gate

**Minimum to start Phase 1 coding:**

- [ ] Supabase project + anon key + service role key
- [ ] Google OAuth configured in Supabase
- [ ] Apple OAuth configured in Supabase
- [ ] Taddy API key obtained and tested
- [ ] AWS S3 bucket + IAM user created
- [ ] OpenAI API key obtained
- [ ] DDL migrations applied (all tables from ERD.md)
- [ ] RLS policies applied (all policies from RLS.md)

**Can be deferred to Phase 2:**

- [ ] RevenueCat subscription products
- [ ] OneSignal push configuration
- [ ] Resend domain verification
- [ ] CloudFront distribution
- [ ] Firebase Crashlytics
- [ ] App Store / Play Store app records

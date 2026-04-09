# Supabase Auth Error Codes Reference

> Source: https://supabase.com/docs/guides/auth/debugging/error-codes

## Best Practices
- Always use `error.code` and `error.name` to identify errors, not string matching on messages.
- Avoid relying solely on HTTP status codes — they may change.
- All errors from `supabase.auth` are wrapped by `AuthException` (has `message`, `statusCode`, `code`).
- `AuthApiException` is the subclass for errors originating from the Supabase Auth API.

## HTTP Status Codes
| Code | Meaning |
|------|---------|
| 403  | Feature not available for the user |
| 422  | Request accepted but can't be processed (user/server state conflict) |
| 429  | Rate-limit breached — must handle, especially in auth functions |
| 500  | Auth server degraded — often points to DB triggers/functions |
| 501  | Feature not enabled on the Auth server |

## Error Codes (Alphabetical)

| Code | Description |
|------|-------------|
| `anonymous_provider_disabled` | Anonymous sign-ins are disabled |
| `bad_code_verifier` | PKCE code verifier mismatch — client library bug |
| `bad_json` | HTTP body is not valid JSON |
| `bad_jwt` | JWT in Authorization header is invalid |
| `bad_oauth_callback` | OAuth callback missing required attributes (state) |
| `bad_oauth_state` | OAuth state not in correct format |
| `captcha_failed` | CAPTCHA verification failed |
| `conflict` | Database conflict (e.g., concurrent session refreshes) — back off exponentially |
| `email_address_invalid` | Test/example domains not supported |
| `email_address_not_authorized` | Default SMTP only sends to org members — set up custom SMTP |
| `email_conflict_identity_not_deletable` | Unlinking would change email to one used by another account |
| `email_exists` | Email already exists in the system |
| `email_not_confirmed` | Email not confirmed — user can't sign in |
| `email_provider_disabled` | Email+password signups disabled |
| `flow_state_expired` | PKCE flow state expired — ask user to sign in again |
| `flow_state_not_found` | PKCE flow state no longer exists — ask user to sign in again |
| `identity_already_exists` | Identity already linked to a user |
| `identity_not_found` | Identity doesn't exist (unlinked/deleted) |
| `insufficient_aal` | User needs higher Authenticator Assurance Level (MFA) |
| `invalid_credentials` | Login credentials or grant type not recognized |
| `invite_not_found` | Invite expired or already used |
| `manual_linking_disabled` | `linkUser()` API not enabled |
| `mfa_challenge_expired` | MFA challenge timed out — request new challenge |
| `mfa_factor_name_conflict` | MFA factors can't share friendly names |
| `mfa_factor_not_found` | MFA factor doesn't exist |
| `mfa_ip_address_mismatch` | MFA enrollment must start and end with same IP |
| `mfa_phone_enroll_not_enabled` | Phone MFA enrollment disabled |
| `mfa_phone_verify_not_enabled` | Phone MFA verification disabled |
| `mfa_totp_enroll_not_enabled` | TOTP MFA enrollment disabled |
| `mfa_totp_verify_not_enabled` | TOTP MFA verification disabled |
| `mfa_verification_failed` | Wrong TOTP code |
| `mfa_verification_rejected` | MFA verification rejected by hook |
| `mfa_verified_factor_exists` | Verified phone factor already exists — unenroll first |
| `mfa_web_authn_enroll_not_enabled` | WebAuthn MFA enrollment disabled |
| `mfa_web_authn_verify_not_enabled` | WebAuthn MFA verification disabled |
| `no_authorization` | Missing Authorization header |
| `not_admin` | JWT doesn't contain admin role claim |
| `oauth_provider_not_supported` | OAuth provider disabled |
| `otp_disabled` | OTP sign-in (magic link, email OTP) disabled |
| `otp_expired` | OTP code expired — ask user to sign in again |
| `over_email_send_rate_limit` | Too many emails — wait before retrying |
| `over_request_rate_limit` | Too many requests from this IP — wait and retry |
| `over_sms_send_rate_limit` | Too many SMS — wait before retrying |
| `phone_exists` | Phone number already exists |
| `phone_not_confirmed` | Phone not confirmed — can't sign in |
| `phone_provider_disabled` | Phone+password signups disabled |
| `provider_disabled` | OAuth provider disabled |
| `provider_email_needs_verification` | OAuth provider didn't verify email — verification email sent |
| `reauthentication_needed` | Must reauthenticate to change password |
| `reauthentication_not_valid` | Reauthentication code incorrect |
| `refresh_token_already_used` | Refresh token revoked, outside reuse interval |
| `refresh_token_not_found` | Session with refresh token not found |
| `request_timeout` | Request took too long — retry |
| `same_password` | New password same as current |
| `saml_*` | Various SAML/SSO errors (see full docs) |
| `session_expired` | Session expired (inactivity timeout or timebox exceeded) |
| `session_not_found` | Session no longer exists (user signed out or deleted) |
| `signup_disabled` | Sign-ups disabled on the server |
| `single_identity_not_deletable` | Can't delete the only identity on a user |
| `sms_send_failed` | SMS sending failed — check provider config |
| `sso_domain_already_exists` | Only one SSO domain per provider |
| `sso_provider_not_found` | SSO provider not found |
| `too_many_enrolled_mfa_factors` | Max MFA factors reached |
| `unexpected_failure` | Auth service degraded or bug |
| `user_already_exists` | User with this email/phone already exists |
| `user_banned` | User is banned (`banned_until` still active) |
| `user_not_found` | User no longer exists |
| `user_sso_managed` | SSO user fields can't be updated |
| `validation_failed` | Parameters in wrong format |
| `weak_password` | Password doesn't meet strength criteria |

## ClipCast Implementation

Error handling flows through the clean architecture layers:

```
Supabase AuthException (code, statusCode, message)
  └─ data/source   → throws AuthException (raw SDK errors)
  └─ data/repository → catches AuthException → maps to AuthFailure(code: AuthErrorCode)
  └─ domain/usecases → passes through (pure Dart)
  └─ presentation/controller → catches AuthFailure → emits AuthState(errorCode, errorMessage)
  └─ presentation/pages → reacts to errorCode for specific UX
```

Mapped codes live in `lib/core/errors/auth_error_codes.dart`.

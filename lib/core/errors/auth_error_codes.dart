/// Domain-level auth error codes mapped from Supabase Auth API.
///
/// Reference: https://supabase.com/docs/guides/auth/debugging/error-codes
/// Only codes relevant to ClipCast client flows are included.
/// Add new codes here as needed when handling additional flows.
enum AuthErrorCode {
  // ── Sign-up / Identity ──────────────────────────────────────
  userAlreadyExists('user_already_exists', 'An account with this email already exists. Try logging in instead.'),
  emailExists('email_exists', 'This email address is already registered.'),
  emailProviderDisabled('email_provider_disabled', 'Email sign-ups are currently disabled.'),
  signupDisabled('signup_disabled', 'Sign-ups are currently disabled.'),
  weakPassword('weak_password', 'Your password is too weak. Please choose a stronger one.'),

  // ── Email / OTP ─────────────────────────────────────────────
  emailNotConfirmed('email_not_confirmed', 'Your email is not confirmed. Please check your inbox.'),
  otpExpired('otp_expired', 'Your verification code has expired. Please request a new one.'),
  otpDisabled('otp_disabled', 'OTP verification is currently disabled.'),

  // ── Credentials / Session ───────────────────────────────────
  invalidCredentials('invalid_credentials', 'Invalid email or password.'),
  sessionExpired('session_expired', 'Your session has expired. Please sign in again.'),
  sessionNotFound('session_not_found', 'Session not found. Please sign in again.'),

  // ── Rate-limiting ───────────────────────────────────────────
  overEmailSendRateLimit('over_email_send_rate_limit', 'Too many emails sent. Please wait a moment and try again.'),
  overRequestRateLimit('over_request_rate_limit', 'Too many requests. Please wait a moment and try again.'),

  // ── Validation ──────────────────────────────────────────────
  emailAddressInvalid('email_address_invalid', 'Please enter a valid email address.'),
  emailAddressNotAuthorized('email_address_not_authorized', 'This email address is not authorized.'),
  validationFailed('validation_failed', 'Invalid input. Please check and try again.'),

  // ── Catch-all ───────────────────────────────────────────────
  unknown('unknown', 'Something went wrong. Please try again.');

  final String supabaseCode;
  final String userMessage;

  const AuthErrorCode(this.supabaseCode, this.userMessage);

  /// Resolve a Supabase error code string to the typed enum.
  /// Returns [AuthErrorCode.unknown] for unrecognised codes.
  static AuthErrorCode fromSupabase(String? code) {
    if (code == null) return AuthErrorCode.unknown;
    return AuthErrorCode.values.firstWhere(
      (e) => e.supabaseCode == code,
      orElse: () => AuthErrorCode.unknown,
    );
  }
}

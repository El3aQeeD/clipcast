import 'package:flutter/material.dart';

/// Typography tokens — Inter font family with a complete Material-aligned scale.
///
/// Naming mirrors Flutter's [TextTheme] slots so wiring in [AppTheme] is
/// one-to-one. Legacy camelCase names are kept as aliases for back-compat.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  // ── Display ─────────────────────────────────────────────────────────────────
  /// 40 px · W700 · ls -0.8 — Hero / splash text.
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 48 / 40,
    letterSpacing: -0.8,
  );

  /// 32 px · W700 · ls -0.7 — Section hero, e.g. "Try Premium free for 1 month".
  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.7,
  );

  /// 28 px · W700 · ls -0.6 — Large page headings.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.6,
  );

  // ── Headline ────────────────────────────────────────────────────────────────
  /// 24 px · W700 · ls -0.5 — Major section headings.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.5,
  );

  /// 20 px · W600 · ls -0.3 — Sub-section headings, e.g. "Why join Premium?".
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.3,
  );

  /// 18 px · W600 · ls -0.2 — Card section heads, e.g. "Your Favorite Podcasts".
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 26 / 18,
    letterSpacing: -0.2,
  );

  // ── Title ───────────────────────────────────────────────────────────────────
  /// 16 px · W600 · ls -0.2 — List item / card titles, e.g. episode title.
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: -0.2,
  );

  /// 14 px · W600 · ls -0.1 — Smaller titles, e.g. follow button label.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: -0.1,
  );

  /// 13 px · W600 · ls 0 — Compact titles.
  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    letterSpacing: 0,
  );

  // ── Body ────────────────────────────────────────────────────────────────────
  /// 16 px · W400 · ls -0.5 — Primary body text.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: -0.5,
  );

  /// 14 px · W400 · ls -0.15 — Secondary body / description text.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: -0.15,
  );

  /// 12 px · W400 · ls -0.5 — Compact body / metadata, e.g. "24 episodes".
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: -0.5,
  );

  // ── Label ───────────────────────────────────────────────────────────────────
  /// 14 px · W500 · ls -0.1 — Button text, active tab labels.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: -0.1,
  );

  /// 12 px · W500 · ls 0 — Tag / badge / nav-bar item labels.
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0,
  );

  /// 10 px · W500 · ls 0.1 — Tiny labels, "KEY TAKEAWAYS", "6 clips".
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 14 / 10,
    letterSpacing: 0.1,
  );

  // ── Legacy aliases (backward-compatible) ────────────────────────────────────
  @Deprecated('Use headlineSmall')
  static const TextStyle h1Large = headlineSmall;

  @Deprecated('Use titleLarge')
  static const TextStyle h1 = titleLarge;

  @Deprecated('Use titleMedium')
  static const TextStyle h2 = titleMedium;

  @Deprecated('Use bodySmall')
  static const TextStyle body1 = bodySmall;

  @Deprecated('Use labelSmall')
  static const TextStyle caption = labelSmall;

  @Deprecated('Use displayMedium')
  // ignore: deprecated_member_use_from_same_package
  static const TextStyle displayLargeOld = displayMedium;

  /// CTA button text — 14 px · W600.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 18 / 14,
    letterSpacing: -0.5,
  );
}

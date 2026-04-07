import 'dart:ui';

import 'primitives.dart';

/// Tier 2: Semantic Tokens — purpose-driven, theme-switchable.
abstract final class SemanticColors {
  // ── Backgrounds ──────────────────────────────────────────────
  static const Color backgroundPrimary   = PrimitiveColors.neutral950;
  static const Color backgroundSecondary = PrimitiveColors.neutral850;
  static const Color backgroundSurface   = PrimitiveColors.neutral800;
  static const Color backgroundCard      = PrimitiveColors.neutral900;
  /// Used for elevated sheets, bottom bars.
  static const Color backgroundElevated  = PrimitiveColors.neutral700;

  // ── Gradient (Premium hero) ───────────────────────────────────
  /// Top of the premium-screen gradient (dark teal).
  static const Color gradientStart = PrimitiveColors.teal950;
  /// Bottom of the premium-screen gradient (merges with backgroundPrimary).
  static const Color gradientEnd   = PrimitiveColors.neutral950;

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary   = PrimitiveColors.neutral50;
  static const Color textSecondary = PrimitiveColors.neutral400;
  static const Color textTertiary  = PrimitiveColors.neutral200;
  static const Color textDisabled  = PrimitiveColors.neutral500;
  static const Color textOnPrimary = PrimitiveColors.neutral950;

  // ── Interactive ───────────────────────────────────────────────
  static const Color interactivePrimary = PrimitiveColors.cyan500;
  static const Color interactiveHover   = PrimitiveColors.cyan400;
  static const Color interactiveMuted   = PrimitiveColors.cyan600;

  // ── Borders ───────────────────────────────────────────────────
  static const Color borderDefault = PrimitiveColors.neutral700;
  static const Color borderSubtle  = PrimitiveColors.neutral600;
  static const Color borderStrong  = PrimitiveColors.neutral500;

  // ── Tags / Badges ─────────────────────────────────────────────
  static const Color tagBackground = PrimitiveColors.neutral700;
  static const Color tagForeground = PrimitiveColors.neutral200;
  /// Dark translucent badge (e.g. "6 clips" overlay on images).
  static const Color overlayBadgeBg   = PrimitiveColors.black60;
  static const Color overlayBadgeText = PrimitiveColors.neutral50;

  // ── Premium ───────────────────────────────────────────────────
  static const Color premiumGold      = PrimitiveColors.amber400;
  static const Color premiumGoldDeep  = PrimitiveColors.amber500;

  // ── Feedback ─────────────────────────────────────────────────
  static const Color feedbackSuccess = PrimitiveColors.green500;
  static const Color feedbackError   = PrimitiveColors.red500;
  static const Color feedbackWarning = PrimitiveColors.amber500;
}

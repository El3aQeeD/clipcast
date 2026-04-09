import 'dart:ui';

import 'primitives.dart';
import 'semantic.dart';

/// Tier 3: Component Tokens — scoped to specific widgets.
abstract final class ComponentColors {
  // ── Buttons ───────────────────────────────────────────────────
  static const Color buttonPrimaryBg     = SemanticColors.interactiveHover;
  static const Color buttonPrimaryText   = SemanticColors.textOnPrimary;
  static const Color buttonSecondaryBg   = PrimitiveColors.white20;
  static const Color buttonSecondaryBorder = PrimitiveColors.white40;
  static const Color buttonSecondaryText = SemanticColors.textTertiary;
  static const Color buttonDestructiveBg = SemanticColors.feedbackError;
  static const Color buttonDestructiveText = SemanticColors.textPrimary;

  // ── Navigation bar ────────────────────────────────────────────
  static const Color navBarBg       = SemanticColors.backgroundPrimary;
  static const Color navBarActive   = SemanticColors.interactivePrimary;
  static const Color navBarInactive = SemanticColors.textSecondary;

  // ── Tabs ─────────────────────────────────────────────────────
  static const Color tabActiveIndicator = SemanticColors.interactivePrimary;
  static const Color tabActiveText      = SemanticColors.textPrimary;
  static const Color tabInactiveText    = SemanticColors.textSecondary;

  // ── Feed / cards ─────────────────────────────────────────────
  static const Color feedCardBg     = SemanticColors.backgroundCard;
  static const Color feedCardBorder = SemanticColors.borderDefault;

  // ── Episode / content cards ──────────────────────────────────
  static const Color contentCardBg     = SemanticColors.backgroundSurface;
  static const Color contentCardBorder = SemanticColors.borderSubtle;

  // ── Player ───────────────────────────────────────────────────
  static const Color playerProgressActive   = SemanticColors.interactivePrimary;
  static const Color playerProgressInactive = SemanticColors.borderSubtle;
  static const Color playerBg               = SemanticColors.backgroundElevated;

  // ── Tags / Badges / Pills ────────────────────────────────────
  static const Color tagBg   = SemanticColors.tagBackground;
  static const Color tagText = SemanticColors.tagForeground;
  /// Dark translucent overlay badge (image overlays like "6 clips").
  static const Color overlayBadgeBg   = SemanticColors.overlayBadgeBg;
  static const Color overlayBadgeText = SemanticColors.overlayBadgeText;

  // ── Premium ───────────────────────────────────────────────────
  static const Color premiumGoldColor  = SemanticColors.premiumGold;
  static const Color premiumGoldDeep   = SemanticColors.premiumGoldDeep;
  static const Color premiumCardBg     = SemanticColors.backgroundCard;
  static const Color premiumCardBorder = SemanticColors.borderDefault;
  /// Semi-opaque overlay for premium-locked content.
  static const Color premiumOverlayBg  = PrimitiveColors.black80;

  // ── Avatar / Profile ─────────────────────────────────────────
  static const Color avatarBg     = SemanticColors.backgroundElevated;
  static const Color avatarBorder = SemanticColors.borderSubtle;

  // ── Inputs ───────────────────────────────────────────────────
  static const Color inputBg            = SemanticColors.backgroundSurface;
  static const Color inputBorder        = SemanticColors.borderDefault;
  static const Color inputBorderFocused = SemanticColors.interactivePrimary;
  static const Color inputPlaceholder   = SemanticColors.textDisabled;
  static const Color inputText          = SemanticColors.textPrimary;

  // ── Dividers ─────────────────────────────────────────────────
  static const Color divider = SemanticColors.borderDefault;

  // ── Button disabled ──────────────────────────────────────────
  static const Color buttonDisabledBg   = SemanticColors.interactiveDisabled;
  static const Color buttonDisabledText = SemanticColors.textOnDisabled;

  // ── Input (light background — sign-up fields) ────────────────
  static const Color inputLightBg          = SemanticColors.inputLightBg;
  static const Color inputLightText        = SemanticColors.inputLightText;
  static const Color inputLightPlaceholder = SemanticColors.inputLightPlaceholder;
  static const Color inputLightBorder      = PrimitiveColors.white10;
  static const Color inputLightBorderFocused = SemanticColors.interactivePrimary;

  // ── OTP ──────────────────────────────────────────────────────
  static const Color otpFieldBg            = SemanticColors.backgroundSurface;
  static const Color otpFieldBorder        = SemanticColors.borderDefault;
  static const Color otpFieldBorderFocused = SemanticColors.interactivePrimary;
  static const Color otpFieldText          = SemanticColors.textPrimary;

  // ── Snackbar ─────────────────────────────────────────────────
  static const Color snackbarErrorBg   = SemanticColors.feedbackError;
  static const Color snackbarInfoBg    = SemanticColors.backgroundElevated;
  static const Color snackbarText      = SemanticColors.textPrimary;

  // ── Validation (input checkmarks & criteria) ─────────────────
  static const Color inputValidCheckmark    = SemanticColors.validCheckmark;
  static const Color criteriaMetIcon        = SemanticColors.criteriaMet;
  static const Color criteriaMetText        = SemanticColors.criteriaMuted;
  static const Color criteriaUnmetIcon      = SemanticColors.feedbackError;
  static const Color criteriaInactiveIcon   = SemanticColors.criteriaMuted;
  static const Color criteriaInactiveText   = SemanticColors.criteriaMuted;
}

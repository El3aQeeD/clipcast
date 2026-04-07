import 'package:flutter/material.dart';

import 'tokens/components.dart';
import 'tokens/semantic.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

/// Builds the app-wide [ThemeData] from design tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: SemanticColors.backgroundPrimary,

      // ── Color scheme ──────────────────────────────────────────
      colorScheme: const ColorScheme.dark(
        primary:        SemanticColors.interactivePrimary,
        primaryFixed:   SemanticColors.interactiveHover,
        secondary:      SemanticColors.premiumGold,
        surface:        SemanticColors.backgroundSurface,
        surfaceContainer: SemanticColors.backgroundCard,
        error:          SemanticColors.feedbackError,
        onPrimary:      SemanticColors.textOnPrimary,
        onSurface:      SemanticColors.textPrimary,
        onSurfaceVariant: SemanticColors.textSecondary,
        outline:        SemanticColors.borderDefault,
        outlineVariant: SemanticColors.borderSubtle,
      ),

      // ── App bar ───────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: SemanticColors.backgroundPrimary,
        foregroundColor: SemanticColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: SemanticColors.textPrimary,
          letterSpacing: -0.2,
        ),
      ),

      // ── Bottom nav ────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ComponentColors.navBarBg,
        selectedItemColor: ComponentColors.navBarActive,
        unselectedItemColor: ComponentColors.navBarInactive,
        type: BottomNavigationBarType.fixed,
      ),

      // ── Tab bar ───────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        indicatorColor: ComponentColors.tabActiveIndicator,
        labelColor: ComponentColors.tabActiveText,
        unselectedLabelColor: ComponentColors.tabInactiveText,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: ComponentColors.feedCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
          side: BorderSide(color: ComponentColors.feedCardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input decoration ─────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ComponentColors.inputBg,
        hintStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          color: ComponentColors.inputPlaceholder,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: ComponentColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: ComponentColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(
            color: ComponentColors.inputBorderFocused,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
      ),

      // ── Elevated button ───────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ComponentColors.buttonPrimaryBg,
          foregroundColor: ComponentColors.buttonPrimaryText,
          textStyle: AppTypography.button,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.base,
          ),
        ),
      ),

      // ── Outlined button ───────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ComponentColors.buttonSecondaryText,
          textStyle: AppTypography.button,
          side: const BorderSide(color: ComponentColors.buttonSecondaryBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.base,
          ),
        ),
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: ComponentColors.divider,
        thickness: 1,
        space: 0,
      ),

      // ── Chip ─────────────────────────────────────────────────
      chipTheme: const ChipThemeData(
        backgroundColor: ComponentColors.tagBg,
        labelStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: ComponentColors.tagText,
          letterSpacing: 0.1,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        shape: StadiumBorder(),
        side: BorderSide.none,
      ),

      // ── Slider (for audio player) ─────────────────────────────
      sliderTheme: const SliderThemeData(
        activeTrackColor: ComponentColors.playerProgressActive,
        inactiveTrackColor: ComponentColors.playerProgressInactive,
        thumbColor: ComponentColors.playerProgressActive,
        trackHeight: 3,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
      ),

      // ── Text theme (full Material scale) ─────────────────────
      textTheme: const TextTheme(
        displayLarge:   AppTypography.displayLarge,
        displayMedium:  AppTypography.displayMedium,
        displaySmall:   AppTypography.displaySmall,
        headlineLarge:  AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall:  AppTypography.headlineSmall,
        titleLarge:     AppTypography.titleLarge,
        titleMedium:    AppTypography.titleMedium,
        titleSmall:     AppTypography.titleSmall,
        bodyLarge:      AppTypography.bodyLarge,
        bodyMedium:     AppTypography.bodyMedium,
        bodySmall:      AppTypography.bodySmall,
        labelLarge:     AppTypography.labelLarge,
        labelMedium:    AppTypography.labelMedium,
        labelSmall:     AppTypography.labelSmall,
      ).apply(
        bodyColor: SemanticColors.textPrimary,
        displayColor: SemanticColors.textPrimary,
        decorationColor: SemanticColors.textSecondary,
      ),
    );
  }
}

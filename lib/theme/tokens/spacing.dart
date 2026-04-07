/// Spacing & layout tokens — 4-point grid.
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs  = 2;
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  /// Horizontal padding used by all full-width content sections.
  static const double screenHorizontal = xl;

  /// Standard inner padding for cards.
  static const double cardInner = base;

  /// Gap between stacked items in a list.
  static const double listItemGap = sm;

  /// Gap between horizontally scrolled cards.
  static const double carouselGap = base;
}

/// Border-radius tokens.
abstract final class AppRadius {
  static const double none = 0;
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double lg   = 16;
  static const double xl   = 20;
  static const double xxl  = 24;
  static const double full = 999;
}

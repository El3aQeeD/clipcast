import 'dart:ui';

/// Tier 1: Primitive Tokens — raw values, never referenced directly in widgets.
abstract final class PrimitiveColors {
  // Neutrals
  static const Color neutral950 = Color(0xFF0B1215);
  static const Color neutral900 = Color(0xFF0C1215);
  static const Color neutral850 = Color(0xFF111C1F);
  static const Color neutral800 = Color(0xFF12191D);
  static const Color neutral700 = Color(0xFF1F2A2E);
  static const Color neutral600 = Color(0xFF2D3A40);
  static const Color neutral500 = Color(0xFF4B5563);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral50  = Color(0xFFF8FAFC);

  // Cyan / Brand
  static const Color cyan600 = Color(0xFF0EA5C9);
  static const Color cyan500 = Color(0xFF11C5E1);
  static const Color cyan400 = Color(0xFF0BC9E9);
  static const Color cyan300 = Color(0xFF67E8F9);

  // Teal (dark, for gradients)
  static const Color teal950 = Color(0xFF0A2832);
  static const Color teal900 = Color(0xFF0D3340);

  // Amber / Premium
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber400 = Color(0xFFFBBF24);

  // Semantic feedback
  static const Color green500  = Color(0xFF22C55E);
  static const Color red500    = Color(0xFFEF4444);

  // White alpha
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white40 = Color(0x66FFFFFF);
  static const Color white60 = Color(0x99FFFFFF);

  // Black alpha
  static const Color black40 = Color(0x66000000);
  static const Color black60 = Color(0x99000000);
  static const Color black80 = Color(0xCC000000);
}

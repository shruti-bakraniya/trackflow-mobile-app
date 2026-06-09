import 'package:flutter/material.dart';

/// Central colour palette for TrackFlow's sage-green light theme, mirrored
/// from the approved design tokens.
class AppColors {
  AppColors._();

  // ── Canvas ────────────────────────────────────────────────
  static const Color background = Color(0xFF519F7D);
  static const Color backgroundDeep = Color(0xFF3F7D61);

  // ── Brand / actions ───────────────────────────────────────
  static const Color accent = Color(0xFF0F5A3C);
  static const Color accentPress = Color(0xFF0B482F);
  static const Color accentSoft = Color(0xFF15894F);

  // ── Semantic ──────────────────────────────────────────────
  static const Color income = Color(0xFF15894F);
  static const Color expense = Color(0xFFD2553F);
  static const Color warn = Color(0xFFC98300);
  static const Color over = Color(0xFFF43F5E);
  static const Color near = Color(0xFFFBBF24);

  // ── Ink (dark text on light glass) ────────────────────────
  static const Color ink = Color(0xFF143A2B);
  static Color get inkSoft => ink.withValues(alpha: 0.62);
  static Color get inkFaint => ink.withValues(alpha: 0.42);
  static Color get inkGhost => ink.withValues(alpha: 0.12);

  // ── On-canvas (light text directly on green) ──────────────
  static const Color onBg = Colors.white;
  static Color get onBgSoft => Colors.white.withValues(alpha: 0.82);
  static Color get onBgFaint => Colors.white.withValues(alpha: 0.62);

  // ── Glass surfaces ────────────────────────────────────────
  static Color get glassFill => Colors.white.withValues(alpha: 0.80);
  static Color get glassFillStrong => Colors.white.withValues(alpha: 0.92);
  static Color get glassStroke => Colors.white.withValues(alpha: 0.65);
  static Color get glassHighlight => Colors.white.withValues(alpha: 0.95);

  /// Solid avatar colour for a category hue (matches the prototype's
  /// `hsl(hue 56% 48%)`).
  static Color categoryColor(double hue) {
    return HSLColor.fromAHSL(1, hue % 360, 0.56, 0.48).toColor();
  }

  /// Lighter, more saturated variant used for chart segments / legends
  /// (matches the prototype's `catColor(hue, 0.72, 0.16)`).
  static Color categoryChartColor(double hue) {
    return HSLColor.fromAHSL(1, hue % 360, 0.69, 0.62).toColor();
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Custom gradients used across the app for depth and to elevate the
/// glassmorphism (subtle sheens, the canvas wash, and category-tinted fills).
class AppGradients {
  AppGradients._();

  /// The full-screen canvas wash — a gentle vertical deepening of the sage
  /// green that gives the frosted cards something to refract.
  static const LinearGradient canvas = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5AAA86), AppColors.background, Color(0xFF478E6E)],
    stops: [0, 0.45, 1],
  );

  /// Thin top-to-bottom sheen layered inside glass cards.
  static LinearGradient glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.35),
      Colors.white.withValues(alpha: 0.04),
    ],
  );

  /// Primary action gradient (FAB, primary buttons).
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentSoft, AppColors.accent],
  );

  /// A soft radial tint derived from a category hue, for avatars/heroes.
  static RadialGradient categoryGlow(double hue) {
    final c = AppColors.categoryColor(hue);
    return RadialGradient(
      colors: [
        Color.lerp(c, Colors.white, 0.18)!,
        c,
      ],
      center: const Alignment(-0.3, -0.4),
      radius: 1.1,
    );
  }
}

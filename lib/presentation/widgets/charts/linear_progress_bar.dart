import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Thin rounded progress bar that animates its fill width on build. Used for
/// cash-flow and per-category budget rows.
class LinearProgressBar extends StatelessWidget {
  const LinearProgressBar({
    super.key,
    required this.percent,
    required this.color,
    this.height = 7,
    this.delay = Duration.zero,
  });

  /// 0..100.
  final double percent;
  final Color color;
  final double height;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 100) / 100;
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Container(
        height: height,
        color: AppColors.ink.withValues(alpha: 0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

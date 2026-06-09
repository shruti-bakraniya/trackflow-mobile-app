import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Animated number that eases from its previous value to [value] whenever it
/// changes — the springy "count-up" used on balances and totals.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.decimals = 2,
    this.prefix = '',
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  final double value;
  final int decimals;
  final String prefix;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        final text = '$prefix${_format(v)}';
        return Text(text, style: style ?? AppTheme.numberStyle(fontSize: 28));
      },
    );
  }

  String _format(double v) {
    final abs = v.abs();
    return abs.toStringAsFixed(decimals).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }
}

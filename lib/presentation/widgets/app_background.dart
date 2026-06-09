import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';

/// The full-screen sage-green canvas wash sitting behind every screen, giving
/// the frosted glass cards something to refract.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppGradients.canvas),
      child: child,
    );
  }
}

/// Small section title used between cards.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.color,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 4),
  });

  final String title;
  final Widget? trailing;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color ?? const Color(0xFF143A2B),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

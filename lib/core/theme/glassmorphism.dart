import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_gradients.dart';

/// Reusable frosted-glass surface: a real backdrop blur + translucent fill,
/// hairline stroke, soft drop shadow and an inner top sheen. This is the
/// visual workhorse behind every card in the app.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = 22,
    this.blur = 20,
    this.fillColor,
    this.strokeColor,
    this.showSheen = true,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final Color? fillColor;
  final Color? strokeColor;
  final bool showSheen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor ?? AppColors.glassFill,
            borderRadius: radius,
            border: Border.all(color: strokeColor ?? AppColors.glassStroke),
          ),
          child: Stack(
            children: [
              if (showSheen)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.34,
                      widthFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(gradient: AppGradients.glassSheen),
                      ),
                    ),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );

    final shadowed = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D3426).withValues(alpha: 0.16),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: content,
    );

    if (onTap == null) return shadowed;
    return _Pressable(onTap: onTap!, child: shadowed);
  }
}

/// Tiny press-scale wrapper used by tappable glass surfaces (and elsewhere)
/// to give the whole UI a consistent, springy tactile feel.
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.955 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Public press-scale wrapper for arbitrary tappable widgets (buttons, tiles).
class Pressable extends StatelessWidget {
  const Pressable({super.key, required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _Pressable(onTap: onTap, child: child);
  }
}

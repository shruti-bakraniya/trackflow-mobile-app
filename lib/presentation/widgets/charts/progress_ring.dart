import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Animated single-value progress ring drawn with a [CustomPainter].
/// Colour escalates from green → amber → red as it nears / exceeds [max],
/// making it double as a budget warning indicator.
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.max,
    this.size = 64,
    this.thickness = 7,
    this.hue = 155,
    this.center,
  });

  final double value;
  final double max;
  final double size;
  final double thickness;
  final double hue;
  final Widget? center;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  late final Animation<double> _anim =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(covariant ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value || oldWidget.max != widget.max) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _color {
    if (widget.value > widget.max) return AppColors.over;
    if (widget.max > 0 && widget.value / widget.max >= 0.8) return AppColors.near;
    return HSLColor.fromAHSL(1, widget.hue, 0.55, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => CustomPaint(
              size: Size.square(widget.size),
              painter: _RingPainter(
                pct: (widget.max <= 0 ? 0 : (widget.value / widget.max)).clamp(0.0, 1.0) * _anim.value,
                thickness: widget.thickness,
                color: _color,
                trackColor: AppColors.ink.withValues(alpha: 0.10),
              ),
            ),
          ),
          if (widget.center != null) widget.center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.pct,
    required this.thickness,
    required this.color,
    required this.trackColor,
  });

  final double pct;
  final double thickness;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (pct <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, pct * 2 * math.pi, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.pct != pct || old.color != color || old.thickness != thickness;
}

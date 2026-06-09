import 'dart:math' as math;

import 'package:flutter/material.dart';

/// One arc of the donut.
class DonutSegment {
  const DonutSegment({required this.value, required this.color});
  final double value;
  final Color color;
}

/// Animated category donut drawn with a [CustomPainter]. Arcs sweep in from
/// zero on mount (and whenever the data changes), with rounded caps and a
/// small gap between slices — the app's signature "where it went" chart.
class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    required this.segments,
    this.size = 150,
    this.thickness = 22,
    this.gap = 0.04,
    this.child,
  });

  final List<DonutSegment> segments;
  final double size;
  final double thickness;

  /// Gap between segments, in radians.
  final double gap;
  final Widget? child;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _anim =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(covariant DonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments != widget.segments) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            builder: (context, _) {
              return CustomPaint(
                size: Size.square(widget.size),
                painter: _DonutPainter(
                  segments: widget.segments,
                  thickness: widget.thickness,
                  gap: widget.gap,
                  progress: _anim.value,
                  trackColor: Colors.white.withValues(alpha: 0.35),
                ),
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.segments,
    required this.thickness,
    required this.gap,
    required this.progress,
    required this.trackColor,
  });

  final List<DonutSegment> segments;
  final double thickness;
  final double gap;
  final double progress;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width - thickness) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final total = segments.fold<double>(0, (a, s) => a + s.value);

    // background track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    if (total <= 0) return;

    var start = -math.pi / 2; // 12 o'clock
    for (final seg in segments) {
      final fraction = seg.value / total;
      final fullSweep = fraction * 2 * math.pi;
      final sweep = math.max(fullSweep - gap, 0.001) * progress;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..color = seg.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += fullSweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.segments != segments || old.thickness != thickness;
}

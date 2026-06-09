import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/statistics.dart';

/// Grouped income/expense bars over a period, drawn with a [CustomPainter].
/// Bars grow from the baseline on mount (and on data change) for a lively,
/// staggered reveal.
class TrendBarChart extends StatefulWidget {
  const TrendBarChart({super.key, required this.data, this.height = 150});

  final List<TrendPoint> data;
  final double height;

  @override
  State<TrendBarChart> createState() => _TrendBarChartState();
}

class _TrendBarChartState extends State<TrendBarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();

  late final Animation<double> _anim =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(covariant TrendBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) => CustomPaint(
                size: Size.infinite,
                painter: _TrendPainter(
                  data: widget.data,
                  progress: _anim.value,
                  income: AppColors.income,
                  expense: AppColors.expense,
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: widget.data
                .map((d) => Expanded(
                      child: Text(
                        d.label,
                        textAlign: TextAlign.center,
                        style: AppTheme.uiStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkFaint,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.data,
    required this.progress,
    required this.income,
    required this.expense,
  });

  final List<TrendPoint> data;
  final double progress;
  final Color income;
  final Color expense;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data
        .map((d) => d.income > d.expense ? d.income : d.expense)
        .fold<double>(1, (a, b) => b > a ? b : a);

    final slot = size.width / data.length;
    const barW = 11.0;
    const gap = 3.0;
    final radius = const Radius.circular(6);

    for (var i = 0; i < data.length; i++) {
      final cx = slot * i + slot / 2;
      final d = data[i];

      final incH = (d.income / maxVal) * size.height * progress;
      final expH = (d.expense / maxVal) * size.height * progress;

      final incRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx - barW - gap / 2, size.height - incH, barW, incH),
        topLeft: radius,
        topRight: radius,
      );
      final expRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(cx + gap / 2, size.height - expH, barW, expH),
        topLeft: radius,
        topRight: radius,
      );

      canvas.drawRRect(incRect, Paint()..color = income);
      canvas.drawRRect(expRect, Paint()..color = expense);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter old) => old.progress != progress || old.data != data;
}

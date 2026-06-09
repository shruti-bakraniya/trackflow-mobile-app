import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SegmentOption<T> {
  const SegmentOption(this.value, this.label);
  final T value;
  final String label;
}

/// Pill segmented control with an animated sliding thumb.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.accent,
  });

  final List<SegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final idx = options.indexWhere((o) => o.value == value).clamp(0, options.length - 1);
    return LayoutBuilder(
      builder: (context, constraints) {
        const pad = 4.0;
        final thumbWidth = (constraints.maxWidth - pad * 2) / options.length;
        return Container(
          padding: const EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: AppColors.ink.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.ink.withValues(alpha: 0.10)),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                left: idx * thumbWidth,
                top: 0,
                bottom: 0,
                width: thumbWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: accent ?? AppColors.accent,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: options.map((o) {
                  final selected = o.value == value;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(o.value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: AppTheme.uiStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.inkSoft,
                          ),
                          textAlign: TextAlign.center,
                          child: Text(o.label, textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

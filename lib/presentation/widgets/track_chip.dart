import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glassmorphism.dart';

/// Pill filter/selection chip with an active accent state.
class TrackChip extends StatelessWidget {
  const TrackChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
    this.leading,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? color;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? (color ?? AppColors.accent) : Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: active ? Colors.transparent : AppColors.glassStroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: AppTheme.uiStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppColors.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

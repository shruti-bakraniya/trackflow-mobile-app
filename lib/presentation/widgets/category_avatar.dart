import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// Rounded, category-tinted glyph tile used throughout lists and grids.
class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({
    super.key,
    required this.categoryId,
    this.size = 44,
    this.radius,
  });

  final String categoryId;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byId(categoryId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppGradients.categoryGlow(cat.hue),
        borderRadius: BorderRadius.circular(radius ?? size * 0.32),
        boxShadow: [
          BoxShadow(
            color: AppColors.categoryColor(cat.hue).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Icon(cat.icon, color: Colors.white, size: size * 0.5),
    );
  }
}

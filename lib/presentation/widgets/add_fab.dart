import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AddFab extends StatelessWidget {
  const AddFab({
    super.key,
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentSoft, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

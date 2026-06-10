import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class NavDestination {
  const NavDestination(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Floating frosted bottom navigation with a raised center FAB notch.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _left = [
    NavDestination(Icons.home_rounded, 'Home'),
    NavDestination(Icons.receipt_long_rounded, 'Activity'),
  ];
  static const _right = [
    NavDestination(Icons.bar_chart_rounded, 'Stats'),
    NavDestination(Icons.track_changes_rounded, 'Budgets'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 14 + MediaQuery.of(context).padding.bottom * 0.4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.glassStroke),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D3426).withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _navItem(0, _left[0]),
                _navItem(1, _left[1]),
                const SizedBox(
                  width: 72,
                ),
                _navItem(2, _right[0]),
                _navItem(3, _right[1]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, NavDestination dest) {
    final active = currentIndex == index;
    final color = active ? AppColors.accent : AppColors.inkFaint;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(dest.icon, size: 23, color: color),
            const SizedBox(height: 3),
            Text(
              dest.label,
              style: AppTheme.uiStyle(
                fontSize: 9.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/transaction/transaction_bloc.dart';

/// Shows a non-disruptive frosted toast at the top of the screen for a save /
/// delete / budget-warning event. Tone drives colour + icon.
void showAppToast(BuildContext context, TransactionFeedback feedback) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ToastWidget(
      feedback: feedback,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _ToastConfig {
  const _ToastConfig(this.bg, this.border, this.icon, this.color);
  final Color bg;
  final Color border;
  final IconData icon;
  final Color color;
}

_ToastConfig _configFor(FeedbackTone tone) {
  switch (tone) {
    case FeedbackTone.danger:
      return _ToastConfig(
        AppColors.over.withValues(alpha: 0.20),
        AppColors.over.withValues(alpha: 0.50),
        Icons.warning_amber_rounded,
        AppColors.expense,
      );
    case FeedbackTone.warning:
      return _ToastConfig(
        AppColors.near.withValues(alpha: 0.22),
        AppColors.near.withValues(alpha: 0.55),
        Icons.info_outline_rounded,
        AppColors.warn,
      );
    case FeedbackTone.success:
      return _ToastConfig(
        Colors.white.withValues(alpha: 0.85),
        AppColors.glassStroke,
        Icons.check_circle_outline_rounded,
        AppColors.income,
      );
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({required this.feedback, required this.onDismiss});
  final TransactionFeedback feedback;
  final VoidCallback onDismiss;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _slide = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);

  @override
  void initState() {
    super.initState();
    _c.forward();
    Future.delayed(const Duration(milliseconds: 3400), _close);
  }

  Future<void> _close() async {
    if (!mounted) return;
    await _c.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(widget.feedback.tone);
    final top = MediaQuery.of(context).padding.top + 8;
    return Positioned(
      top: top,
      left: 14,
      right: 14,
      child: AnimatedBuilder(
        animation: _slide,
        builder: (context, child) => Opacity(
          opacity: _c.value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - _slide.value) * -24),
            child: child,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: _close,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              decoration: BoxDecoration(
                color: cfg.bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cfg.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(cfg.icon, size: 20, color: cfg.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.feedback.title,
                          style: AppTheme.uiStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                        if (widget.feedback.subtitle != null) ...[
                          const SizedBox(height: 1),
                          Text(
                            widget.feedback.subtitle!,
                            style: AppTheme.uiStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

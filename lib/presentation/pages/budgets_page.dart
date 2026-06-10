import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../widgets/category_avatar.dart';
import '../widgets/charts/linear_progress_bar.dart';
import '../widgets/charts/progress_ring.dart';
import '../widgets/count_up_text.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, budgetState) {
        final spend = context.watch<TransactionBloc>().state.monthSpendByCategory;
        final statuses = budgetState.budgets
            .map((b) => BudgetStatus(categoryId: b.categoryId, limit: b.limit, spent: spend[b.categoryId] ?? 0))
            .toList()
          ..sort((a, b) => b.ratio.compareTo(a.ratio));

        final totalLimit = statuses.fold<double>(0, (a, s) => a + s.limit);
        final totalSpent = statuses.fold<double>(0, (a, s) => a + s.spent);
        final unbudgeted = Categories.expense.where((c) => !budgetState.limitByCategory.containsKey(c.id)).toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 130),
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _OverviewCard(totalSpent: totalSpent, totalLimit: totalLimit),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Text('Category limits',
                  style: AppTheme.uiStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.inkSoft)),
            ),
            const SizedBox(height: 10),
            for (final s in statuses)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _BudgetRow(status: s, onEdit: () => _openEditor(context, s.categoryId, s.limit, s.spent)),
              ),
            if (unbudgeted.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: Text('Add a limit',
                    style: AppTheme.uiStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.inkSoft)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: unbudgeted
                      .map((c) => Pressable(
                            onTap: () => _openEditor(context, c.id, null, spend[c.id] ?? 0),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(9, 9, 13, 9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.glassStroke,
                                    style: BorderStyle.solid),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CategoryAvatar(categoryId: c.id, size: 28, radius: 9),
                                  const SizedBox(width: 8),
                                  Text(c.label,
                                      style: AppTheme.uiStyle(
                                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                                  const SizedBox(width: 6),
                                  Icon(Icons.add_rounded, size: 16, color: AppColors.inkFaint),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Formatters.monthYear(DateTime.now()),
                style: AppTheme.uiStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onBgSoft)),
            const SizedBox(height: 2),
            Text('Budgets',
                style: AppTheme.uiStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onBg)),
          ],
        ),
      );

  void _openEditor(BuildContext context, String categoryId, double? current, double spent) {
    final bloc = context.read<BudgetBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _BudgetEditSheet(categoryId: categoryId, current: current, spent: spent),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.totalSpent, required this.totalLimit});
  final double totalSpent;
  final double totalLimit;

  @override
  Widget build(BuildContext context) {
    final pct = totalLimit <= 0 ? 0.0 : (totalSpent / totalLimit * 100).clamp(0, 100).toDouble();
    final over = totalSpent > totalLimit;
    return GlassCard(
      borderRadius: 30,
      fillColor: const Color(0xFF0F5A3C).withValues(alpha: 0.14),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total spent this month',
                        style: AppTheme.uiStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        CountUpText(
                          value: totalSpent,
                          decimals: 0,
                          prefix: '\$',
                          style: AppTheme.numberStyle(fontSize: 34, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 4),
                        Text('/ ${Formatters.money(totalLimit, cents: false)}',
                            style: AppTheme.numberStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.inkFaint)),
                      ],
                    ),
                  ],
                ),
              ),
              ProgressRing(
                value: totalSpent,
                max: totalLimit <= 0 ? 1 : totalLimit,
                size: 58,
                thickness: 7,
                hue: 265,
                center: Text('${pct.round()}%',
                    style: AppTheme.numberStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressBar(percent: pct, color: over ? AppColors.expense : AppColors.accent),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.status, required this.onEdit});
  final BudgetStatus status;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byId(status.categoryId);
    final color = switch (status.level) {
      BudgetLevel.over => AppColors.expense,
      BudgetLevel.near => AppColors.near,
      BudgetLevel.ok => AppColors.income,
    };
    final pct = (status.ratio * 100).clamp(0, 100).toDouble();

    return Pressable(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: status.isOver ? AppColors.over.withValues(alpha: 0.10) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: status.isOver ? AppColors.over.withValues(alpha: 0.4) : AppColors.glassStroke,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CategoryAvatar(categoryId: status.categoryId, size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(cat.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.uiStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                          if (status.level != BudgetLevel.ok) ...[
                            const SizedBox(width: 7),
                            _badge(status.level),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${Formatters.money(status.spent, cents: false)} of ${Formatters.money(status.limit, cents: false)}',
                        style: AppTheme.numberStyle(
                            fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkFaint),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      status.remaining >= 0
                          ? Formatters.money(status.remaining, cents: false)
                          : '−${Formatters.money(status.remaining, cents: false).substring(1)}',
                      style: AppTheme.numberStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(status.remaining >= 0 ? 'left' : 'over',
                        style: AppTheme.uiStyle(
                            fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.inkFaint)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressBar(percent: pct, color: color),
          ],
        ),
      ),
    );
  }

  Widget _badge(BudgetLevel level) {
    final isOver = level == BudgetLevel.over;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isOver ? AppColors.over : AppColors.near,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOver) ...[
            const Icon(Icons.warning_amber_rounded, size: 11, color: Colors.white),
            const SizedBox(width: 3),
          ],
          Text(isOver ? 'Over budget' : 'Almost there',
              style: AppTheme.uiStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: isOver ? Colors.white : const Color(0xFF3A2A00))),
        ],
      ),
    );
  }
}

/// Bottom-sheet editor with a live slider + quick-pick chips.
class _BudgetEditSheet extends StatefulWidget {
  const _BudgetEditSheet({required this.categoryId, required this.current, required this.spent});
  final String categoryId;
  final double? current;
  final double spent;

  @override
  State<_BudgetEditSheet> createState() => _BudgetEditSheetState();
}

class _BudgetEditSheetState extends State<_BudgetEditSheet> {
  late double _val = widget.current ?? 200;

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byId(widget.categoryId);
    final status = BudgetStatus(categoryId: widget.categoryId, limit: _val, spent: widget.spent);
    final color = switch (status.level) {
      BudgetLevel.over => AppColors.expense,
      BudgetLevel.near => AppColors.near,
      BudgetLevel.ok => AppColors.income,
    };
    final label = switch (status.level) {
      BudgetLevel.over => 'Over budget',
      BudgetLevel.near => 'Almost there',
      BudgetLevel.ok => 'On track',
    };

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(22, 14, 22, 36 + MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.ink.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                CategoryAvatar(categoryId: widget.categoryId, size: 50),
                const SizedBox(width: 13),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cat.label, style: AppTheme.uiStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                    Text('Monthly limit',
                        style: AppTheme.uiStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.inkFaint)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('\$${_val.round()}',
                style: AppTheme.numberStyle(fontSize: 46, fontWeight: FontWeight.w700, color: AppColors.accent)),
            const SizedBox(height: 6),
            Text('${Formatters.money(widget.spent, cents: false)} spent · $label',
                style: AppTheme.uiStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 14),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                thumbColor: Colors.white,
                overlayColor: color.withValues(alpha: 0.15),
                inactiveTrackColor: AppColors.ink.withValues(alpha: 0.12),
                trackHeight: 6,
              ),
              child: Slider(
                min: 50,
                max: 1000,
                divisions: 95,
                value: _val.clamp(50, 1000),
                onChanged: (v) => setState(() => _val = v),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('\$50', style: AppTheme.uiStyle(fontSize: 10.5, color: AppColors.inkFaint)),
                Text('\$1,000', style: AppTheme.uiStyle(fontSize: 10.5, color: AppColors.inkFaint)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [200, 350, 500].map((v) {
                final selected = _val.round() == v;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _val = v.toDouble()),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.accent.withValues(alpha: 0.15) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassStroke),
                        ),
                        child: Text('\$$v',
                            style: AppTheme.uiStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<BudgetBloc>().add(BudgetSet(Budget(categoryId: widget.categoryId, limit: _val)));
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(widget.current != null ? 'Update limit' : 'Set limit',
                    style: AppTheme.uiStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
            if (widget.current != null)
              TextButton(
                onPressed: () {
                  context.read<BudgetBloc>().add(BudgetRemoved(widget.categoryId));
                  Navigator.of(context).pop();
                },
                child: Text('Remove budget',
                    style: AppTheme.uiStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.expense)),
              ),
          ],
        ),
      ),
    );
  }
}

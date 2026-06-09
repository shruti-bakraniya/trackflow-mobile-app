import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/budget/budget_bloc.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../widgets/count_up_text.dart';
import '../widgets/transaction_tile.dart';

/// Overview dashboard: greeting, net-balance hero, income/expense pills,
/// a budget-alert strip and recent activity.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onOpenTransaction,
    required this.onSeeAll,
    required this.onOpenBudgets,
  });

  final void Function(Transaction) onOpenTransaction;
  final VoidCallback onSeeAll;
  final VoidCallback onOpenBudgets;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, txState) {
        final recent = txState.transactions.take(5).toList();
        final hour = DateTime.now().hour;
        final greet = hour < 12
            ? 'Good morning'
            : hour < 18
                ? 'Good afternoon'
                : 'Good evening';

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 130),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greet, Alex',
                      style: AppTheme.uiStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onBgSoft)),
                  const SizedBox(height: 2),
                  Text('This Month',
                      style: AppTheme.uiStyle(
                          fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.onBg)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _BalanceHero(
                balance: txState.monthBalance,
                income: txState.monthIncome,
                expense: txState.monthExpense,
              ),
            ),
            _BudgetAlert(onTap: onOpenBudgets),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent activity',
                      style: AppTheme.uiStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: onSeeAll,
                    child: Text('See all',
                        style: AppTheme.uiStyle(
                            fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentSoft)),
                  ),
                ],
              ),
            ),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GlassCard(
                  child: Center(
                    child: Text('No transactions yet',
                        style: AppTheme.uiStyle(color: AppColors.inkSoft, fontWeight: FontWeight.w700)),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    children: [
                      for (var i = 0; i < recent.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 56),
                            child: Divider(height: 1, color: AppColors.ink.withValues(alpha: 0.06)),
                          ),
                        TransactionTile(
                          transaction: recent[i],
                          onTap: () => onOpenTransaction(recent[i]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.balance, required this.income, required this.expense});
  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 30,
      fillColor: const Color(0xFF0F5A3C).withValues(alpha: 0.14),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.inkSoft),
              const SizedBox(width: 8),
              Text('Net balance',
                  style: AppTheme.uiStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('\$',
                  style: AppTheme.numberStyle(
                      fontSize: 21, fontWeight: FontWeight.w600, color: AppColors.inkSoft)),
              CountUpText(
                value: balance,
                decimals: 2,
                style: AppTheme.numberStyle(fontSize: 44, fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  color: AppColors.income,
                  icon: Icons.south_rounded,
                  label: 'Income',
                  value: income,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  color: AppColors.expense,
                  icon: Icons.north_rounded,
                  label: 'Expense',
                  value: expense,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.color, required this.icon, required this.label, required this.value});
  final Color color;
  final IconData icon;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: AppTheme.uiStyle(
                      fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.inkFaint)),
              Text(Formatters.money(value, cents: false),
                  style: AppTheme.numberStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Surfaces the worst over/near budget as a tappable strip (amber/red).
class _BudgetAlert extends StatelessWidget {
  const _BudgetAlert({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final txState = context.watch<TransactionBloc>().state;
    final budgets = context.watch<BudgetBloc>().state.budgets;
    final spend = txState.monthSpendByCategory;

    final alerts = budgets
        .map((b) => BudgetStatus(categoryId: b.categoryId, limit: b.limit, spent: spend[b.categoryId] ?? 0))
        .where((s) => s.ratio >= 0.8)
        .toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));

    if (alerts.isEmpty) return const SizedBox.shrink();
    final worst = alerts.first;
    final over = worst.isOver;
    final label = Categories.byId(worst.categoryId).label;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: (over ? AppColors.over : AppColors.near).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: (over ? AppColors.over : AppColors.near).withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (over ? AppColors.over : AppColors.near).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.warning_amber_rounded,
                    size: 20, color: over ? AppColors.expense : AppColors.warn),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(over ? '$label budget exceeded' : '$label almost maxed',
                        style: AppTheme.uiStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 1),
                    Text(
                      '${Formatters.money(worst.spent, cents: false)} of ${Formatters.money(worst.limit, cents: false)}'
                      '${alerts.length > 1 ? ' · +${alerts.length - 1} more' : ''}',
                      style: AppTheme.uiStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.inkSoft),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.inkFaint),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/statistics.dart';
import '../bloc/statistics/statistics_cubit.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../widgets/charts/donut_chart.dart';
import '../widgets/charts/linear_progress_bar.dart';
import '../widgets/charts/progress_ring.dart';
import '../widgets/charts/trend_bar_chart.dart';
import '../widgets/count_up_text.dart';
import '../widgets/segmented_control.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recompute statistics whenever the underlying transactions change.
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (a, b) => a.transactions != b.transactions,
      listener: (context, _) => context.read<StatisticsCubit>().load(),
      child: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          final stats = state.statistics;
          return ListView(
            padding: const EdgeInsets.only(bottom: 130),
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedControl<StatsPeriod>(
                  value: state.period,
                  onChanged: (p) => context.read<StatisticsCubit>().changePeriod(p),
                  options: const [
                    SegmentOption(StatsPeriod.week, 'Week'),
                    SegmentOption(StatsPeriod.month, 'Month'),
                    SegmentOption(StatsPeriod.year, 'Year'),
                  ],
                ),
              ),
              _DonutCard(stats: stats),
              _CashFlowRow(stats: stats),
              _TrendCard(stats: stats),
            ],
          );
        },
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Insights & trends',
                style: AppTheme.uiStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onBgSoft)),
            const SizedBox(height: 2),
            Text('Statistics',
                style: AppTheme.uiStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onBg)),
          ],
        ),
      );
}

class _DonutCard extends StatelessWidget {
  const _DonutCard({required this.stats});
  final Statistics stats;

  @override
  Widget build(BuildContext context) {
    final slices = stats.expenseByCategory;
    final top = slices.take(5).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GlassCard(
        borderRadius: 30,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Where it went',
                style: AppTheme.uiStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Expenses by category',
                style: AppTheme.uiStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.inkFaint)),
            const SizedBox(height: 14),
            if (slices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Text('No expenses this period',
                      style: AppTheme.uiStyle(color: AppColors.inkFaint, fontWeight: FontWeight.w600)),
                ),
              )
            else
              Row(
                children: [
                  DonutChart(
                    size: 150,
                    thickness: 22,
                    segments: slices
                        .map((s) => DonutSegment(
                              value: s.total,
                              color: AppColors.categoryChartColor(Categories.byId(s.categoryId).hue),
                            ))
                        .toList(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('SPENT',
                            style: AppTheme.uiStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkFaint,
                                letterSpacing: 0.5)),
                        CountUpText(
                          value: stats.totalExpense,
                          decimals: 0,
                          prefix: '\$',
                          style: AppTheme.numberStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        Text('${slices.length} categories',
                            style: AppTheme.uiStyle(
                                fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.inkFaint)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: top.map((s) {
                        final cat = Categories.byId(s.categoryId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.categoryChartColor(cat.hue),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(cat.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.uiStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.inkSoft)),
                              ),
                              Text('${(s.ratio * 100).round()}%',
                                  style: AppTheme.numberStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CashFlowRow extends StatelessWidget {
  const _CashFlowRow({required this.stats});
  final Statistics stats;

  @override
  Widget build(BuildContext context) {
    final maxVal = (stats.totalIncome > stats.totalExpense ? stats.totalIncome : stats.totalExpense);
    double pct(double v) => maxVal <= 0 ? 0 : v / maxVal * 100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cash flow',
                      style: AppTheme.uiStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkFaint)),
                  const SizedBox(height: 10),
                  _flowRow('Income', stats.totalIncome, AppColors.income, pct(stats.totalIncome)),
                  const SizedBox(height: 9),
                  _flowRow('Expense', stats.totalExpense, AppColors.expense, pct(stats.totalExpense)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: SizedBox(
              width: 88,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProgressRing(
                    value: stats.savingsRate.clamp(0, 100).toDouble(),
                    max: 100,
                    size: 72,
                    thickness: 8,
                    hue: 155,
                    center: Text('${stats.savingsRate}%',
                        style: AppTheme.numberStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 8),
                  Text('Savings rate',
                      textAlign: TextAlign.center,
                      style: AppTheme.uiStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.inkFaint)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _flowRow(String label, double value, Color color, double pct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.uiStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
            Text(Formatters.money(value, cents: false),
                style: AppTheme.numberStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressBar(percent: pct, color: color),
      ],
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.stats});
  final Statistics stats;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassCard(
        borderRadius: 30,
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Trend', style: AppTheme.uiStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                Row(
                  children: [
                    _legend('In', AppColors.income),
                    const SizedBox(width: 12),
                    _legend('Out', AppColors.expense),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            TrendBarChart(data: stats.trend),
          ],
        ),
      ),
    );
  }

  Widget _legend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTheme.uiStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
      ],
    );
  }
}

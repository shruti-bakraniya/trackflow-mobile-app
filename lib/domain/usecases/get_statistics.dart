import '../../core/errors/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/statistics.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Aggregates the raw transaction list into period-scoped [Statistics]:
/// totals, the per-category expense breakdown (for the donut) and a trend
/// series (for the bar chart). This is pure business logic — no UI, no I/O
/// beyond the repository read — so it's fully unit-testable.
class GetStatistics implements UseCase<Statistics, StatsPeriod> {
  const GetStatistics(this._repository);
  final TransactionRepository _repository;

  static const _msPerDay = 86400000;

  @override
  Future<Either<Failure, Statistics>> call(StatsPeriod period) async {
    final result = await _repository.getTransactions();
    return result.fold<Either<Failure, Statistics>>(
      (failure) => Left(failure),
      (txns) => Right(_compute(txns, period)),
    );
  }

  Statistics _compute(List<Transaction> txns, StatsPeriod period) {
    final now = _today();
    final scoped = txns.where((t) => _inPeriod(t.date, now, period)).toList();

    final totalIncome = _sum(scoped, TransactionType.income);
    final totalExpense = _sum(scoped, TransactionType.expense);

    // ── donut: expense by category ──
    final byCat = <String, double>{};
    for (final t in scoped.where((t) => t.type.isExpense)) {
      byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + t.amount;
    }
    final slices = byCat.entries
        .map((e) => CategorySlice(
              categoryId: e.key,
              total: e.value,
              ratio: totalExpense <= 0 ? 0 : e.value / totalExpense,
            ))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    // ── trend series ──
    final trend = _buildTrend(txns, now, period);

    return Statistics(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      expenseByCategory: slices,
      trend: trend,
    );
  }

  List<TrendPoint> _buildTrend(List<Transaction> txns, DateTime now, StatsPeriod period) {
    const weekdayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const monthInitials = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    final points = <TrendPoint>[];

    switch (period) {
      case StatsPeriod.week:
        for (var i = 6; i >= 0; i--) {
          final day = now.subtract(Duration(days: i));
          final dayTx = txns.where((t) => _sameDay(t.date, day));
          points.add(TrendPoint(
            label: weekdayInitials[(day.weekday - 1) % 7],
            income: _sum(dayTx, TransactionType.income),
            expense: _sum(dayTx, TransactionType.expense),
          ));
        }
      case StatsPeriod.month:
        for (var w = 0; w < 4; w++) {
          final lo = now.millisecondsSinceEpoch - (4 - w) * 7 * _msPerDay;
          final hi = now.millisecondsSinceEpoch - (3 - w) * 7 * _msPerDay;
          final wTx = txns.where((t) {
            final x = t.date.millisecondsSinceEpoch;
            return x > lo && x <= hi;
          });
          points.add(TrendPoint(
            label: 'W${w + 1}',
            income: _sum(wTx, TransactionType.income),
            expense: _sum(wTx, TransactionType.expense),
          ));
        }
      case StatsPeriod.year:
        for (var m = 0; m < 12; m++) {
          final mTx = txns.where((t) => t.date.year == now.year && t.date.month == m + 1);
          points.add(TrendPoint(
            label: monthInitials[m],
            income: _sum(mTx, TransactionType.income),
            expense: _sum(mTx, TransactionType.expense),
          ));
        }
    }
    return points;
  }

  bool _inPeriod(DateTime date, DateTime now, StatsPeriod period) {
    switch (period) {
      case StatsPeriod.week:
        return now.difference(date).inMilliseconds / _msPerDay <= 7;
      case StatsPeriod.month:
        return date.year == now.year && date.month == now.month;
      case StatsPeriod.year:
        return date.year == now.year;
    }
  }

  double _sum(Iterable<Transaction> txns, TransactionType type) {
    return txns.where((t) => t.type == type).fold(0.0, (a, t) => a + t.amount);
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, 12);
  }
}

import 'package:equatable/equatable.dart';

/// One slice of the expense/income breakdown: how much a single category
/// contributed over the selected period.
class CategorySlice extends Equatable {
  const CategorySlice({
    required this.categoryId,
    required this.total,
    required this.ratio,
  });

  final String categoryId;
  final double total;

  /// Fraction of the relevant total (0..1) this category represents.
  final double ratio;

  @override
  List<Object?> get props => [categoryId, total, ratio];
}

/// One bucket of the trend chart (a day / week / month).
class TrendPoint extends Equatable {
  const TrendPoint({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label;
  final double income;
  final double expense;

  @override
  List<Object?> get props => [label, income, expense];
}

/// Aggregated statistics for a period — everything the Statistics screen
/// needs in one immutable bundle, computed in the domain layer.
class Statistics extends Equatable {
  const Statistics({
    required this.totalIncome,
    required this.totalExpense,
    required this.expenseByCategory,
    required this.trend,
  });

  final double totalIncome;
  final double totalExpense;
  final List<CategorySlice> expenseByCategory;
  final List<TrendPoint> trend;

  double get balance => totalIncome - totalExpense;

  int get savingsRate {
    if (totalIncome <= 0) return 0;
    return (((totalIncome - totalExpense) / totalIncome) * 100).round();
  }

  static const empty = Statistics(
    totalIncome: 0,
    totalExpense: 0,
    expenseByCategory: [],
    trend: [],
  );

  @override
  List<Object?> get props => [totalIncome, totalExpense, expenseByCategory, trend];
}

/// Which window the statistics are computed over.
enum StatsPeriod { week, month, year }

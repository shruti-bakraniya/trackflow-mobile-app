part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, loaded, failure }

/// Quick relative-time filters for the activity list.
enum DateRangeFilter {
  all('All time'),
  days7('7 days'),
  days30('30 days'),
  month('This month');

  const DateRangeFilter(this.label);
  final String label;
}

enum FeedbackTone { success, warning, danger }

/// One-shot user feedback (toast/snackbar). Carries a unique [id] so two
/// otherwise-identical messages still register as a distinct state change.
class TransactionFeedback extends Equatable {
  const TransactionFeedback({
    required this.id,
    required this.title,
    this.subtitle,
    this.tone = FeedbackTone.success,
  });

  final int id;
  final String title;
  final String? subtitle;
  final FeedbackTone tone;

  @override
  List<Object?> get props => [id, title, subtitle, tone];
}

class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.query = '',
    this.typeFilter,
    this.categoryFilter = const {},
    this.range = DateRangeFilter.all,
    this.errorMessage,
    this.feedback,
  });

  final TransactionStatus status;
  final List<Transaction> transactions; // all, newest first
  final String query;
  final TransactionType? typeFilter; // null = all types
  final Set<String> categoryFilter;
  final DateRangeFilter range;
  final String? errorMessage;
  final TransactionFeedback? feedback;

  int get activeFilterCount =>
      (typeFilter != null ? 1 : 0) + categoryFilter.length + (range != DateRangeFilter.all ? 1 : 0);

  /// The list after applying search + filters (used by the Activity screen).
  List<Transaction> get filtered {
    final now = DateTime.now();
    final q = query.trim().toLowerCase();
    return transactions.where((t) {
      if (typeFilter != null && t.type != typeFilter) return false;
      if (categoryFilter.isNotEmpty && !categoryFilter.contains(t.categoryId)) return false;
      if (q.isNotEmpty) {
        final label = Categories.byId(t.categoryId).label;
        final hay = '${t.note} $label'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      switch (range) {
        case DateRangeFilter.all:
          break;
        case DateRangeFilter.month:
          if (t.date.year != now.year || t.date.month != now.month) return false;
        case DateRangeFilter.days7:
          if (now.difference(t.date).inDays > 7) return false;
        case DateRangeFilter.days30:
          if (now.difference(t.date).inDays > 30) return false;
      }
      return true;
    }).toList();
  }

  /// Income / expense / balance for the current calendar month.
  double get monthIncome => _monthSum(TransactionType.income);
  double get monthExpense => _monthSum(TransactionType.expense);
  double get monthBalance => monthIncome - monthExpense;

  double _monthSum(TransactionType type) {
    final now = DateTime.now();
    return transactions
        .where((t) => t.type == type && t.date.year == now.year && t.date.month == now.month)
        .fold(0.0, (a, t) => a + t.amount);
  }

  /// Expense spend per category for the current month (for budget warnings).
  Map<String, double> get monthSpendByCategory {
    final now = DateTime.now();
    final m = <String, double>{};
    for (final t in transactions.where(
      (t) => t.type.isExpense && t.date.year == now.year && t.date.month == now.month,
    )) {
      m[t.categoryId] = (m[t.categoryId] ?? 0) + t.amount;
    }
    return m;
  }

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? transactions,
    String? query,
    TransactionType? Function()? typeFilter,
    Set<String>? categoryFilter,
    DateRangeFilter? range,
    String? Function()? errorMessage,
    TransactionFeedback? Function()? feedback,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      query: query ?? this.query,
      typeFilter: typeFilter != null ? typeFilter() : this.typeFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      range: range ?? this.range,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      feedback: feedback != null ? feedback() : this.feedback,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        query,
        typeFilter,
        categoryFilter,
        range,
        errorMessage,
        feedback,
      ];
}

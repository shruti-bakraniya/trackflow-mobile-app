import 'package:equatable/equatable.dart';

/// Whether money came in or went out.
enum TransactionType {
  expense,
  income;

  bool get isExpense => this == TransactionType.expense;
  bool get isIncome => this == TransactionType.income;

  String get asString => name; // 'expense' | 'income'

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}

/// Pure-Dart domain entity for a single money movement.
///
/// No Flutter / sqflite imports here by design — this is the stable contract
/// the whole app reasons about, independent of how it's stored or rendered.
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note = '',
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String note;

  /// Signed value: positive for income, negative for expense. Handy for
  /// computing running balances and daily nets.
  double get signedAmount => type.isIncome ? amount : -amount;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, type, amount, categoryId, date, note];
}

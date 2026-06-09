import '../../core/constants/app_constants.dart';
import '../../domain/entities/transaction.dart';

/// Data-layer representation of a [Transaction] with sqflite (de)serialization.
///
/// Dates are stored as `yyyy-MM-dd` strings and re-hydrated at noon, matching
/// the day-granularity the app reasons about (avoids timezone drift around
/// midnight when bucketing into days/weeks).
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.categoryId,
    required super.date,
    super.note,
  });

  factory TransactionModel.fromEntity(Transaction t) {
    return TransactionModel(
      id: t.id,
      type: t.type,
      amount: t.amount,
      categoryId: t.categoryId,
      date: t.date,
      note: t.note,
    );
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map[AppConstants.colId] as String,
      type: TransactionType.fromString(map[AppConstants.colType] as String),
      amount: (map[AppConstants.colAmount] as num).toDouble(),
      categoryId: map[AppConstants.colCategory] as String,
      date: _parseDate(map[AppConstants.colDate] as String),
      note: (map[AppConstants.colNote] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      AppConstants.colId: id,
      AppConstants.colType: type.asString,
      AppConstants.colAmount: amount,
      AppConstants.colCategory: categoryId,
      AppConstants.colDate: _formatDate(date),
      AppConstants.colNote: note,
      AppConstants.colCreatedAt: DateTime.now().millisecondsSinceEpoch,
    };
  }

  static String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static DateTime _parseDate(String iso) {
    final parts = iso.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
      12, // noon
    );
  }
}

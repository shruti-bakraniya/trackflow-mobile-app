part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

/// Load (or reload) all transactions from storage.
class TransactionsRequested extends TransactionEvent {
  const TransactionsRequested();
}

class TransactionAdded extends TransactionEvent {
  const TransactionAdded(this.transaction);
  final Transaction transaction;
  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionEvent {
  const TransactionUpdated(this.transaction);
  final Transaction transaction;
  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionEvent {
  const TransactionDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

// ── search & filter ─────────────────────────────────────────
class SearchQueryChanged extends TransactionEvent {
  const SearchQueryChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class TypeFilterChanged extends TransactionEvent {
  const TypeFilterChanged(this.type); // null = all
  final TransactionType? type;
  @override
  List<Object?> get props => [type];
}

class CategoryFilterToggled extends TransactionEvent {
  const CategoryFilterToggled(this.categoryId);
  final String categoryId;
  @override
  List<Object?> get props => [categoryId];
}

class DateRangeFilterChanged extends TransactionEvent {
  const DateRangeFilterChanged(this.range);
  final DateRangeFilter range;
  @override
  List<Object?> get props => [range];
}

class FiltersCleared extends TransactionEvent {
  const FiltersCleared();
}

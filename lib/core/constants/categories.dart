import 'package:flutter/material.dart';

import '../../domain/entities/transaction.dart';

/// Static metadata for a spending / income category.
///
/// This lives in `core/constants` (not the domain layer) on purpose: the
/// domain only ever deals with the category *id* string, while the UI needs
/// the human label, glyph and hue. Colours are derived from [hue] via the
/// helpers in `core/theme/app_colors.dart` so the palette stays consistent.
@immutable
class AppCategory {
  const AppCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.hue,
    required this.type,
  });

  final String id;
  final String label;
  final IconData icon;
  final double hue;
  final TransactionType type;
}

/// Registry of every category plus convenient lookups.
class Categories {
  Categories._();

  static const List<AppCategory> expense = [
    AppCategory(id: 'meals', label: 'Meals', icon: Icons.restaurant, hue: 18, type: TransactionType.expense),
    AppCategory(id: 'transport', label: 'Transport', icon: Icons.directions_bus_filled, hue: 255, type: TransactionType.expense),
    AppCategory(id: 'shopping', label: 'Shopping', icon: Icons.shopping_bag, hue: 320, type: TransactionType.expense),
    AppCategory(id: 'fun', label: 'Entertainment', icon: Icons.sentiment_satisfied_alt, hue: 285, type: TransactionType.expense),
    AppCategory(id: 'grocery', label: 'Groceries', icon: Icons.local_grocery_store, hue: 145, type: TransactionType.expense),
    AppCategory(id: 'bills', label: 'Bills', icon: Icons.receipt_long, hue: 200, type: TransactionType.expense),
    AppCategory(id: 'health', label: 'Health', icon: Icons.favorite, hue: 165, type: TransactionType.expense),
    AppCategory(id: 'home', label: 'Home', icon: Icons.cottage, hue: 45, type: TransactionType.expense),
  ];

  static const List<AppCategory> income = [
    AppCategory(id: 'salary', label: 'Salary', icon: Icons.payments, hue: 152, type: TransactionType.income),
    AppCategory(id: 'freelance', label: 'Freelance', icon: Icons.work, hue: 190, type: TransactionType.income),
    AppCategory(id: 'invest', label: 'Investment', icon: Icons.trending_up, hue: 95, type: TransactionType.income),
    AppCategory(id: 'gift', label: 'Gift', icon: Icons.card_giftcard, hue: 310, type: TransactionType.income),
  ];

  static const List<AppCategory> all = [...expense, ...income];

  /// Returns the matching category, falling back to the first expense
  /// category so the UI never has to deal with a null glyph.
  static AppCategory byId(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => expense.first,
    );
  }

  static List<AppCategory> forType(TransactionType type) {
    return type == TransactionType.expense ? expense : income;
  }
}

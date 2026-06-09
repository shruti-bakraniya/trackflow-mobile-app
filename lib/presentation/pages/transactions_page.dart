import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../widgets/track_chip.dart';
import '../widgets/transaction_tile.dart';

/// Full transaction list with live search, type chips, an expandable filter
/// panel (time range + categories) and day-grouped results.
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, required this.onOpenTransaction});
  final void Function(Transaction) onOpenTransaction;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final bloc = context.read<TransactionBloc>();
        final filtered = state.filtered;
        final groups = _groupByDate(filtered);

        return ListView(
          padding: const EdgeInsets.only(bottom: 130),
          children: [
            _Header(count: filtered.length),
            // search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GlassCard(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  height: 46,
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20, color: AppColors.inkFaint),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => bloc.add(SearchQueryChanged(v)),
                          style: AppTheme.uiStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            hintText: 'Search notes, categories…',
                            hintStyle: AppTheme.uiStyle(
                                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.inkFaint),
                          ),
                        ),
                      ),
                      if (state.query.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            bloc.add(const SearchQueryChanged(''));
                          },
                          child: Icon(Icons.close_rounded, size: 18, color: AppColors.inkFaint),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // type chips + filter toggle
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                children: [
                  TrackChip(
                    label: 'All',
                    active: state.typeFilter == null,
                    onTap: () => bloc.add(const TypeFilterChanged(null)),
                  ),
                  const SizedBox(width: 8),
                  TrackChip(
                    label: 'Expense',
                    color: AppColors.expense,
                    active: state.typeFilter == TransactionType.expense,
                    onTap: () => bloc.add(const TypeFilterChanged(TransactionType.expense)),
                  ),
                  const SizedBox(width: 8),
                  TrackChip(
                    label: 'Income',
                    color: AppColors.income,
                    active: state.typeFilter == TransactionType.income,
                    onTap: () => bloc.add(const TypeFilterChanged(TransactionType.income)),
                  ),
                  const SizedBox(width: 10),
                  TrackChip(
                    label: 'Filters${state.activeFilterCount > 0 ? ' · ${state.activeFilterCount}' : ''}',
                    active: _showFilters || state.activeFilterCount > 0,
                    leading: Icon(Icons.tune_rounded,
                        size: 15,
                        color: (_showFilters || state.activeFilterCount > 0)
                            ? Colors.white
                            : AppColors.inkSoft),
                    onTap: () => setState(() => _showFilters = !_showFilters),
                  ),
                ],
              ),
            ),
            if (_showFilters) _FilterPanel(state: state, bloc: bloc),
            if (groups.isEmpty)
              _EmptyState()
            else
              for (final g in groups) _DayGroup(group: g, onOpen: widget.onOpenTransaction),
          ],
        );
      },
    );
  }

  List<_DateGroupData> _groupByDate(List<Transaction> txns) {
    final groups = <_DateGroupData>[];
    for (final t in txns) {
      final key = '${t.date.year}-${t.date.month}-${t.date.day}';
      if (groups.isNotEmpty && groups.last.key == key) {
        groups.last.items.add(t);
      } else {
        groups.add(_DateGroupData(key, t.date)..items.add(t));
      }
    }
    return groups;
  }
}

class _DateGroupData {
  _DateGroupData(this.key, this.date);
  final String key;
  final DateTime date;
  final List<Transaction> items = [];

  double get net => items.fold(0.0, (a, t) => a + t.signedAmount);
}

class _Header extends StatelessWidget {
  const _Header({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count transactions',
              style: AppTheme.uiStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onBgSoft)),
          const SizedBox(height: 2),
          Text('Activity', style: AppTheme.uiStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.onBg)),
        ],
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.state, required this.bloc});
  final TransactionState state;
  final TransactionBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('TIME RANGE'),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DateRangeFilter.values
                  .map((r) => TrackChip(
                        label: r.label,
                        active: state.range == r,
                        onTap: () => bloc.add(DateRangeFilterChanged(r)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            _label('CATEGORIES'),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Categories.all
                  .map((c) => TrackChip(
                        label: c.label,
                        active: state.categoryFilter.contains(c.id),
                        color: AppColors.categoryColor(c.hue),
                        onTap: () => bloc.add(CategoryFilterToggled(c.id)),
                      ))
                  .toList(),
            ),
            if (state.activeFilterCount > 0) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => bloc.add(const FiltersCleared()),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.glassStroke),
                  ),
                  child: Text('Clear all filters',
                      style: AppTheme.uiStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: AppTheme.uiStyle(
          fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.inkFaint, letterSpacing: 0.5));
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.group, required this.onOpen});
  final _DateGroupData group;
  final void Function(Transaction) onOpen;

  @override
  Widget build(BuildContext context) {
    final net = group.net;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Formatters.dateLabel(group.date),
                    style: AppTheme.uiStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkFaint)),
                Text('${net >= 0 ? '+' : '−'}${Formatters.money(net).substring(1)}',
                    style: AppTheme.numberStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: net >= 0 ? AppColors.income : AppColors.inkFaint)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < group.items.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Divider(height: 1, color: AppColors.ink.withValues(alpha: 0.06)),
                      ),
                    TransactionTile(transaction: group.items[i], onTap: () => onOpen(group.items[i])),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.search_off_rounded, size: 28, color: AppColors.inkFaint),
          ),
          const SizedBox(height: 14),
          Text('No transactions found',
              style: AppTheme.uiStyle(fontWeight: FontWeight.w700, color: AppColors.inkSoft)),
          const SizedBox(height: 4),
          Text('Try adjusting your filters',
              style: AppTheme.uiStyle(fontSize: 13, color: AppColors.inkFaint)),
        ],
      ),
    );
  }
}

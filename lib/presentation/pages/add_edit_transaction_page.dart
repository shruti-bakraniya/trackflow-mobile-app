import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction/transaction_bloc.dart';
import '../widgets/category_avatar.dart';
import '../widgets/segmented_control.dart';
import '../widgets/track_chip.dart';

/// Add or edit a transaction: type toggle, custom glass keypad, category
/// grid, date chips + native picker and a note field. Saving dispatches to
/// [TransactionBloc]; the budget-aware toast is raised by the shell listener.
class AddEditTransactionPage extends StatefulWidget {
  const AddEditTransactionPage({super.key, this.existing});
  final Transaction? existing;

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  late TransactionType _type = widget.existing?.type ?? TransactionType.expense;
  late String _amountStr =
      widget.existing != null ? _trimZeros(widget.existing!.amount) : '0';
  late String? _categoryId = widget.existing?.categoryId;
  late DateTime _date = widget.existing?.date ?? _today();
  late final TextEditingController _noteController =
      TextEditingController(text: widget.existing?.note ?? '');

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, 12);
  }

  static String _trimZeros(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? s.substring(0, s.length - 3) : s;
  }

  double get _amount => double.tryParse(_amountStr) ?? 0;
  bool get _valid => _amount > 0 && _categoryId != null;
  bool get _isEditing => widget.existing != null;

  List<AppCategory> get _cats => Categories.forType(_type);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onType(TransactionType type) {
    setState(() {
      _type = type;
      if (_categoryId != null && !_cats.any((c) => c.id == _categoryId)) {
        _categoryId = null;
      }
    });
  }

  void _onKey(String k) {
    setState(() {
      var s = _amountStr;
      if (k == 'del') {
        s = s.length <= 1 ? '0' : s.substring(0, s.length - 1);
      } else if (k == '.') {
        if (!s.contains('.')) s = '$s.';
      } else {
        if (s.contains('.') && s.split('.')[1].length >= 2) return;
        if (s.replaceAll('.', '').length >= 7) return;
        s = s == '0' ? k : '$s$k';
      }
      _amountStr = s;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: _today(),
    );
    if (picked != null) setState(() => _date = DateTime(picked.year, picked.month, picked.day, 12));
  }

  void _submit() {
    if (!_valid) return;
    final tx = Transaction(
      id: widget.existing?.id ?? '',
      type: _type,
      amount: (_amount * 100).roundToDouble() / 100,
      categoryId: _categoryId!,
      date: _date,
      note: _noteController.text.trim(),
    );
    final bloc = context.read<TransactionBloc>();
    if (_isEditing) {
      bloc.add(TransactionUpdated(tx));
    } else {
      bloc.add(TransactionAdded(tx));
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    if (!_isEditing) return;
    context.read<TransactionBloc>().add(TransactionDeleted(widget.existing!.id));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _type.isIncome ? AppColors.income : AppColors.expense;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _iconButton(Icons.close_rounded, AppColors.ink, () => Navigator.of(context).pop()),
                  Text(_isEditing ? 'Edit' : 'New Transaction',
                      style: AppTheme.uiStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onBg)),
                  if (_isEditing)
                    _iconButton(Icons.delete_outline_rounded, AppColors.expense, _delete,
                        bg: AppColors.over.withValues(alpha: 0.16),
                        border: AppColors.over.withValues(alpha: 0.4))
                  else
                    const SizedBox(width: 38),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                child: Column(
                  children: [
                    SegmentedControl<TransactionType>(
                      value: _type,
                      accent: accent,
                      onChanged: _onType,
                      options: const [
                        SegmentOption(TransactionType.expense, 'Expense'),
                        SegmentOption(TransactionType.income, 'Income'),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: FittedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(_type.isIncome ? '+\$' : '−\$',
                                style: AppTheme.numberStyle(
                                    fontSize: 26, fontWeight: FontWeight.w600, color: accent)),
                            const SizedBox(width: 3),
                            Text(_amountStr,
                                style: AppTheme.numberStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w700,
                                    color: _amount > 0 ? AppColors.ink : AppColors.inkFaint)),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('CATEGORY',
                          style: AppTheme.uiStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkFaint,
                              letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 8),
                    _categoryGrid(),
                    const SizedBox(height: 14),
                    _dateRow(),
                    const SizedBox(height: 12),
                    _noteField(),
                  ],
                ),
              ),
            ),
            // footer keypad + save
            Container(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.ink.withValues(alpha: 0.06))),
              ),
              child: Column(
                children: [
                  _Keypad(onKey: _onKey),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _valid ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                      ),
                      child: Text(
                        _isEditing
                            ? 'Save changes'
                            : _type.isIncome
                                ? 'Add income'
                                : 'Add expense',
                        style: AppTheme.uiStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _valid ? Colors.white : AppColors.inkFaint),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, Color color, VoidCallback onTap, {Color? bg, Color? border}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bg ?? Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border ?? AppColors.glassStroke),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _categoryGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
      children: _cats.map((c) {
        final on = _categoryId == c.id;
        return GestureDetector(
          onTap: () => setState(() => _categoryId = c.id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CategoryAvatar(categoryId: c.id, size: 46, radius: 15),
                  if (on)
                    Positioned(
                      left: -3,
                      top: -3,
                      right: -3,
                      bottom: -3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.categoryColor(c.hue).withValues(alpha: 0.6),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(c.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.uiStyle(
                      fontSize: 10.5,
                      fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                      color: on ? AppColors.ink : AppColors.inkFaint)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _dateRow() {
    final today = _today();
    final yesterday = today.subtract(const Duration(days: 1));
    final isToday = _sameDay(_date, today);
    final isYesterday = _sameDay(_date, yesterday);
    final isCustom = !isToday && !isYesterday;
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          TrackChip(label: 'Today', active: isToday, onTap: () => setState(() => _date = today)),
          TrackChip(label: 'Yesterday', active: isYesterday, onTap: () => setState(() => _date = yesterday)),
          TrackChip(
            label: isCustom ? Formatters.dateLabel(_date) : 'Pick date',
            active: isCustom,
            leading: Icon(Icons.calendar_today_rounded,
                size: 14, color: isCustom ? Colors.white : AppColors.inkSoft),
            onTap: _pickDate,
          ),
        ],
      ),
    );
  }

  Widget _noteField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.glassStroke),
      ),
      child: Row(
        children: [
          Icon(Icons.edit_outlined, size: 18, color: AppColors.inkFaint),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _noteController,
              maxLength: 40,
              style: AppTheme.uiStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                counterText: '',
                hintText: 'Add a note (optional)',
                hintStyle: AppTheme.uiStyle(
                    fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.inkFaint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});
  final ValueChanged<String> onKey;

  static const _keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', 'del'];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.4,
      children: _keys.map((k) {
        return GestureDetector(
          onTap: () => onKey(k),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassStroke),
            ),
            alignment: Alignment.center,
            child: k == 'del'
                ? Icon(Icons.backspace_outlined, size: 22, color: AppColors.inkSoft)
                : Text(k, style: AppTheme.numberStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }
}

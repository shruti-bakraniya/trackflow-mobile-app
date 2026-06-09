import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transaction.dart';
import 'category_avatar.dart';

/// A single transaction row: avatar, title/sub, signed amount.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cat = Categories.byId(transaction.categoryId);
    final isIncome = transaction.type.isIncome;
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            CategoryAvatar(categoryId: transaction.categoryId),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note.isNotEmpty ? transaction.note : cat.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.uiStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${cat.label} · ${Formatters.dateLabel(transaction.date)}',
                    style: AppTheme.uiStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isIncome ? '+' : '−'}${Formatters.money(transaction.amount).substring(1)}',
              style: AppTheme.numberStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isIncome ? AppColors.income : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

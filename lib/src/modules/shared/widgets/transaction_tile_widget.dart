import 'package:flutter/material.dart';
import 'package:gestao_financeira/src/core/theme/app_theme.dart';
import 'package:gestao_financeira/src/core/utils/date_formatters.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final amountColor = tx.isIncome ? AppColors.income : AppColors.expense;
    final typeIcon = tx.isIncome ? Icons.south_west : Icons.north_east;

    return Semantics(
      button: onTap != null,
      label:
          '${tx.typeLabel} ${tx.description}, ${tx.signedAmount.format()}, ${tx.statusLabel}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: amountColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          DateFormatters.dateTime(tx.dateUtc),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(status: tx.status),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${tx.typeSymbol} ${tx.amount.formatAbsolute()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: amountColor,
                          fontSize: 15,
                        ),
                  ),
                  Text(
                    tx.typeLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TransactionStatus.completed => ('Concluída', AppColors.income),
      TransactionStatus.pending => ('Pendente', AppColors.pending),
      TransactionStatus.failed => ('Falha', AppColors.failed),
      TransactionStatus.reversed => ('Estornada', AppColors.softInk),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          fontFamily: 'Georgia',
        ),
      ),
    );
  }
}

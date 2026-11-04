import 'package:gestao_financeira/src/core/theme/app_theme.dart';
import 'package:gestao_financeira/src/core/utils/date_formatters.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/account_balance.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.visible,
    required this.onToggleVisibility,
  });

  final AccountBalance balance;
  final bool visible;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.forest, AppColors.teal],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Saldo disponível',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
              const Spacer(),
              IconButton(
                tooltip: visible ? 'Ocultar saldo' : 'Exibir saldo',
                onPressed: onToggleVisibility,
                icon: Icon(
                  visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            label: visible
                ? 'Saldo ${balance.available.format()}'
                : 'Saldo oculto',
            child: Text(
              visible ? balance.available.format() : 'R\$ ••••••',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 34,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Atualizado em ${DateFormatters.dateTime(balance.updatedAtUtc)}'
            '${balance.fromCache ? ' · cache' : ''}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}
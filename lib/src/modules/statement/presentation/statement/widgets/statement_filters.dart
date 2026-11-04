import 'package:flutter/material.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';

class StatementFilters extends StatelessWidget {
  const StatementFilters({
    super.key,
    required this.filter,
    required this.onQueryChanged,
    required this.onToggleType,
    required this.onToggleStatus,
    required this.onPeriodChanged,
    required this.onCustomPeriod,
  });

  final TransactionFilter filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<TransactionType> onToggleType;
  final ValueChanged<TransactionStatus> onToggleStatus;
  final ValueChanged<PeriodPreset> onPeriodChanged;
  final void Function(DateTime start, DateTime end) onCustomPeriod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Buscar por descrição',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Entradas'),
              selected: filter.types.contains(TransactionType.income),
              onSelected: (_) => onToggleType(TransactionType.income),
            ),
            FilterChip(
              label: const Text('Saídas'),
              selected: filter.types.contains(TransactionType.expense),
              onSelected: (_) => onToggleType(TransactionType.expense),
            ),
            for (final status in TransactionStatus.values)
              FilterChip(
                label: Text(_statusLabel(status)),
                selected: filter.statuses.contains(status),
                onSelected: (_) => onToggleStatus(status),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final preset in PeriodPreset.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_periodLabel(preset)),
                    selected: filter.period == preset,
                    onSelected: (_) async {
                      if (preset == PeriodPreset.custom) {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          locale: const Locale('pt', 'BR'),
                        );
                        if (range != null) {
                          onCustomPeriod(range.start, range.end);
                        }
                      } else {
                        onPeriodChanged(preset);
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(TransactionStatus s) => switch (s) {
    TransactionStatus.completed => 'Concluída',
    TransactionStatus.pending => 'Pendente',
    TransactionStatus.failed => 'Falha',
    TransactionStatus.reversed => 'Estornada',
  };

  String _periodLabel(PeriodPreset p) => switch (p) {
    PeriodPreset.today => 'Hoje',
    PeriodPreset.last7Days => '7 dias',
    PeriodPreset.last30Days => '30 dias',
    PeriodPreset.custom => 'Personalizado',
    PeriodPreset.all => 'Tudo',
  };
}

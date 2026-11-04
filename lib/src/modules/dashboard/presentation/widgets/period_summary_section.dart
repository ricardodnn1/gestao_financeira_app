import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestao_financeira/src/core/theme/app_theme.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';

class PeriodSummarySection extends StatelessWidget {
  const PeriodSummarySection({
    super.key,
    required this.summary,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  final PeriodSummary summary;
  final PeriodPreset selectedPeriod;
  final ValueChanged<PeriodPreset> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo do período',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 20),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final preset in const [
                PeriodPreset.today,
                PeriodPreset.last7Days,
                PeriodPreset.last30Days,
                PeriodPreset.all,
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_label(preset)),
                    selected: selectedPeriod == preset,
                    onSelected: (_) => onPeriodChanged(preset),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _TotalTile(
                label: 'Entradas',
                value: summary.totalIncome.format(),
                color: AppColors.income,
                icon: Icons.south_west,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TotalTile(
                label: 'Saídas',
                value: summary.totalExpense.format(),
                color: AppColors.expense,
                icon: Icons.north_east,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Evolução do saldo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        SizedBox(height: 160, child: _BalanceChart(points: summary.evolution)),
      ],
    );
  }

  String _label(PeriodPreset p) => switch (p) {
    PeriodPreset.today => 'Hoje',
    PeriodPreset.last7Days => '7 dias',
    PeriodPreset.last30Days => '30 dias',
    PeriodPreset.custom => 'Personalizado',
    PeriodPreset.all => 'Tudo',
  };
}

class _TotalTile extends StatelessWidget {
  const _TotalTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _BalanceChart extends StatelessWidget {
  const _BalanceChart({required this.points});

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('Sem dados para o gráfico'));
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].balance.cents / 100.0));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.teal,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.mint.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

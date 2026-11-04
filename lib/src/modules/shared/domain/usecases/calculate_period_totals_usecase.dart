import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';

class CalculatePeriodTotals {
  const CalculatePeriodTotals();

  PeriodSummary call({
    required List<Transaction> transactions,
    required TransactionFilter filter,
    Money openingBalance = const Money(0),
    DateTime? nowUtc,
  }) {
    final filtered =
        transactions
            .where((tx) => filter.matches(tx, nowUtc: nowUtc))
            .where((tx) => tx.status != TransactionStatus.failed)
            .toList()
          ..sort((a, b) => a.dateUtc.compareTo(b.dateUtc));

    var income = Money.zero();
    var expense = Money.zero();

    for (final tx in filtered) {
      if (tx.status == TransactionStatus.reversed) continue;
      if (tx.isIncome) {
        income = income + tx.amount.abs();
      } else {
        expense = expense + tx.amount.abs();
      }
    }

    final (start, end) = filter.resolveRange(nowUtc: nowUtc);
    final evolution = _buildEvolution(filtered, openingBalance: openingBalance);

    return PeriodSummary(
      totalIncome: income,
      totalExpense: expense,
      startUtc:
          start ??
          (filtered.isEmpty ? DateTime.now().toUtc() : filtered.first.dateUtc),
      endUtc: end ?? DateTime.now().toUtc(),
      evolution: evolution,
    );
  }

  Money computeBalance({
    required List<Transaction> transactions,
    Money openingBalance = const Money(0),
  }) {
    var balance = openingBalance;
    for (final tx in transactions) {
      if (tx.status == TransactionStatus.failed ||
          tx.status == TransactionStatus.reversed) {
        continue;
      }
      balance = balance + tx.signedAmount;
    }
    return balance;
  }

  List<ChartPoint> _buildEvolution(
    List<Transaction> sorted, {
    required Money openingBalance,
  }) {
    if (sorted.isEmpty) {
      return [
        ChartPoint(dateUtc: DateTime.now().toUtc(), balance: openingBalance),
      ];
    }

    var running = openingBalance;
    final points = <ChartPoint>[
      ChartPoint(dateUtc: sorted.first.dateUtc, balance: running),
    ];

    for (final tx in sorted) {
      if (tx.status == TransactionStatus.reversed) continue;
      running = running + tx.signedAmount;
      points.add(ChartPoint(dateUtc: tx.dateUtc, balance: running));
    }

    if (points.length <= 14) return points;
    final step = (points.length / 14).ceil();
    final sampled = <ChartPoint>[];
    for (var i = 0; i < points.length; i += step) {
      sampled.add(points[i]);
    }
    if (sampled.last != points.last) sampled.add(points.last);
    return sampled;
  }
}

import 'package:equatable/equatable.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';

class ChartPoint extends Equatable {
  const ChartPoint({required this.dateUtc, required this.balance});

  final DateTime dateUtc;
  final Money balance;

  @override
  List<Object?> get props => [dateUtc, balance];
}

base class PeriodSummary extends Equatable {
  const PeriodSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.startUtc,
    required this.endUtc,
    this.evolution = const [],
    this.fromCache = false,
  });

  final Money totalIncome;
  final Money totalExpense;
  final DateTime startUtc;
  final DateTime endUtc;
  final List<ChartPoint> evolution;
  final bool fromCache;

  Money get net => totalIncome - totalExpense;

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    startUtc,
    endUtc,
    evolution,
    fromCache,
  ];
}

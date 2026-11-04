import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';

void main() {
  final now = DateTime.utc(2026, 11, 2, 15);

  final sample = Transaction(
    id: '1',
    description: 'Apreciação · Bitcoin',
    amount: const Money(100),
    dateUtc: now.subtract(const Duration(days: 1)),
    type: TransactionType.income,
    status: TransactionStatus.completed,
  );

  test('filtra por tipo e busca com case-insensitive', () {
    const filter = TransactionFilter(
      types: {TransactionType.income},
      query: 'bitcoin',
      period: PeriodPreset.all,
    );
    expect(filter.matches(sample, nowUtc: now), isTrue);

    const expenseOnly = TransactionFilter(
      types: {TransactionType.expense},
      period: PeriodPreset.all,
    );
    expect(expenseOnly.matches(sample, nowUtc: now), isFalse);
  });

  test('filtra por status', () {
    const filter = TransactionFilter(
      statuses: {TransactionStatus.pending},
      period: PeriodPreset.all,
    );
    expect(filter.matches(sample, nowUtc: now), isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/calculate_period_totals_usecase.dart';

void main() {
  const calculator = CalculatePeriodTotals();
  final now = DateTime.utc(2026, 11, 2, 12);

  Transaction tx({
    required String id,
    required int cents,
    required TransactionType type,
    TransactionStatus status = TransactionStatus.completed,
    int daysAgo = 0,
  }) {
    return Transaction(
      id: id,
      description: 'Tx $id',
      amount: Money(cents),
      dateUtc: now.subtract(Duration(days: daysAgo)),
      type: type,
      status: status,
    );
  }

  group('CalculatePeriodTotals', () {
    test('soma entradas e saídas excluindo falhas e estornos', () {
      final txs = [
        tx(id: '1', cents: 1000, type: TransactionType.income),
        tx(id: '2', cents: 400, type: TransactionType.expense),
        tx(
          id: '3',
          cents: 200,
          type: TransactionType.income,
          status: TransactionStatus.failed,
        ),
        tx(
          id: '4',
          cents: 100,
          type: TransactionType.expense,
          status: TransactionStatus.reversed,
        ),
      ];

      final summary = calculator(
        transactions: txs,
        filter: const TransactionFilter(period: PeriodPreset.all),
        nowUtc: now,
      );

      expect(summary.totalIncome.cents, 1000);
      expect(summary.totalExpense.cents, 400);
      expect(summary.net.cents, 600);
    });

    test('computeBalance considera abertura e pendentes', () {
      final balance = calculator.computeBalance(
        transactions: [
          tx(id: '1', cents: 500, type: TransactionType.income),
          tx(
            id: '2',
            cents: 100,
            type: TransactionType.expense,
            status: TransactionStatus.pending,
          ),
          tx(
            id: '3',
            cents: 999,
            type: TransactionType.income,
            status: TransactionStatus.failed,
          ),
        ],
        openingBalance: const Money(1000),
      );

      expect(balance.cents, 1400); // 1000 + 500 - 100
    });

    test('filtro de período last7Days', () {
      final txs = [
        tx(id: 'old', cents: 9000, type: TransactionType.income, daysAgo: 20),
        tx(id: 'new', cents: 300, type: TransactionType.income, daysAgo: 2),
      ];

      final summary = calculator(
        transactions: txs,
        filter: const TransactionFilter(period: PeriodPreset.last7Days),
        nowUtc: now,
      );

      expect(summary.totalIncome.cents, 300);
    });

    test('lista vazia retorna zeros', () {
      final summary = calculator(
        transactions: const [],
        filter: TransactionFilter.empty,
        nowUtc: now,
      );
      expect(summary.totalIncome.isZero, isTrue);
      expect(summary.totalExpense.isZero, isTrue);
      expect(summary.evolution, isNotEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/core/errors/failure.dart';
import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/account_balance.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/paginated_transctions.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';

Transaction _transaction({
  TransactionType type = TransactionType.income,
  TransactionStatus status = TransactionStatus.completed,
  Money amount = const Money(1000),
}) => Transaction(
  id: 'tx-1',
  description: 'Movimentação',
  amount: amount,
  dateUtc: DateTime.utc(2026, 11, 4),
  type: type,
  status: status,
);

void main() {
  group('Transaction', () {
    test('expõe propriedades derivadas para entradas e saídas', () {
      final income = _transaction();
      final expense = _transaction(
        type: TransactionType.expense,
        amount: const Money(-250),
      );

      expect(income.isIncome, isTrue);
      expect(income.isExpense, isFalse);
      expect(income.signedAmount, const Money(1000));
      expect(income.typeLabel, 'Entrada');
      expect(income.typeSymbol, '+');
      expect(income.statusLabel, 'Concluída');
      expect(expense.isIncome, isFalse);
      expect(expense.isExpense, isTrue);
      expect(expense.signedAmount, const Money(-250));
      expect(expense.typeLabel, 'Saída');
      expect(expense.typeSymbol, '−');
    });

    test('mapeia todos os rótulos de status', () {
      expect(
        _transaction(status: TransactionStatus.pending).statusLabel,
        'Pendente',
      );
      expect(
        _transaction(status: TransactionStatus.failed).statusLabel,
        'Falha',
      );
      expect(
        _transaction(status: TransactionStatus.reversed).statusLabel,
        'Estornada',
      );
    });
  });

  test('AccountBalance copia valores mantendo os não alterados', () {
    final original = AccountBalance(
      available: const Money(1000),
      updatedAtUtc: DateTime.utc(2026, 11, 1),
      fromCache: true,
    );
    final copied = original.copyWith(available: const Money(2500));

    expect(copied.available, const Money(2500));
    expect(copied.updatedAtUtc, original.updatedAtUtc);
    expect(copied.currency, 'BRL');
    expect(copied.fromCache, isTrue);
  });

  test('PeriodSummary calcula saldo líquido e compara pontos do gráfico', () {
    final summary = PeriodSummary(
      totalIncome: const Money(5000),
      totalExpense: const Money(1200),
      startUtc: DateTime.utc(2026, 11, 1),
      endUtc: DateTime.utc(2026, 11, 4),
    );
    final point = ChartPoint(
      dateUtc: DateTime.utc(2026, 11, 4),
      balance: const Money(3800),
    );

    expect(summary.net, const Money(3800));
    expect(
      point,
      ChartPoint(dateUtc: point.dateUtc, balance: const Money(3800)),
    );
  });

  test('compara páginas de transações por seus valores', () {
    final transaction = _transaction();
    final page = PaginatedTransactions(
      items: [transaction],
      page: 1,
      pageSize: 10,
      hasMore: false,
      totalCount: 1,
      fromCache: true,
    );

    expect(page, isA<PaginatedTransactions>());
    expect(page.props, [page.items, 1, 10, false, 1, true]);
  });

  test('falhas carregam mensagem e código conforme o tipo', () {
    expect(const NetworkFailure().message, 'Sem conexão com a internet.');
    expect(const ServerFailure().message, 'Erro no servidor. Tente novamente.');
    expect(const RateLimitFailure().code, '429');
    expect(const CacheFailure().message, isNotEmpty);
    expect(const NotFoundFailure().code, '404');
    expect(const ParsingFailure().message, isNotEmpty);
    expect(const UnexpectedFailure().message, isNotEmpty);

    final result = const Error<int>(NetworkFailure());
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(result.valueOrNull, isNull);
    expect(
      result.fold(
        onFailure: (failure) => failure.message,
        onSuccess: (_) => '',
      ),
      'Sem conexão com a internet.',
    );
    expect(result.map((_) => 1), isA<Error<int>>());
  });
}

import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/ledger_store.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/account_balance.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/account_repository.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/calculate_period_totals_usecase.dart';

class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl({
    required this.ledgerStore,
    this.calculator = const CalculatePeriodTotals(),
  });

  final LedgerStore ledgerStore;
  final CalculatePeriodTotals calculator;

  @override
  Future<Result<AccountBalance>> getBalance({bool forceRefresh = false}) async {
    final loaded = await ledgerStore.ensureLoaded(forceRefresh: forceRefresh);
    if (loaded.isFailure) {
      return Error(loaded.failureOrNull!);
    }

    final available = calculator.computeBalance(
      transactions: ledgerStore.transactions,
      openingBalance: ledgerStore.openingBalance,
    );

    return Success(
      AccountBalance(
        available: available,
        updatedAtUtc: ledgerStore.loadedAt ?? DateTime.now().toUtc(),
        fromCache: ledgerStore.fromCache,
      ),
    );
  }

  @override
  Future<Result<PeriodSummary>> getPeriodSummary({
    TransactionFilter filter = TransactionFilter.empty,
    bool forceRefresh = false,
  }) async {
    final loaded = await ledgerStore.ensureLoaded(forceRefresh: forceRefresh);
    if (loaded.isFailure) {
      return Error(loaded.failureOrNull!);
    }

    final summary = calculator(
      transactions: ledgerStore.transactions,
      filter: filter,
      openingBalance: ledgerStore.openingBalance,
    );

    return Success(
      PeriodSummary(
        totalIncome: summary.totalIncome,
        totalExpense: summary.totalExpense,
        startUtc: summary.startUtc,
        endUtc: summary.endUtc,
        evolution: summary.evolution,
        fromCache: ledgerStore.fromCache,
      ),
    );
  }
}

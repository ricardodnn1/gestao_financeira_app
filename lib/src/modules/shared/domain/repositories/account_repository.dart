import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/account_balance.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';

abstract class AccountRepository {
  Future<Result<AccountBalance>> getBalance({bool forceRefresh = false});

  Future<Result<PeriodSummary>> getPeriodSummary({
    TransactionFilter filter = TransactionFilter.empty,
    bool forceRefresh = false,
  });
}

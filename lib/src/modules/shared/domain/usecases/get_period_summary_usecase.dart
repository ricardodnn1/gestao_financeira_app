import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/period_summary.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/account_repository.dart';

class GetPeriodSummary {
  const GetPeriodSummary(this._repository);

  final AccountRepository _repository;

  Future<Result<PeriodSummary>> call({
    TransactionFilter filter = TransactionFilter.empty,
    bool forceRefresh = false,
  }) {
    return _repository.getPeriodSummary(
      filter: filter,
      forceRefresh: forceRefresh,
    );
  }
}

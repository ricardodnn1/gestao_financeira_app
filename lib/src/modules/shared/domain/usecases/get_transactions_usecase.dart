import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/paginated_transctions.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/transaction_repository.dart';

class GetTransactions {
  const GetTransactions(this._repository);

  final TransactionRepository _repository;

  Future<Result<PaginatedTransactions>> call({
    TransactionFilter filter = TransactionFilter.empty,
    int page = 1,
    int pageSize = 20,
    bool forceRefresh = false,
  }) {
    return _repository.getTransactions(
      filter: filter,
      page: page,
      pageSize: pageSize,
      forceRefresh: forceRefresh,
    );
  }
}
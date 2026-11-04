import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/paginated_transctions.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';

abstract class TransactionRepository {
  Future<Result<PaginatedTransactions>> getTransactions({
    TransactionFilter filter = TransactionFilter.empty,
    int page = 1,
    int pageSize = 20,
    bool forceRefresh = false,
  });

  Future<Result<Transaction>> getById(String id);

  Future<Result<List<Transaction>>> getRecent({int limit = 5});
}

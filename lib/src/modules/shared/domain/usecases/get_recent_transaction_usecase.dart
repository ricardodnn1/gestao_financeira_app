import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/transaction_repository.dart';

class GetRecentTransactions {
  const GetRecentTransactions(this._repository);

  final TransactionRepository _repository;

  Future<Result<List<Transaction>>> call({int limit = 5}) {
    return _repository.getRecent(limit: limit);
  }
}
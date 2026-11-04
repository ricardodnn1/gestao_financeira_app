import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/transaction_repository.dart';

class GetTransactionById {
  const GetTransactionById(this._repository);

  final TransactionRepository _repository;

  Future<Result<Transaction>> call(String id) {
    return _repository.getById(id);
  }
}

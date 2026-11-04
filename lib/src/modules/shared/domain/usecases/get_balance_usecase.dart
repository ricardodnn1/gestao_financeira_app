import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/account_balance.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/account_repository.dart';

class GetBalance {
  const GetBalance(this._repository);

  final AccountRepository _repository;

  Future<Result<AccountBalance>> call({bool forceRefresh = false}) {
    return _repository.getBalance(forceRefresh: forceRefresh);
  }
}

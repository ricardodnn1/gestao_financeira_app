import 'package:gestao_financeira/src/modules/shared/domain/repositories/preferences_repository.dart';

class GetBalanceVisibility {
  const GetBalanceVisibility(this._repository);

  final PreferencesRepository _repository;

  Future<bool> call() => _repository.isBalanceVisible();
}

class SetBalanceVisibility {
  const SetBalanceVisibility(this._repository);

  final PreferencesRepository _repository;

  Future<void> call(bool visible) => _repository.setBalanceVisible(visible);
}

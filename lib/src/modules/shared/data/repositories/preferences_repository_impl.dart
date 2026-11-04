import 'package:gestao_financeira/src/modules/shared/data/datasources/local/preferences_local_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/domain/repositories/preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  PreferencesRepositoryImpl(this._local);

  final PreferencesLocalDataSource _local;

  @override
  Future<bool> isBalanceVisible() => _local.isBalanceVisible();

  @override
  Future<void> setBalanceVisible(bool visible) =>
      _local.setBalanceVisible(visible);
}

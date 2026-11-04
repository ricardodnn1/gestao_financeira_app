import 'package:shared_preferences/shared_preferences.dart';

abstract class PreferencesLocalDataSource {
  Future<bool> isBalanceVisible();
  Future<void> setBalanceVisible(bool visible);
}

class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  PreferencesLocalDataSourceImpl(this._prefs);

  static const _balanceVisibleKey = 'balance_visible';

  final SharedPreferences _prefs;

  @override
  Future<bool> isBalanceVisible() async {
    return _prefs.getBool(_balanceVisibleKey) ?? true;
  }

  @override
  Future<void> setBalanceVisible(bool visible) {
    return _prefs.setBool(_balanceVisibleKey, visible);
  }
}

abstract class PreferencesRepository {
  Future<bool> isBalanceVisible();
  Future<void> setBalanceVisible(bool visible);
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/local/cache_local_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences preferences;
  late CacheLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    dataSource = CacheLocalDataSourceImpl(preferences);
  });

  test('retorna null quando ainda não há cache', () async {
    expect(await dataSource.readLedger(), isNull);
  });

  test('grava e restaura ledger, transações e metadados', () async {
    final cachedAt = DateTime.utc(2026, 11, 4, 12);
    final transactionDate = DateTime.utc(2026, 11, 3, 10);
    final transaction = Transaction(
      id: 'bitcoin-1',
      description: 'Compra de Bitcoin',
      amount: const Money(12550),
      dateUtc: transactionDate,
      type: TransactionType.income,
      status: TransactionStatus.completed,
      assetSymbol: 'BTC',
      assetName: 'Bitcoin',
      metadata: const {'source': 'manual'},
    );

    await dataSource.writeLedger(
      CachedLedger(
        transactions: [transaction],
        cachedAtUtc: cachedAt,
        openingBalance: const Money(50000),
      ),
    );

    final restored = await dataSource.readLedger();

    expect(restored, isNotNull);
    expect(restored!.cachedAtUtc, cachedAt);
    expect(restored.openingBalance, const Money(50000));
    expect(restored.transactions, [transaction]);
  });

  test('ignora cache corrompido', () async {
    await preferences.setString('ledger_cache_v1', '{invalid json');

    expect(await dataSource.readLedger(), isNull);
  });

  test('limpa o ledger persistido', () async {
    await preferences.setString('ledger_cache_v1', 'cache');

    await dataSource.clear();

    expect(preferences.getString('ledger_cache_v1'), isNull);
    expect(await dataSource.readLedger(), isNull);
  });
}

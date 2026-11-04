import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/local/cache_local_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/remote/coingecko_remote_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/coin_market_model.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/market_chart_model.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/account_repository_impl.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/ledger_store.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/transaction_repository_impl.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction_filter.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/period_preset_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/usecases/calculate_period_totals_usecase.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements CoinGeckoRemoteDataSource {}

class _MockCache extends Mock implements CacheLocalDataSource {}

Future<void> _complete(Invocation _) async {}

Future<List<CoinMarketModel>> _markets(Invocation _) async => const [
  CoinMarketModel(
    id: 'bitcoin',
    symbol: 'BTC',
    name: 'Bitcoin',
    currentPrice: 100000,
    priceChange24h: 2000,
    priceChangePercentage24h: 2,
  ),
];

/// Integração: saldo do dashboard == abertura + soma assinada das txs do extrato.
void main() {
  setUpAll(() {
    registerFallbackValue(
      CachedLedger(
        transactions: const [],
        cachedAtUtc: DateTime.utc(2026),
        openingBalance: const Money(0),
      ),
    );
  });

  test('consistência entre saldo, totais e detalhes (fonte única)', () async {
    final remote = _MockRemote();
    final cache = _MockCache();
    when(() => cache.writeLedger(any())).thenAnswer(_complete);
    when(remote.fetchMarkets).thenAnswer(_markets);
    when(
      () => remote.fetchMarketChart(
        coinId: any(named: 'coinId'),
        days: any(named: 'days'),
      ),
    ).thenAnswer(
      (_) async => MarketChartModel(
        prices: [
          PricePointModel(
            timestampMs: DateTime.utc(2026, 10, 1).millisecondsSinceEpoch,
            price: 100,
          ),
          PricePointModel(
            timestampMs: DateTime.utc(2026, 10, 2).millisecondsSinceEpoch,
            price: 120,
          ),
        ],
      ),
    );

    final store = LedgerStore(remote: remote, cache: cache);
    final accountRepo = AccountRepositoryImpl(ledgerStore: store);
    final txRepo = TransactionRepositoryImpl(store);
    const calculator = CalculatePeriodTotals();

    final balance = (await accountRepo.getBalance()).valueOrNull!;
    final page = (await txRepo.getTransactions(
      filter: const TransactionFilter(period: PeriodPreset.all),
      pageSize: 100,
    )).valueOrNull!;
    final detail = (await txRepo.getById(page.items.first.id)).valueOrNull!;

    final recomputed = calculator.computeBalance(
      transactions: store.transactions,
      openingBalance: store.openingBalance,
    );

    expect(balance.available, recomputed);
    expect(page.items.length, store.transactions.length);
    expect(detail.id, page.items.first.id);
    expect(detail.description, page.items.first.description);
  });
}

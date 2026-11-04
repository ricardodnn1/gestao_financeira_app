import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/local/cache_local_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/remote/coingecko_remote_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/coin_market_model.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/market_chart_model.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/ledger_store.dart';
import 'package:gestao_financeira/src/modules/shared/data/repositories/transaction_repository_impl.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements CoinGeckoRemoteDataSource {}

class _MockCache extends Mock implements CacheLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late LedgerStore store;
  late TransactionRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(
      CachedLedger(
        transactions: const [],
        cachedAtUtc: DateTime.utc(2026),
        openingBalance: const Money(0),
      ),
    );
  });

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    store = LedgerStore(remote: remote, cache: cache);
    repo = TransactionRepositoryImpl(store);

    when(() => cache.writeLedger(any())).thenAnswer((_) async {});
  });

  test('getTransactions pagina e filtra a partir da fonte única', () async {
    when(() => remote.fetchMarkets()).thenAnswer(
      (_) async => [
        const CoinMarketModel(
          id: 'bitcoin',
          symbol: 'BTC',
          name: 'Bitcoin',
          currentPrice: 500000,
          priceChange24h: 1000,
          priceChangePercentage24h: 1.2,
        ),
        const CoinMarketModel(
          id: 'ethereum',
          symbol: 'ETH',
          name: 'Ethereum',
          currentPrice: 20000,
          priceChange24h: -500,
          priceChangePercentage24h: -0.5,
        ),
      ],
    );
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
            price: 110,
          ),
          PricePointModel(
            timestampMs: DateTime.utc(2026, 10, 3).millisecondsSinceEpoch,
            price: 105,
          ),
        ],
      ),
    );

    final page1 = await repo.getTransactions(page: 1, pageSize: 2);
    expect(page1.isSuccess, isTrue);
    final data = page1.valueOrNull!;
    expect(data.items.length, lessThanOrEqualTo(2));
    expect(data.totalCount, greaterThan(0));

    final byId = await repo.getById(data.items.first.id);
    expect(byId.isSuccess, isTrue);
  });
}

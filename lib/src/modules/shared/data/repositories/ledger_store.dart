import 'package:gestao_financeira/src/core/constants/api_constants.dart';
import 'package:gestao_financeira/src/core/errors/failure.dart';
import 'package:gestao_financeira/src/core/errors/result.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/local/cache_local_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/remote/coingecko_remote_datasource.dart';
import 'package:gestao_financeira/src/modules/shared/data/mappers/transactioon_mapper.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';

class LedgerStore {
  LedgerStore({
    required this._remote,
    required this._cache,
    this.mapper = const TransactionMapper(),
  });

  final CoinGeckoRemoteDataSource _remote;
  final CacheLocalDataSource _cache;
  final TransactionMapper mapper;

  List<Transaction> _transactions = [];
  Money _opening = TransactionMapper.openingBalance;
  DateTime? _loadedAt;
  bool _fromCache = false;
  Future<Result<void>>? _loading;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  Money get openingBalance => _opening;
  bool get fromCache => _fromCache;
  DateTime? get loadedAt => _loadedAt;

  Future<Result<void>> ensureLoaded({bool forceRefresh = false}) {
    if (!forceRefresh && _transactions.isNotEmpty) {
      return Future.value(const Success(null));
    }

    if (_loading != null && !forceRefresh) {
      return _loading!;
    }

    _loading = _load(forceRefresh: forceRefresh).whenComplete(() {
      _loading = null;
    });
    return _loading!;
  }

  Future<Result<void>> _load({required bool forceRefresh}) async {
    try {
      final markets = await _remote.fetchMarkets();
      final chart = await _remote.fetchMarketChart(
        coinId: ApiConstants.trackedCoinIds.first,
        days: 30,
      );

      final fromMarkets = mapper.fromMarketCoins(markets);
      final fromChart = mapper.fromMarketChart(
        coinId: ApiConstants.trackedCoinIds.first,
        symbol: markets.isNotEmpty ? markets.first.symbol : 'BTC',
        name: markets.isNotEmpty ? markets.first.name : 'Bitcoin',
        chart: chart,
      );

      final merged = <String, Transaction>{};
      for (final tx in [...fromChart, ...fromMarkets]) {
        merged[tx.id] = tx;
      }

      final list = merged.values.toList()
        ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));

      _transactions = list;
      _opening = TransactionMapper.openingBalance;
      _loadedAt = DateTime.now().toUtc();
      _fromCache = false;

      await _cache.writeLedger(
        CachedLedger(
          transactions: list,
          cachedAtUtc: _loadedAt!,
          openingBalance: _opening,
        ),
      );

      return const Success(null);
    } on Failure catch (failure) {
      final cached = await _cache.readLedger();
      if (cached != null && cached.transactions.isNotEmpty) {
        _transactions = cached.transactions;
        _opening = cached.openingBalance;
        _loadedAt = cached.cachedAtUtc;
        _fromCache = true;
        return const Success(null);
      }
      return Error(failure);
    } on Object catch (e) {
      final cached = await _cache.readLedger();
      if (cached != null && cached.transactions.isNotEmpty) {
        _transactions = cached.transactions;
        _opening = cached.openingBalance;
        _loadedAt = cached.cachedAtUtc;
        _fromCache = true;
        return const Success(null);
      }
      return Error(UnexpectedFailure(e.toString()));
    }
  }

  Transaction? findById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } on StateError {
      return null;
    }
  }
}

import 'dart:convert';

import 'package:gestao_financeira/src/modules/shared/data/models/coin_market_model.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/market_chart_model.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/transaction.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart';

class TransactionMapper {
  const TransactionMapper();

  static const Money openingBalance = Money(50_000_00);

  List<Transaction> fromMarketCoins(List<CoinMarketModel> coins) {
    final now = DateTime.now().toUtc();
    return coins.asMap().entries.map((entry) {
      final i = entry.key;
      final coin = entry.value;
      final change = coin.priceChange24h;
      final type = change >= 0
          ? TransactionType.income
          : TransactionType.expense;
      final amount = Money.fromDecimal(change.abs());
      // Escala: 0,1 unidade do ativo ≈ movimento financeiro.
      final scaled = Money((amount.cents * 0.1).round());
      final id = 'mkt-${coin.id}-24h';

      return Transaction(
        id: id,
        description: 'Variação 24h · ${coin.name} (${coin.symbol})',
        amount: scaled.isZero ? const Money(1) : scaled,
        dateUtc: now.subtract(Duration(hours: i)),
        type: type,
        status: _statusFromId(id),
        assetSymbol: coin.symbol,
        assetName: coin.name,
        metadata: {
          'source': 'coingecko/coins/markets',
          'coin_id': coin.id,
          'spot_price_brl': coin.currentPrice.toString(),
          'change_pct_24h': coin.priceChangePercentage24h.toStringAsFixed(2),
          if (coin.lastUpdated != null) 'last_updated': coin.lastUpdated!,
        },
      );
    }).toList();
  }

  List<Transaction> fromMarketChart({
    required String coinId,
    required String symbol,
    required String name,
    required MarketChartModel chart,
  }) {
    if (chart.prices.length < 2) return const [];

    final transactions = <Transaction>[];
    for (var i = 1; i < chart.prices.length; i++) {
      final prev = chart.prices[i - 1];
      final curr = chart.prices[i];
      final delta = curr.price - prev.price;
      if (delta == 0) continue;

      final type = delta >= 0
          ? TransactionType.income
          : TransactionType.expense;
      // 0,05 unidade do ativo por candle.
      final amount = Money.fromDecimal(delta.abs() * 0.05);
      if (amount.isZero) continue;

      final day = curr.dateUtc.toIso8601String().substring(0, 10);
      final id = 'chart-$coinId-$day-${curr.timestampMs}';

      transactions.add(
        Transaction(
          id: id,
          description: delta >= 0
              ? 'Apreciação · $name ($symbol)'
              : 'Depreciação · $name ($symbol)',
          amount: amount,
          dateUtc: curr.dateUtc,
          type: type,
          status: _statusFromId(id),
          assetSymbol: symbol,
          assetName: name,
          metadata: {
            'source': 'coingecko/market_chart',
            'coin_id': coinId,
            'price_brl': curr.price.toString(),
          },
        ),
      );
    }
    return transactions;
  }

  TransactionStatus _statusFromId(String id) {
    final hash = utf8.encode(id).fold<int>(0, (a, b) => a + b);
    return switch (hash % 10) {
      0 => TransactionStatus.pending,
      1 => TransactionStatus.failed,
      2 => TransactionStatus.reversed,
      _ => TransactionStatus.completed,
    };
  }
}

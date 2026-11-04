import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/coin_market_model.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/market_chart_model.dart';

void main() {
  group('CoinMarketModel', () {
    test('converte números e texto e normaliza valores opcionais', () {
      final model = CoinMarketModel.fromJson({
        'id': 42,
        'symbol': 'btc',
        'name': 'Bitcoin',
        'current_price': '250.5',
        'price_change_24h': -2,
        'price_change_percentage_24h': '0.8',
        'image': 'https://example.test/bitcoin.png',
        'market_cap': '100000',
        'last_updated': '2026-11-04T10:00:00Z',
      });

      expect(model.id, '42');
      expect(model.symbol, 'BTC');
      expect(model.currentPrice, 250.5);
      expect(model.priceChange24h, -2);
      expect(model.priceChangePercentage24h, 0.8);
      expect(model.image, 'https://example.test/bitcoin.png');
      expect(model.marketCap, 100000);
      expect(model.lastUpdated, '2026-11-04T10:00:00Z');
    });

    test('usa padrões seguros para dados ausentes ou inválidos', () {
      final model = CoinMarketModel.fromJson({
        'current_price': 'indisponível',
        'price_change_24h': false,
      });

      expect(model.id, '');
      expect(model.symbol, '');
      expect(model.name, 'Desconhecido');
      expect(model.currentPrice, 0);
      expect(model.priceChange24h, 0);
      expect(model.priceChangePercentage24h, 0);
      expect(model.marketCap, isNull);
    });
  });

  group('MarketChartModel', () {
    test('mantém pontos válidos e ignora itens inválidos', () {
      final model = MarketChartModel.fromJson({
        'prices': [
          [1791000000000, 250000],
          [1791086400000, 251000, 'extra'],
          ['timestamp', 10],
          [1791172800000],
          'inválido',
        ],
      });

      expect(model.prices, hasLength(2));
      expect(model.prices.first.timestampMs, 1791000000000);
      expect(model.prices.first.price, 250000);
      expect(model.prices.first.dateUtc.isUtc, isTrue);
    });

    test('retorna lista vazia quando não recebe preços', () {
      expect(MarketChartModel.fromJson({}).prices, isEmpty);
      expect(MarketChartModel.fromJson({'prices': 'inválido'}).prices, isEmpty);
    });
  });
}

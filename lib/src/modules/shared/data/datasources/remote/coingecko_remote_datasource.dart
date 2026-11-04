import 'dart:convert';

import 'package:gestao_financeira/src/core/constants/api_constants.dart';
import 'package:gestao_financeira/src/core/errors/failure.dart';
import 'package:gestao_financeira/src/core/network/http_client.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/coin_market_model.dart';
import 'package:gestao_financeira/src/modules/shared/data/models/market_chart_model.dart';

abstract class CoinGeckoRemoteDataSource {
  Future<List<CoinMarketModel>> fetchMarkets();

  Future<MarketChartModel> fetchMarketChart({
    required String coinId,
    int days = 30,
  });
}

class CoinGeckoRemoteDataSourceImpl implements CoinGeckoRemoteDataSource {
  CoinGeckoRemoteDataSourceImpl(this._client);

  final AppHttpClient _client;

  @override
  Future<List<CoinMarketModel>> fetchMarkets() async {
    final response = await _client.get(
      '/coins/markets',
      queryParameters: {
        'vs_currency': ApiConstants.vsCurrency,
        'ids': ApiConstants.trackedCoinIds.join(','),
        'order': 'market_cap_desc',
        'per_page': '10',
        'page': '1',
        'sparkline': 'false',
        'price_change_percentage': '24h',
      },
    );

    _ensureSuccess(response);

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ParsingFailure('Resposta de markets inválida.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CoinMarketModel.fromJson)
        .where((c) => c.id.isNotEmpty)
        .toList();
  }

  @override
  Future<MarketChartModel> fetchMarketChart({
    required String coinId,
    int days = 30,
  }) async {
    final response = await _client.get(
      '/coins/$coinId/market_chart',
      queryParameters: {
        'vs_currency': ApiConstants.vsCurrency,
        'days': '$days',
      },
    );

    _ensureSuccess(response);

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const ParsingFailure('Resposta de market_chart inválida.');
    }

    return MarketChartModel.fromJson(decoded);
  }

  void _ensureSuccess(AppHttpResponse response) {
    if (response.statusCode == 429) {
      throw const RateLimitFailure();
    }
    if (response.statusCode == 404) {
      throw const NotFoundFailure();
    }
    if (!response.isSuccess) {
      throw ServerFailure(
        'Erro HTTP ${response.statusCode}',
        '${response.statusCode}',
      );
    }
  }
}

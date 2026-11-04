import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/core/errors/failure.dart';
import 'package:gestao_financeira/src/core/network/http_client.dart';
import 'package:gestao_financeira/src/modules/shared/data/datasources/remote/coingecko_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements AppHttpClient {}

void main() {
  late _MockHttpClient client;
  late CoinGeckoRemoteDataSourceImpl dataSource;

  setUp(() {
    client = _MockHttpClient();
    dataSource = CoinGeckoRemoteDataSourceImpl(client);
  });

  test('busca mercados e converte os dados recebidos', () async {
    when(
      () => client.get(
        '/coins/markets',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => const AppHttpResponse(
        statusCode: 200,
        body:
            '[{"id":"bitcoin","symbol":"btc","name":"Bitcoin",'
            '"current_price":250000,"price_change_24h":1200,'
            '"price_change_percentage_24h":0.5,"market_cap":1000},'
            '{"name":"Sem identificador"}]',
      ),
    );

    final markets = await dataSource.fetchMarkets();

    expect(markets, hasLength(1));
    expect(markets.single.id, 'bitcoin');
    expect(markets.single.symbol, 'BTC');
    expect(markets.single.currentPrice, 250000);
    expect(markets.single.priceChange24h, 1200);
    expect(markets.single.priceChangePercentage24h, 0.5);
    expect(markets.single.marketCap, 1000);
    verify(
      () => client.get(
        '/coins/markets',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(1);
  });

  test('busca histórico de preços', () async {
    when(
      () => client.get(
        '/coins/bitcoin/market_chart',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => const AppHttpResponse(
        statusCode: 200,
        body: '{"prices":[[1791000000000,250000],[1791086400000,251000]]}',
      ),
    );

    final chart = await dataSource.fetchMarketChart(coinId: 'bitcoin');

    expect(chart.prices, hasLength(2));
    expect(chart.prices.first.price, 250000);
    expect(chart.prices.first.dateUtc.isUtc, isTrue);
  });

  test('mapeia respostas HTTP de erro para falhas específicas', () async {
    for (final (status, expected) in [
      (429, isA<RateLimitFailure>()),
      (404, isA<NotFoundFailure>()),
      (500, isA<ServerFailure>()),
    ]) {
      when(
        () => client.get(
          '/coins/markets',
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => AppHttpResponse(statusCode: status, body: '{}'),
      );

      await expectLater(dataSource.fetchMarkets(), throwsA(expected));
    }
  });

  test('rejeita formatos de resposta inválidos', () async {
    when(
      () => client.get(
        '/coins/markets',
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => const AppHttpResponse(statusCode: 200, body: '{}'),
    );

    await expectLater(
      dataSource.fetchMarkets(),
      throwsA(isA<ParsingFailure>()),
    );
  });
}

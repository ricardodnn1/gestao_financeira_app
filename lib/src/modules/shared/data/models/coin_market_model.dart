class CoinMarketModel {
  const CoinMarketModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    this.image,
    this.marketCap,
    this.lastUpdated,
  });

  factory CoinMarketModel.fromJson(Map<String, dynamic> json) {
    return CoinMarketModel(
      id: _asString(json['id']) ?? '',
      symbol: (_asString(json['symbol']) ?? '').toUpperCase(),
      name: _asString(json['name']) ?? 'Desconhecido',
      currentPrice: _asNum(json['current_price']) ?? 0,
      priceChange24h: _asNum(json['price_change_24h']) ?? 0,
      priceChangePercentage24h:
          _asNum(json['price_change_percentage_24h']) ?? 0,
      image: _asString(json['image']),
      marketCap: _asNum(json['market_cap']),
      lastUpdated: _asString(json['last_updated']),
    );
  }

  final String id;
  final String symbol;
  final String name;
  final num currentPrice;
  final num priceChange24h;
  final num priceChangePercentage24h;
  final String? image;
  final num? marketCap;
  final String? lastUpdated;

  static String? _asString(Object? value) =>
      value is String ? value : value?.toString();

  static num? _asNum(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

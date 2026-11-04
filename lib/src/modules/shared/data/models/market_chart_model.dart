class MarketChartModel {
  const MarketChartModel({required this.prices});

  factory MarketChartModel.fromJson(Map<String, dynamic> json) {
    final raw = json['prices'];
    final prices = <PricePointModel>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is List && item.length >= 2) {
          final ts = item[0];
          final price = item[1];
          if (ts is num && price is num) {
            prices.add(PricePointModel(timestampMs: ts.toInt(), price: price));
          }
        }
      }
    }
    return MarketChartModel(prices: prices);
  }

  final List<PricePointModel> prices;
}

class PricePointModel {
  const PricePointModel({required this.timestampMs, required this.price});

  final int timestampMs;
  final num price;

  DateTime get dateUtc =>
      DateTime.fromMillisecondsSinceEpoch(timestampMs, isUtc: true);
}

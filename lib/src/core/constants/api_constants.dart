class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.coingecko.com/api/v3',
  );

  static const String apiKey = String.fromEnvironment('API_KEY');

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const int maxRetries = 3;
  static const Duration initialBackoff = Duration(seconds: 1);

  static const List<String> trackedCoinIds = [
    'bitcoin',
    'ethereum',
    'solana',
    'cardano',
    'ripple',
  ];

  static const String vsCurrency = 'brl';
}

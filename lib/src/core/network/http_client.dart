/// Abstração de cliente HTTP para portabilidade (http → Dio etc.).
abstract class AppHttpClient {
  Future<AppHttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  Future<AppHttpResponse> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  });

  /// Cancela requisições em andamento do mesmo [requestKey] (deduplicação).
  void cancel(String requestKey);

  void dispose();
}

class AppHttpResponse {
  const AppHttpResponse({
    required this.statusCode,
    required this.body,
    this.headers = const {},
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

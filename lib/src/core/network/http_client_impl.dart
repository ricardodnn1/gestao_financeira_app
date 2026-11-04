import 'dart:async';
import 'dart:convert';
import 'dart:io'; 
 
import 'package:gestao_financeira/src/core/constants/api_constants.dart';
import 'package:gestao_financeira/src/core/errors/failure.dart';
import 'package:gestao_financeira/src/core/network/http_client.dart';
import 'package:http/http.dart' as http;

/// Implementação com o package `http`.
/// Pode ser trocada por Dio mantendo o contrato [AppHttpClient].
class HttpClientImpl implements AppHttpClient {
  HttpClientImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final http.Client _client;
  final String _baseUrl;
  final Map<String, Completer<AppHttpResponse>> _inFlight = {};
  final Map<String, http.Client> _cancellable = {};

  @override
  Future<AppHttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  @override
  Future<AppHttpResponse> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    return _request(
      method: 'POST',
      path: path,
      queryParameters: queryParameters,
      headers: headers,
      body: body,
    );
  }

  Future<AppHttpResponse> _request({
    required String method,
    required String path,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final key = _requestKey(method, path, queryParameters);

    // Deduplicação: reutiliza a mesma Future se já houver chamada idêntica.
    final existing = _inFlight[key];
    if (existing != null) {
      return existing.future;
    }

    final completer = Completer<AppHttpResponse>();
    _inFlight[key] = completer;

    try {
      final response = await _executeWithRetry(
        method: method,
        path: path,
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        requestKey: key,
      );
      completer.complete(response);
      return response;
    } catch (e, s) {
      completer.completeError(e, s);
      rethrow;
    } finally {
      _inFlight.remove(key);
      _cancellable.remove(key)?.close();
    }
  }

  Future<AppHttpResponse> _executeWithRetry({
    required String method,
    required String path,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    required String requestKey,
  }) async {
    var attempt = 0;
    var backoff = ApiConstants.initialBackoff;

    while (true) {
      attempt++;
      try {
        final uri = Uri.parse('$_baseUrl$path').replace(
          queryParameters: queryParameters,
        );

        final requestHeaders = <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json', 
        };

        final cancelClient = http.Client();
        _cancellable[requestKey] = cancelClient;

        late final http.Response raw;
        if (method == 'GET') {
          raw = await cancelClient
              .get(uri, headers: requestHeaders)
              .timeout(ApiConstants.receiveTimeout);
        } else {
          raw = await cancelClient
              .post(
                uri,
                headers: requestHeaders,
                body: body == null
                    ? null
                    : body is String
                        ? body
                        : jsonEncode(body),
              )
              .timeout(ApiConstants.receiveTimeout);
        }

        if (raw.statusCode == 429) {
          if (attempt >= ApiConstants.maxRetries) {
            throw const RateLimitFailure();
          }
          await Future<void>.delayed(backoff);
          backoff *= 2;
          continue;
        }

        return AppHttpResponse(
          statusCode: raw.statusCode,
          body: raw.body,
          headers: raw.headers,
        );
      } on RateLimitFailure {
        rethrow;
      } on SocketException {
        throw const NetworkFailure();
      } on TimeoutException {
        throw const NetworkFailure('Tempo de conexão esgotado.');
      } on http.ClientException {
        throw const NetworkFailure();
      } catch (e) {
        if (e is Failure) rethrow;
        throw UnexpectedFailure(e.toString());
      }
    }
  }

  String _requestKey(
    String method,
    String path,
    Map<String, String>? query,
  ) {
    final sorted = (query?.entries.toList() ?? [])
      ..sort((a, b) => a.key.compareTo(b.key));
    final qs = sorted.map((e) => '${e.key}=${e.value}').join('&');
    return '$method:$path?$qs';
  }

  @override
  void cancel(String requestKey) {
    _cancellable.remove(requestKey)?.close();
    final pending = _inFlight.remove(requestKey);
    if (pending != null && !pending.isCompleted) {
      pending.completeError(const NetworkFailure('Requisição cancelada.'));
    }
  }

  @override
  void dispose() {
    for (final c in _cancellable.values) {
      c.close();
    }
    _cancellable.clear();
    _inFlight.clear();
    _client.close();
  }
}

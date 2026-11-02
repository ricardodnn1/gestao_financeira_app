import 'dart:convert';
import 'package:gestao_financeira/src/core/errors/app_exception.dart';
import 'package:http/http.dart' as http; 

class ApiClient {
  ApiClient({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<dynamic> get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');

    try {
      final response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      }

      throw ApiException(
        message: 'A API retornou HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(message: 'A resposta da API é inválida.');
    } catch (_) {
      throw const NetworkException(
        message: 'Não foi possível conectar ao servidor.',
      );
    }
  }

  void close() => _client.close();
}

sealed class AppException implements Exception {
  const AppException({required this.message});
  final String message;
}

class ApiException extends AppException {
  const ApiException({required super.message, this.statusCode});
  final int? statusCode;
}

class NetworkException extends AppException {
  const NetworkException({required super.message});
}

class UnexpectedException extends AppException {
  const UnexpectedException({required super.message});
}
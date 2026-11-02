sealed class AppFailure {
  const AppFailure({required this.message});
  final String message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure({required super.message});
}

class ServerFailure extends AppFailure {
  const ServerFailure({required super.message, this.statusCode});
  final int? statusCode;
}

class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure({required super.message});
}

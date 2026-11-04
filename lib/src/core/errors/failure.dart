import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Sem conexão com a internet.',
  ]);
}

final class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Erro no servidor. Tente novamente.',
    String? code,
  ]) : super(code: code);
}

final class RateLimitFailure extends Failure {
  const RateLimitFailure([
    super.message = 'Limite de requisições atingido. Aguarde e tente novamente.',
  ]) : super(code: '429');
}

final class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Não foi possível acessar o cache local.',
  ]);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'Recurso não encontrado.',
  ]) : super(code: '404');
}

final class ParsingFailure extends Failure {
  const ParsingFailure([
    super.message = 'Dados inconsistentes recebidos da API.',
  ]);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'Ocorreu um erro inesperado.',
  ]);
}
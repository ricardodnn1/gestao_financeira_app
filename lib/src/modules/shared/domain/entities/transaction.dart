import 'package:equatable/equatable.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_status_enum.dart';
import 'package:gestao_financeira/src/modules/shared/domain/enums/transaction_type_enum.dart'; 
 

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.dateUtc,
    required this.type,
    required this.status,
    this.assetSymbol,
    this.assetName,
    this.metadata = const {},
  });

  final String id;
  final String description;
  final Money amount;
  final DateTime dateUtc;
  final TransactionType type;
  final TransactionStatus status;
  final String? assetSymbol;
  final String? assetName;
  final Map<String, String> metadata;

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  Money get signedAmount =>
      type == TransactionType.income ? amount.abs() : -amount.abs();

  String get statusLabel => switch (status) {
        TransactionStatus.completed => 'Concluída',
        TransactionStatus.pending => 'Pendente',
        TransactionStatus.failed => 'Falha',
        TransactionStatus.reversed => 'Estornada',
      };

  String get typeLabel =>
      type == TransactionType.income ? 'Entrada' : 'Saída';

  String get typeSymbol => type == TransactionType.income ? '+' : '−';

  @override
  List<Object?> get props => [
        id,
        description,
        amount,
        dateUtc,
        type,
        status,
        assetSymbol,
        assetName,
        metadata,
      ];
}

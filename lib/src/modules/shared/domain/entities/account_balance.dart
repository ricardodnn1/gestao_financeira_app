import 'package:equatable/equatable.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';

base class AccountBalance extends Equatable {
  const AccountBalance  ({
    required this.available,
    required this.updatedAtUtc,
    this.currency = 'BRL',
    this.fromCache = false,
  });

  final Money available;
  final DateTime updatedAtUtc;
  final String currency;
  final bool fromCache;

  AccountBalance copyWith({
    Money? available,
    DateTime? updatedAtUtc,
    String? currency,
    bool? fromCache,
  }) {
    return AccountBalance(
      available: available ?? this.available,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      currency: currency ?? this.currency,
      fromCache: fromCache ?? this.fromCache,
    );
  }

  @override
  List<Object?> get props => [available, updatedAtUtc, currency, fromCache];
}

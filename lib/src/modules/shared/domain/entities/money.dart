import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Valor monetário em centavos (menor unidade). Nunca usa double.
base class Money extends Equatable implements Comparable<Money> {
  const Money(this.cents);

  /// Cria a partir de um valor decimal (ex.: preço da API), arredondando.
  factory Money.fromDecimal(num value) {
    return Money((value * 100).round());
  }

  factory Money.zero() => const Money(0);

  final int cents;

  bool get isZero => cents == 0;
  bool get isPositive => cents > 0;
  bool get isNegative => cents < 0;
  bool get isIncome => cents >= 0;
  bool get isExpense => cents < 0;

  Money abs() => Money(cents.abs());

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator -() => Money(-cents);

  Money operator *(num factor) => Money((cents * factor).round());

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  String format({String locale = 'pt_BR', String symbol = r'R$'}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 2,
    );
    return formatter.format(cents / 100);
  }

  /// Formatação sem sinal (para exibir com prefixo +/- separado).
  String formatAbsolute({String locale = 'pt_BR', String symbol = r'R$'}) {
    return abs().format(locale: locale, symbol: symbol);
  }

  @override
  List<Object?> get props => [cents];

  @override
  String toString() => 'Money($cents)';
}
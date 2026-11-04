import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';

void main() {
  group('Money', () {
    test('armazena valores em centavos sem double', () {
      expect(Money.fromDecimal(10.50).cents, 1050);
      expect(Money.fromDecimal(10.555).cents, 1056); // round
      expect(Money.fromDecimal(0).cents, 0);
    });

    test('operações aritméticas', () {
      const a = Money(1000);
      const b = Money(250);
      expect((a + b).cents, 1250);
      expect((a - b).cents, 750);
      expect((-a).cents, -1000);
      expect((a * 2).cents, 2000);
    });

    test('formatação pt-BR', () {
      final formatted = const Money(123456).format();
      expect(formatted.contains('1.234,56'), isTrue);
      expect(formatted.contains('R\$'), isTrue);
    });

    test('casos de borda', () {
      expect(Money.zero().isZero, isTrue);
      expect(const Money(-1).isExpense, isTrue);
      expect(const Money(1).isIncome, isTrue);
      expect(const Money(-500).abs().cents, 500);
    });
  });
}

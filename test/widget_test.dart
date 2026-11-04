import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_financeira/src/modules/shared/domain/entities/money.dart';

void main() {
  test('Money formata valores grandes', () {
    final money = Money.fromDecimal(1_000_000.99);
    expect(money.cents, 100000099);
    expect(money.format().contains('1.000.000,99'), isTrue);
  });
}

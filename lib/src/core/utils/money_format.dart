
import 'package:intl/intl.dart';

extension MoneyFormat on int {
  String toMoneyFormat() {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(this);
  }
}
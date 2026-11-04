import 'package:intl/intl.dart'; 
 
class DateFormatters {
  DateFormatters._();

  static final DateFormat _date = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  static final DateFormat _time = DateFormat('HH:mm', 'pt_BR');
  static final DateFormat _dayHeader = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
  static final DateFormat _shortDay = DateFormat('dd/MM', 'pt_BR');

  static String date(DateTime utc) => _date.format(utc.toLocal());

  static String dateTime(DateTime utc) => _dateTime.format(utc.toLocal());

  static String time(DateTime utc) => _time.format(utc.toLocal());

  static String dayHeader(DateTime utc) {
    final local = utc.toLocal();
    final label = _dayHeader.format(local);
    return '${label[0].toUpperCase()}${label.substring(1)}';
  }

  static String shortDay(DateTime utc) => _shortDay.format(utc.toLocal());
 
  static String dayKey(DateTime utc) {
    final local = utc.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
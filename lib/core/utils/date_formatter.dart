import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatAppointmentDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }
}

import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toDateOnlyString() {
    return DateFormat.MMMMEEEEd().format(this);
  }

  String toTimeOnlyString() {
    return DateFormat.jm().format(this);
  }

  String toDateTimeString() {
    return DateFormat.MMMMEEEEd().add_jm().format(this);
  }
}

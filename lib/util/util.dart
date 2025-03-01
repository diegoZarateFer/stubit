import 'package:intl/intl.dart';

String getDateAsString() {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);

  return DateFormat('yyyy-MM-dd').format(today);
}

bool isDifferentDay(DateTime date1, DateTime date2) {
  return date1.year != date2.year ||
      date1.month != date2.month ||
      date1.day != date2.day;
}

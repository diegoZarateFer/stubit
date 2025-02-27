import 'package:intl/intl.dart';

String getDateAsString() {
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  
  return DateFormat('yyyy-MM-dd').format(today);
}

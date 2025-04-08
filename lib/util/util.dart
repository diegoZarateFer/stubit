import 'dart:math';

import 'package:intl/intl.dart';

final Map<int, String> _monthsInSpanish = {
  1: 'enero',
  2: 'febrero',
  3: 'marzo',
  4: 'abril',
  5: 'mayo',
  6: 'junio',
  7: 'julio',
  8: 'agosto',
  9: 'septiembre',
  10: 'octubre',
  11: 'noviembre',
  12: 'diciembre'
};

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

int assignGems() {
  int gems = Random().nextInt(6) + 5;
  return gems;
}

int getStreakCost(int currentStreak) {
  int randomFactor = Random().nextInt(4) + 3;
  int cost = randomFactor * currentStreak;
  return cost;
}

String formatDate(DateTime date) {
  String monthName = _monthsInSpanish[date.month]!;
  return "${date.day} de $monthName de ${date.year}";
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 410,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E8E8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        locale: 'es_ES',
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 3, 14),
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 12),
          weekendStyle: TextStyle(fontSize: 12),
        ),
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: Color.fromARGB(255, 150, 134, 252),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: TextStyle(
            color: Color.fromARGB(190, 255, 255, 255),
          ),
          todayDecoration: BoxDecoration(
            color: Color.fromARGB(187, 164, 87, 232),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Colors.black,
          ),
          weekendTextStyle: TextStyle(
            color: Color.fromARGB(255, 140, 101, 89),
          ),
          disabledTextStyle: TextStyle(
            color: Color(0xFF6F6F6F),
            fontSize: 12,
          ),
          outsideTextStyle: TextStyle(color: Color(0xFF757575), fontSize: 12),
          defaultTextStyle: TextStyle(
            fontSize: 12,
            color: Color(0xFF000000),
          ),
          cellPadding: EdgeInsets.all(2),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
          formatButtonTextStyle: const TextStyle(
            color: Color.fromARGB(187, 164, 87, 232),
          ),
          formatButtonDecoration: BoxDecoration(
            color: const Color(0xFF373737),
            borderRadius: BorderRadius.circular(8),
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: Colors.black,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
    required this.dates,
    required this.onSelectDay,
  });

  final Set<DateTime> dates;
  final void Function(DateTime date) onSelectDay;

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late Set<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _dates = widget.dates;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    if (_dates.any((d) => isSameDay(d, _selectedDay))) {
      widget.onSelectDay(_selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 410,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(230, 35, 35, 35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        locale: 'es_ES',
        focusedDay: _focusedDay,
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.utc(2030, 3, 14),
        calendarFormat: CalendarFormat.month,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: _onDaySelected,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontSize: 12, color: Colors.white),
          weekendStyle: TextStyle(fontSize: 12, color: Colors.white),
        ),
        calendarStyle: const CalendarStyle(
          defaultTextStyle: TextStyle(color: Color(0xFFE0E0E0)),
          disabledTextStyle: TextStyle(color: Color(0xFF6F6F6F)),
          outsideTextStyle: TextStyle(color: Color(0xFF757575)),
          weekendTextStyle: TextStyle(color: Color.fromARGB(255, 140, 101, 89)),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          titleTextStyle:
              const TextStyle(color: Color(0xFFE0E0E0), fontSize: 18),
          formatButtonTextStyle: const TextStyle(color: Color(0xFF03DAC5)),
          formatButtonDecoration: BoxDecoration(
            color: const Color(0xFF373737),
            borderRadius: BorderRadius.circular(8),
          ),
          leftChevronIcon:
              const Icon(Icons.chevron_left, color: Color(0xFFE0E0E0)),
          rightChevronIcon:
              const Icon(Icons.chevron_right, color: Color(0xFFE0E0E0)),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            if (_dates.any((d) => isSameDay(d, day))) {
              return Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA500), // log day
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }
            return null;
          },
          todayBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(139, 34, 227, 1), // today
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: const Color.fromARGB(255, 89, 22, 144), // selected day
                ),
              ),
              child: Center(
                child: Text('${day.day}',
                    style: const TextStyle(color: Colors.white)),
              ),
            );
          },
        ),
      ),
    );
  }
}

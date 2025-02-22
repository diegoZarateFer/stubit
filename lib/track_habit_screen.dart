import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:stubit/widgets/user_button.dart';
import 'package:table_calendar/table_calendar.dart';

class TrackHabitScreen extends StatefulWidget {
  const TrackHabitScreen({
    super.key,
  });

  @override
  State<TrackHabitScreen> createState() => _TrackHabitScreenState();
}

class _TrackHabitScreenState extends State<TrackHabitScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
        actions: [
          ImageButton(
            imagePath: "assets/images/book.png",
            onPressed: () {},
          ),
          Text(
            '0',
            style: GoogleFonts.dmSans(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Stu - Bit',
            style: GoogleFonts.satisfy(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 40,
              ),
            ),
          ),
          const Spacer(),
          const UserButton(),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(139, 34, 227, 1),
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 32,
              ),
              Image.asset(
                "assets/images/calendar.png",
                height: 60,
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "Lectura",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Container(
                  height: 410,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E8E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TableCalendar(
                    focusedDay: DateTime.now(),
                    firstDay: DateTime.utc(2025, 1, 1),
                    lastDay: DateTime.utc(2030, 3, 14),
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    calendarStyle: const CalendarStyle(
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFFBB86FC),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Color(0xFF03DAC5),
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
                      ),
                      outsideTextStyle: TextStyle(
                        color: Color(0xFF757575),
                      ),
                      defaultTextStyle: TextStyle(
                        color: Color(0xFF000000),
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                      formatButtonTextStyle: const TextStyle(
                        color: Color(0xFF03DAC5),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

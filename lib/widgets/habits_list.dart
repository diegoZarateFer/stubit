import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/widgets/habit_item.dart';

class HabitsList extends StatefulWidget {
  const HabitsList({
    super.key,
    required this.loadedHabits,
  });

  @override
  State<HabitsList> createState() => _HabitsListState();

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> loadedHabits;
}

class _HabitsListState extends State<HabitsList> {
  bool _showTodayHabits = true;
  bool _showWeekHabits = false;

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat('EEEE').format(DateTime.now()).toLowerCase();

    final habitsForToday = widget.loadedHabits.where((habit) {
      final habitData = habit.data();
      final habitParameters = habitData['habitParameters'];
      List<dynamic> loadedDays = habitParameters['days'];
      List<String> days = loadedDays.map((item) => item.toString()).toList();
      return days.contains(dayOfWeek);
    }).toList();

    return Column(
      children: [
        Text(
          "Mis Hábitos",
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          children: [
            FilterChip(
              label: const Text(
                "Hoy",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              selected: _showTodayHabits,
              selectedColor: const Color(0xFF292D39),
              backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
              side: BorderSide(
                color: _showTodayHabits
                    ? Colors.black
                    : const Color.fromRGBO(139, 34, 227, 1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onSelected: (_) {
                setState(() {
                  _showTodayHabits = true;
                  _showWeekHabits = false;
                });
              },
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text(
                "Mi semana",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              selected: _showWeekHabits,
              selectedColor: const Color(0xFF292D39),
              backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
              side: BorderSide(
                color: _showWeekHabits
                    ? Colors.black
                    : const Color.fromRGBO(139, 34, 227, 1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onSelected: (_) {
                setState(() {
                  _showTodayHabits = false;
                  _showWeekHabits = true;
                });
              },
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _showTodayHabits
                ? habitsForToday.length
                : widget.loadedHabits.length,
            itemBuilder: (ctx, index) {
              final habitData = _showTodayHabits
                  ? habitsForToday[index].data()
                  : widget.loadedHabits[index].data();
              final habitId = widget.loadedHabits[index].id.toString();
              final Habit habit = Habit(
                id: habitId,
                name: habitData['name'],
                description: habitData['description'],
                category: habitData['category'],
                strategy: habitData['strategy'],
              );
              final habitParameters = habitData['habitParameters'];
              return HabitItem(
                key: ValueKey(habitId),
                habit: habit,
                habitParameters: habitParameters,
              );
            },
          ),
        ),
      ],
    );
  }
}

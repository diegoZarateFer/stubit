import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/widgets/apology.dart';
import 'package:stubit/widgets/habit_item.dart';

String apology = """
  Lo sentimos mucho pero no se ha podido conectar al servidor.
  Por favor, intentalo de nuevo más tarde.
""";

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  bool _showTodayHabits = true;
  bool _showWeekHabits = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                "Todos",
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
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: ListOfHabits(
            showTodayHabits: _showTodayHabits,
          ),
        ),
      ],
    );
  }
}

class ListOfHabits extends StatelessWidget {
  const ListOfHabits({
    super.key,
    required this.showTodayHabits,
  });

  final bool showTodayHabits;

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final userId = currentUser.uid.toString();

    return StreamBuilder(
      stream: _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .snapshots(),
      builder: (ctx, boardSnapshots) {
        if (boardSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!boardSnapshots.hasData || boardSnapshots.data!.docs.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Aún no tienes hábitos creados',
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 180,
                ),
                Text(
                  "Da click en \"+\" para añadir un nuevo hábito",
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }

        if (boardSnapshots.hasError) {
          return const Apology(
            message: "Lo sentimos pero algo salió mal :(",
          );
        }

        final loadedHabits = boardSnapshots.data!.docs;
        if (loadedHabits.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'Aún no tienes hábitos creados',
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 180,
                ),
                Text(
                  "Da click en \"+\" para añadir un nuevo hábito",
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }

        final today = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
        final filteredHabits = showTodayHabits
            ? loadedHabits.where((habit) {
                final habitParameters = habit.data()["habitParameters"];
                if (habitParameters["days"] == null) {
                  return true;
                }

                List<dynamic> days = habitParameters["days"];
                final daysAsString = days.map((d) => d.toString()).toList();
                return daysAsString.contains(today);
              }).toList()
            : loadedHabits;

        if (filteredHabits.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  '¡Hoy tienes el día libre! No hay actividades programadas.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: filteredHabits.length,
                  itemBuilder: (ctx, index) {
                    final habitData = filteredHabits[index].data();
                    final habitId = filteredHabits[index].id.toString();

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
                      streak: habitData['streak'],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

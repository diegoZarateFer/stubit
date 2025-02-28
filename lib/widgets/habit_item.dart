import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/screens/register_habits_screens/register_habit.dart';
import 'package:stubit/screens/track_habit_screen.dart';

class HabitItem extends StatelessWidget {
  const HabitItem({
    super.key,
    required this.habit,
    required this.onTap,
    required this.habitParameters,
    this.lastLoggedData,
  });

  final Habit habit;
  final Map<String, dynamic> habitParameters;
  final Map<String, dynamic>? lastLoggedData;
  final void Function() onTap;

  void _showMenuAction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                habit.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Registrar día'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => RegisterHabit(
                      habit: habit,
                      habitParameters: habitParameters,
                      lastLoggedData: lastLoggedData,
                    ),
                  ),
                );

                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Seguimiento'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => const TrackHabitScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar hábito'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar hábito'),
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMenuAction(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF292D39),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                textAlign: TextAlign.center,
                habit.name,
                softWrap: true,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(
              Icons.local_fire_department,
              color: Colors.grey,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';

class HabitItem extends StatelessWidget {
  const HabitItem({
    super.key,
    required this.habit,
    required this.onTap,
  });

  final Habit habit;
  final void Function() onTap;

  String _formatHabitName(String habitName) {
    const int maxLength = 26;
    return (habitName.length > maxLength)
        ? "${habitName.substring(0, maxLength)}..."
        : habitName;
  }

  @override
  Widget build(BuildContext context) {
    final String habitName = habit.name;
    return Container(
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
              habitName,
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
    );
  }
}

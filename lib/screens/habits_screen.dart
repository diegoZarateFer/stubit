import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    ));
  }
}

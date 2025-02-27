import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/widgets/apology.dart';
import 'package:stubit/widgets/habit_item.dart';

String apology = """
  Lo sentimos mucho pero no se ha podido conectar al servidor.
  Por favor, intentalo de nuevo más tarde.
""";

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

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

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Text(
                "Mis Hábitos",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: loadedHabits.length,
                  itemBuilder: (ctx, index) {
                    final habitData = loadedHabits[index].data();
                    final habitId = loadedHabits[index].id.toString();
                    final Habit habit = Habit(
                      id: habitId,
                      name: habitData['name'],
                      description: habitData['description'],
                      category: habitData['category'],
                      strategy: habitData['strategy'],
                      unit: habitData['unit'],
                    );
                    return HabitItem(
                      habit: habit,
                      onTap: () {},
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

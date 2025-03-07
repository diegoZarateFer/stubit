import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/widgets/apology.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HabitLogInformation extends StatefulWidget {
  const HabitLogInformation({
    super.key,
    required this.habit,
    required this.selectedDay,
  });

  final Habit habit;
  final DateTime selectedDay;

  @override
  State<HabitLogInformation> createState() => _HabitLogInformationState();
}

class _HabitLogInformationState extends State<HabitLogInformation> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    final userId = _currentUser.uid.toString();
    final date = DateFormat('yyyy-MM-dd').format(widget.selectedDay);
    return StreamBuilder(
      stream: _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .doc(widget.habit.id)
          .collection("habit_log")
          .doc(date)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return const Apology(
            message:
                "Lo sentimos, no hemos podido cargar el registro de este día. Inténtalo de nuevo más tarde.",
          );
        }

        if (snapshot.hasData) {
          if (widget.habit.strategy == 'CF') {
            final answerOne = snapshot.data!['answerOne'];
            final answerTwo = snapshot.data!['answerTwo'];

            final questionOne = snapshot.data!['questionOne'];
            final questionTwo = snapshot.data!['questionOne'];

            final selectedDifficulty = snapshot.data!['difficulty'];
            return Column(
              children: [
                Text(
                  questionOne,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "R: ",
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      answerOne,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        decorationThickness: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  questionTwo,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "R: ",
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      answerTwo,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        decorationThickness: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                RatingSelector(
                  selectedDifficulty: selectedDifficulty,
                ),
              ],
            );
          }

          if (widget.habit.strategy == 'COF') {}

          if (widget.habit.strategy == 'TP') {}

          if (widget.habit.strategy == 'T') {}

          if (widget.habit.strategy == 'TF') {}

          // L
          final list = snapshot.data!['list'];
          final selectedDifficulty = snapshot.data!['difficulty'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in list)
                ListTile(
                  leading: const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  title: Text(item.toString()),
                ),
              RatingSelector(
                selectedDifficulty: selectedDifficulty,
              ),
            ],
          );
        }

        return Center(
          child: Text(
            "No tienes un registroF para este día",
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }
}

class RatingSelector extends StatelessWidget {
  const RatingSelector({
    super.key,
    required this.selectedDifficulty,
  });

  final int selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: RatingBar.builder(
          itemCount: 5,
          unratedColor: Colors.white,
          initialRating: selectedDifficulty.toDouble(),
          itemBuilder: (ctx, _) => const Icon(
            Icons.local_fire_department,
            color: Colors.amber,
          ),
          onRatingUpdate: (_) {},
        ),
      ),
    );
  }
}

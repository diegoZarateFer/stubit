import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
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
          final logData = snapshot.data!.data();

          if (logData!.containsKey('payed')) {
            final gemsPayed = snapshot.data!['gemsPayed'];
            return StreakLog(gemsPayed: gemsPayed);
          }

          if (widget.habit.strategy == 'CF') {
            final answerOne = snapshot.data!['answerOne'];
            final answerTwo = snapshot.data!['answerTwo'];

            final questionOne = snapshot.data!['questionOne'];
            final questionTwo = snapshot.data!['questionOne'];

            int selectedDifficulty = snapshot.data!['difficulty'];
            return CFLog(
              questionOne: questionOne,
              questionTwo: questionTwo,
              answerOne: answerOne,
              answerTwo: answerTwo,
              selectedDifficulty: selectedDifficulty,
            );
          }

          if (widget.habit.strategy == 'COF') {
            int fetchedCounter = snapshot.data!['counter'];
            int fetchedDailyTarget = snapshot.data!['dailyTarget'];
            final unit = snapshot.data!['unit'];

            return COFLog(
              fetchedCounter: fetchedCounter,
              fetchedDailyTarget: fetchedDailyTarget,
              unit: unit,
            );
          }

          if (widget.habit.strategy == 'TP') {
            int fetchedCompletedCycles = snapshot.data!['completedCycles'];
            final restInterval = snapshot.data!['restInterval'];
            final workInterval = snapshot.data!['workInterval'];
            int fetchedTargetCycles = snapshot.data!['targetCycles'];

            return TPLog(
              fetchedCompletedCycles: fetchedCompletedCycles,
              fetchedTargetCycles: fetchedTargetCycles,
              restInterval: restInterval,
              workInterval: workInterval,
            );
          }

          if (widget.habit.strategy == 'T') {
            final minutes = snapshot.data!['minutes'];
            final hours = snapshot.data!['hours'];
            int fetchedTotalTime = snapshot.data!['time'];
            int fetchedTargetTime = snapshot.data!['targetTime'];
            final selectedDifficulty = snapshot.data!['difficulty'];

            return TLOG(
              hours: hours,
              minutes: minutes,
              fetchedTargetTime: fetchedTargetTime,
              fetchedTotalTime: fetchedTotalTime,
              selectedDifficulty: selectedDifficulty,
            );
          }

          if (widget.habit.strategy == 'TF') {
            final minutes = snapshot.data!['minutes'];
            final hours = snapshot.data!['hours'];

            int fetchedTotalTime = snapshot.data!['time'];
            int fetchedTargetTime = snapshot.data!['targetTime'];

            final selectedDifficulty = snapshot.data!['difficulty'];
            String activityDescription = snapshot.data!['activityDescription'];

            return TFLog(
              hours: hours,
              minutes: minutes,
              fetchedTargetTime: fetchedTargetTime,
              fetchedTotalTime: fetchedTotalTime,
              activityDescription: activityDescription,
              selectedDifficulty: selectedDifficulty,
            );
          }

          // L
          List<dynamic> fetchedList = snapshot.data!['list'];
          final selectedDifficulty = snapshot.data!['difficulty'];

          final list = fetchedList.map((item) => item.toString()).toList();

          return LLog(
            list: list,
            selectedDifficulty: selectedDifficulty,
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

class LLog extends StatelessWidget {
  const LLog({
    super.key,
    required this.list,
    required this.selectedDifficulty,
  });

  final List<String> list;
  final int selectedDifficulty;

  @override
  Widget build(BuildContext context) {
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
}

class TLOG extends StatelessWidget {
  const TLOG({
    super.key,
    required this.hours,
    required this.minutes,
    required this.fetchedTargetTime,
    required this.fetchedTotalTime,
    required this.selectedDifficulty,
  });

  final int fetchedTargetTime,
      fetchedTotalTime,
      hours,
      minutes,
      selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    double targetTime = fetchedTargetTime.toDouble();
    double totalTime = fetchedTotalTime.toDouble();

    double percent = totalTime / targetTime > 1 ? 1 : totalTime / targetTime;

    String legend = (hours == 0)
        ? "Dedicaste $minutes a esta actividad"
        : "Dedicaste $hours horas con $minutes minutos a esta actividad.";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: CircularPercentIndicator(
              radius: 50,
              lineWidth: 5,
              percent: percent,
              center: Text(
                "${(percent * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              backgroundColor: const Color.fromARGB(178, 158, 158, 158),
              progressColor: const Color.fromARGB(255, 228, 200, 247),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            legend,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          RatingSelector(
            selectedDifficulty: selectedDifficulty,
          ),
        ],
      ),
    );
  }
}

class TFLog extends StatelessWidget {
  const TFLog({
    super.key,
    required this.hours,
    required this.minutes,
    required this.fetchedTargetTime,
    required this.fetchedTotalTime,
    required this.activityDescription,
    required this.selectedDifficulty,
  });

  final int hours,
      minutes,
      fetchedTargetTime,
      fetchedTotalTime,
      selectedDifficulty;
  final String activityDescription;

  @override
  Widget build(BuildContext context) {
    double targetTime = fetchedTargetTime.toDouble();
    double totalTime = fetchedTotalTime.toDouble();

    double percent = totalTime / targetTime > 1 ? 1 : totalTime / targetTime;

    String legend = (hours == 0)
        ? "Dedicaste $minutes a esta actividad"
        : "Dedicaste $hours horas con $minutes minutos a esta actividad.";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: CircularPercentIndicator(
              radius: 50,
              lineWidth: 5,
              percent: percent,
              center: Text(
                "${(percent * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              backgroundColor: const Color.fromARGB(178, 158, 158, 158),
              progressColor: const Color.fromARGB(255, 228, 200, 247),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            legend,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          if (activityDescription.isNotEmpty)
            const SizedBox(
              height: 8,
            ),
          if (activityDescription.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Descripción:",
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  activityDescription,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          RatingSelector(
            selectedDifficulty: selectedDifficulty,
          ),
        ],
      ),
    );
  }
}

class TPLog extends StatelessWidget {
  const TPLog({
    super.key,
    required this.fetchedCompletedCycles,
    required this.fetchedTargetCycles,
    required this.restInterval,
    required this.workInterval,
  });

  final int fetchedCompletedCycles,
      fetchedTargetCycles,
      workInterval,
      restInterval;

  @override
  Widget build(BuildContext context) {
    final completedCycles = fetchedCompletedCycles.toDouble();
    final targetCycles = fetchedTargetCycles.toDouble();
    double percent =
        completedCycles / targetCycles > 1 ? 1 : completedCycles / targetCycles;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: CircularPercentIndicator(
              radius: 50,
              lineWidth: 5,
              percent: percent,
              center: Text(
                "$fetchedTargetCycles / $fetchedTargetCycles",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              backgroundColor: const Color.fromARGB(178, 158, 158, 158),
              progressColor: const Color.fromARGB(255, 228, 200, 247),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Ciclos completados:",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "$fetchedCompletedCycles de $fetchedTargetCycles.",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Intervalo de trabajo:",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "$workInterval.",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Intervalo de descanso:",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "$restInterval.",
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class COFLog extends StatelessWidget {
  const COFLog({
    super.key,
    required this.fetchedCounter,
    required this.fetchedDailyTarget,
    required this.unit,
  });

  final int fetchedCounter, fetchedDailyTarget;
  final String unit;

  @override
  Widget build(BuildContext context) {
    double counter = fetchedCounter.toDouble();
    double dailyTarget = fetchedDailyTarget.toDouble();
    double percent = counter / dailyTarget > 1 ? 1 : counter / dailyTarget;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: CircularPercentIndicator(
              radius: 50,
              lineWidth: 5,
              percent: percent,
              center: Text(
                "$fetchedCounter / $fetchedDailyTarget",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              backgroundColor: const Color.fromARGB(178, 158, 158, 158),
              progressColor: const Color.fromARGB(255, 228, 200, 247),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            unit,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class StreakLog extends StatelessWidget {
  const StreakLog({
    super.key,
    required this.gemsPayed,
  });

  final int gemsPayed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Image.asset(
              "assets/images/book.png",
              height: 60,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              "Pagaste $gemsPayed gemas.",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.white,
                decorationColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CFLog extends StatelessWidget {
  const CFLog(
      {super.key,
      required this.questionOne,
      required this.questionTwo,
      required this.answerOne,
      required this.answerTwo,
      required this.selectedDifficulty});

  final int selectedDifficulty;
  final String questionOne, questionTwo, answerOne, answerTwo;

  @override
  Widget build(BuildContext context) {
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
          ignoreGestures: true,
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

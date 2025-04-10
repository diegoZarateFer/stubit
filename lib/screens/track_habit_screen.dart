import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/apology.dart';
import 'package:stubit/widgets/calendar.dart';
import 'package:stubit/widgets/habit_log.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class TrackHabitScreen extends StatefulWidget {
  const TrackHabitScreen(
      {super.key,
      required this.habit,
      required this.streak,
      required this.streakIsActive});

  final Habit habit;
  final int streak;
  final bool streakIsActive;

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

  Future<Set<DateTime>?> fetchLogDates() async {
    final userId = _currentUser!.uid.toString();
    Set<DateTime> logDates = {};
    try {
      CollectionReference logRef = _firestore
          .collection("user_data")
          .doc(userId)
          .collection("habits")
          .doc(widget.habit.id)
          .collection("habit_log");

      var snapshot = await logRef.get();
      for (var doc in snapshot.docs) {
        if (doc.id != "daily_form") {
          DateTime logDate = DateTime.parse(doc.id);
          logDates.add(logDate);
        }
      }

      return logDates;
    } catch (e) {
      throw Exception('Falló al cargar el LOG.');
    }
  }

  void _showHabitLogDay(DateTime selectedDay) {
    String formatedDate = formatDate(selectedDay);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      formatedDate,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(),
              HabitLogInformation(
                habit: widget.habit,
                selectedDay: selectedDay,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(139, 34, 227, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        centerTitle: true,
        title: Text(
          "Seguimiento",
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchLogDates(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Apology(
                message:
                    "Lo sentimos, no se ha podido cargar tu información. Inténtalo de nuevo más tarde.",
              ),
            );
          }

          final logDates = snapshot.data!;
          return Container(
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/calendar.png",
                        height: 60,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        widget.habit.name,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Calendar(
                        dates: logDates,
                        onSelectDay: _showHabitLogDay,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              size: 60,
                              color: widget.streakIsActive
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Positioned(
                                child: Text(
                                  "${widget.streak}",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.koHo(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/widgets/apology.dart';
import 'package:stubit/widgets/calendar.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:stubit/widgets/user_button.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class TrackHabitScreen extends StatefulWidget {
  const TrackHabitScreen({
    super.key,
    required this.habit,
  });

  final Habit habit;

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
      throw Exception('Falló la eliminación del LOG.');
    }
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
                        "Lectura",
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
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 60,
                        height: 80,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/fire.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "100",
                              style: GoogleFonts.koHo(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
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

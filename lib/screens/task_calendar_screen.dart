import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/apology.dart';
import 'package:stubit/widgets/calendar.dart';
import 'package:stubit/widgets/task_log.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class TaskCalendarScreen extends StatefulWidget {
  const TaskCalendarScreen({
    super.key,
  });

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<Set<DateTime>?> fetchTaskDates() async {
    final userId = _currentUser!.uid.toString();
    Set<DateTime> taskDates = {};
    try {
      CollectionReference tasksRef =
          _firestore.collection("user_data").doc(userId).collection("tasks");

      var snapshot = await tasksRef.get();
      DateTime today = DateTime.now();
      today = DateTime(today.year, today.month, today.day);
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        DateTime taskDate = DateTime.parse(data["date"]);
        if (taskDate.isAfter(today) || taskDate.isAtSameMomentAs(today)) {
          taskDates.add(taskDate);
        }
      }

      return taskDates;
    } catch (e) {
      throw Exception('Falló al cargar el LOG.');
    }
  }

  void _showHabitLogDay(DateTime selectedDay) async {
    String formatedDate = formatDate(selectedDay);
    await showModalBottomSheet(
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
              TaskLog(
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
          "Mis Actividades",
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchTaskDates(),
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

          final taskDates = snapshot.data!;
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
                        "Mis tareas",
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
                        dates: taskDates,
                        onSelectDay: _showHabitLogDay,
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

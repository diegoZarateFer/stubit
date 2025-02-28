import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/models/habit.dart';
import 'package:stubit/util/util.dart';
import 'package:stubit/widgets/pomodoro_timer.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class RegisterTpHabit extends StatefulWidget {
  const RegisterTpHabit({
    super.key,
    required this.habit,
    required this.workInterval,
    required this.restInterval,
    required this.targetNumberOfCycles,
    this.lastLoggedData,
  });

  final Habit habit;
  final int workInterval, restInterval, targetNumberOfCycles;
  final Map<String, dynamic>? lastLoggedData;

  @override
  State<RegisterTpHabit> createState() => _CreateFtHabitScreenState();
}

class _CreateFtHabitScreenState extends State<RegisterTpHabit> {
  final _currentUser = FirebaseAuth.instance.currentUser!;

  late String _date, _userId;
  int _completedCycles = 0;
  bool _confirmationBoxIsSelected = false, _targetIsCompleted = false;

  void _registerHabit() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    if (!_confirmationBoxIsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Falta confirmar que se realizó la actividad.',
          ),
        ),
      );
      return;
    }

    Map<String, dynamic> lastLog = {
      "date": _date,
      "counter": _completedCycles,
      "workInterval": widget.workInterval,
      "resInterval": widget.restInterval,
    };

    try {
      await _firestore
          .collection("user_data")
          .doc(_userId)
          .collection("habits")
          .doc(widget.habit.id)
          .collection("habit_log")
          .doc(_date)
          .set({
        "completedCycles": _completedCycles,
        "restInterval": widget.restInterval,
        "workInterval": widget.workInterval,
      });

      // TODO: mostrar las gemas obtenidas con la frase motivacional.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Felicidades! Registro del día completado."),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Hubo un problema al guardar el registro. Inténtalo más tarde.",
          ),
        ),
      );
    }
  }

  void _loadLastLog() {
    
   }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Text(
                "REGISTRO DE HÁBITO",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
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
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Tiempo para trabajo:",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    "${widget.workInterval} mins.",
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
                    "Tiempo de descanso:",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    "${widget.restInterval} mins.",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              PomodoroTimer(
                workInterval: widget.workInterval,
                restInterval: widget.restInterval,
                targetNumberOfCycles: widget.targetNumberOfCycles,
                onFinish: (int completedCycles) {
                  setState(() {
                    _targetIsCompleted = true;
                  });
                  _completedCycles = completedCycles;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              if (_targetIsCompleted)
                Row(
                  children: [
                    Expanded(
                      child: Checkbox(
                        shape: const CircleBorder(),
                        value: _confirmationBoxIsSelected,
                        onChanged: (bool? isSelected) {
                          setState(() {
                            _confirmationBoxIsSelected = isSelected ?? false;
                          });
                        },
                      ),
                    ),
                    Text(
                      "Confirmo que hoy realicé este hábito",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              if (_targetIsCompleted)
                const SizedBox(
                  height: 16,
                ),
              ElevatedButton(
                onPressed: _targetIsCompleted ? _registerHabit : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromRGBO(121, 30, 198, 1),
                ),
                child: Text(
                  "Registrar",
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  "Cancelar",
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    decorationColor: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
